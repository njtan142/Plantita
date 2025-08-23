import withAuth from '@/components/auth/with-auth';
'use client';

import { useState, useEffect } from 'react';
import { Users, FileText, HardDrive, Activity } from 'lucide-react';
import { StatsCard } from '@/components/dashboard/StatsCard';
import { UserGrowthChart } from '@/components/dashboard/UserGrowthChart';
import { MediaUploadChart } from '@/components/dashboard/MediaUploadChart';
import { RecentActivity } from '@/components/dashboard/RecentActivity';
import { QuickActions } from '@/components/dashboard/QuickActions';
import { LoadingSpinner } from '@/components/layout/LoadingSpinner';
import { userService } from '@/services/userService';
import { mediaService } from '@/services/mediaService';
import { DashboardStats } from '@/types/api';

interface UserStats {
  totalUsers: number;
  activeUsers: number;
  inactiveUsers: number;
  suspendedUsers: number;
  bannedUsers: number;
  usersByRole: Record<string, number>;
  recentRegistrations: number;
}

interface MediaStats {
  totalCount: number;
  totalSize: number;
  countByType: Record<string, number>;
  countByStatus: Record<string, number>;
  recentUploads: number;
  storageUsageTrend: Array<{
    date: string;
    size: number;
  }>;
}

interface ActivityItem {
  id: string;
  type: 'user_registered' | 'media_uploaded' | 'user_login' | 'media_approved' | 'media_rejected';
  title: string;
  description: string;
  timestamp: string;
  user?: {
    id: string;
    name: string;
    avatar?: string;
  };
}

function DashboardPage() {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [userStats, setUserStats] = useState<UserStats | null>(null);
  const [mediaStats, setMediaStats] = useState<MediaStats | null>(null);
  const [activities, setActivities] = useState<ActivityItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchDashboardData = async () => {
    try {
      setLoading(true);
      setError(null);

      // Fetch all data in parallel
      const [userStatsResponse, mediaStatsResponse] = await Promise.all([
        userService.getUserStats(),
        mediaService.getMediaStats(),
      ]);

      if (userStatsResponse.success && userStatsResponse.data) {
        setUserStats(userStatsResponse.data);
      }

      if (mediaStatsResponse.success && mediaStatsResponse.data) {
        setMediaStats(mediaStatsResponse.data);
      }

      // Calculate dashboard stats
      const dashboardStats: DashboardStats = {
        totalUsers: userStatsResponse.data?.totalUsers || 0,
        activeUsers: userStatsResponse.data?.activeUsers || 0,
        totalMedia: mediaStatsResponse.data?.totalCount || 0,
        recentUploads: mediaStatsResponse.data?.recentUploads || 0,
        storageUsed: mediaStatsResponse.data?.totalSize || 0,
        systemHealth: 'healthy' as const,
      };

      setStats(dashboardStats);

      // Mock recent activities (in a real app, this would come from an API)
      const mockActivities: ActivityItem[] = [
        {
          id: '1',
          type: 'user_registered',
          title: 'New user registered',
          description: 'John Doe joined the platform',
          timestamp: new Date(Date.now() - 1000 * 60 * 30).toISOString(), // 30 minutes ago
          user: { id: '1', name: 'John Doe' }
        },
        {
          id: '2',
          type: 'media_uploaded',
          title: 'Media uploaded',
          description: 'New image uploaded by Jane Smith',
          timestamp: new Date(Date.now() - 1000 * 60 * 60 * 2).toISOString(), // 2 hours ago
          user: { id: '2', name: 'Jane Smith' }
        },
        {
          id: '3',
          type: 'media_approved',
          title: 'Media approved',
          description: 'Image approved for public viewing',
          timestamp: new Date(Date.now() - 1000 * 60 * 60 * 4).toISOString(), // 4 hours ago
        },
        {
          id: '4',
          type: 'user_login',
          title: 'User login',
          description: 'Admin user logged in',
          timestamp: new Date(Date.now() - 1000 * 60 * 60 * 6).toISOString(), // 6 hours ago
          user: { id: '3', name: 'Admin User' }
        },
        {
          id: '5',
          type: 'media_rejected',
          title: 'Media rejected',
          description: 'Video content violated guidelines',
          timestamp: new Date(Date.now() - 1000 * 60 * 60 * 8).toISOString(), // 8 hours ago
        }
      ];

      setActivities(mockActivities);

    } catch (err) {
      console.error('Error fetching dashboard data:', err);
      setError('Failed to load dashboard data. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const formatFileSize = (bytes: number): string => {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  };

  const calculateTrend = (current: number, previous: number): { value: number; isPositive: boolean } => {
    if (previous === 0) return { value: 0, isPositive: true };
    const change = ((current - previous) / previous) * 100;
    return {
      value: Math.abs(Math.round(change)),
      isPositive: change >= 0
    };
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-96">
        <LoadingSpinner />
      </div>
    );
  }

  if (error) {
    return (
      <div className="text-center py-12">
        <p className="text-red-600 mb-4">{error}</p>
        <button
          onClick={fetchDashboardData}
          className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
        >
          Retry
        </button>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
          <p className="text-gray-600">Welcome back! Here's what's happening with your platform today.</p>
        </div>
      </div>

      {/* Statistics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatsCard
          title="Total Users"
          value={stats?.totalUsers.toLocaleString() || '0'}
          description="All registered users"
          icon={Users}
          trend={userStats ? calculateTrend(userStats.recentRegistrations, userStats.totalUsers - userStats.recentRegistrations) : undefined}
          loading={loading}
        />
        <StatsCard
          title="Active Users"
          value={stats?.activeUsers.toLocaleString() || '0'}
          description="Users active in last 30 days"
          icon={Activity}
          trend={userStats ? calculateTrend(userStats.activeUsers, userStats.totalUsers - userStats.activeUsers) : undefined}
          loading={loading}
        />
        <StatsCard
          title="Total Media"
          value={stats?.totalMedia.toLocaleString() || '0'}
          description="All uploaded files"
          icon={FileText}
          trend={mediaStats ? calculateTrend(mediaStats.recentUploads, mediaStats.totalCount - mediaStats.recentUploads) : undefined}
          loading={loading}
        />
        <StatsCard
          title="Storage Used"
          value={formatFileSize(stats?.storageUsed || 0)}
          description="Total storage consumption"
          icon={HardDrive}
          trend={mediaStats ? calculateTrend(mediaStats.totalSize, mediaStats.totalSize - (mediaStats.storageUsageTrend[0]?.size || 0)) : undefined}
          loading={loading}
        />
      </div>

      {/* Charts Section */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <UserGrowthChart
          data={[
            { date: '2024-01', users: 1200 },
            { date: '2024-02', users: 1350 },
            { date: '2024-03', users: 1480 },
            { date: '2024-04', users: 1620 },
            { date: '2024-05', users: 1780 },
            { date: '2024-06', users: 1950 },
          ]}
          loading={loading}
        />
        <MediaUploadChart
          data={[
            { date: '2024-01', uploads: 450 },
            { date: '2024-02', uploads: 520 },
            { date: '2024-03', uploads: 480 },
            { date: '2024-04', uploads: 610 },
            { date: '2024-05', uploads: 580 },
            { date: '2024-06', uploads: 720 },
          ]}
          loading={loading}
        />
      </div>

      {/* Bottom Section */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2">
          <RecentActivity activities={activities} loading={loading} />
        </div>
        <div>
          <QuickActions onRefresh={fetchDashboardData} loading={loading} />
        </div>
      </div>
    </div>
  );
}

export default withAuth(DashboardPage);
