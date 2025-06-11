from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from datetime import datetime, timedelta
from typing import Optional
from jose import JWTError, jwt
from passlib.context import CryptContext
from pydantic import BaseModel
from pymongo.collection import Collection
from bson import ObjectId # Import ObjectId for MongoDB _id

from ..database import get_database  # Changed to get_database for MongoDB
from ..models import User # Ensure this refers to the Pydantic User model
from ..schemas import UserCreate, UserResponse, Token, TokenData

router = APIRouter()

# Security configuration
SECRET_KEY = "your-secret-key-here"  # In production, use environment variable
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/token") # Ensure this matches main.py

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    return pwd_context.hash(password)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES) # Use global constant
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

async def get_current_user(token: str = Depends(oauth2_scheme), db: Collection = Depends(get_database)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub") # Changed to user_id
        if user_id is None:
            raise credentials_exception
        token_data = TokenData(user_id=user_id) # Changed to user_id
    except JWTError:
        raise credentials_exception
    
    # Fetch user from MongoDB
    user_data = await db["users"].find_one({"_id": ObjectId(token_data.user_id)}) # Use ObjectId
    if user_data is None:
        raise credentials_exception
    
    # Convert MongoDB document to Pydantic model
    user = User(**user_data)
    return user

@router.post("/register", response_model=UserResponse)
async def register_user(user: UserCreate, db: Collection = Depends(get_database)):
    existing_user = await db["users"].find_one({"email": user.email})
    if existing_user:
        raise HTTPException(
            status_code=400,
            detail="Email already registered"
        )
    hashed_password = get_password_hash(user.password)
    
    db_user = User(
        email=user.email,
        hashed_password=hashed_password,
        full_name=user.full_name,
        is_active=True,
        is_verified=False,
        is_admin=False, # Ensure admin is false by default
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow()
    )
    
    # Insert user into MongoDB
    result = await db["users"].insert_one(db_user.model_dump(by_alias=True, exclude_none=True))
    db_user.id = str(result.inserted_id) # Assign the generated ObjectId back to the model

    return db_user

@router.post("/token", response_model=Token)
async def login_for_access_token(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Collection = Depends(get_database)
):
    user_data = await db["users"].find_one({"email": form_data.username})
    
    if not user_data or not verify_password(form_data.password, user_data["hashed_password"]):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Convert user_data to Pydantic User model for type consistency
    user = User(**user_data)

    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    # Use user.id (ObjectId converted to string) as the sub for the token
    access_token = create_access_token(
        data={"sub": str(user.id)}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

@router.get("/me", response_model=UserResponse)
async def read_users_me(current_user: User = Depends(get_current_user)):
    return current_user 