"""
Audio input validator for VyapaarPilot Voice Subsystem.
Validates file sizes, MIME types, and non-empty streams.
"""

from typing import Tuple, Set

SUPPORTED_AUDIO_MIMES: Set[str] = {
    "audio/wav",
    "audio/wave",
    "audio/x-wav",
    "audio/mpeg",
    "audio/mp3",
    "audio/mp4",
    "audio/m4a",
    "audio/aac",
    "audio/webm",
    "audio/ogg",
    "application/octet-stream"  # Flutter sometimes sends this for raw recordings
}

def validate_audio_file(
    content: bytes,
    content_type: str,
    max_mb: float = 15.0
) -> Tuple[bool, str, str]:
    """
    Validates audio file content and MIME type.
    Returns (is_valid: bool, error_code: str, error_message: str).
    """
    clean_mime = (content_type or "").split(";")[0].strip().lower()
    if clean_mime and clean_mime not in SUPPORTED_AUDIO_MIMES:
        return False, "INVALID_AUDIO_FORMAT", f"Unsupported audio format '{clean_mime}'. Supported formats: {', '.join(sorted(SUPPORTED_AUDIO_MIMES))}"

    if not content or len(content) == 0:
        return False, "EMPTY_AUDIO", "Uploaded audio file is empty."

    max_bytes = int(max_mb * 1024 * 1024)
    if len(content) > max_bytes:
        return False, "AUDIO_TOO_LARGE", f"Audio file size exceeds maximum limit of {max_mb} MB."

    if len(content) < 44:
        return False, "EMPTY_AUDIO", "Uploaded audio file is too short or corrupted."

    return True, "", ""
