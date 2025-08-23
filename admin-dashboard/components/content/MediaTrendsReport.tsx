'use client';

import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { Alert, AlertTitle, AlertDescription } from '@/components/ui/alert';
import { Button } from '@/components/ui/button';
import { 
  PieChart, 
  PieChartIcon, 
  Image as ImageIcon,
  Tag,
  RotateCcw
} from 'lucide-react';
import { reportingService } from '@/services/reportingService';
import { MediaTrendsReport } from '@/types/api';
import { AlertCircle } from 'lucide-react';

interface MediaTrendsReportProps {
  className?: string;
}

export function MediaTrendsReportComponent({ className }: MediaTrendsReportProps) {
  const [report, setReport] = useState<MediaTrendsReport | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchReport();
  }, []);

  const fetchReport = async () => {
    try {
      setLoading(true);
      setError(null);

      const response = await reportingService.getMediaTrendsReport();
      
      if (response.success && response.data) {
        setReport(response.data);
      } else {
        setError(response.message || 'Failed to fetch media trends report');
      }
    } catch (err) {
      console.error('Error fetching media trends report:', err);
      setError('An unexpected error occurred while fetching media trends report');
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
            <span>Media Trends Report</span>
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
          <PieChartIcon className="h-5 w-5" />
          Media Trends Report
        </CardTitle>
      </CardHeader>
      <CardContent>
        {loading ? (
          <div className="space-y-4">
            <Skeleton className="h-4 w-full" />
            <Skeleton className="h-4 w-5/6" />
            <Skeleton className="h-4 w-4/6" />
            <div className="mt-6 space-y-2">
              <Skeleton className="h-6 w-full" />
              <Skeleton className="h-6 w-5/6" />
              <Skeleton className="h-6 w-4/6" />
            </div>
          </div>
        ) : report ? (
          <div className="space-y-6">
            <div>
              <h3 className="font-medium mb-2">Uploads by Category</h3>
              <div className="space-y-1">
                {Object.entries(report.uploadsByCategory).map(([category, count]) => (
                  <div key={category} className="flex justify-between text-sm">
                    <span className="capitalize">{category}</span>
                    <span>{count} uploads</span>
                  </div>
                ))}
              </div>
            </div>
            
            <div>
              <h3 className="font-medium mb-2">Uploads by Type</h3>
              <div className="space-y-1">
                {Object.entries(report.uploadsByType).map(([type, count]) => (
                  <div key={type} className="flex justify-between text-sm">
                    <span className="capitalize">{type}</span>
                    <span>{count} uploads</span>
                  </div>
                ))}
              </div>
            </div>
            
            <div>
              <h3 className="font-medium mb-2">Popular Tags</h3>
              <div className="flex flex-wrap gap-2">
                {report.popularTags.map((tag, index) => (
                  <span key={index} className="bg-primary/10 text-primary px-2 py-1 rounded-full text-xs">
                    {tag.tag} ({tag.count})
                  </span>
                ))}
              </div>
            </div>
            
            <div>
              <h3 className="font-medium mb-2">Peak Upload Times</h3>
              <div className="space-y-1">
                {report.peakUploadTimes.map((time, index) => (
                  <div key={index} className="flex justify-between text-sm">
                    <span>{time.hour}:00</span>
                    <span>{time.count} uploads</span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        ) : (
          <div className="text-center py-8 text-muted-foreground">
            No media trends data available
          </div>
        )}
      </CardContent>
    </Card>
  );
}