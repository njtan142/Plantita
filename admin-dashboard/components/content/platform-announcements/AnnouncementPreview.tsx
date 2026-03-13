'use client';

import { Badge } from '@/components/ui/badge';
import { Bell, Calendar, Clock } from 'lucide-react';
import { PlatformAnnouncement } from '@/types/api';
import { format, parseISO } from 'date-fns';
import { getPriorityVariant, getStatus, getStatusVariant } from './utils';

interface AnnouncementPreviewProps {
  announcement: PlatformAnnouncement;
}

export function AnnouncementPreview({ announcement }: AnnouncementPreviewProps) {
  return (
    <div className="space-y-4">
      <div className="flex flex-wrap gap-2">
        <Badge variant={getPriorityVariant(announcement.priority)}>
          {announcement.priority}
        </Badge>
        <Badge variant={getStatusVariant(getStatus(announcement))}>
          {getStatus(announcement)}
        </Badge>
      </div>
      <div className="prose max-w-none">
        <p className="whitespace-pre-wrap">{announcement.content}</p>
      </div>
      <div className="text-sm text-muted-foreground flex flex-wrap gap-4">
        <div className="flex items-center gap-1">
          <Calendar className="h-4 w-4" />
          <span>Start: {format(parseISO(announcement.startDate), 'MMM d, yyyy h:mm a')}</span>
        </div>
        <div className="flex items-center gap-1">
          <Clock className="h-4 w-4" />
          <span>End: {format(parseISO(announcement.endDate), 'MMM d, yyyy h:mm a')}</span>
        </div>
      </div>
    </div>
  );
}
