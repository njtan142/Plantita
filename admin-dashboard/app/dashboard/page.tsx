import withAuth from '@/components/auth/with-auth';
'use client';

import { useState } from 'react';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import { Users, FileText, HardDrive, Activity } from 'lucide-react';
import { StatsCard } from '@/components/dashboard/StatsCard';
import { UserGrowthChart } from '@/components/dashboard/UserGrowthChart';
import { MediaUploadChart } from '@/components/dashboard/MediaUploadChart';
import { RecentActivity } from '@/components/dashboard/RecentActivity';
import { QuickActions } from '@/components/dashboard/QuickActions';
import { LoadingSpinner } from '@/components/layout/LoadingSpinner';
import { ErrorAlert } from '@/components/layout/ErrorAlert';
import { dashboardService } from '@/services/dashboardService';
import { userService } from '@/services/userService';
import { mediaService } from '@/services/mediaService';
import { DashboardStats, Activity as ActivityType } from '@/types/api';

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
  const queryClient = useQueryClient();

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
        type: 'user_registered', // Default type, would be determined by activity.type in real implementation
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
    isError: userGrowthError, 
    error: userGrowthErrorMessage,
    refetch: refetchUserGrowth
  } = useQuery({
    queryKey: ['userGrowth'],
    queryFn: async () => {
      const response = await userService.getUserStats();
      if (!response.success) {
        throw new Error(response.error || 'Failed to fetch user stats');
      }
      
      // Transform user stats to chart data
      return response.data?.userGrowth || [];
    },
  });

  // Fetch media uploads data
  const { 
    data: mediaUploadsData, 
    isLoading: mediaUploadsLoading, 
    isError: mediaUploadsError, 
    error: mediaUploadsErrorMessage,
    refetch: refetchMediaUploads
  } = useQuery({
    queryKey: ['mediaUploads'],
    queryFn: async () => {
      const response = await mediaService.getMediaStats();
      if (!response.success) {
        throw new Error(response.error || 'Failed to fetch media stats');
      }
      
      // Transform media stats to chart data
      return response.data?.storageUsageTrend || [];
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

  const calculateTrend = (current: number, previous: number): { value: number; isPositive: boolean } => {
    if (previous === 0) return { value: 0, isPositive: true };
    const change = ((current - previous) / previous) * 100;
    return {
      value: Math.abs(Math.round(change)),
      isPositive: change >= 0
    };
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
