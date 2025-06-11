from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
from typing import List, Optional
import os
from dotenv import load_dotenv

from app.database import mongodb, get_database  # Import MongoDB and get_database

# Load environment variables
load_dotenv()

# Initialize FastAPI app
app = FastAPI(
    title="PASSGOD API",
    description="Universal Password Management System API",
    version="1.0.0"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3001"],  # Allow specific frontend origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# OAuth2 scheme for token authentication
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/token")

# Startup and Shutdown events for MongoDB
@app.on_event("startup")
async def startup_db_client():
    await mongodb.connect()

@app.on_event("shutdown")
async def shutdown_db_client():
    await mongodb.close()

# Import routers
from app.routers import auth, passwords, social_accounts, breach_monitor, users, share, admin, activity_notifications

# Include routers
app.include_router(auth.router, prefix="/api/v1/auth", tags=["Authentication"])
app.include_router(passwords.router, prefix="/api/v1/passwords", tags=["Passwords"])
app.include_router(social_accounts.router, prefix="/api/v1/social", tags=["Social Accounts"])
app.include_router(breach_monitor.router, prefix="/api/v1/breach", tags=["Breach Monitor"])
app.include_router(users.router, prefix="/api/v1/users", tags=["Users"])
app.include_router(share.router, prefix="/api/v1/share", tags=["Secure Sharing"])
app.include_router(admin.router, prefix="/api/v1/admin", tags=["Admin"])
app.include_router(activity_notifications.router, prefix="/api/v1/notifications", tags=["Activity Notifications"])

@app.get("/")
async def root():
    return {
        "message": "Welcome to PASSGOD API",
        "version": "1.0.0",
        "status": "active"
    }

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "version": "1.0.0"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True) 