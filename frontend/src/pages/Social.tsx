import React, { useState, useEffect, useCallback } from 'react';
import { Link } from 'react-router-dom';
import MainLayout from '../components/Layout/MainLayout';
import { useAuth } from '../context/AuthContext';
import axios from 'axios';
import { Constants } from '../utils/constants';
import {
  PlusIcon,
  MagnifyingGlassIcon,
  ShieldExclamationIcon,
  ArrowPathIcon,
  TrashIcon,
} from '@heroicons/react/24/outline';

interface SocialAccount {
  id: string;
  platform: string;
  username: string;
  // email: string; // Removed as per backend model
  lastChecked?: string; // This might be a frontend-only display or derived
  status?: 'secure' | 'warning' | 'breached'; // This might be a frontend-only display or derived
}

const statusColors = {
  secure: 'bg-green-100 text-green-800',
  warning: 'bg-yellow-100 text-yellow-800',
  breached: 'bg-red-100 text-red-800',
};

const Social = () => {
  const [accounts, setAccounts] = useState<SocialAccount[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const { token } = useAuth();

  const API_URL = Constants.apiBaseUrl;

  const fetchSocialAccounts = useCallback(async () => {
    if (!token) {
      setLoading(false);
      setError('Authentication token not found. Please log in.');
      return;
    }
    try {
      const response = await axios.get(`${API_URL}/social/`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });
      // Map backend data to frontend interface, adding dummy status/lastChecked for now
      setAccounts(response.data.map((account: any) => ({
        ...account,
        status: 'secure', // Placeholder: will be determined by breach monitor
        lastChecked: 'just now', // Placeholder
      })));
      setError(null);
    } catch (err: any) {
      console.error('Failed to fetch social accounts:', err.response?.data || err.message);
      setError(err.response?.data?.detail || 'Failed to fetch social accounts');
      setAccounts([]);
    } finally {
      setLoading(false);
    }
  }, [token, API_URL]);

  useEffect(() => {
    fetchSocialAccounts();
  }, [fetchSocialAccounts]);

  const filteredAccounts = accounts.filter(
    (a) =>
      a.platform.toLowerCase().includes(searchQuery.toLowerCase()) ||
      a.username.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleDelete = async (accountId: string) => {
    if (!window.confirm('Are you sure you want to delete this social account?')) {
      return;
    }
    if (!token) {
      setError('Authentication token not found. Please log in.');
      return;
    }
    try {
      await axios.delete(`${API_URL}/social/${accountId}`, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });
      setAccounts(accounts.filter((a) => a.id !== accountId));
      setSuccess('Social account deleted successfully!');
      setTimeout(() => setSuccess(null), 3000);
    } catch (err: any) {
      console.error('Failed to delete social account:', err.response?.data || err.message);
      setError(err.response?.data?.detail || 'Failed to delete social account');
    }
  };

  return (
    <MainLayout>
      <div className="space-y-6">
        <div className="sm:flex sm:items-center sm:justify-between">
          <div>
            <h1 className="text-2xl font-semibold text-gray-900">Social Accounts</h1>
            <p className="mt-2 text-sm text-gray-700">
              Monitor and secure your social media accounts.
            </p>
          </div>
          <div className="mt-4 sm:mt-0">
            <Link
              to="/social/new"
              className="inline-flex items-center rounded-md bg-indigo-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
            >
              <PlusIcon className="-ml-0.5 mr-1.5 h-5 w-5" aria-hidden="true" />
              Add Account
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
            placeholder="Search accounts..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>

        {error && <p className="text-sm text-red-600 mt-2">{error}</p>}
        {success && <p className="text-sm text-green-600 mt-2">{success}</p>}

        {/* Account List */}
        <div className="overflow-hidden rounded-lg bg-white shadow">
          {loading ? (
            <div className="p-4 text-center text-gray-500">Loading social accounts...</div>
          ) : filteredAccounts.length === 0 ? (
            <div className="p-4 text-center text-gray-500">No social accounts found.</div>
          ) : (
            <ul className="divide-y divide-gray-200">
              {filteredAccounts.map((account) => (
                <li key={account.id} className="px-4 py-4 sm:px-6">
                  <div className="flex items-center justify-between">
                    <div className="flex min-w-0 flex-1 items-center">
                      <div className="min-w-0 flex-1">
                        <div className="flex items-center justify-between">
                          <p className="truncate text-sm font-medium text-indigo-600">
                            {account.platform}
                          </p>
                          <div className="ml-2 flex flex-shrink-0">
                            <p
                              className={`inline-flex rounded-full px-2 text-xs font-semibold leading-5 ${
                                statusColors[account.status || 'secure'] // Use 'secure' as default if status is undefined
                              }`}
                            >
                              {(account.status || 'secure').charAt(0).toUpperCase() + (account.status || 'secure').slice(1)}
                            </p>
                          </div>
                        </div>
                        <div className="mt-2 flex">
                          <div className="flex items-center text-sm text-gray-500">
                            <p>{account.username}</p>
                            {/* <span className="mx-2">•</span>
                            <p>{account.email}</p> */}
                          </div>
                        </div>
                      </div>
                    </div>
                    <div className="ml-4 flex flex-shrink-0 space-x-2">
                      <button
                        type="button"
                        className="inline-flex items-center rounded-md bg-white px-2.5 py-1.5 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
                        onClick={() => alert(`Perform security check for ${account.platform}`)} // Placeholder
                      >
                        <ShieldExclamationIcon className="h-5 w-5 text-gray-400" aria-hidden="true" />
                      </button>
                      <button
                        type="button"
                        className="inline-flex items-center rounded-md bg-white px-2.5 py-1.5 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
                        onClick={() => alert(`Refresh status for ${account.platform}`)} // Placeholder
                      >
                        <ArrowPathIcon className="h-5 w-5 text-gray-400" aria-hidden="true" />
                      </button>
                      <button
                        type="button"
                        className="inline-flex items-center rounded-md bg-white px-2.5 py-1.5 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50"
                        onClick={() => handleDelete(account.id)}
                      >
                        <TrashIcon className="h-5 w-5 text-gray-400" aria-hidden="true" />
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

export default Social; 