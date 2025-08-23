'use client';

import React from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { mediaService } from '@/services/mediaService';
import { Media } from '@/types/api';
import { LoadingSpinner } from '@/components/layout/LoadingSpinner';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { Trash2 } from 'lucide-react';
import { toast } from 'sonner';

const MediaGrid = () => {
  const queryClient = useQueryClient();

  const { data: mediaData, isLoading, isError, error } = useQuery({
    queryKey: ['media'],
    queryFn: () => mediaService.getMedia(),
  });

  const media = mediaData?.data || [];

  const mutation = useMutation({
    mutationFn: (id: string) => mediaService.deleteMedia(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['media'] });
      toast.success('Media deleted successfully');
    },
    onError: () => {
      toast.error('Failed to delete media');
    },
  });

  const handleDelete = (id: string) => {
    if (window.confirm('Are you sure you want to delete this media?')) {
      mutation.mutate(id);
    }
  };

  if (isLoading) {
    return <LoadingSpinner />;
  }

  if (isError) {
    return <p className="text-red-500">{error.message}</p>;
  }

  return (
    <div>
      <h2 className="text-2xl font-bold mb-4">Media Management</h2>
      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
        {media.map((item) => (
          <Card key={item.id}>
            <CardContent className="p-0">
              <img src={item.url} alt={item.altText || 'Media'} className="w-full h-48 object-cover" />
              <div className="p-4">
                <p className="text-sm text-gray-500">{item.filename}</p>
                <Button
                  variant="destructive"
                  size="sm"
                  className="mt-2"
                  onClick={() => handleDelete(item.id)}
                  disabled={mutation.isPending}
                >
                  <Trash2 className="h-4 w-4 mr-2" />
                  Delete
                </Button>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    </div>
  );
};

export default MediaGrid;
