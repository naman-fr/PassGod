import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import MainLayout from '../../components/Layout/MainLayout';
import { useAuth } from '../../context/AuthContext';
import axios from 'axios';
import { Constants } from '../../utils/constants';

const supportedPlatforms = [
  "whatsapp", "instagram", "reddit", "discord", "facebook", "linkedin"
];

const NewSocialAccount = () => {
  const [platform, setPlatform] = useState('');
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);
  const navigate = useNavigate();
  const { token } = useAuth();

  const API_URL = Constants.apiBaseUrl;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setSuccess(null);

    if (!token) {
      setError('Authentication token not found. Please log in.');
      return;
    }

    if (!platform) {
      setError('Please select a platform.');
      return;
    }

    try {
      await axios.post(`${API_URL}/social/`, {
        platform,
        username,
        password,
      }, {
        headers: {
          Authorization: `Bearer ${token}`
        }
      });
      setSuccess('Social account added successfully!');
      setTimeout(() => navigate('/social'), 2000);
    } catch (err: any) {
      setError(err.response?.data?.detail || 'Failed to add social account');
    }
  };

  return (
    <MainLayout>
      <div className="space-y-6 max-w-2xl mx-auto p-4 sm:p-6 lg:p-8 bg-white shadow rounded-lg">
        <h1 className="text-2xl font-semibold text-gray-900">Add New Social Account</h1>
        <p className="mt-2 text-sm text-gray-700">Fill in the details to securely store a new social account.</p>
        
        {error && <p className="text-sm text-red-600">{error}</p>}
        {success && <p className="text-sm text-green-600">{success}</p>}

        <form onSubmit={handleSubmit} className="space-y-6">
          <div>
            <label htmlFor="platform" className="block text-sm font-medium leading-6 text-gray-900">Platform</label>
            <div className="mt-2">
              <select
                id="platform"
                name="platform"
                value={platform}
                onChange={(e) => setPlatform(e.target.value)}
                required
                className="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
              >
                <option value="">Select a platform</option>
                {supportedPlatforms.map((p) => (
                  <option key={p} value={p}>{p.charAt(0).toUpperCase() + p.slice(1)}</option>
                ))}
              </select>
            </div>
          </div>

          <div>
            <label htmlFor="username" className="block text-sm font-medium leading-6 text-gray-900">Username/Email</label>
            <div className="mt-2">
              <input
                type="text"
                name="username"
                id="username"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                required
                className="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
              />
            </div>
          </div>

          <div>
            <label htmlFor="password" className="block text-sm font-medium leading-6 text-gray-900">Password</label>
            <div className="mt-2">
              <input
                type="password"
                name="password"
                id="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                className="block w-full rounded-md border-0 py-1.5 text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-indigo-600 sm:text-sm sm:leading-6"
              />
            </div>
          </div>

          <div>
            <button
              type="submit"
              className="flex w-full justify-center rounded-md bg-indigo-600 px-3 py-1.5 text-sm font-semibold leading-6 text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
            >
              Add Social Account
            </button>
          </div>
        </form>
      </div>
    </MainLayout>
  );
};

export default NewSocialAccount; 