'use client';

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { MediaTrendsReport } from '@/types/api';

interface MediaTrendsTabProps {
  loading: boolean;
  mediaTrendsReport: MediaTrendsReport | null;
}

export function MediaTrendsTab({ loading, mediaTrendsReport }: MediaTrendsTabProps) {
  return (
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
  );
}
