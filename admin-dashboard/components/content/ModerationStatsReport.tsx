'use client';

import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { Alert, AlertTitle, AlertDescription } from '@/components/ui/alert';
import { Button } from '@/components/ui/button';
import { 
  Flag,
  CheckCircle,
  XCircle,
  AlertTriangle,
  RotateCcw
} from 'lucide-react';
import { reportingService } from '@/services/reportingService';
import { ModerationStats } from '@/types/api';
import { AlertCircle } from 'lucide-react';

interface ModerationStatsReportProps {
  className?: string;
}

export function ModerationStatsReportComponent({ className }: ModerationStatsReportProps) {
  const [report, setReport] = useState<ModerationStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchReport();
  }, []);

  const fetchReport = async () => {
    try {
      setLoading(true);
      setError(null);

      const response = await reportingService.getModerationStats();
      
      if (response.success && response.data) {
        setReport(response.data);
      } else {
        setError(response.message || 'Failed to fetch moderation statistics');
      }
    } catch (err) {
      console.error('Error fetching moderation statistics:', err);
      setError('An unexpected error occurred while fetching moderation statistics');
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
            <span>Moderation Statistics</span>
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
          <Flag className="h-5 w-5" />
          Moderation Statistics
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
            <div className="grid grid-cols-3 gap-4">
              <div className="bg-muted p-3 rounded-lg text-center">
                <Flag className="h-5 w-5 mx-auto text-muted-foreground" />
                <div className="text-2xl font-bold mt-1">{report.totalFlagged}</div>
                <div className="text-xs text-muted-foreground">Flagged</div>
              </div>
              <div className="bg-muted p-3 rounded-lg text-center">
                <CheckCircle className="h-5 w-5 mx-auto text-muted-foreground" />
                <div className="text-2xl font-bold mt-1">{report.resolved}</div>
                <div className="text-xs text-muted-foreground">Resolved</div>
              </div>
              <div className="bg-muted p-3 rounded-lg text-center">
                <AlertTriangle className="h-5 w-5 mx-auto text-muted-foreground" />
                <div className="text-2xl font-bold mt-1">{report.pending}</div>
                <div className="text-xs text-muted-foreground">Pending</div>
              </div>
            </div>
            
            <div>
              <h3 className="font-medium mb-2">Moderation Actions</h3>
              <div className="grid grid-cols-3 gap-4">
                <div className="bg-muted p-3 rounded-lg text-center">
                  <CheckCircle className="h-5 w-5 mx-auto text-muted-foreground" />
                  <div className="text-2xl font-bold mt-1">{report.actions.approved}</div>
                  <div className="text-xs text-muted-foreground">Approved</div>
                </div>
                <div className="bg-muted p-3 rounded-lg text-center">
                  <XCircle className="h-5 w-5 mx-auto text-muted-foreground" />
                  <div className="text-2xl font-bold mt-1">{report.actions.rejected}</div>
                  <div className="text-xs text-muted-foreground">Rejected</div>
                </div>
                <div className="bg-muted p-3 rounded-lg text-center">
                  <AlertTriangle className="h-5 w-5 mx-auto text-muted-foreground" />
                  <div className="text-2xl font-bold mt-1">{report.actions.warned}</div>
                  <div className="text-xs text-muted-foreground">Warned</div>
                </div>
              </div>
            </div>
            
            <div>
              <h3 className="font-medium mb-2">Moderator Activity</h3>
              <div className="space-y-1">
                {report.moderatorActivity.map((mod, index) => (
                  <div key={index} className="flex justify-between text-sm">
                    <span>Moderator {mod.moderatorId}</span>
                    <span>{mod.actions} actions</span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        ) : (
          <div className="text-center py-8 text-muted-foreground">
            No moderation data available
          </div>
        )}
      </CardContent>
    </Card>
  );
}