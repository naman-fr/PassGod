import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Landing from './pages/Landing';
import Dashboard from './pages/Dashboard';
import VaultPage from './pages/VaultPage';
import Social from './pages/Social';
import Breach from './pages/Breach';
import Settings from './pages/Settings';
import NotFound from './pages/NotFound';
import { AuthProvider } from './context/AuthContext';
import ShareView from './pages/ShareView';
import AdminDashboard from './pages/Admin';
import Login from './pages/Auth/Login';
import Register from './pages/Auth/Register';
import ProtectedRoute from './components/ProtectedRoute';
import NewPassword from './pages/Vault/NewPassword';
import NewSocialAccount from './pages/Social/NewSocialAccount';

const App = () => (
  <AuthProvider>
    <Router future={{ v7_startTransition: true, v7_relativeSplatPath: true }}>
      <Routes>
        {/* Public Routes */}
        <Route path="/" element={<Landing />} />
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<Register />} />
        <Route path="/share/:token" element={<ShareView />} />

        {/* Protected Routes (Requires Authentication) */}
        <Route element={<ProtectedRoute />}>
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/vault" element={<VaultPage />} />
          <Route path="/vault/new" element={<NewPassword />} />
          <Route path="/social" element={<Social />} />
          <Route path="/social/new" element={<NewSocialAccount />} />
          <Route path="/breach" element={<Breach />} />
          <Route path="/settings" element={<Settings />} />
          <Route path="/admin/*" element={<AdminDashboard />} />
        </Route>
        
        {/* Catch-all for 404 */} 
        <Route path="*" element={<NotFound />} />
      </Routes>
    </Router>
  </AuthProvider>
);

export default App; 