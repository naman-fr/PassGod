from pydantic import BaseModel, Field
from typing import Optional, Dict, Any
from datetime import datetime

class PatternLockCreate(BaseModel):
    pattern: str = Field(..., min_length=4, max_length=100)

class PinLockCreate(BaseModel):
    pin: str = Field(..., min_length=4, max_length=6)

class PrivateStorageBase(BaseModel):
    is_locked: bool = True

class PrivateStorageCreate(PrivateStorageBase):
    user_id: int

class PrivateStorageUpdate(PrivateStorageBase):
    pattern_hash: Optional[str] = None
    pin_hash: Optional[str] = None

class PrivateStorageInDB(PrivateStorageBase):
    id: int
    user_id: int
    pattern_hash: Optional[str]
    pin_hash: Optional[str]
    last_accessed: datetime

    class Config:
        orm_mode = True

class PrivateItemBase(BaseModel):
    item_type: str
    encrypted_data: str
    metadata: Optional[Dict[str, Any]] = None

class PrivateItemCreate(PrivateItemBase):
    pass

class PrivateItemResponse(PrivateItemBase):
    id: int
    storage_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True 