import React, { useState } from 'react';
import Users from './Users';
import Breaches from './Breaches';
// import Logs from './Logs'; // For future
// import Analytics from './Analytics'; // For future

const AdminDashboard = () => {
  const [tab, setTab] = useState<'users' | 'breaches'>('users');

  return (
    <div className="min-h-screen flex bg-gray-100">
      <aside className="w-64 bg-blue-900 text-white flex flex-col p-6">
        <h1 className="text-2xl font-bold mb-8">Admin Panel</h1>
        <button className={`mb-4 text-left px-2 py-2 rounded ${tab === 'users' ? 'bg-blue-700' : ''}`} onClick={() => setTab('users')}>Users</button>
        <button className={`mb-4 text-left px-2 py-2 rounded ${tab === 'breaches' ? 'bg-blue-700' : ''}`} onClick={() => setTab('breaches')}>Breaches</button>
        {/* <button className={`mb-4 text-left px-2 py-2 rounded ${tab === 'logs' ? 'bg-blue-700' : ''}`} onClick={() => setTab('logs')}>Logs</button> */}
        {/* <button className={`mb-4 text-left px-2 py-2 rounded ${tab === 'analytics' ? 'bg-blue-700' : ''}`} onClick={() => setTab('analytics')}>Analytics</button> */}
      </aside>
      <main className="flex-1 p-8">
        {tab === 'users' && <Users />}
        {tab === 'breaches' && <Breaches />}
        {/* {tab === 'logs' && <Logs />} */}
        {/* {tab === 'analytics' && <Analytics />} */}
      </main>
    </div>
  );
};

export default AdminDashboard; 