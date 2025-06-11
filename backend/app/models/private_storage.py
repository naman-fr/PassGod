from sqlalchemy import Column, Integer, String, ForeignKey, DateTime, Boolean
from sqlalchemy.orm import relationship
from datetime import datetime
from app.database import Base

class PrivateStorage(Base):
    __tablename__ = "private_storage"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    pattern_hash = Column(String, nullable=True)  # For pattern lock
    pin_hash = Column(String, nullable=True)      # For PIN lock
    last_accessed = Column(DateTime, default=datetime.utcnow)
    is_locked = Column(Boolean, default=True)
    
    # Relationships
    user = relationship("User", back_populates="private_storage")
    private_items = relationship("PrivateItem", back_populates="storage", cascade="all, delete-orphan")

class PrivateItem(Base):
    __tablename__ = "private_items"

    id = Column(Integer, primary_key=True, index=True)
    storage_id = Column(Integer, ForeignKey("private_storage.id"), nullable=False)
    item_type = Column(String, nullable=False)  # "photo", "document", "note", etc.
    encrypted_data = Column(String, nullable=False)
    metadata = Column(String, nullable=True)  # JSON string for additional info
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    storage = relationship("PrivateStorage", back_populates="private_items") 