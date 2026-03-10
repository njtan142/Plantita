'use client';

import { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Calendar } from 'lucide-react';
import { ContentReportsDashboard } from '@/components/content/ContentReportsDashboard';
import { ReportExportToolbar } from '@/components/content/ReportExportToolbar';
import { toast } from 'sonner';

export default function ContentReportingPage() {
  const [dateRange, setDateRange] = useState<{
    start: string;
    end: string;
  } | null>(null);

  const handleScheduleReport = () => {
    // In a real implementation, this would open a dialog to schedule reports
    // For now, we'll just show a toast notification
    toast.success('Report scheduling', {
      description: 'In a real implementation, this would open a dialog to schedule reports.',
    });
  };

  const handleExportStart = () => {
    // Callback when export starts
    console.log('Export started');
  };

  const handleExportComplete = () => {
    // Callback when export completes
  };

  const handleExportError = (error: string) => {
    // Callback when export fails
    console.error('Export error:', error);
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Content Reports</h1>
          <p className="text-muted-foreground">
            Detailed analytics and reporting on user and media content
          </p>
        </div>
        <div className="flex flex-wrap gap-2">
          <ReportExportToolbar 
            onExportStart={handleExportStart}
            onExportComplete={handleExportComplete}
            onExportError={handleExportError}
          />
          <Button variant="outline" onClick={handleScheduleReport}>
            <Calendar className="mr-2 h-4 w-4" />
            Schedule Report
          </Button>
        </div>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Report Filters</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex flex-wrap gap-4">
            <div className="text-sm text-muted-foreground">
              Date Range: Last 30 days (default)
            </div>
            {/* In a real implementation, this would include actual date pickers and filters */}
          </div>
        </CardContent>
      </Card>

      <ContentReportsDashboard dateRange={dateRange || undefined} />
      
      <div className="text-center text-sm text-muted-foreground mt-8">
        <p>Report data is updated daily. Last updated: Today at 08:00 AM</p>
      </div>
    </div>
  );
}