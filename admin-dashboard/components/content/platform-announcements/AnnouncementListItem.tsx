'use client';

import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Eye, Edit, Trash2, Calendar, Clock } from 'lucide-react';
import { PlatformAnnouncement } from '@/types/api';
import { format, parseISO } from 'date-fns';
import { getPriorityVariant, getStatus, getStatusVariant } from './utils';

interface AnnouncementListItemProps {
  announcement: PlatformAnnouncement;
  onPreview: (announcement: PlatformAnnouncement) => void;
  onEdit: (announcement: PlatformAnnouncement) => void;
  onDelete: (announcement: PlatformAnnouncement) => void;
}

export function AnnouncementListItem({
  announcement,
  onPreview,
  onEdit,
  onDelete
}: AnnouncementListItemProps) {
  const status = getStatus(announcement);
  return (
    <Card className="p-4">
      <div className="flex justify-between items-start">
        <div className="flex-1">
          <div className="flex items-start justify-between">
            <h4 className="font-semibold">{announcement.title}</h4>
            <div className="flex flex-wrap gap-1 ml-2">
              <Badge variant={getPriorityVariant(announcement.priority)}>
                {announcement.priority}
              </Badge>
              <Badge variant={getStatusVariant(status)}>
                {status}
              </Badge>
            </div>
          </div>
          <p className="text-sm text-muted-foreground mt-2 line-clamp-2">
            {announcement.content}
          </p>
          <div className="text-xs text-muted-foreground mt-2 flex flex-wrap gap-4">
            <div className="flex items-center gap-1">
              <Calendar className="h-3 w-3" />
              <span>{format(parseISO(announcement.startDate), 'MMM d, yyyy')}</span>
            </div>
            <div className="flex items-center gap-1">
              <Clock className="h-3 w-3" />
              <span>{format(parseISO(announcement.endDate), 'MMM d, yyyy')}</span>
            </div>
          </div>
        </div>
        <div className="flex gap-1 ml-2">
          <Button
            variant="ghost"
            size="sm"
            onClick={() => onPreview(announcement)}
          >
            <Eye className="h-4 w-4" />
          </Button>
          <Button
            variant="ghost"
            size="sm"
            onClick={() => onEdit(announcement)}
          >
            <Edit className="h-4 w-4" />
          </Button>
          <Button
            variant="ghost"
            size="sm"
            onClick={() => onDelete(announcement)}
          >
            <Trash2 className="h-4 w-4" />
          </Button>
        </div>
      </div>
    </Card>
  );
}
