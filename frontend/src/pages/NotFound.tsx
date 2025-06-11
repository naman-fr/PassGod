import React from 'react';
import { Link } from 'react-router-dom';

const NotFound = () => (
  <div className="min-h-screen flex flex-col items-center justify-center bg-gray-100">
    <h1 className="text-6xl font-bold text-blue-900 mb-4">404</h1>
    <p className="text-xl mb-6">Page not found.</p>
    <Link to="/" className="text-blue-600 hover:underline">Go Home</Link>
  </div>
);

export default NotFound; 