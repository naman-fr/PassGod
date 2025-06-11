import os
from dotenv import load_dotenv
from motor.motor_asyncio import AsyncIOMotorClient

load_dotenv()

class MongoDB: 
    client: AsyncIOMotorClient = None
    database_name: str = os.getenv("MONGODB_NAME", "passgod")

    async def connect(self): 
        self.client = AsyncIOMotorClient(os.getenv("MONGODB_URL", "mongodb://localhost:27017/"))
        print("Connected to MongoDB!")

    async def close(self): 
        self.client.close()
        print("MongoDB connection closed.")

    def get_db(self):
        return self.client[self.database_name]

mongodb = MongoDB()

async def get_database():
    return mongodb.get_db()

def get_db():
    return mongodb.get_db() 