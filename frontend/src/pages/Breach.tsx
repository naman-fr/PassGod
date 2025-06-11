import React, { useState, useEffect, useCallback } from 'react';
import { toast } from 'react-toastify';
import { checkPasswordsForBreach, checkEmailForBreach, getBreachAlerts, resolveBreachAlert } from '../services/api';
import { BreachAlert } from '../types';

const Breach: React.FC = () => {
  const [alerts, setAlerts] = useState<BreachAlert[]>([]);
  const [loading, setLoading] = useState(false);

  const fetchBreachAlerts = useCallback(async () => {
    setLoading(true);
    try {
      const response = await getBreachAlerts();
      setAlerts(response.data);
    } catch (error) {
      toast.error('Failed to fetch breach alerts.');
      console.error('Error fetching breach alerts:', error);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchBreachAlerts();
  }, [fetchBreachAlerts]);

  const handleCheckPasswords = async () => {
    setLoading(true);
    try {
      await checkPasswordsForBreach();
      toast.success('Password breach check initiated. Alerts will appear shortly.');
      await fetchBreachAlerts();
    } catch (error) {
      toast.error('Failed to initiate password breach check.');
      console.error('Error checking passwords:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleCheckEmail = async () => {
    setLoading(true);
    try {
      await checkEmailForBreach();
      toast.success('Email breach check initiated. Alerts will appear shortly.');
      await fetchBreachAlerts();
    } catch (error) {
      toast.error('Failed to initiate email breach check.');
      console.error('Error checking email:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleResolveAlert = async (alertId: string) => {
    try {
      await resolveBreachAlert(alertId);
      toast.success('Breach alert marked as resolved.');
      await fetchBreachAlerts();
    } catch (error) {
      toast.error('Failed to resolve breach alert.');
      console.error('Error resolving alert:', error);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 p-8">
      <h1 className="text-3xl font-bold mb-6 text-gray-800">Breach Monitor</h1>
      <p className="text-lg mb-8 text-gray-600">Check if your credentials have been leaked in a data breach and manage your alerts.</p>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
        <div className="bg-white p-6 rounded-lg shadow-md">
          <h2 className="text-xl font-semibold mb-4 text-gray-700">Check Passwords</h2>
          <p className="text-gray-600 mb-4">Scan all your stored passwords for known data breaches using the HaveIBeenPwned database.</p>
          <button
            onClick={handleCheckPasswords}
            disabled={loading}
            className="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-opacity-50 disabled:opacity-50"
          >
            {loading ? 'Checking...' : 'Check My Passwords'}
          </button>
        </div>

        <div className="bg-white p-6 rounded-lg shadow-md">
          <h2 className="text-xl font-semibold mb-4 text-gray-700">Check Email</h2>
          <p className="text-gray-600 mb-4">Scan your registered email address for exposure in data breaches.</p>
          <button
            onClick={handleCheckEmail}
            disabled={loading}
            className="w-full bg-green-600 text-white py-2 px-4 rounded-md hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-green-500 focus:ring-opacity-50 disabled:opacity-50"
          >
            {loading ? 'Checking...' : 'Check My Email'}
          </button>
        </div>
      </div>

      <div className="bg-white p-6 rounded-lg shadow-md">
        <h2 className="text-xl font-semibold mb-4 text-gray-700">Breach Alerts</h2>
        {loading && alerts.length === 0 ? (
          <p className="text-gray-500">Loading alerts...</p>
        ) : alerts.length === 0 ? (
          <p className="text-gray-500">No breach alerts found. You're safe!</p>
        ) : (
          <div className="space-y-4">
            {alerts.map((alert) => (
              <div key={alert.id} className="border border-gray-200 p-4 rounded-md flex items-center justify-between">
                <div>
                  <p className="font-semibold text-gray-800">Platform: {alert.platform}</p>
                  <p className="text-gray-700">Description: {alert.description}</p>
                  <p className="text-sm text-gray-500">Severity: <span className={`${alert.severity === 'high' ? 'text-red-500' : alert.severity === 'medium' ? 'text-orange-500' : 'text-gray-500'} font-medium`}>{alert.severity}</span></p>
                  <p className="text-sm text-gray-500">Breach Date: {new Date(alert.breach_date).toLocaleDateString()}</p>
                </div>
                {!alert.is_resolved && (
                  <button
                    onClick={() => handleResolveAlert(alert.id)}
                    className="ml-4 bg-yellow-500 text-white py-1 px-3 rounded-md hover:bg-yellow-600 focus:outline-none focus:ring-2 focus:ring-yellow-400 focus:ring-opacity-50"
                  >
                    Resolve
                  </button>
                )}
                {alert.is_resolved && (
                  <span className="ml-4 text-green-600 font-semibold">Resolved</span>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default Breach; 