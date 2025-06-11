import React, { createContext, useState, useContext, useEffect, ReactNode, useCallback } from 'react';
import axios from 'axios';
import { Constants } from '../utils/constants';

interface User {
  id: string;
  email: string;
  full_name: string;
  is_active: boolean;
  is_verified: boolean;
  is_admin: boolean;
  created_at: string;
  updated_at?: string;
}

interface AuthContextType {
  user: User | null;
  token: string | null;
  loading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  loadUser: () => Promise<void>;
  setUser: (user: User | null) => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [user, setUser] = useState<User | null>(null);
  const [token, setToken] = useState<string | null>(localStorage.getItem(Constants.tokenKey));
  const [loading, setLoading] = useState(true);

  const API_URL = Constants.apiBaseUrl;

  const loadUser = useCallback(async () => {
    if (!token) {
      setUser(null);
      setLoading(false);
      return;
    }
    try {
      const response = await axios.get(`${API_URL}/auth/me`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      setUser(response.data);
    } catch (error) {
      console.error('Failed to load user:', error);
      setUser(null);
      setToken(null);
      localStorage.removeItem(Constants.tokenKey);
    } finally {
      setLoading(false);
    }
  }, [token, API_URL]);

  useEffect(() => {
    loadUser();
  }, [loadUser]);

  const login = async (email: string, password: string) => {
    setLoading(true);
    try {
      const response = await axios.post(`${API_URL}/auth/token`, 
        new URLSearchParams({
          username: email,
          password: password,
        }).toString(),
        {
          headers: {'Content-Type': 'application/x-www-form-urlencoded'}
        }
      );
      const { access_token } = response.data;
      localStorage.setItem(Constants.tokenKey, access_token);
      setToken(access_token);
      await loadUser(); // Load user after successful login
      return Promise.resolve();
    } catch (error: any) {
      console.error('Login failed:', error.response?.data || error.message);
      setLoading(false);
      setUser(null);
      setToken(null);
      localStorage.removeItem(Constants.tokenKey);
      return Promise.reject(error.response?.data?.detail || 'Login failed');
    }
  };

  const logout = () => {
    setUser(null);
    setToken(null);
    localStorage.removeItem(Constants.tokenKey);
  };

  return (
    <AuthContext.Provider value={{ user, token, loading, login, logout, loadUser, setUser }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used within AuthProvider');
  return context;
}; 