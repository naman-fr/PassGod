import axios from 'axios';
import { User, Password, SocialAccount, BreachAlert, SecureNote, SharedSecret, UserLogin, UserRegister, Token, UserUpdate, UserPasswordUpdate } from '../types';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:8000';

export const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add a request interceptor to add the auth token to requests
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Add a response interceptor to handle common errors
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Handle unauthorized access
      localStorage.removeItem('token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export const checkPasswordsForBreach = () => {
  const token = localStorage.getItem('token');
  return api.post<BreachAlert[]>('/api/v1/breach/check-passwords', {}, {
    headers: {
      Authorization: `Bearer ${token}`
    }
  });
};

export const checkEmailForBreach = () => {
  const token = localStorage.getItem('token');
  return api.post<BreachAlert[]>('/api/v1/breach/check-email', {}, {
    headers: {
      Authorization: `Bearer ${token}`
    }
  });
};

export const getBreachAlerts = () => {
  const token = localStorage.getItem('token');
  return api.get<BreachAlert[]>('/api/v1/breach/alerts', {
    headers: {
      Authorization: `Bearer ${token}`
    }
  });
};

export const resolveBreachAlert = (alertId: string) => {
  const token = localStorage.getItem('token');
  return api.put<BreachAlert>(`/api/v1/breach/alerts/${alertId}/resolve`, {}, {
    headers: {
      Authorization: `Bearer ${token}`
    }
  });
};

export const updateUserProfile = (profileData: any) => {
  const token = localStorage.getItem('token');
  return api.put('/api/v1/users/me', profileData, {
    headers: {
      Authorization: `Bearer ${token}`
    }
  });
};

export const updateUserPassword = (passwordData: any) => {
  const token = localStorage.getItem('token');
  return api.put('/api/v1/users/me/password', passwordData, {
    headers: {
      Authorization: `Bearer ${token}`
    }
  });
};

export const deleteAccount = () => {
  const token = localStorage.getItem('token');
  return api.delete('/api/v1/users/me', {
    headers: {
      Authorization: `Bearer ${token}`
    }
  });
}; 