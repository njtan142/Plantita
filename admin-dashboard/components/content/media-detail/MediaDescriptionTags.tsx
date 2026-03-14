'use client';

import React from 'react';
import { Media } from '@/types/api';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Hash } from 'lucide-react';

interface MediaDescriptionTagsProps {
  media: Media;
}

export const MediaDescriptionTags = ({ media }: MediaDescriptionTagsProps) => {
  if (!media.description && (!media.tags || media.tags.length === 0)) {
    return null;
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Description & Tags</CardTitle>
      </CardHeader>
      <CardContent>
        {media.description && (
          <p className="text-gray-700 mb-4">{media.description}</p>
        )}
        {media.tags && media.tags.length > 0 && (
          <div className="flex flex-wrap gap-2">
            <Hash className="h-4 w-4 text-gray-500 mt-1" />
            {media.tags.map((tag, index) => (
              <Badge key={index} variant="secondary">
                {tag}
              </Badge>
            ))}
          </div>
        )}
      </CardContent>
    </Card>
  );
};
