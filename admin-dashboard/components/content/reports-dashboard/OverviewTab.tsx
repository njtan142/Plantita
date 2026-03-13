'use client';

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { BarChartIcon, PieChartIcon } from 'lucide-react';

interface OverviewTabProps {
  loading: boolean;
}

export function OverviewTab({ loading }: OverviewTabProps) {
  return (
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
  );
}
