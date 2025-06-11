from fastapi import APIRouter, Depends, HTTPException, status
from typing import List
from cryptography.fernet import Fernet
import os
from dotenv import load_dotenv, set_key
from pymongo.collection import Collection
from bson import ObjectId
from datetime import datetime

from ..database import get_database # Changed to get_database for MongoDB
from ..models import User, Password # User and Password models from Pydantic
from ..schemas import PasswordCreate, PasswordResponse
from .auth import get_current_user # Assuming get_current_user now works with MongoDB

router = APIRouter()

# Load encryption key from environment variable or generate a new one
load_dotenv(override=True) # Ensure .env is loaded and can be overridden
ENCRYPTION_KEY = os.getenv("ENCRYPTION_KEY")

# If ENCRYPTION_KEY is not set, generate one and save it to .env
if not ENCRYPTION_KEY:
    ENCRYPTION_KEY = Fernet.generate_key().decode()
    env_path = os.path.join(os.path.dirname(__file__), "..", ".env")
    # Ensure the .env file exists before trying to set the key
    if not os.path.exists(env_path):
        with open(env_path, "w") as f:
            f.write("")
    set_key(env_path, "ENCRYPTION_KEY", ENCRYPTION_KEY)
    print(f"Generated new ENCRYPTION_KEY and saved to {env_path}")

cipher_suite = Fernet(ENCRYPTION_KEY.encode())

def encrypt_password(password: str) -> str:
    return cipher_suite.encrypt(password.encode()).decode()

def decrypt_password(encrypted_password: str) -> str:
    return cipher_suite.decrypt(encrypted_password.encode()).decode()

@router.post("/", response_model=PasswordResponse)
async def create_password(
    password_data: PasswordCreate,
    db: Collection = Depends(get_database),
    current_user: User = Depends(get_current_user)
):
    encrypted_password = encrypt_password(password_data.password)
    
    password_dict = password_data.model_dump(exclude={'password'})
    password_dict["encrypted_password"] = encrypted_password
    password_dict["user_id"] = ObjectId(current_user.id)
    password_dict["created_at"] = datetime.utcnow()
    password_dict["updated_at"] = datetime.utcnow()

    result = await db["passwords"].insert_one(password_dict)
    
    created_password = await db["passwords"].find_one({"_id": result.inserted_id})
    if created_password is None:
        raise HTTPException(status_code=500, detail="Failed to create password")
    
    return PasswordResponse(**created_password)

@router.get("/", response_model=List[PasswordResponse])
async def read_passwords(
    skip: int = 0,
    limit: int = 100,
    db: Collection = Depends(get_database),
    current_user: User = Depends(get_current_user)
):
    passwords_cursor = db["passwords"].find({"user_id": ObjectId(current_user.id)}).skip(skip).limit(limit)
    passwords = await passwords_cursor.to_list(length=limit) # Use to_list with length
    
    return [PasswordResponse(**p) for p in passwords]

@router.get("/{password_id}", response_model=PasswordResponse)
async def read_password(
    password_id: str,
    db: Collection = Depends(get_database),
    current_user: User = Depends(get_current_user)
):
    password_data = await db["passwords"].find_one({
        "_id": ObjectId(password_id),
        "user_id": ObjectId(current_user.id)
    })
    
    if password_data is None:
        raise HTTPException(status_code=404, detail="Password not found")
    
    return PasswordResponse(**password_data)

@router.put("/{password_id}", response_model=PasswordResponse)
async def update_password(
    password_id: str,
    password_data: PasswordCreate,
    db: Collection = Depends(get_database),
    current_user: User = Depends(get_current_user)
):
    # Prepare update data
    update_fields = password_data.model_dump(exclude={'password'}, exclude_unset=True)
    if password_data.password: # Only update password if provided
        update_fields["encrypted_password"] = encrypt_password(password_data.password)
    update_fields["updated_at"] = datetime.utcnow()

    # Find and update the password
    updated_password = await db["passwords"].find_one_and_update(
        filter={
            "_id": ObjectId(password_id),
            "user_id": ObjectId(current_user.id)
        },
        update={"$set": update_fields},
        return_document=True # Return the updated document
    )
    
    if updated_password is None:
        raise HTTPException(status_code=404, detail="Password not found or not owned by user")
    
    return PasswordResponse(**updated_password)

@router.delete("/{password_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_password(
    password_id: str,
    db: Collection = Depends(get_database),
    current_user: User = Depends(get_current_user)
):
    result = await db["passwords"].delete_one({
        "_id": ObjectId(password_id),
        "user_id": ObjectId(current_user.id)
    })
    
    if result.deleted_count == 0:
        raise HTTPException(status_code=404, detail="Password not found or not owned by user")
    
    return None 