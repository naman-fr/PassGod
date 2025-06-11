from fastapi import APIRouter, Depends, HTTPException, status
from datetime import datetime, timedelta
from pymongo.collection import Collection
from bson import ObjectId
import secrets

from ..database import get_database
from ..models import SharedSecret, User, PyObjectId
from ..schemas import SharedSecretCreate, SharedSecretResponse, SharedSecretConsumeResponse
from .auth import get_current_user

router = APIRouter(prefix="/share", tags=["share"])

@router.post("/create", response_model=SharedSecretResponse)
async def create_shared_secret(
    payload: SharedSecretCreate,
    db: Collection = Depends(get_database),
    current_user: User = Depends(get_current_user)
):
    token = secrets.token_urlsafe(32)
    expires_at = datetime.utcnow() + timedelta(minutes=payload.expires_in_minutes)
    
    shared_secret_data = {
        "token": token,
        "encrypted_data": payload.encrypted_data,
        "expires_at": expires_at,
        "used": False,
        "created_by": ObjectId(current_user.id),
        "created_at": datetime.utcnow()
    }
    
    result = await db["shared_secrets"].insert_one(shared_secret_data)
    created_secret = await db["shared_secrets"].find_one({"_id": result.inserted_id})
    if created_secret is None:
        raise HTTPException(status_code=500, detail="Failed to create shared secret")
    
    return SharedSecretResponse(token=created_secret["token"], expires_at=created_secret["expires_at"], used=created_secret["used"])

@router.get("/{token}", response_model=SharedSecretConsumeResponse)
async def consume_shared_secret(token: str, db: Collection = Depends(get_database)):
    shared_secret = await db["shared_secrets"].find_one({"token": token})
    
    if not shared_secret or shared_secret["used"] or shared_secret["expires_at"] < datetime.utcnow():
        raise HTTPException(status_code=404, detail="Invalid or expired token")
    
    # Mark as used
    await db["shared_secrets"].update_one(
        {"_id": shared_secret["_id"]},
        {"$set": {"used": True}}
    )
    
    return SharedSecretConsumeResponse(data=shared_secret["encrypted_data"])