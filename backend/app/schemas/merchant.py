from pydantic import BaseModel, Field, ConfigDict
from typing import Optional
from datetime import datetime

class MerchantBase(BaseModel):
    merchant_id: str
    name: str
    business_type: str
    city: str

class MerchantCreate(MerchantBase):
    pass

class MerchantResponse(MerchantBase):
    created_at: Optional[datetime] = None

    model_config = ConfigDict(from_attributes=True)

class MerchantSummaryResponse(BaseModel):
    merchant_id: str
    merchant_name: str
    name: Optional[str] = None
    business_type: Optional[str] = "Retail"
    city: Optional[str] = "Lucknow"
    today_sales: float = Field(..., ge=0, description="Total sales for current day (SUCCESS only)")
    today_transaction_count: int = Field(0, ge=0)
    transaction_count: int = Field(0, ge=0)
    current_week_sales: float = Field(0.0, ge=0)
    current_month_sales: float = Field(0.0, ge=0)
    average_transaction_value: float = Field(0.0, ge=0)
    average_transaction: float = Field(0.0, ge=0)
    successful_transaction_count: int = Field(0, ge=0)
    failed_transaction_count: int = Field(0, ge=0)
    success_rate: float = Field(100.0, ge=0, le=100)
    sales_change_percent: float = Field(0.0)
    currency: str = "INR"
