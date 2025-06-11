import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';
import { useAuth } from '../context/AuthContext'; // Changed to import useAuth

interface ProtectedRouteProps {
  children?: React.ReactNode;
}

const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ children }) => {
  const { user, loading } = useAuth(); // Get user and loading state from useAuth hook

  if (loading) {
    // Optionally, render a loading spinner or placeholder
    return <div>Loading authentication...</div>;
  }

  if (!user) {
    // User is not authenticated, redirect to login page
    return <Navigate to="/login" replace />;
  }

  // User is authenticated, render the child routes
  return children ? <>{children}</> : <Outlet />;
};

export default ProtectedRoute; 