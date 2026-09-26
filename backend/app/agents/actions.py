"""
Structured Actions and Tool Execution Engine for VyapaarPilot.
Enforces:
- Schema validation via Pydantic
- Risk levels (read vs write)
- Explicit merchant confirmation for write actions
- Clean typed UI action payloads for Flutter
"""

import uuid
import logging
from enum import Enum
from typing import Dict, Any, List, Optional, Callable
from pydantic import BaseModel, Field
from sqlalchemy.orm import Session

from app.services.analytics_service import analytics_service
from app.services.customer_service import customer_service
from app.services.opportunity_service import opportunity_service
from app.services.recommendation_service import recommendation_service
from app.services.experiment_service import experiment_service

logger = logging.getLogger("vyapaarpilot.actions")

class ActionType(str, Enum):
    NAVIGATE = "navigate"
    TOOL = "tool"
    SUGGESTION = "suggestion"
    CONFIRMATION = "confirmation"

class RiskLevel(str, Enum):
    READ = "read"
    WRITE = "write"

class ActionPayload(BaseModel):
    id: str = Field(default_factory=lambda: f"act_{uuid.uuid4().hex[:8]}")
    type: ActionType = ActionType.SUGGESTION
    label: str
    tool: Optional[str] = None
    arguments: Dict[str, Any] = {}
    requires_confirmation: bool = False
    confirmation_prompt: Optional[str] = None

class ToolDefinition(BaseModel):
    name: str
    description: str
    risk_level: RiskLevel = RiskLevel.READ
    requires_confirmation: bool = False
    input_schema: Dict[str, Any] = {}

class ToolRegistry:

    def __init__(self):
        self._tools: Dict[str, ToolDefinition] = {}
        self._executors: Dict[str, Callable] = {}
        self._pending_confirmations: Dict[str, Dict[str, Any]] = {}
        self._register_default_tools()

    def register(
        self,
        name: str,
        description: str,
        executor: Callable,
        risk_level: RiskLevel = RiskLevel.READ,
        requires_confirmation: bool = False,
        input_schema: Dict[str, Any] = None
    ):
        tool_def = ToolDefinition(
            name=name,
            description=description,
            risk_level=risk_level,
            requires_confirmation=requires_confirmation,
            input_schema=input_schema or {}
        )
        self._tools[name] = tool_def
        self._executors[name] = executor

    def _register_default_tools(self):
        # 1. Summary
        self.register(
            name="get_merchant_summary",
            description="Fetches sales summary (today, week, month, success rate, ATV)",
            executor=lambda db, **kw: analytics_service.get_merchant_summary(db, kw["merchant_id"]),
            risk_level=RiskLevel.READ,
            requires_confirmation=False
        )

        # 2. Trends
        self.register(
            name="get_sales_trends",
            description="Fetches daily trends and Tuesday hourly baseline",
            executor=lambda db, **kw: analytics_service.get_merchant_trends(db, kw["merchant_id"], kw.get("period", "7d")),
            risk_level=RiskLevel.READ,
            requires_confirmation=False
        )

        # 3. Customer analytics
        self.register(
            name="get_customer_analytics",
            description="Fetches anonymous customer stats (repeat customers, churn, frequency)",
            executor=lambda db, **kw: customer_service.get_customer_analytics(db, kw["merchant_id"]),
            risk_level=RiskLevel.READ,
            requires_confirmation=False
        )

        # 4. Opportunities
        self.register(
            name="get_opportunities",
            description="Detects active business opportunities directly from transaction logs",
            executor=lambda db, **kw: opportunity_service.detect_opportunities(db, kw["merchant_id"]),
            risk_level=RiskLevel.READ,
            requires_confirmation=False
        )

        # 5. Opportunity Details
        self.register(
            name="get_opportunity_details",
            description="Fetches detailed evidence and baseline for a specific opportunity",
            executor=lambda db, **kw: opportunity_service.get_opportunity_by_id(db, kw["opportunity_id"]),
            risk_level=RiskLevel.READ,
            requires_confirmation=False
        )

        # 6. Recommendation
        self.register(
            name="get_recommendation",
            description="Generates safe, structured promotional recommendation for an opportunity",
            executor=lambda db, **kw: recommendation_service.generate_recommendation(db, kw["opportunity_id"], kw.get("language", "hinglish")),
            risk_level=RiskLevel.READ,
            requires_confirmation=False
        )

        # 7. Experiment result
        self.register(
            name="get_experiment_result",
            description="Fetches baseline vs experiment outcome and uplift",
            executor=lambda db, **kw: experiment_service.get_experiment(db, kw["experiment_id"]),
            risk_level=RiskLevel.READ,
            requires_confirmation=False
        )

        # 8. Create experiment (WRITE OPERATION - Requires Confirmation)
        self.register(
            name="create_experiment",
            description="Creates and starts a promotional experiment for an opportunity",
            executor=lambda db, **kw: experiment_service.create_experiment(
                db=db,
                merchant_id=kw["merchant_id"],
                opportunity_id=kw["opportunity_id"],
                baseline_amount=kw.get("baseline_amount"),
                experiment_amount=kw.get("experiment_amount"),
                promotion_type=kw.get("promotion_type", "3-hour targeted discount")
            ),
            risk_level=RiskLevel.WRITE,
            requires_confirmation=True,
            input_schema={
                "merchant_id": "string",
                "opportunity_id": "string",
                "promotion_type": "string"
            }
        )

    def get_tool(self, name: str) -> Optional[ToolDefinition]:
        return self._tools.get(name)

    def execute_tool(self, name: str, db: Session, arguments: Dict[str, Any]) -> Dict[str, Any]:
        """
        Executes a registered tool if it does not require confirmation.
        """
        if name not in self._tools:
            raise ValueError(f"Unknown tool '{name}'")

        tool_def = self._tools[name]
        if tool_def.requires_confirmation:
            raise PermissionError(f"Tool '{name}' requires explicit merchant confirmation before execution.")

        executor = self._executors[name]
        return executor(db, **arguments)

    def create_confirmation_action(
        self,
        tool_name: str,
        arguments: Dict[str, Any],
        label: str,
        confirmation_prompt: str
    ) -> ActionPayload:
        """
        Registers a pending write action requiring merchant confirmation.
        """
        action_id = f"act_{uuid.uuid4().hex[:8]}"
        self._pending_confirmations[action_id] = {
            "tool": tool_name,
            "arguments": arguments
        }
        return ActionPayload(
            id=action_id,
            type=ActionType.CONFIRMATION,
            label=label,
            tool=tool_name,
            arguments=arguments,
            requires_confirmation=True,
            confirmation_prompt=confirmation_prompt
        )

    def execute_confirmed_action(
        self,
        action_id: str,
        db: Session,
        override_arguments: Optional[Dict[str, Any]] = None,
        tool: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        Executes an approved write action upon merchant confirmation.
        """
        if action_id in self._pending_confirmations:
            pending = self._pending_confirmations.pop(action_id)
            tool_name = pending["tool"]
            args = {**pending["arguments"], **(override_arguments or {})}
        elif tool and tool in self._tools:
            tool_name = tool
            args = override_arguments or {}
        else:
            raise KeyError(f"Action '{action_id}' not found or already executed.")

        if tool_name not in self._executors:
            raise ValueError(f"No executor registered for tool '{tool_name}'")

        executor = self._executors[tool_name]
        result = executor(db, **args)
        return {
            "action_id": action_id,
            "tool": tool_name,
            "status": "executed",
            "result": result
        }

tool_registry = ToolRegistry()
