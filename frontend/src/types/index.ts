export interface Password {
  id: string;
  title: string;
  username: string;
  encrypted_password: string;
  website_url?: string;
  notes?: string;
  created_at: string;
  updated_at: string;
  user_id: string;
}

export interface User {
  id: string;
  email: string;
  username: string;
  is_admin: boolean;
  created_at: string;
  updated_at: string;
}

export interface SocialAccount {
  id: string;
  user_id: string;
  platform: string;
  username: string;
  encrypted_password: string;
  url?: string;
  notes?: string;
  created_at: string;
  updated_at: string;
}

export interface SecureNote {
  id: string;
  user_id: string;
  title: string;
  content: string;
  created_at: string;
  updated_at: string;
}

export interface SharedSecret {
  id: string;
  sender_id: string;
  recipient_id: string;
  encrypted_secret: string;
  created_at: string;
  expires_at: string;
  is_read: boolean;
}

export interface UserLogin {
  username: string;
  password: string;
}

export interface UserRegister {
  username: string;
  email: string;
  password: string;
}

export interface Token {
  access_token: string;
  token_type: string;
}

export interface UserUpdate {
  username?: string;
  email?: string;
}

export interface UserPasswordUpdate {
  current_password: string;
  new_password: string;
}

export interface BreachAlert {
  id: string;
  user_id: string;
  platform: string;
  description: string;
  severity: 'low' | 'medium' | 'high';
  is_resolved: boolean;
  created_at: string;
  breach_date: string;
}

export interface ActivityNotification {
  id: string;
  user_id: string;
  message: string;
  type: string;
  entity_id?: string;
  is_read: boolean;
  created_at: string;
} 