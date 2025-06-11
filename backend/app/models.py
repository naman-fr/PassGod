from datetime import datetime
from typing import Optional, Any
from pydantic import BaseModel, Field, BeforeValidator
from pydantic_settings import SettingsConfigDict
from typing_extensions import Annotated
import secrets

# Custom type for MongoDB ObjectId
# Allows using ObjectId as a string in Pydantic models
PyObjectId = Annotated[str, BeforeValidator(str)]

class MongoBaseModel(BaseModel):
    id: Optional[PyObjectId] = Field(alias="_id", default=None)
    model_config = SettingsConfigDict(arbitrary_types_allowed=True, populate_by_name=True)


class User(MongoBaseModel):
    email: str = Field(..., unique=True)
    hashed_password: str
    full_name: Optional[str] = None
    is_active: bool = True
    is_verified: bool = False
    is_admin: bool = False
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)


class Password(MongoBaseModel):
    user_id: PyObjectId
    title: str
    username: str
    encrypted_password: str
    website_url: Optional[str] = None
    notes: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)


class SocialAccount(MongoBaseModel):
    user_id: PyObjectId
    platform: str
    username: str
    encrypted_password: str
    additional_data: Optional[dict] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)


class BreachAlert(MongoBaseModel):
    user_id: PyObjectId
    platform: str
    breach_date: datetime
    description: str
    severity: str
    is_resolved: bool = False
    created_at: datetime = Field(default_factory=datetime.utcnow)


class SecureNote(MongoBaseModel):
    user_id: PyObjectId
    title: str
    encrypted_content: str
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)


class SharedSecret(MongoBaseModel):
    token: str = Field(default_factory=lambda: secrets.token_urlsafe(32), unique=True)
    encrypted_data: str
    expires_at: datetime
    used: bool = False
    created_by: PyObjectId
    created_at: datetime = Field(default_factory=datetime.utcnow)


class ActivityNotification(MongoBaseModel):
    user_id: PyObjectId
    message: str
    type: str
    entity_id: Optional[PyObjectId] = None
    is_read: bool = False
    created_at: datetime = Field(default_factory=datetime.utcnow) 