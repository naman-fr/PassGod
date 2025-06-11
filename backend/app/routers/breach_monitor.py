from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from typing import List, Dict, Any, Optional
import aiohttp
import hashlib
import os
from dotenv import load_dotenv
from pymongo.collection import Collection
from bson import ObjectId
from datetime import datetime

from ..database import get_database
from ..models import User, Password, SocialAccount, BreachAlert, PyObjectId
from ..schemas import BreachAlertResponse
from .auth import get_current_user
from .passwords import decrypt_password

router = APIRouter()

# Load environment variables
load_dotenv()
HIBP_API_KEY = os.getenv("HIBP_API_KEY", "")

async def check_password_breach(password: str) -> bool:
    """Check if a password has been breached using HaveIBeenPwned API"""
    sha1_hash = hashlib.sha1(password.encode()).hexdigest().upper()
    prefix, suffix = sha1_hash[:5], sha1_hash[5:]
    
    async with aiohttp.ClientSession() as session:
        headers = {"hibp-api-key": HIBP_API_KEY} if HIBP_API_KEY else {}
        async with session.get(
            f"https://api.pwnedpasswords.com/range/{prefix}",
            headers=headers
        ) as response:
            if response.status == 200:
                text = await response.text()
                for line in text.splitlines():
                    if line.startswith(suffix):
                        return True
    return False

async def check_email_breach_api(email: str) -> List[Dict[str, Any]]: # Renamed to avoid conflict
    """Check if an email has been involved in any breaches"""
    async with aiohttp.ClientSession() as session:
        headers = {"hibp-api-key": HIBP_API_KEY} if HIBP_API_KEY else {}
        async with session.get(
            f"https://haveibeenpwned.com/api/v3/breachedaccount/{email}",
            headers=headers
        ) as response:
            if response.status == 200:
                return await response.json()
            elif response.status == 404:
                return [] # Email not found in any breaches
            else:
                response.raise_for_status() # Raise an exception for other HTTP errors
    return []

async def create_breach_alert(
    db: Collection,
    user_id: PyObjectId,
    platform: str,
    description: str,
    severity: str = "medium"
):
    """Create a breach alert in the database"""
    alert_data = {
        "user_id": ObjectId(user_id),
        "platform": platform,
        "description": description,
        "severity": severity,
        "is_resolved": False,
        "created_at": datetime.utcnow(),
        "breach_date": datetime.utcnow(), # Placeholder for now, can be actual breach date if available
    }
    
    result = await db["breach_alerts"].insert_one(alert_data)
    created_alert = await db["breach_alerts"].find_one({"_id": result.inserted_id})
    if created_alert is None:
        raise HTTPException(status_code=500, detail="Failed to create breach alert")
    return BreachAlertResponse(**created_alert)

@router.post("/check-passwords", response_model=List[BreachAlertResponse])
async def check_passwords_for_breach(
    background_tasks: BackgroundTasks,
    db: Collection = Depends(get_database),
    current_user: User = Depends(get_current_user)
):
    """Check all user's passwords for breaches"""
    alerts = []
    
    # Check regular passwords
    passwords_cursor = db["passwords"].find({"user_id": ObjectId(current_user.id)})
    passwords_list = await passwords_cursor.to_list(length=None) # Get all passwords

    for password_data in passwords_list:
        password = Password(**password_data) # Convert dict to Pydantic model
        decrypted_password = decrypt_password(password.encrypted_password)
        if await check_password_breach(decrypted_password):
            alert = await create_breach_alert(
                db,
                current_user.id,
                password.title,
                f"Password for {password.title} has been found in known data breaches",
                "high"
            )
            alerts.append(alert)
    
    # Check social media passwords
    social_accounts_cursor = db["social_accounts"].find({"user_id": ObjectId(current_user.id)})
    social_accounts_list = await social_accounts_cursor.to_list(length=None) # Get all social accounts

    for account_data in social_accounts_list:
        account = SocialAccount(**account_data) # Convert dict to Pydantic model
        decrypted_password = decrypt_password(account.encrypted_password)
        if await check_password_breach(decrypted_password):
            alert = await create_breach_alert(
                db,
                current_user.id,
                account.platform,
                f"Password for {account.platform} account has been found in known data breaches",
                "high"
            )
            alerts.append(alert)
    
    return alerts

@router.post("/check-email", response_model=List[BreachAlertResponse])
async def check_user_email_breach(
    background_tasks: BackgroundTasks,
    db: Collection = Depends(get_database),
    current_user: User = Depends(get_current_user)
):
    """Check user's email for breaches"""
    breaches = await check_email_breach_api(current_user.email)
    alerts = []
    
    for breach in breaches:
        alert = await create_breach_alert(
            db,
            current_user.id,
            breach.get("Name", "Unknown"),
            f"Your email was found in the {breach.get('Name')} breach. Breach date: {breach.get('BreachDate')}",
            "medium"
        )
        alerts.append(alert)
    
    return alerts

@router.get("/alerts", response_model=List[BreachAlertResponse])
async def get_breach_alerts(
    skip: int = 0,
    limit: int = 100,
    resolved: Optional[bool] = None,
    db: Collection = Depends(get_database),
    current_user: User = Depends(get_current_user)
):
    """Get all breach alerts for the user"""
    query_filter = {"user_id": ObjectId(current_user.id)}
    if resolved is not None:
        query_filter["is_resolved"] = resolved
        
    alerts_cursor = db["breach_alerts"].find(query_filter).sort("created_at", -1).skip(skip).limit(limit)
    alerts = await alerts_cursor.to_list(length=limit)
    
    return [BreachAlertResponse(**a) for a in alerts]

@router.put("/alerts/{alert_id}/resolve", response_model=BreachAlertResponse)
async def resolve_breach_alert(
    alert_id: str,
    db: Collection = Depends(get_database),
    current_user: User = Depends(get_current_user)
):
    """Mark a breach alert as resolved"""
    updated_alert = await db["breach_alerts"].find_one_and_update(
        filter={
            "_id": ObjectId(alert_id),
            "user_id": ObjectId(current_user.id)
        },
        update={"$set": {"is_resolved": True}},
        return_document=True
    )
    
    if updated_alert is None:
        raise HTTPException(status_code=404, detail="Breach alert not found or not owned by user")
    
    return BreachAlertResponse(**updated_alert) 