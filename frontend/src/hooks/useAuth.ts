import { useEffect } from 'react';
import api from '../api/api';
import { useAuth } from '../context/AuthContext';

export const useAuthInit = () => {
  const { setUser } = useAuth();
  useEffect(() => {
    const token = localStorage.getItem('token');
    if (token) {
      api.get('/users/me', {
        headers: { Authorization: `Bearer ${token}` },
      })
        .then(res => setUser(res.data))
        .catch(() => setUser(null));
    }
  }, [setUser]);
}; 