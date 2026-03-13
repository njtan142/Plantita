'use client';

import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Trash2 } from 'lucide-react';

interface BulkActionsProps {
  selectedCount: number;
  isPending: boolean;
  onBulkAction: (action: 'activate' | 'deactivate' | 'delete') => void;
}

export function BulkActions({ selectedCount, isPending, onBulkAction }: BulkActionsProps) {
  if (selectedCount === 0) return null;

  return (
    <Card>
      <CardContent className="pt-6">
        <div className="flex items-center justify-between">
          <span className="text-sm text-gray-600">
            {selectedCount} user(s) selected
          </span>
          <div className="flex items-center gap-2">
            <Button
              variant="outline"
              size="sm"
              onClick={() => onBulkAction('activate')}
              disabled={isPending}
            >
              Activate
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => onBulkAction('deactivate')}
              disabled={isPending}
            >
              Deactivate
            </Button>
            <Button
              variant="destructive"
              size="sm"
              onClick={() => onBulkAction('delete')}
              disabled={isPending}
            >
              <Trash2 className="h-4 w-4 mr-2" />
              Delete
            </Button>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
