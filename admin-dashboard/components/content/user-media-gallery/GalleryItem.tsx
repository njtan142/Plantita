'use client';

import React from 'react';
import { Media, MediaStatus } from '@/types/api';
import { Card } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { 
  Image as ImageIcon,
  Video,
  FileText
} from 'lucide-react';
import { format, parseISO } from 'date-fns';

interface GalleryItemProps {
  item: Media;
}

export const GalleryItem = ({ item }: GalleryItemProps) => {
  const getMediaTypeIcon = (mimeType: string) => {
    if (mimeType.startsWith('image/')) {
      return <ImageIcon className="h-4 w-4" />;
    } else if (mimeType.startsWith('video/')) {
      return <Video className="h-4 w-4" />;
    } else {
      return <FileText className="h-4 w-4" />;
    }
  };

  const getMediaTypeLabel = (mimeType: string) => {
    if (mimeType.startsWith('image/')) {
      return 'Image';
    } else if (mimeType.startsWith('video/')) {
      return 'Video';
    } else {
      return 'File';
    }
  };

  const getStatusBadgeVariant = (status: MediaStatus) => {
    switch (status) {
      case MediaStatus.APPROVED:
        return 'default';
      case MediaStatus.PENDING:
        return 'secondary';
      case MediaStatus.REJECTED:
        return 'destructive';
      case MediaStatus.DELETED:
        return 'outline';
      default:
        return 'secondary';
    }
  };

  return (
    <div className="group relative">
      <Card className="overflow-hidden hover:shadow-md transition-shadow">
        <div className="aspect-square bg-gray-100 relative">
          {item.mimeType.startsWith('image/') ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img
              src={item.thumbnailUrl || item.url}
              alt={item.description || item.filename}
              className="w-full h-full object-cover"
            />
          ) : (
            <div className="w-full h-full flex flex-col items-center justify-center p-4 text-gray-500">
              <div className="bg-gray-200 rounded-full p-3 mb-2">
                {getMediaTypeIcon(item.mimeType)}
              </div>
              <span className="text-xs text-center truncate w-full px-2">
                {item.filename}
              </span>
            </div>
          )}
          
          <div className="absolute top-2 right-2">
            <Badge variant={getStatusBadgeVariant(item.status)}>
              {item.status}
            </Badge>
          </div>
        </div>
        
        <div className="p-3">
          <div className="flex items-center justify-between mb-2">
            <div className="flex items-center space-x-1 text-xs text-gray-500">
              {getMediaTypeIcon(item.mimeType)}
              <span>{getMediaTypeLabel(item.mimeType)}</span>
            </div>
            <div className="text-xs text-gray-500">
              {format(parseISO(item.createdAt), 'MMM d, yyyy')}
            </div>
          </div>
          
          {item.description && (
            <p className="text-sm text-gray-700 line-clamp-2 mb-2">
              {item.description}
            </p>
          )}
          
          {item.tags && item.tags.length > 0 && (
            <div className="flex flex-wrap gap-1">
              {item.tags.slice(0, 3).map((tag, index) => (
                <Badge key={index} variant="secondary" className="text-xs">
                  {tag}
                </Badge>
              ))}
              {item.tags.length > 3 && (
                <Badge variant="secondary" className="text-xs">
                  +{item.tags.length - 3}
                </Badge>
              )}
            </div>
          )}
        </div>
      </Card>
    </div>
  );
};
