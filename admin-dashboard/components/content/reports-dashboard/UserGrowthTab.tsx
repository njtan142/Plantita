'use client';

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { UserGrowthReport } from '@/types/api';

interface UserGrowthTabProps {
  loading: boolean;
  userGrowthReport: UserGrowthReport | null;
}

export function UserGrowthTab({ loading, userGrowthReport }: UserGrowthTabProps) {
  return (
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
  );
}
