import React, { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import api from '../api/api';

const ShareView = () => {
  const { token } = useParams();
  const [data, setData] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!token) return;
    api.get(`/share/${token}`)
      .then(res => {
        setData(res.data.data);
        setLoading(false);
      })
      .catch(() => {
        setError('This share link is invalid, expired, or already used.');
        setLoading(false);
      });
  }, [token]);

  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-gray-100">
      <div className="bg-white rounded-lg shadow p-8 w-full max-w-md text-center">
        <h1 className="text-2xl font-bold mb-4">Shared Secret</h1>
        {loading && <div>Loading...</div>}
        {error && <div className="text-red-600">{error}</div>}
        {data && (
          <div className="bg-gray-100 p-4 rounded text-gray-800 break-all">
            {data}
          </div>
        )}
      </div>
    </div>
  );
};

export default ShareView; 