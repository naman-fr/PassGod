import React, { useEffect, useState } from 'react';
import api from '../../api/api';

interface BreachAlert {
  id: number;
  platform: string;
  breach_date: string;
  description: string;
  severity: string;
  is_resolved: boolean;
  user_id: number;
  created_at: string;
}

const Breaches = () => {
  const [breaches, setBreaches] = useState<BreachAlert[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    api.get('/admin/breaches')
      .then(res => setBreaches(res.data))
      .catch(() => setError('Failed to load breach alerts.'))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <div>Loading breach alerts...</div>;
  if (error) return <div className="text-red-600">{error}</div>;

  return (
    <div>
      <h2 className="text-xl font-bold mb-4">Breach Alerts</h2>
      <table className="w-full bg-white rounded shadow">
        <thead>
          <tr>
            <th className="p-2">ID</th>
            <th className="p-2">Platform</th>
            <th className="p-2">Date</th>
            <th className="p-2">Description</th>
            <th className="p-2">Severity</th>
            <th className="p-2">Resolved</th>
            <th className="p-2">User ID</th>
            <th className="p-2">Created</th>
          </tr>
        </thead>
        <tbody>
          {breaches.map(breach => (
            <tr key={breach.id} className="border-t">
              <td className="p-2">{breach.id}</td>
              <td className="p-2">{breach.platform}</td>
              <td className="p-2">{breach.breach_date}</td>
              <td className="p-2">{breach.description}</td>
              <td className="p-2">{breach.severity}</td>
              <td className="p-2">{breach.is_resolved ? 'Yes' : 'No'}</td>
              <td className="p-2">{breach.user_id}</td>
              <td className="p-2">{new Date(breach.created_at).toLocaleString()}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default Breaches; 