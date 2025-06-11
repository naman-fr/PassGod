from fastapi import APIRouter, Depends, HTTPException, status
from typing import List, Optional
from pymongo.collection import Collection
from bson import ObjectId
from datetime import datetime

from ..database import get_database
from ..models import User, ActivityNotification, PyObjectId
from ..schemas import ActivityNotificationResponse, ActivityNotificationCreate
from .auth import get_current_user

router = APIRouter()

async def create_activity_notification(
    db: Collection,
    user_id: PyObjectId,
    message: str,
    type: str,
    entity_id: Optional[PyObjectId] = None,
):
    """Create an activity notification in the database"""
    notification_data = {
        "user_id": ObjectId(user_id),
        "message": message,
        "type": type,
        "entity_id": ObjectId(entity_id) if entity_id else None,
        "is_read": False,
        "created_at": datetime.utcnow(),
    }
    
    result = await db["activity_notifications"].insert_one(notification_data)
    created_notification = await db["activity_notifications"].find_one({"_id": result.inserted_id})
    if created_notification is None:
        raise HTTPException(status_code=500, detail="Failed to create activity notification")
    return ActivityNotificationResponse(**created_notification)

@router.get("/", response_model=List[ActivityNotificationResponse])
async def get_activity_notifications(
    skip: int = 0,
    limit: int = 100,
    read: Optional[bool] = None,
    db: Collection = Depends(get_database),
    current_user: User = Depends(get_current_user)
):
    """Get all activity notifications for the user"""
    query_filter = {"user_id": ObjectId(current_user.id)}
    if read is not None:
        query_filter["is_read"] = read
        
    notifications_cursor = db["activity_notifications"].find(query_filter).sort("created_at", -1).skip(skip).limit(limit)
    notifications = await notifications_cursor.to_list(length=limit)
    
    return [ActivityNotificationResponse(**n) for n in notifications]

@router.put("/{notification_id}/read", response_model=ActivityNotificationResponse)
async def mark_notification_as_read(
    notification_id: str,
    db: Collection = Depends(get_database),
    current_user: User = Depends(get_current_user)
):
    """Mark an activity notification as read"""
    updated_notification = await db["activity_notifications"].find_one_and_update(
        filter={
            "_id": ObjectId(notification_id),
            "user_id": ObjectId(current_user.id)
        },
        update={"$set": {"is_read": True}},
        return_document=True
    )
    
    if updated_notification is None:
        raise HTTPException(status_code=404, detail="Notification not found or not owned by user")
    
    return ActivityNotificationResponse(**updated_notification) 