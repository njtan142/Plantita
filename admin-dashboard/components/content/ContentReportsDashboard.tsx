'use client';

import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Skeleton } from '@/components/ui/skeleton';
import { Alert, AlertTitle, AlertDescription } from '@/components/ui/alert';
import { Button } from '@/components/ui/button';
import { 
  TrendingUp, 
  Users, 
  Image as ImageIcon,
  Flag,
  Download
} from 'lucide-react';
import { reportingService } from '@/services/reportingService';
import { UserGrowthReport, MediaTrendsReport, ModerationStats } from '@/types/api';
import { AlertCircle } from 'lucide-react';
import { SummaryCards } from './reports-dashboard/SummaryCards';
import { OverviewTab } from './reports-dashboard/OverviewTab';
import { UserGrowthTab } from './reports-dashboard/UserGrowthTab';
import { MediaTrendsTab } from './reports-dashboard/MediaTrendsTab';
import { ModerationTab } from './reports-dashboard/ModerationTab';

interface ContentReportsDashboardProps {
  dateRange?: {
    start: string;
    end: string;
  };
}

export function ContentReportsDashboard({ dateRange }: ContentReportsDashboardProps) {
  const [userGrowthReport, setUserGrowthReport] = useState<UserGrowthReport | null>(null);
  const [mediaTrendsReport, setMediaTrendsReport] = useState<MediaTrendsReport | null>(null);
  const [moderationStats, setModerationStats] = useState<ModerationStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState('overview');

  useEffect(() => {
    fetchAllReports();
  }, []);

  const fetchAllReports = async () => {
    try {
      setLoading(true);
      setError(null);

      // Fetch all reports in parallel
      const [userGrowthResponse, mediaTrendsResponse, moderationResponse] = await Promise.all([
        reportingService.getUserGrowthReport(),
        reportingService.getMediaTrendsReport(),
        reportingService.getModerationStats()
      ]);

      if (userGrowthResponse.success && userGrowthResponse.data) {
        setUserGrowthReport(userGrowthResponse.data);
      } else {
        console.error('Failed to fetch user growth report:', userGrowthResponse.message);
      }

      if (mediaTrendsResponse.success && mediaTrendsResponse.data) {
        setMediaTrendsReport(mediaTrendsResponse.data);
      } else {
        console.error('Failed to fetch media trends report:', mediaTrendsResponse.message);
      }

      if (moderationResponse.success && moderationResponse.data) {
        setModerationStats(moderationResponse.data);
      } else {
        console.error('Failed to fetch moderation stats:', moderationResponse.message);
      }
    } catch (err) {
      console.error('Error fetching reports:', err);
      setError('An unexpected error occurred while fetching reports');
    } finally {
      setLoading(false);
    }
  };

  const handleRetry = () => {
    fetchAllReports();
  };

  const handleExport = (format: 'csv' | 'pdf') => {
    // In a real implementation, this would trigger the export functionality
    console.log(`Exporting reports as ${format.toUpperCase()}`);
    alert(`Export functionality would export reports as ${format.toUpperCase()} in a real implementation`);
  };

  // Calculate summary statistics from the reports
  const totalUsers = userGrowthReport?.activeUsers?.monthly || 0;
  const totalMediaUploads = mediaTrendsReport 
    ? Object.values(mediaTrendsReport.uploadsByCategory || {}).reduce((sum, count) => sum + (count || 0), 0)
    : 0;
  const totalFlaggedContent = moderationStats?.totalFlagged || 0;
  
  const dailyRegistrations = userGrowthReport?.dailyRegistrations?.slice(-7) || [];
  const recentRegistrations = dailyRegistrations.length > 0 
    ? dailyRegistrations[dailyRegistrations.length - 1]?.count || 0 
    : 0;

  if (error) {
    return (
      <Alert variant="destructive">
        <AlertCircle className="h-4 w-4" />
        <AlertTitle>Error</AlertTitle>
        <AlertDescription className="flex items-center justify-between">
          <span>{error}</span>
          <Button variant="outline" onClick={handleRetry} className="ml-4">
            Retry
          </Button>
        </AlertDescription>
      </Alert>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header with export options */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h2 className="text-3xl font-bold tracking-tight">Content Reports</h2>
          <p className="text-muted-foreground">
            Overview of key content metrics and platform analytics
          </p>
        </div>
        <div className="flex gap-2">
          <Button variant="outline" onClick={() => handleExport('csv')}>
            <Download className="mr-2 h-4 w-4" />
            Export CSV
          </Button>
          <Button variant="outline" onClick={() => handleExport('pdf')}>
            <Download className="mr-2 h-4 w-4" />
            Export PDF
          </Button>
        </div>
      </div>

      {/* Summary Cards */}
      <SummaryCards
        loading={loading}
        totalUsers={totalUsers}
        totalMediaUploads={totalMediaUploads}
        recentRegistrations={recentRegistrations}
        totalFlaggedContent={totalFlaggedContent}
      />

      {/* Tabs for different report views */}
      <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-4">
        <TabsList>
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="user-growth">User Growth</TabsTrigger>
          <TabsTrigger value="media-trends">Media Trends</TabsTrigger>
          <TabsTrigger value="moderation">Moderation</TabsTrigger>
        </TabsList>
        
        <TabsContent value="overview" className="space-y-4">
          <OverviewTab loading={loading} />
        </TabsContent>
        
        <TabsContent value="user-growth" className="space-y-4">
          <UserGrowthTab loading={loading} userGrowthReport={userGrowthReport} />
        </TabsContent>
        
        <TabsContent value="media-trends" className="space-y-4">
          <MediaTrendsTab loading={loading} mediaTrendsReport={mediaTrendsReport} />
        </TabsContent>
        
        <TabsContent value="moderation" className="space-y-4">
          <ModerationTab loading={loading} moderationStats={moderationStats} />
        </TabsContent>
      </Tabs>
    </div>
  );
}