'use client';

import withAuth from '@/components/auth/with-auth';
import { useQuery } from '@tanstack/react-query';
import { Users, FileText, HardDrive, Activity } from 'lucide-react';
import { StatsCard } from '@/components/dashboard/StatsCard';
import { UserGrowthChart } from '@/components/dashboard/UserGrowthChart';
import { MediaUploadChart } from '@/components/dashboard/MediaUploadChart';
import { RecentActivity } from '@/components/dashboard/RecentActivity';
import { QuickActions } from '@/components/dashboard/QuickActions';
import { LoadingSpinner } from '@/components/layout/LoadingSpinner';
import { ErrorAlert } from '@/components/layout/ErrorAlert';
import { dashboardService } from '@/services/dashboardService';

function DashboardPage() {
  // Fetch dashboard stats using TanStack Query
  const { 
    data: stats, 
    isLoading: statsLoading, 
    isError: statsError, 
    error: statsErrorMessage,
    refetch: refetchStats
  } = useQuery({
    queryKey: ['dashboardStats'],
    queryFn: async () => {
      const response = await dashboardService.getDashboardStats();
      if (!response.success) {
        throw new Error(response.error || 'Failed to fetch dashboard stats');
      }
      return response.data;
    },
  });

  // Fetch recent activities using TanStack Query
  const { 
    data: activities, 
    isLoading: activitiesLoading, 
    isError: activitiesError, 
    error: activitiesErrorMessage,
    refetch: refetchActivities
  } = useQuery({
    queryKey: ['recentActivities'],
    queryFn: async () => {
      const response = await dashboardService.getRecentActivities();
      if (!response.success) {
        throw new Error(response.error || 'Failed to fetch recent activities');
      }
      // Convert API Activity to ActivityItem for UI
      return response.data?.map(activity => ({
        id: activity.id,
        type: 'user_registered' as const, // Default type, would be determined by activity.type in real implementation
        title: activity.type,
        description: activity.description,
        timestamp: activity.timestamp,
      })) || [];
    },
  });

  // Fetch user growth data
  const { 
    data: userGrowthData, 
    isLoading: userGrowthLoading, 
    refetch: refetchUserGrowth
  } = useQuery({
    queryKey: ['userGrowth'],
    queryFn: async () => {
      // In a real implementation, this would fetch actual user growth data
      // For now, we'll return mock data that matches the expected format
      return [
        { date: '2024-01', users: 1200 },
        { date: '2024-02', users: 1350 },
        { date: '2024-03', users: 1480 },
        { date: '2024-04', users: 1620 },
        { date: '2024-05', users: 1780 },
        { date: '2024-06', users: 1950 },
      ];
    },
  });

  // Fetch media uploads data
  const { 
    data: mediaUploadsData, 
    isLoading: mediaUploadsLoading, 
    refetch: refetchMediaUploads
  } = useQuery({
    queryKey: ['mediaUploads'],
    queryFn: async () => {
      // In a real implementation, this would fetch actual media upload data
      // For now, we'll return mock data that matches the expected format
      return [
        { date: '2024-01', uploads: 450 },
        { date: '2024-02', uploads: 520 },
        { date: '2024-03', uploads: 480 },
        { date: '2024-04', uploads: 610 },
        { date: '2024-05', uploads: 580 },
        { date: '2024-06', uploads: 720 },
      ];
    },
  });

  const handleRefresh = () => {
    refetchStats();
    refetchActivities();
    refetchUserGrowth();
    refetchMediaUploads();
  };

  const formatFileSize = (bytes: number): string => {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  };

  // Show loading state if any critical data is loading
  const loading = statsLoading || activitiesLoading;
  
  // Show error if any critical data failed to load
  const hasError = statsError || activitiesError;
  const errorMessage = statsErrorMessage?.message || activitiesErrorMessage?.message;

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-96">
        <LoadingSpinner />
      </div>
    );
  }

  if (hasError) {
    return (
      <div className="py-12">
        <ErrorAlert 
          title="Failed to load dashboard data" 
          message={errorMessage || 'An error occurred while loading dashboard data. Please try again.'}
        />
        <div className="text-center mt-4">
          <button
            onClick={handleRefresh}
            className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
          >
            Retry
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
          <p className="text-gray-600">Welcome back! Here&apos;s what&apos;s happening with your platform today.</p>
        </div>
      </div>

      {/* Statistics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <StatsCard
          title="Total Users"
          value={stats?.totalUsers.toLocaleString() || '0'}
          description="All registered users"
          icon={Users}
          loading={statsLoading}
        />
        <StatsCard
          title="Active Users"
          value={stats?.activeUsers.toLocaleString() || '0'}
          description="Users active in last 30 days"
          icon={Activity}
          loading={statsLoading}
        />
        <StatsCard
          title="Total Media"
          value={stats?.totalMedia.toLocaleString() || '0'}
          description="All uploaded files"
          icon={FileText}
          loading={statsLoading}
        />
        <StatsCard
          title="Storage Used"
          value={formatFileSize(stats?.storageUsed || 0)}
          description="Total storage consumption"
          icon={HardDrive}
          loading={statsLoading}
        />
      </div>

      {/* Charts Section */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <UserGrowthChart
          data={userGrowthData || []}
          loading={userGrowthLoading}
        />
        <MediaUploadChart
          data={mediaUploadsData || []}
          loading={mediaUploadsLoading}
        />
      </div>

      {/* Bottom Section */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2">
          <RecentActivity activities={activities || []} loading={activitiesLoading} />
        </div>
        <div>
          <QuickActions onRefresh={handleRefresh} loading={loading} />
        </div>
      </div>
    </div>
  );
}

export default withAuth(DashboardPage);
