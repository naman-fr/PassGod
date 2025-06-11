from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Optional
from pydantic import EmailStr
from pymongo.collection import Collection
from bson import ObjectId
from datetime import datetime

from ..database import get_database
from ..models import User
from ..schemas import UserResponse, UserCreate
from .auth import get_current_user, get_password_hash, verify_password

router = APIRouter()

@router.get("/me", response_model=UserResponse)
async def read_user_me(current_user: User = Depends(get_current_user)):
    """Get current user's profile"""
    return current_user

@router.put("/me", response_model=UserResponse)
async def update_user_me(
    email: Optional[EmailStr] = None,
    full_name: Optional[str] = None,
    current_password: Optional[str] = None,
    new_password: Optional[str] = None,
    db: Collection = Depends(get_database),
    current_user: User = Depends(get_current_user)
):
    """Update current user's profile"""
    update_fields = {}
    
    if email and email != current_user.email:
        # Check if email is already taken
        existing_user = await db["users"].find_one({"email": email})
        if existing_user:
            raise HTTPException(
                status_code=400,
                detail="Email already registered"
            )
        update_fields["email"] = email
    
    if full_name:
        update_fields["full_name"] = full_name
    
    if current_password and new_password:
        # Verify current password
        if not verify_password(current_password, current_user.hashed_password):
            raise HTTPException(
                status_code=400,
                detail="Incorrect current password"
            )
        # Update password
        update_fields["hashed_password"] = get_password_hash(new_password)
    
    if not update_fields:
        raise HTTPException(status_code=400, detail="No fields to update")

    update_fields["updated_at"] = datetime.utcnow()

    updated_user_data = await db["users"].find_one_and_update(
        filter={
            "_id": ObjectId(current_user.id)
        },
        update={"$set": update_fields},
        return_document=True
    )
    
    if updated_user_data is None:
        raise HTTPException(status_code=404, detail="User not found or not owned by user")
    
    return UserResponse(**updated_user_data)

@router.delete("/me", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user_me(
    db: Collection = Depends(get_database),
    current_user: User = Depends(get_current_user)
):
    """Delete current user's account"""
    result = await db["users"].delete_one({"_id": ObjectId(current_user.id)})
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="User not found or not owned by user")
    return None

@router.post("/verify-email", response_model=UserResponse)
async def verify_email(
    verification_token: str,
    db: Collection = Depends(get_database),
    current_user: User = Depends(get_current_user)
):
    """Verify user's email address"""
    # In a real application, you would verify the token securely
    # For now, we'll just mark the user as verified
    updated_user_data = await db["users"].find_one_and_update(
        filter={
            "_id": ObjectId(current_user.id)
        },
        update={"$set": {"is_verified": True, "updated_at": datetime.utcnow()}},
        return_document=True
    )
    if updated_user_data is None:
        raise HTTPException(status_code=404, detail="User not found or not owned by user")
    
    return UserResponse(**updated_user_data)

@router.post("/request-password-reset")
async def request_password_reset(
    email: EmailStr,
    db: Collection = Depends(get_database)
):
    """Request a password reset email"""
    user = await db["users"].find_one({"email": email})
    if user:
        # In a real application, you would:
        # 1. Generate a password reset token
        # 2. Store it in the database with an expiration time
        # 3. Send an email with a reset link
        pass
    # Always return success to prevent email enumeration
    return {"message": "If an account exists with this email, a password reset link has been sent"}

@router.post("/reset-password")
async def reset_password(
    token: str,
    new_password: str,
    db: Collection = Depends(get_database)
):
    """Reset user's password using a reset token"""
    # In a real application, you would:
    # 1. Verify the token
    # 2. Check if it's expired
    # 3. Update the user's password
    # 4. Invalidate the token
    return {"message": "Password has been reset successfully"} 