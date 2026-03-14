'use client';

import React from 'react';
import { MediaEngagement } from '@/types/api';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { 
  Eye,
  Heart,
  MessageCircle,
  Share2
} from 'lucide-react';

interface MediaEngagementMetricsProps {
  engagement: MediaEngagement | null;
}

export const MediaEngagementMetrics = ({ engagement }: MediaEngagementMetricsProps) => {
  if (!engagement) return null;

  return (
    <Card>
      <CardHeader>
        <CardTitle>Engagement Metrics</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
          <div className="flex flex-col items-center p-4 bg-gray-50 rounded-lg">
            <Eye className="h-6 w-6 text-blue-500 mb-2" />
            <span className="text-2xl font-bold">{engagement.views}</span>
            <span className="text-sm text-gray-500">Views</span>
          </div>
          <div className="flex flex-col items-center p-4 bg-gray-50 rounded-lg">
            <Heart className="h-6 w-6 text-red-500 mb-2" />
            <span className="text-2xl font-bold">{engagement.likes}</span>
            <span className="text-sm text-gray-500">Likes</span>
          </div>
          <div className="flex flex-col items-center p-4 bg-gray-50 rounded-lg">
            <MessageCircle className="h-6 w-6 text-green-500 mb-2" />
            <span className="text-2xl font-bold">{engagement.comments}</span>
            <span className="text-sm text-gray-500">Comments</span>
          </div>
          <div className="flex flex-col items-center p-4 bg-gray-50 rounded-lg">
            <Share2 className="h-6 w-6 text-yellow-500 mb-2" />
            <span className="text-2xl font-bold">{engagement.shares}</span>
            <span className="text-sm text-gray-500">Shares</span>
          </div>
          <div className="flex flex-col items-center p-4 bg-gray-50 rounded-lg">
            <div className="h-6 w-6 mb-2 flex items-center justify-center">
              <span className="text-lg">%</span>
            </div>
            <span className="text-2xl font-bold">
              {Math.round(engagement.engagementRate * 100)}%
            </span>
            <span className="text-sm text-gray-500">Engagement</span>
          </div>
        </div>
      </CardContent>
    </Card>
  );
};
