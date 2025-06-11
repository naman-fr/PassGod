from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime
import json

from ..api import deps
from app.models.private_storage import PrivateStorage, PrivateItem
from app.schemas.private_storage import (
    PrivateStorageCreate,
    PrivateStorageUpdate,
    PrivateItemCreate,
    PrivateItemResponse,
    PatternLockCreate,
    PinLockCreate
)
from app.core.security import verify_password, get_password_hash

router = APIRouter()

@router.get("/status")
def get_private_storage_status(
    *,
    db: Session = Depends(deps.get_db),
    current_user = Depends(deps.get_current_user),
):
    """Get the status of private storage for the current user"""
    storage = db.query(PrivateStorage).filter(PrivateStorage.user_id == current_user.id).first()

    if not storage:
        return {"is_initialized": False, "is_locked": True}
    
    return {"is_initialized": True, "is_locked": storage.is_locked}

@router.post("/setup", response_model=PrivateStorageCreate)
def setup_private_storage(
    *,
    db: Session = Depends(deps.get_db),
    current_user = Depends(deps.get_current_user),
    pattern: Optional[PatternLockCreate] = None,
    pin: Optional[PinLockCreate] = None
):
    """Setup private storage with either pattern or PIN lock"""
    if not pattern and not pin:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Either pattern or PIN must be provided"
        )
    
    storage = PrivateStorage(
        user_id=current_user.id,
        pattern_hash=get_password_hash(pattern.pattern) if pattern else None,
        pin_hash=get_password_hash(pin.pin) if pin else None
    )
    db.add(storage)
    db.commit()
    db.refresh(storage)
    return storage

@router.post("/unlock")
def unlock_private_storage(
    *,
    db: Session = Depends(deps.get_db),
    current_user = Depends(deps.get_current_user),
    pattern: Optional[str] = None,
    pin: Optional[str] = None
):
    """Unlock private storage with pattern or PIN"""
    storage = db.query(PrivateStorage).filter(PrivateStorage.user_id == current_user.id).first()
    if not storage:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Private storage not found"
        )
    
    if pattern and storage.pattern_hash:
        if not verify_password(pattern, storage.pattern_hash):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid pattern"
            )
    elif pin and storage.pin_hash:
        if not verify_password(pin, storage.pin_hash):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid PIN"
            )
    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid unlock method"
        )
    
    storage.is_locked = False
    storage.last_accessed = datetime.utcnow()
    db.commit()
    return {"message": "Storage unlocked successfully"}

@router.post("/items", response_model=PrivateItemResponse)
def create_private_item(
    *,
    db: Session = Depends(deps.get_db),
    current_user = Depends(deps.get_current_user),
    item: PrivateItemCreate
):
    """Create a new private item"""
    storage = db.query(PrivateStorage).filter(
        PrivateStorage.user_id == current_user.id,
        PrivateStorage.is_locked == False
    ).first()
    
    if not storage:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Private storage is locked or not found"
        )
    
    private_item = PrivateItem(
        storage_id=storage.id,
        item_type=item.item_type,
        encrypted_data=item.encrypted_data,
        metadata=json.dumps(item.metadata) if item.metadata else None
    )
    
    db.add(private_item)
    db.commit()
    db.refresh(private_item)
    return private_item

@router.get("/items", response_model=List[PrivateItemResponse])
def get_private_items(
    *,
    db: Session = Depends(deps.get_db),
    current_user = Depends(deps.get_current_user),
    item_type: Optional[str] = None
):
    """Get all private items, optionally filtered by type"""
    storage = db.query(PrivateStorage).filter(
        PrivateStorage.user_id == current_user.id,
        PrivateStorage.is_locked == False
    ).first()
    
    if not storage:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Private storage is locked or not found"
        )
    
    query = db.query(PrivateItem).filter(PrivateItem.storage_id == storage.id)
    if item_type:
        query = query.filter(PrivateItem.item_type == item_type)
    
    return query.all()

@router.delete("/items/{item_id}")
def delete_private_item(
    *,
    db: Session = Depends(deps.get_db),
    current_user = Depends(deps.get_current_user),
    item_id: int
):
    """Delete a private item"""
    storage = db.query(PrivateStorage).filter(
        PrivateStorage.user_id == current_user.id,
        PrivateStorage.is_locked == False
    ).first()
    
    if not storage:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Private storage is locked or not found"
        )
    
    item = db.query(PrivateItem).filter(
        PrivateItem.id == item_id,
        PrivateItem.storage_id == storage.id
    ).first()
    
    if not item:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Item not found"
        )
    
    db.delete(item)
    db.commit()
    return {"message": "Item deleted successfully"} 