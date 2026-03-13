'use client';

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { Users, Image as ImageIcon, TrendingUp, Flag } from 'lucide-react';

interface SummaryCardsProps {
  loading: boolean;
  totalUsers: number;
  totalMediaUploads: number;
  recentRegistrations: number;
  totalFlaggedContent: number;
}

export function SummaryCards({
  loading,
  totalUsers,
  totalMediaUploads,
  recentRegistrations,
  totalFlaggedContent
}: SummaryCardsProps) {
  return (
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
  );
}
