'use client';

import React from 'react';
import { Media } from '@/types/api';
import { Card, CardContent, CardHeader } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { 
  Image as ImageIcon,
  Video,
  FileText,
  Calendar,
  Info,
  User
} from 'lucide-react';
import { format, parseISO } from 'date-fns';

interface MediaDetailHeaderProps {
  media: Media;
}

export const MediaDetailHeader = ({ media }: MediaDetailHeaderProps) => {
  const getMediaTypeIcon = (mimeType: string) => {
    if (mimeType.startsWith('image/')) {
      return <ImageIcon className="h-4 w-4" />;
    } else if (mimeType.startsWith('video/')) {
      return <Video className="h-4 w-4" />;
    } else {
      return <FileText className="h-4 w-4" />;
    }
  };

  const getStatusBadgeVariant = (status: string) => {
    switch (status) {
      case 'approved':
        return 'default';
      case 'pending':
        return 'secondary';
      case 'rejected':
        return 'destructive';
      case 'flagged':
        return 'destructive';
      default:
        return 'secondary';
    }
  };

  return (
    <Card>
      <CardHeader>
        <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
          <div className="flex items-center space-x-3">
            <div className="p-2 rounded-full bg-gray-100">
              {getMediaTypeIcon(media.mimeType)}
            </div>
            <div>
              <h2 className="text-xl font-bold">{media.filename}</h2>
              <p className="text-sm text-gray-500">{media.originalName}</p>
            </div>
          </div>
          <Badge variant={getStatusBadgeVariant(media.status)}>
            {media.status}
          </Badge>
        </div>
      </CardHeader>
      <CardContent>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div className="flex items-center space-x-2">
            <User className="h-4 w-4 text-gray-500" />
            <span className="text-sm">Uploaded by: {media.uploadedBy}</span>
          </div>
          <div className="flex items-center space-x-2">
            <Calendar className="h-4 w-4 text-gray-500" />
            <span className="text-sm">
              Uploaded: {format(parseISO(media.createdAt), 'MMM d, yyyy h:mm a')}
            </span>
          </div>
          <div className="flex items-center space-x-2">
            <Info className="h-4 w-4 text-gray-500" />
            <span className="text-sm">
              Size: {Math.round(media.size / 1024)} KB
            </span>
          </div>
        </div>
      </CardContent>
    </Card>
  );
};
