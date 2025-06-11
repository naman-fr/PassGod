from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List, Dict, Any
from datetime import datetime
from app.models import PyObjectId

# User schemas
class UserBase(BaseModel):
    email: EmailStr
    full_name: str

class UserCreate(UserBase):
    password: str

class UserResponse(UserBase):
    id: PyObjectId = Field(alias="_id")
    is_active: bool
    is_verified: bool
    is_admin: bool = False
    created_at: datetime
    updated_at: Optional[datetime] = None

    class Config:
        populate_by_name = True

# Token schemas
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    user_id: Optional[str] = None

# Password schemas
class PasswordBase(BaseModel):
    title: str
    username: str
    website_url: Optional[str] = None
    notes: Optional[str] = None

class PasswordCreate(PasswordBase):
    password: str

class PasswordResponse(PasswordBase):
    id: PyObjectId = Field(alias="_id")
    created_at: datetime
    updated_at: Optional[datetime] = None
    user_id: PyObjectId

    class Config:
        populate_by_name = True

# Social Account schemas
class SocialAccountBase(BaseModel):
    platform: str
    username: str
    additional_data: Optional[Dict[str, Any]] = None

class SocialAccountCreate(SocialAccountBase):
    password: str

class SocialAccountResponse(SocialAccountBase):
    id: PyObjectId = Field(alias="_id")
    created_at: datetime
    updated_at: Optional[datetime] = None
    user_id: PyObjectId

    class Config:
        populate_by_name = True

# Breach Alert schemas
class BreachAlertBase(BaseModel):
    platform: str
    breach_date: datetime
    description: str
    severity: str

class BreachAlertCreate(BreachAlertBase):
    pass

class BreachAlertResponse(BreachAlertBase):
    id: PyObjectId = Field(alias="_id")
    is_resolved: bool
    created_at: datetime
    user_id: PyObjectId

    class Config:
        populate_by_name = True

# Secure Note schemas
class SecureNoteBase(BaseModel):
    title: str

class SecureNoteCreate(SecureNoteBase):
    content: str

class SecureNoteResponse(SecureNoteBase):
    id: PyObjectId = Field(alias="_id")
    created_at: datetime
    updated_at: Optional[datetime] = None
    user_id: PyObjectId

    class Config:
        populate_by_name = True

class SharedSecretCreate(BaseModel):
    encrypted_data: str
    expires_in_minutes: int = 60

class SharedSecretResponse(BaseModel):
    token: str
    expires_at: datetime
    used: bool

class SharedSecretConsumeResponse(BaseModel):
    data: str

# Admin schemas
class UserAdminResponse(BaseModel):
    id: PyObjectId = Field(alias="_id")
    email: EmailStr
    full_name: Optional[str]
    is_active: bool
    is_verified: bool
    is_admin: bool
    created_at: datetime

class AuditLogResponse(BaseModel):
    action: str
    user_id: Optional[PyObjectId] = None
    timestamp: datetime
    details: Optional[str]

# Activity Notification schemas
class ActivityNotificationBase(BaseModel):
    message: str
    type: str
    entity_id: Optional[PyObjectId] = None # ID of the entity related to the notification (e.g., password_id, breach_alert_id)
    is_read: bool = False

class ActivityNotificationCreate(ActivityNotificationBase):
    pass

class ActivityNotificationResponse(ActivityNotificationBase):
    id: PyObjectId = Field(alias="_id")
    user_id: PyObjectId
    created_at: datetime

    class Config:
        populate_by_name = True
 