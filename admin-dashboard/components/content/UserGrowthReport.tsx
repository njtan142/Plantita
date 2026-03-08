'use client';

import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { Alert, AlertTitle, AlertDescription } from '@/components/ui/alert';
import { Button } from '@/components/ui/button';
import { 
  BarChart, 
  BarChartIcon, 
  TrendingUp, 
  Calendar,
  RotateCcw
} from 'lucide-react';
import { reportingService } from '@/services/reportingService';
import { UserGrowthReport } from '@/types/api';
import { AlertCircle } from 'lucide-react';

interface UserGrowthReportProps {
  className?: string;
}

export function UserGrowthReportComponent({ className }: UserGrowthReportProps) {
  const [report, setReport] = useState<UserGrowthReport | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchReport();
  }, []);

  const fetchReport = async () => {
    try {
      setLoading(true);
      setError(null);

      const response = await reportingService.getUserGrowthReport();
      
      if (response.success && response.data) {
        setReport(response.data);
      } else {
        setError(response.message || 'Failed to fetch user growth report');
      }
    } catch (err) {
      console.error('Error fetching user growth report:', err);
      setError('An unexpected error occurred while fetching user growth report');
    } finally {
      setLoading(false);
    }
  };

  const handleRetry = () => {
    fetchReport();
  };

  if (error) {
    return (
      <Card className={className}>
        <CardHeader>
          <CardTitle className="flex items-center justify-between">
            <span>User Growth Report</span>
            <AlertCircle className="h-5 w-5 text-destructive" />
          </CardTitle>
        </CardHeader>
        <CardContent>
          <Alert variant="destructive">
            <AlertTitle>Error</AlertTitle>
            <AlertDescription className="flex items-center justify-between">
              <span>{error}</span>
              <Button variant="outline" size="sm" onClick={handleRetry}>
                <RotateCcw className="h-4 w-4 mr-2" />
                Retry
              </Button>
            </AlertDescription>
          </Alert>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className={className}>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <BarChartIcon className="h-5 w-5" />
          User Growth Report
        </CardTitle>
      </CardHeader>
      <CardContent>
        {loading ? (
          <div className="space-y-4">
            <Skeleton className="h-4 w-full" />
            <Skeleton className="h-4 w-5/6" />
            <Skeleton className="h-4 w-4/6" />
            <div className="grid grid-cols-3 gap-4 mt-6">
              <div className="space-y-2">
                <Skeleton className="h-4 w-16" />
                <Skeleton className="h-8 w-12" />
              </div>
              <div className="space-y-2">
                <Skeleton className="h-4 w-16" />
                <Skeleton className="h-8 w-12" />
              </div>
              <div className="space-y-2">
                <Skeleton className="h-4 w-16" />
                <Skeleton className="h-8 w-12" />
              </div>
            </div>
          </div>
        ) : report ? (
          <div className="space-y-6">
            <div>
              <h3 className="font-medium mb-2">Daily Registrations (Last 7 Days)</h3>
              <div className="space-y-1">
                {report.dailyRegistrations.slice(-7).map((reg, index) => (
                  <div key={index} className="flex justify-between text-sm">
                    <span>{reg.date}</span>
                    <span>{reg.count} users</span>
                  </div>
                ))}
              </div>
            </div>
            
            <div>
              <h3 className="font-medium mb-2">Retention Rate</h3>
              <div className="grid grid-cols-3 gap-4">
                <div className="bg-muted p-3 rounded-lg text-center">
                  <div className="text-2xl font-bold">{(report.retentionRate.day1 * 100).toFixed(1)}%</div>
                  <div className="text-xs text-muted-foreground">Day 1</div>
                </div>
                <div className="bg-muted p-3 rounded-lg text-center">
                  <div className="text-2xl font-bold">{(report.retentionRate.day7 * 100).toFixed(1)}%</div>
                  <div className="text-xs text-muted-foreground">Day 7</div>
                </div>
                <div className="bg-muted p-3 rounded-lg text-center">
                  <div className="text-2xl font-bold">{(report.retentionRate.day30 * 100).toFixed(1)}%</div>
                  <div className="text-xs text-muted-foreground">Day 30</div>
                </div>
              </div>
            </div>
            
            <div>
              <h3 className="font-medium mb-2">Active Users</h3>
              <div className="grid grid-cols-3 gap-4">
                <div className="bg-muted p-3 rounded-lg text-center">
                  <div className="text-2xl font-bold">{report.activeUsers.daily.toLocaleString()}</div>
                  <div className="text-xs text-muted-foreground">Daily</div>
                </div>
                <div className="bg-muted p-3 rounded-lg text-center">
                  <div className="text-2xl font-bold">{report.activeUsers.weekly.toLocaleString()}</div>
                  <div className="text-xs text-muted-foreground">Weekly</div>
                </div>
                <div className="bg-muted p-3 rounded-lg text-center">
                  <div className="text-2xl font-bold">{report.activeUsers.monthly.toLocaleString()}</div>
                  <div className="text-xs text-muted-foreground">Monthly</div>
                </div>
              </div>
            </div>
          </div>
        ) : (
          <div className="text-center py-8 text-muted-foreground">
            No user growth data available
          </div>
        )}
      </CardContent>
    </Card>
  );
}