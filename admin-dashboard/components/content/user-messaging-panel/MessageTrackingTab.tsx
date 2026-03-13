'use client';

import { Skeleton } from '@/components/ui/skeleton';
import { BarChart } from 'lucide-react';

interface MessageTrackingTabProps {
  isLoading: boolean;
}

export function MessageTrackingTab({ isLoading }: MessageTrackingTabProps) {
  return (
    <div className="space-y-4">
      <div className="text-center py-8 text-muted-foreground">
        <BarChart className="h-12 w-12 mx-auto mb-4" />
        <p>Message tracking data will appear here after sending messages.</p>
        <p className="text-sm mt-2">Select a message from the list to view detailed tracking information.</p>
      </div>
      
      <div className="space-y-4">
        <div className="rounded-lg border p-4">
          <h3 className="font-medium mb-2">Recent Messages</h3>
          <div className="space-y-3">
            {isLoading ? (
              <>
                <Skeleton className="h-16 w-full" />
                <Skeleton className="h-16 w-full" />
                <Skeleton className="h-16 w-full" />
              </>
            ) : (
              <>
                <div className="flex justify-between items-center p-3 bg-muted rounded-lg">
                  <div>
                    <p className="font-medium">Welcome Message</p>
                    <p className="text-sm text-muted-foreground">Sent to 1,247 users</p>
                  </div>
                  <div className="text-right">
                    <p className="text-sm">876 opened</p>
                    <p className="text-xs text-muted-foreground">70.3% open rate</p>
                  </div>
                </div>
                <div className="flex justify-between items-center p-3 bg-muted rounded-lg">
                  <div>
                    <p className="font-medium">Content Violation Notice</p>
                    <p className="text-sm text-muted-foreground">Sent to 24 users</p>
                  </div>
                  <div className="text-right">
                    <p className="text-sm">18 opened</p>
                    <p className="text-xs text-muted-foreground">75% open rate</p>
                  </div>
                </div>
                <div className="flex justify-between items-center p-3 bg-muted rounded-lg">
                  <div>
                    <p className="font-medium">Platform Update</p>
                    <p className="text-sm text-muted-foreground">Sent to 876 users</p>
                  </div>
                  <div className="text-right">
                    <p className="text-sm">642 opened</p>
                    <p className="text-xs text-muted-foreground">73.3% open rate</p>
                  </div>
                </div>
              </>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
