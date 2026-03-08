'use client';

import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Skeleton } from '@/components/ui/skeleton';
import { Alert, AlertTitle, AlertDescription } from '@/components/ui/alert';
import { Button } from '@/components/ui/button';
import { 
  BarChart, 
  BarChartIcon, 
  PieChart, 
  PieChartIcon, 
  TrendingUp, 
  Users, 
  Image as ImageIcon,
  Flag,
  Calendar,
  Download
} from 'lucide-react';
import { reportingService } from '@/services/reportingService';
import { UserGrowthReport, MediaTrendsReport, ModerationStats } from '@/types/api';
import { AlertCircle } from 'lucide-react';

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
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total Users</CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            {loading ? (
              <Skeleton className="h-8 w-16" />
            ) : (
              <div className="text-2xl font-bold">{totalUsers.toLocaleString()}</div>
            )}
            <p className="text-xs text-muted-foreground">Active users this month</p>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Media Uploads</CardTitle>
            <ImageIcon className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            {loading ? (
              <Skeleton className="h-8 w-16" />
            ) : (
              <div className="text-2xl font-bold">{totalMediaUploads.toLocaleString()}</div>
            )}
            <p className="text-xs text-muted-foreground">Total uploads</p>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">New Registrations</CardTitle>
            <TrendingUp className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            {loading ? (
              <Skeleton className="h-8 w-16" />
            ) : (
              <div className="text-2xl font-bold">{recentRegistrations}</div>
            )}
            <p className="text-xs text-muted-foreground">Today&apos;s new users</p>
          </CardContent>
        </Card>
        
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Flagged Content</CardTitle>
            <Flag className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            {loading ? (
              <Skeleton className="h-8 w-16" />
            ) : (
              <div className="text-2xl font-bold">{totalFlaggedContent}</div>
            )}
            <p className="text-xs text-muted-foreground">Pending moderation</p>
          </CardContent>
        </Card>
      </div>

      {/* Tabs for different report views */}
      <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-4">
        <TabsList>
          <TabsTrigger value="overview">Overview</TabsTrigger>
          <TabsTrigger value="user-growth">User Growth</TabsTrigger>
          <TabsTrigger value="media-trends">Media Trends</TabsTrigger>
          <TabsTrigger value="moderation">Moderation</TabsTrigger>
        </TabsList>
        
        <TabsContent value="overview" className="space-y-4">
          <div className="grid gap-4 md:grid-cols-2">
            {/* User Growth Chart Placeholder */}
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <BarChartIcon className="h-5 w-5" />
                  Recent User Growth
                </CardTitle>
              </CardHeader>
              <CardContent>
                {loading ? (
                  <div className="h-64 flex items-center justify-center">
                    <Skeleton className="h-64 w-full" />
                  </div>
                ) : (
                  <div className="h-64 flex items-center justify-center bg-muted rounded-lg">
                    <p className="text-muted-foreground">User Growth Chart Visualization</p>
                  </div>
                )}
              </CardContent>
            </Card>
            
            {/* Media Categories Chart Placeholder */}
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <PieChartIcon className="h-5 w-5" />
                  Media by Category
                </CardTitle>
              </CardHeader>
              <CardContent>
                {loading ? (
                  <div className="h-64 flex items-center justify-center">
                    <Skeleton className="h-64 w-full" />
                  </div>
                ) : (
                  <div className="h-64 flex items-center justify-center bg-muted rounded-lg">
                    <p className="text-muted-foreground">Media Categories Chart Visualization</p>
                  </div>
                )}
              </CardContent>
            </Card>
          </div>
        </TabsContent>
        
        <TabsContent value="user-growth" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>User Growth Report</CardTitle>
            </CardHeader>
            <CardContent>
              {loading ? (
                <div className="space-y-2">
                  <Skeleton className="h-4 w-full" />
                  <Skeleton className="h-4 w-5/6" />
                  <Skeleton className="h-4 w-4/6" />
                </div>
              ) : userGrowthReport ? (
                <div className="space-y-4">
                  <div>
                    <h3 className="font-medium">Daily Registrations (Last 7 Days)</h3>
                    <div className="mt-2 space-y-1">
                      {userGrowthReport.dailyRegistrations.slice(-7).map((reg, index) => (
                        <div key={index} className="flex justify-between text-sm">
                          <span>{reg.date}</span>
                          <span>{reg.count} users</span>
                        </div>
                      ))}
                    </div>
                  </div>
                  <div>
                    <h3 className="font-medium">Retention Rate</h3>
                    <div className="mt-2 grid grid-cols-3 gap-4">
                      <div className="bg-muted p-3 rounded-lg text-center">
                        <div className="text-2xl font-bold">{(userGrowthReport.retentionRate.day1 * 100).toFixed(1)}%</div>
                        <div className="text-xs text-muted-foreground">Day 1</div>
                      </div>
                      <div className="bg-muted p-3 rounded-lg text-center">
                        <div className="text-2xl font-bold">{(userGrowthReport.retentionRate.day7 * 100).toFixed(1)}%</div>
                        <div className="text-xs text-muted-foreground">Day 7</div>
                      </div>
                      <div className="bg-muted p-3 rounded-lg text-center">
                        <div className="text-2xl font-bold">{(userGrowthReport.retentionRate.day30 * 100).toFixed(1)}%</div>
                        <div className="text-xs text-muted-foreground">Day 30</div>
                      </div>
                    </div>
                  </div>
                  <div>
                    <h3 className="font-medium">Active Users</h3>
                    <div className="mt-2 grid grid-cols-3 gap-4">
                      <div className="bg-muted p-3 rounded-lg text-center">
                        <div className="text-2xl font-bold">{userGrowthReport.activeUsers.daily.toLocaleString()}</div>
                        <div className="text-xs text-muted-foreground">Daily</div>
                      </div>
                      <div className="bg-muted p-3 rounded-lg text-center">
                        <div className="text-2xl font-bold">{userGrowthReport.activeUsers.weekly.toLocaleString()}</div>
                        <div className="text-xs text-muted-foreground">Weekly</div>
                      </div>
                      <div className="bg-muted p-3 rounded-lg text-center">
                        <div className="text-2xl font-bold">{userGrowthReport.activeUsers.monthly.toLocaleString()}</div>
                        <div className="text-xs text-muted-foreground">Monthly</div>
                      </div>
                    </div>
                  </div>
                </div>
              ) : (
                <p>No user growth data available</p>
              )}
            </CardContent>
          </Card>
        </TabsContent>
        
        <TabsContent value="media-trends" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Media Trends Report</CardTitle>
            </CardHeader>
            <CardContent>
              {loading ? (
                <div className="space-y-2">
                  <Skeleton className="h-4 w-full" />
                  <Skeleton className="h-4 w-5/6" />
                  <Skeleton className="h-4 w-4/6" />
                </div>
              ) : mediaTrendsReport ? (
                <div className="space-y-4">
                  <div>
                    <h3 className="font-medium">Uploads by Category</h3>
                    <div className="mt-2 space-y-1">
                      {Object.entries(mediaTrendsReport.uploadsByCategory).map(([category, count]) => (
                        <div key={category} className="flex justify-between text-sm">
                          <span className="capitalize">{category}</span>
                          <span>{count} uploads</span>
                        </div>
                      ))}
                    </div>
                  </div>
                  <div>
                    <h3 className="font-medium">Uploads by Type</h3>
                    <div className="mt-2 space-y-1">
                      {Object.entries(mediaTrendsReport.uploadsByType).map(([type, count]) => (
                        <div key={type} className="flex justify-between text-sm">
                          <span className="capitalize">{type}</span>
                          <span>{count} uploads</span>
                        </div>
                      ))}
                    </div>
                  </div>
                  <div>
                    <h3 className="font-medium">Popular Tags</h3>
                    <div className="mt-2 flex flex-wrap gap-2">
                      {mediaTrendsReport.popularTags.map((tag, index) => (
                        <span key={index} className="bg-primary/10 text-primary px-2 py-1 rounded-full text-xs">
                          {tag.tag} ({tag.count})
                        </span>
                      ))}
                    </div>
                  </div>
                </div>
              ) : (
                <p>No media trends data available</p>
              )}
            </CardContent>
          </Card>
        </TabsContent>
        
        <TabsContent value="moderation" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>Moderation Statistics</CardTitle>
            </CardHeader>
            <CardContent>
              {loading ? (
                <div className="space-y-2">
                  <Skeleton className="h-4 w-full" />
                  <Skeleton className="h-4 w-5/6" />
                  <Skeleton className="h-4 w-4/6" />
                </div>
              ) : moderationStats ? (
                <div className="space-y-4">
                  <div className="grid grid-cols-3 gap-4">
                    <div className="bg-muted p-3 rounded-lg text-center">
                      <div className="text-2xl font-bold">{moderationStats.totalFlagged}</div>
                      <div className="text-xs text-muted-foreground">Flagged</div>
                    </div>
                    <div className="bg-muted p-3 rounded-lg text-center">
                      <div className="text-2xl font-bold">{moderationStats.resolved}</div>
                      <div className="text-xs text-muted-foreground">Resolved</div>
                    </div>
                    <div className="bg-muted p-3 rounded-lg text-center">
                      <div className="text-2xl font-bold">{moderationStats.pending}</div>
                      <div className="text-xs text-muted-foreground">Pending</div>
                    </div>
                  </div>
                  <div>
                    <h3 className="font-medium">Moderation Actions</h3>
                    <div className="mt-2 grid grid-cols-3 gap-4">
                      <div className="bg-muted p-3 rounded-lg text-center">
                        <div className="text-2xl font-bold">{moderationStats.actions.approved}</div>
                        <div className="text-xs text-muted-foreground">Approved</div>
                      </div>
                      <div className="bg-muted p-3 rounded-lg text-center">
                        <div className="text-2xl font-bold">{moderationStats.actions.rejected}</div>
                        <div className="text-xs text-muted-foreground">Rejected</div>
                      </div>
                      <div className="bg-muted p-3 rounded-lg text-center">
                        <div className="text-2xl font-bold">{moderationStats.actions.warned}</div>
                        <div className="text-xs text-muted-foreground">Warned</div>
                      </div>
                    </div>
                  </div>
                  <div>
                    <h3 className="font-medium">Moderator Activity</h3>
                    <div className="mt-2 space-y-1">
                      {moderationStats.moderatorActivity.map((mod, index) => (
                        <div key={index} className="flex justify-between text-sm">
                          <span>Moderator {mod.moderatorId}</span>
                          <span>{mod.actions} actions</span>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              ) : (
                <p>No moderation data available</p>
              )}
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}