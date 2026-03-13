'use client';

import React from 'react';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Trash2, Eye, Check, X } from 'lucide-react';
import { Media, MediaStatus } from '@/types/api';

interface MediaCardProps {
  item: Media;
  onPreview: (item: Media) => void;
  onApprove: (id: string) => void;
  onReject: (id: string) => void;
  onDelete: (item: Media) => void;
  isActionPending: boolean;
}

export const MediaCard = ({
  item,
  onPreview,
  onApprove,
  onReject,
  onDelete,
  isActionPending,
}: MediaCardProps) => {
  const getStatusBadge = (status: MediaStatus) => {
    switch (status) {
      case MediaStatus.PENDING:
        return <Badge className="bg-yellow-100 text-yellow-800 hover:bg-yellow-100">Pending</Badge>;
      case MediaStatus.APPROVED:
        return <Badge className="bg-green-100 text-green-800 hover:bg-green-100">Approved</Badge>;
      case MediaStatus.REJECTED:
        return <Badge className="bg-red-100 text-red-800 hover:bg-red-100">Rejected</Badge>;
      case MediaStatus.DELETED:
        return <Badge className="bg-gray-100 text-gray-800 hover:bg-gray-100">Deleted</Badge>;
      default:
        return <Badge className="bg-gray-100 text-gray-800 hover:bg-gray-100">{status}</Badge>;
    }
  };

  return (
    <Card className="overflow-hidden">
      <CardContent className="p-0">
        <div className="relative">
          <img 
            src={item.thumbnailUrl || item.url} 
            alt={item.filename} 
            className="w-full h-48 object-cover cursor-pointer"
            onClick={() => onPreview(item)}
          />
          <Button
            variant="secondary"
            size="sm"
            className="absolute top-2 right-2"
            onClick={() => onPreview(item)}
          >
            <Eye className="h-4 w-4" />
          </Button>
        </div>
        <div className="p-4">
          <p className="text-sm font-medium truncate">{item.filename}</p>
          <div className="flex items-center justify-between mt-2">
            {getStatusBadge(item.status)}
            <span className="text-xs text-gray-500">
              {(item.size / 1024 / 1024).toFixed(2)} MB
            </span>
          </div>
          <div className="flex items-center justify-between mt-3">
            <div className="flex space-x-1">
              {item.status === MediaStatus.PENDING && (
                <>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => onApprove(item.id)}
                    disabled={isActionPending}
                  >
                    <Check className="h-4 w-4" />
                  </Button>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => onReject(item.id)}
                    disabled={isActionPending}
                  >
                    <X className="h-4 w-4" />
                  </Button>
                </>
              )}
            </div>
            <Button
              variant="destructive"
              size="sm"
              onClick={() => onDelete(item)}
              disabled={isActionPending}
            >
              <Trash2 className="h-4 w-4" />
            </Button>
          </div>
        </div>
      </CardContent>
    </Card>
  );
};
