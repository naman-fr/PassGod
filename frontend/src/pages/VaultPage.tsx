import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import MainLayout from '../components/Layout/MainLayout';
import { useAuth } from '../context/AuthContext';
import axios from 'axios';
import { Constants } from '../utils/constants';
import {
  PlusIcon,
  MagnifyingGlassIcon,
  EyeIcon,
  PencilSquareIcon,
  TrashIcon,
} from '@heroicons/react/24/outline';

interface Password {
  id: string;
  title: string;
  username: string;
  encrypted_password: string; // This will actually be the encrypted password from backend
  website_url?: string;
  notes?: string;
  created_at: string;
  updated_at?: string;
  user_id: string;
}

const VaultPage = () => {
  const [passwords, setPasswords] = useState<Password[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const { token } = useAuth();

  const API_URL = Constants.apiBaseUrl;

  useEffect(() => {
    const fetchPasswords = async () => {
      if (!token) {
        setLoading(false);
        setError('Authentication token not found. Please log in.');
        return;
      }
      try {
        const response = await axios.get(`${API_URL}/passwords/`, {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        });
        setPasswords(response.data);
        setError(null);
      } catch (err: any) {
        console.error('Failed to fetch passwords:', err.response?.data || err.message);
        setError(err.response?.data?.detail || 'Failed to fetch passwords');
        setPasswords([]);
      } finally {
        setLoading(false);
      }
    };

    fetchPasswords();
  }, [token, API_URL]);

  const filteredPasswords = passwords.filter(
    (p) =>
      p.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      p.username.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleDelete = async (passwordId: string) => {
    if (!window.confirm('Are you sure you want to delete this password?')) {
      return;
    }
    if (!token) {
      setError('Authentication token not found. Please log in.');
      return;
    }
    try {
      await axios.delete(`${API_URL}/passwords/${passwordId}`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });
      setPasswords(passwords.filter((p) => p.id !== passwordId));
      setSuccess('Password deleted successfully!');
      // Clear success message after a few seconds
      setTimeout(() => setSuccess(null), 3000);
    } catch (err: any) {
      console.error('Failed to delete password:', err.response?.data || err.message);
      setError(err.response?.data?.detail || 'Failed to delete password');
    }
  };

  const [showPasswordMap, setShowPasswordMap] = useState<{[key: string]: boolean}>({});
  
  const togglePasswordVisibility = (id: string) => {
    setShowPasswordMap(prev => ({ ...prev, [id]: !prev[id] }));
  };

  // For simplicity, directly show encrypted password. Decryption would happen in view/edit modal.
  const getDisplayPassword = (password: Password) => {
    return showPasswordMap[password.id] ? "***********" : password.encrypted_password;
  }

  return (
    <MainLayout>
      <div className="space-y-6">
        <div className="sm:flex sm:items-center sm:justify-between">
          <div>
            <h1 className="text-2xl font-semibold text-gray-900">Password Vault</h1>
            <p className="mt-2 text-sm text-gray-700">
              Manage your securely stored passwords.
            </p>
          </div>
          <div className="mt-4 sm:mt-0">
            <Link
              to="/vault/new"
              className="inline-flex items-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
            >
              <PlusIcon className="-ml-0.5 mr-1.5 h-5 w-5" aria-hidden="true" />
              Add Password
            </Link>
          </div>
        </div>

        {/* Search */}
        <div className="relative">
          <div className="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
            <MagnifyingGlassIcon className="h-5 w-5 text-gray-400" aria-hidden="true" />
          </div>
          <input
            type="text"
            className="block w-full rounded-md border-0 py-1.5 pl-10 text-gray-900 ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
            placeholder="Search passwords..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>

        {error && <p className="text-sm text-red-600 mt-2">{error}</p>}
        {success && <p className="text-sm text-green-600 mt-2">{success}</p>}

        {/* Password List */}
        <div className="overflow-hidden rounded-lg bg-white shadow">
          {loading ? (
            <div className="p-4 text-center text-gray-500">Loading passwords...</div>
          ) : filteredPasswords.length === 0 ? (
            <div className="p-4 text-center text-gray-500">No passwords found.</div>
          ) : (
            <ul className="divide-y divide-gray-200">
              {filteredPasswords.map((password) => (
                <li key={password.id} className="px-4 py-4 sm:px-6">
                  <div className="flex items-center justify-between">
                    <div className="flex min-w-0 flex-1 items-center">
                      <div className="min-w-0 flex-1">
                        <p className="truncate text-sm font-medium text-indigo-600">
                          {password.title}
                        </p>
                        <p className="mt-2 text-sm text-gray-500">Username: {password.username}</p>
                        <p className="text-sm text-gray-500">Password: {getDisplayPassword(password)}
                            <button type="button" onClick={() => togglePasswordVisibility(password.id)} className="ml-2 text-indigo-600 hover:text-indigo-500">
                                <EyeIcon className="h-5 w-5" aria-hidden="true" />
                            </button>
                        </p>
                        {password.website_url && (
                          <p className="text-sm text-gray-500">URL: {password.website_url}</p>
                        )}
                      </div>
                    </div>
                    <div className="ml-4 flex flex-shrink-0 space-x-2">
                      {/* View/Edit/Delete buttons */}
                      <button
                        type="button"
                        className="inline-flex items-center rounded-md bg-white px-2.5 py-1.5 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
                        onClick={() => alert(`View/Edit ${password.title}`)} // Placeholder
                      >
                        <PencilSquareIcon className="h-5 w-5 text-gray-400" aria-hidden="true" />
                      </button>
                      <button
                        type="button"
                        className="inline-flex items-center rounded-md bg-white px-2.5 py-1.5 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
                        onClick={() => handleDelete(password.id)}
                      >
                        <TrashIcon className="h-5 w-5" aria-hidden="true" />
                      </button>
                    </div>
                  </div>
                </li>
              ))}
            </ul>
          )}
        </div>
      </div>
    </MainLayout>
  );
};

export default VaultPage;