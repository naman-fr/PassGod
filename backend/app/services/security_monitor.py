from typing import List, Dict, Any
import requests
from datetime import datetime
from sqlalchemy.orm import Session
from app.core.config import settings
from app.models.user import User
from app.models.social_account import SocialAccount
from app.models.notification import Notification
from app.core.security import get_password_hash

class SecurityMonitor:
    def __init__(self, db: Session):
        self.db = db
        self.hibp_api_key = settings.HIBP_API_KEY
        self.hibp_base_url = "https://haveibeenpwned.com/api/v3"

    def check_email_breach(self, email: str) -> List[Dict[str, Any]]:
        """Check if an email has been involved in any known breaches"""
        headers = {
            "hibp-api-key": self.hibp_api_key,
            "user-agent": "PassGod"
        }
        
        try:
            response = requests.get(
                f"{self.hibp_base_url}/breachedaccount/{email}",
                headers=headers
            )
            
            if response.status_code == 404:
                return []
            
            response.raise_for_status()
            breaches = response.json()
            
            # Create notification for each breach
            for breach in breaches:
                notification = Notification(
                    user_id=self.db.query(User).filter(User.email == email).first().id,
                    type="breach_alert",
                    title=f"Breach Alert: {breach['Name']}",
                    message=f"Your email was found in the {breach['Name']} breach. "
                           f"Breach date: {breach['BreachDate']}. "
                           f"Compromised data: {', '.join(breach['DataClasses'])}",
                    severity="high"
                )
                self.db.add(notification)
            
            self.db.commit()
            return breaches
            
        except requests.exceptions.RequestException as e:
            # Log the error and return empty list
            print(f"Error checking breach for {email}: {str(e)}")
            return []

    def check_password_breach(self, password: str) -> bool:
        """Check if a password has been exposed in known breaches"""
        password_hash = get_password_hash(password)
        prefix = password_hash[:5]
        suffix = password_hash[5:]
        
        headers = {
            "hibp-api-key": self.hibp_api_key,
            "user-agent": "PassGod"
        }
        
        try:
            response = requests.get(
                f"{self.hibp_base_url}/range/{prefix}",
                headers=headers
            )
            response.raise_for_status()
            
            # Check if the suffix exists in the response
            hashes = response.text.splitlines()
            return any(hash.split(':')[0] == suffix for hash in hashes)
            
        except requests.exceptions.RequestException as e:
            print(f"Error checking password breach: {str(e)}")
            return False

    def monitor_social_login(self, account: SocialAccount, login_data: Dict[str, Any]):
        """Monitor and detect suspicious login activities for social accounts"""
        # Check if this is a new login location
        if account.last_login_location != login_data.get('location'):
            notification = Notification(
                user_id=account.user_id,
                type="suspicious_login",
                title="New Login Location Detected",
                message=f"Your {account.platform} account was accessed from a new location: "
                       f"{login_data.get('location', 'Unknown')}. "
                       f"Time: {datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')}",
                severity="medium"
            )
            self.db.add(notification)
            
            # Update account with new login info
            account.last_login_location = login_data.get('location')
            account.last_login_time = datetime.utcnow()
            account.last_login_ip = login_data.get('ip')
            
            self.db.commit()

    def check_account_security(self, user: User) -> List[Dict[str, Any]]:
        """Perform comprehensive security check for a user's accounts"""
        security_issues = []
        
        # Check email breach
        email_breaches = self.check_email_breach(user.email)
        if email_breaches:
            security_issues.append({
                "type": "email_breach",
                "severity": "high",
                "details": email_breaches
            })
        
        # Check social accounts
        social_accounts = self.db.query(SocialAccount).filter(
            SocialAccount.user_id == user.id
        ).all()
        
        for account in social_accounts:
            # Check for suspicious login patterns
            if account.last_login_time:
                time_since_last_login = datetime.utcnow() - account.last_login_time
                if time_since_last_login.days > 30:
                    security_issues.append({
                        "type": "inactive_account",
                        "severity": "medium",
                        "details": {
                            "platform": account.platform,
                            "last_login": account.last_login_time
                        }
                    })
        
        return security_issues 