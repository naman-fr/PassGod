import React from 'react';
import { Link } from 'react-router-dom';
import MainLayout from '../components/Layout/MainLayout';
import {
  ShieldCheckIcon,
  ExclamationTriangleIcon,
  KeyIcon,
  UserGroupIcon,
} from '@heroicons/react/24/outline';

const stats = [
  { name: 'Total Passwords', value: '24', icon: KeyIcon, color: 'bg-blue-500' },
  { name: 'Social Accounts', value: '8', icon: UserGroupIcon, color: 'bg-green-500' },
  { name: 'Security Score', value: '85%', icon: ShieldCheckIcon, color: 'bg-yellow-500' },
  { name: 'Active Alerts', value: '2', icon: ExclamationTriangleIcon, color: 'bg-red-500' },
];

const recentActivity = [
  {
    id: 1,
    type: 'password_update',
    title: 'Updated Instagram password',
    time: '2 hours ago',
    icon: KeyIcon,
  },
  {
    id: 2,
    type: 'breach_alert',
    title: 'New breach detected for LinkedIn',
    time: '5 hours ago',
    icon: ExclamationTriangleIcon,
  },
  {
    id: 3,
    type: 'account_added',
    title: 'Added Twitter account',
    time: '1 day ago',
    icon: UserGroupIcon,
  },
];

const quickActions = [
  {
    name: 'Add Password',
    description: 'Store a new password securely',
    href: '/vault/new',
    icon: KeyIcon,
  },
  {
    name: 'Add Social Account',
    description: 'Connect a social media account',
    href: '/social/new',
    icon: UserGroupIcon,
  },
  {
    name: 'Check Breaches',
    description: 'Scan for compromised accounts',
    href: '/breach/scan',
    icon: ExclamationTriangleIcon,
  },
];

const Dashboard = () => {
  return (
    <MainLayout>
      <div className="space-y-6">
        {/* Stats */}
        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-4">
          {stats.map((stat) => (
            <div
              key={stat.name}
              className="relative overflow-hidden rounded-lg bg-white px-4 py-5 shadow sm:px-6 sm:py-6"
            >
              <dt>
                <div className={`absolute rounded-md ${stat.color} p-3`}>
                  <stat.icon className="h-6 w-6 text-white" aria-hidden="true" />
                </div>
                <p className="ml-16 truncate text-sm font-medium text-gray-500">{stat.name}</p>
              </dt>
              <dd className="ml-16 flex items-baseline">
                <p className="text-2xl font-semibold text-gray-900">{stat.value}</p>
              </dd>
            </div>
          ))}
        </div>

        {/* Quick Actions */}
        <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {quickActions.map((action) => (
            <Link
              key={action.name}
              to={action.href}
              className="relative flex items-center space-x-3 rounded-lg border border-gray-300 bg-white px-6 py-5 shadow-sm hover:border-gray-400"
            >
              <div className="flex-shrink-0">
                <action.icon className="h-6 w-6 text-gray-400" aria-hidden="true" />
              </div>
              <div className="min-w-0 flex-1">
                <span className="absolute inset-0" aria-hidden="true" />
                <p className="text-sm font-medium text-gray-900">{action.name}</p>
                <p className="truncate text-sm text-gray-500">{action.description}</p>
              </div>
            </Link>
          ))}
        </div>

        {/* Recent Activity */}
        <div className="overflow-hidden rounded-lg bg-white shadow">
          <div className="p-6">
            <h3 className="text-base font-semibold leading-6 text-gray-900">Recent Activity</h3>
            <div className="mt-6 flow-root">
              <ul className="-my-5 divide-y divide-gray-200">
                {recentActivity.map((activity) => (
                  <li key={activity.id} className="py-4">
                    <div className="flex items-center space-x-4">
                      <div className="flex-shrink-0">
                        <activity.icon className="h-5 w-5 text-gray-400" aria-hidden="true" />
                      </div>
                      <div className="min-w-0 flex-1">
                        <p className="truncate text-sm font-medium text-gray-900">{activity.title}</p>
                        <p className="truncate text-sm text-gray-500">{activity.time}</p>
                      </div>
                    </div>
                  </li>
                ))}
              </ul>
            </div>
          </div>
        </div>
      </div>
    </MainLayout>
  );
};

export default Dashboard; 