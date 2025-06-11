import React, { useEffect, useState } from 'react';
import api from '../../api/api';

interface User {
  id: number;
  email: string;
  full_name?: string;
  is_active: boolean;
  is_verified: boolean;
  is_admin: boolean;
  created_at: string;
}

const Users = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    api.get('/admin/users')
      .then(res => setUsers(res.data))
      .catch(() => setError('Failed to load users.'))
      .finally(() => setLoading(false));
  }, []);

  const handleDelete = async (id: number) => {
    if (!window.confirm('Are you sure you want to delete this user?')) return;
    try {
      await api.delete(`/admin/users/${id}`);
      setUsers(users.filter(u => u.id !== id));
    } catch {
      alert('Failed to delete user.');
    }
  };

  if (loading) return <div>Loading users...</div>;
  if (error) return <div className="text-red-600">{error}</div>;

  return (
    <div>
      <h2 className="text-xl font-bold mb-4">Users</h2>
      <table className="w-full bg-white rounded shadow">
        <thead>
          <tr>
            <th className="p-2">ID</th>
            <th className="p-2">Email</th>
            <th className="p-2">Name</th>
            <th className="p-2">Active</th>
            <th className="p-2">Verified</th>
            <th className="p-2">Admin</th>
            <th className="p-2">Created</th>
            <th className="p-2">Actions</th>
          </tr>
        </thead>
        <tbody>
          {users.map(user => (
            <tr key={user.id} className="border-t">
              <td className="p-2">{user.id}</td>
              <td className="p-2">{user.email}</td>
              <td className="p-2">{user.full_name || '-'}</td>
              <td className="p-2">{user.is_active ? 'Yes' : 'No'}</td>
              <td className="p-2">{user.is_verified ? 'Yes' : 'No'}</td>
              <td className="p-2">{user.is_admin ? 'Yes' : 'No'}</td>
              <td className="p-2">{new Date(user.created_at).toLocaleString()}</td>
              <td className="p-2">
                <button
                  className="bg-red-600 text-white px-3 py-1 rounded hover:bg-red-700"
                  onClick={() => handleDelete(user.id)}
                  disabled={user.is_admin}
                >
                  Delete
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default Users; 