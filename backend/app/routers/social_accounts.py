from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Dict, Any
from cryptography.fernet import Fernet
import os
from dotenv import load_dotenv
from pymongo.collection import Collection
from bson import ObjectId
from datetime import datetime

from ..database import get_database
from ..models import User, SocialAccount
from ..schemas import SocialAccountCreate, SocialAccountResponse
from .auth import get_current_user
from .passwords import encrypt_password

router = APIRouter()

# Supported social media platforms
SUPPORTED_PLATFORMS = {
    "whatsapp": {
        "icon": "whatsapp",
        "color": "#25D366",
        "fields": ["phone_number"]
    },
    "instagram": {
        "icon": "instagram",
        "color": "#E4405F",
        "fields": ["username"]
    },
    "reddit": {
        "icon": "reddit",
        "color": "#FF4500",
        "fields": ["username"]
    },
    "discord": {
        "icon": "discord",
        "color": "#5865F2",
        "fields": ["username", "discriminator"]
    },
    "facebook": {
        "icon": "facebook",
        "color": "#1877F2",
        "fields": ["email", "username"]
    },
    "linkedin": {
        "icon": "linkedin",
        "color": "#0A66C2",
        "fields": ["email"]
    }
}

@router.post("/", response_model=SocialAccountResponse)
async def create_social_account(
    account_data: SocialAccountCreate,
    db: Collection = Depends(get_database),
    current_user: User = Depends(get_current_user)
):
    if account_data.platform.lower() not in SUPPORTED_PLATFORMS:
        raise HTTPException(
            status_code=400,
            detail=f"Unsupported platform. Supported platforms: {', '.join(SUPPORTED_PLATFORMS.keys())}"
        )
    
    encrypted_password = encrypt_password(account_data.password)
    
    account_dict = account_data.model_dump(exclude={'password'})
    account_dict["encrypted_password"] = encrypted_password
    account_dict["user_id"] = ObjectId(current_user.id)
    account_dict["created_at"] = datetime.utcnow()
    account_dict["updated_at"] = datetime.utcnow()

    result = await db["social_accounts"].insert_one(account_dict)
    
    created_account = await db["social_accounts"].find_one({"_id": result.inserted_id})
    if created_account is None:
        raise HTTPException(status_code=500, detail="Failed to create social account")
    
    return SocialAccountResponse(**created_account)

@router.get("/", response_model=List[SocialAccountResponse])
async def read_social_accounts(
    skip: int = 0,
    limit: int = 100,
    platform: str = None,
    db: Collection = Depends(get_database),
    current_user: User = Depends(get_current_user)
):
    query_filter = {"user_id": ObjectId(current_user.id)}
    if platform:
        query_filter["platform"] = platform.lower()
        
    accounts_cursor = db["social_accounts"].find(query_filter).skip(skip).limit(limit)
    accounts = await accounts_cursor.to_list(length=limit)
    
    return [SocialAccountResponse(**a) for a in accounts]

@router.get("/{account_id}", response_model=SocialAccountResponse)
async def read_social_account(
    account_id: str,
    db: Collection = Depends(get_database),
    current_user: User = Depends(get_current_user)
):
    account_data = await db["social_accounts"].find_one({
        "_id": ObjectId(account_id),
        "user_id": ObjectId(current_user.id)
    })
    
    if account_data is None:
        raise HTTPException(status_code=404, detail="Social account not found")
    
    return SocialAccountResponse(**account_data)

@router.put("/{account_id}", response_model=SocialAccountResponse)
async def update_social_account(
    account_id: str,
    account_data: SocialAccountCreate,
    db: Collection = Depends(get_database),
    current_user: User = Depends(get_current_user)
):
    if account_data.platform.lower() not in SUPPORTED_PLATFORMS:
        raise HTTPException(
            status_code=400,
            detail=f"Unsupported platform. Supported platforms: {', '.join(SUPPORTED_PLATFORMS.keys())}"
        )
    
    update_fields = account_data.model_dump(exclude={'password'}, exclude_unset=True)
    if account_data.password:
        update_fields["encrypted_password"] = encrypt_password(account_data.password)
    update_fields["updated_at"] = datetime.utcnow()

    updated_account = await db["social_accounts"].find_one_and_update(
        filter={
            "_id": ObjectId(account_id),
            "user_id": ObjectId(current_user.id)
        },
        update={"$set": update_fields},
        return_document=True
    )
    
    if updated_account is None:
        raise HTTPException(status_code=404, detail="Social account not found or not owned by user")
    
    return SocialAccountResponse(**updated_account)

@router.delete("/{account_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_social_account(
    account_id: str,
    db: Collection = Depends(get_database),
    current_user: User = Depends(get_current_user)
):
    result = await db["social_accounts"].delete_one({
        "_id": ObjectId(account_id),
        "user_id": ObjectId(current_user.id)
    })
    
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Social account not found or not owned by user")
    
    return None

@router.get("/platforms/supported", response_model=Dict[str, Any])
def get_supported_platforms():
    return SUPPORTED_PLATFORMS 