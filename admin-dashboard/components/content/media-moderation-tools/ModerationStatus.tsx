'use client';

import { Badge } from '@/components/ui/badge';
import { format, parseISO } from 'date-fns';

interface ModerationStatusProps {
  status: string;
  updatedAt: string;
}

export function ModerationStatus({ status, updatedAt }: ModerationStatusProps) {
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
    <div className="flex items-center justify-between">
      <div className="flex items-center space-x-2">
        <span className="font-medium">Current Status:</span>
        <Badge variant={getStatusBadgeVariant(status)}>
          {status}
        </Badge>
      </div>
      <div className="text-sm text-gray-500">
        Last updated: {format(parseISO(updatedAt), 'MMM d, yyyy h:mm a')}
      </div>
    </div>
  );
}
