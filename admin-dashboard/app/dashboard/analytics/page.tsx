'use client';

import withAuth from '@/components/auth/with-auth';
import { useAnalyticsData } from '@/hooks/useAnalytics';
import { LoadingSpinner } from '@/components/layout/LoadingSpinner';
import { ErrorAlert } from '@/components/layout/ErrorAlert';
import { MetricCard } from '@/components/analytics';
import { DateRangeSelector } from '@/components/analytics';
import { AnalyticsChart } from '@/components/analytics';
import { Users, TrendingUp, FileText, HardDrive } from 'lucide-react';

function AnalyticsPage() {
  // Fetch analytics data using custom hook
  const { 
    data: analyticsData, 
    isLoading, 
    isError, 
    error,
    refetch 
  } = useAnalyticsData();

  const handleRefresh = () => {
    refetch();
  };

  const handleDateRangeChange = (value: string) => {
    // In a real implementation, this would trigger a refetch with new parameters
    console.log('Date range changed to:', value);
    // For now, we'll just refetch with the same data
    refetch();
  };

  const formatFileSize = (bytes: number): string => {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-96">
        <LoadingSpinner />
      </div>
    );
  }

  if (isError) {
    return (
      <div className="py-12">
        <ErrorAlert 
          title="Failed to load analytics data" 
          message={error?.message || 'An error occurred while loading analytics data. Please try again.'}
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

  // Calculate trends for metrics (in a real app, this would be based on historical data)
  const userGrowthTrend = { value: 12.5, isPositive: true };
  const mediaUploadsTrend = { value: 8.3, isPositive: true };
  const activeUsersTrend = { value: 5.2, isPositive: true };
  const storageTrend = { value: 3.7, isPositive: true };

  return (
    <div className="space-y-6">
      {/* Page Header with Date Range Selector */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Analytics</h1>
          <p className="text-gray-600">View platform analytics and insights.</p>
        </div>
        <DateRangeSelector onChange={handleDateRangeChange} />
      </div>

      {/* Platform Metrics */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <MetricCard
          title="Total Users"
          value={analyticsData?.platformMetrics.totalUsers.toLocaleString() || '0'}
          description="All registered users"
          icon={Users}
          trend={userGrowthTrend}
          loading={isLoading}
        />
        <MetricCard
          title="Active Users"
          value={analyticsData?.platformMetrics.activeUsers.toLocaleString() || '0'}
          description="Users active in selected period"
          icon={TrendingUp}
          trend={activeUsersTrend}
          loading={isLoading}
        />
        <MetricCard
          title="Total Media"
          value={analyticsData?.platformMetrics.totalMedia.toLocaleString() || '0'}
          description="All uploaded files"
          icon={FileText}
          trend={mediaUploadsTrend}
          loading={isLoading}
        />
        <MetricCard
          title="Storage Used"
          value={formatFileSize(analyticsData?.platformMetrics.storageUsed || 0)}
          description="Total storage consumption"
          icon={HardDrive}
          trend={storageTrend}
          loading={isLoading}
        />
      </div>

      {/* Charts Section */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <AnalyticsChart
          title="User Growth"
          data={analyticsData?.userGrowth.map(item => ({
            date: item.date,
            users: item.count
          })) || []}
          dataKeys={[
            { key: 'users', name: 'Users', color: '#3b82f6' }
          ]}
          chartType="line"
          loading={isLoading}
        />
        <AnalyticsChart
          title="Media Uploads"
          data={analyticsData?.mediaUploads.map(item => ({
            date: item.date,
            uploads: item.count
          })) || []}
          dataKeys={[
            { key: 'uploads', name: 'Uploads', color: '#10b981' }
          ]}
          chartType="bar"
          loading={isLoading}
        />
      </div>

      {/* Engagement Metrics */}
      <div className="grid grid-cols-1 gap-6">
        <AnalyticsChart
          title="Engagement Metrics"
          data={analyticsData?.engagementMetrics || []}
          dataKeys={[
            { key: 'likes', name: 'Likes', color: '#ef4444' },
            { key: 'comments', name: 'Comments', color: '#f59e0b' },
            { key: 'shares', name: 'Shares', color: '#8b5cf6' }
          ]}
          chartType="line"
          loading={isLoading}
        />
      </div>
    </div>
  );
}

export default withAuth(AnalyticsPage);