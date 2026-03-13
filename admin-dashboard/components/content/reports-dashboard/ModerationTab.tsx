'use client';

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { ModerationStats } from '@/types/api';

interface ModerationTabProps {
  loading: boolean;
  moderationStats: ModerationStats | null;
}

export function ModerationTab({ loading, moderationStats }: ModerationTabProps) {
  return (
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
  );
}
