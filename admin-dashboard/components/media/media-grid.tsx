'use client';

import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { mediaService } from '@/services/mediaService';
import { Media, MediaStatus } from '@/types/api';
import { LoadingSpinner } from '@/components/layout/LoadingSpinner';
import { Button } from '@/components/ui/button';
import { toast } from 'sonner';
import { GridFilters } from './grid/GridFilters';
import { MediaCard } from './grid/MediaCard';
import { MediaPreview } from './grid/MediaPreview';
import { DeleteConfirmation } from './grid/DeleteConfirmation';

const MediaGrid = () => {
  const queryClient = useQueryClient();
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');
  const [currentPage, setCurrentPage] = useState(1);
  const [previewMedia, setPreviewMedia] = useState<Media | null>(null);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [mediaToDelete, setMediaToDelete] = useState<Media | null>(null);
  const itemsPerPage = 12;

  const { data: mediaData, isLoading, isError, error } = useQuery({
    queryKey: ['media'],
    queryFn: () => mediaService.getMedia(),
  });

  const media = mediaData?.data || [];

  // Filter media based on search term and status
  const filteredMedia = media.filter((item) => {
    const matchesSearch = item.filename.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesStatus = statusFilter === 'all' || item.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  // Pagination
  const totalPages = Math.ceil(filteredMedia.length / itemsPerPage);
  const paginatedMedia = filteredMedia.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

  // Optimistic update for deleting media
  const deleteMutation = useMutation({
    mutationFn: (id: string) => mediaService.deleteMedia(id),
    onMutate: async (id: string) => {
      await queryClient.cancelQueries({ queryKey: ['media'] });
      const previousMedia = queryClient.getQueryData<{ data: Media[] }>(['media']);
      queryClient.setQueryData<{ data: Media[] }>(['media'], (old) => {
        if (!old) return old;
        return {
          ...old,
          data: old.data.filter((item: Media) => item.id !== id)
        };
      });
      return { previousMedia };
    },
    onError: (err, id, context) => {
      queryClient.setQueryData(['media'], context?.previousMedia);
      toast.error('Failed to delete media');
    },
    onSuccess: () => {
      toast.success('Media deleted successfully');
      setDeleteDialogOpen(false);
      setMediaToDelete(null);
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['media'] });
    },
  });

  // Optimistic update for approving media
  const approveMutation = useMutation({
    mutationFn: (id: string) => mediaService.approveMedia(id),
    onMutate: async (id: string) => {
      await queryClient.cancelQueries({ queryKey: ['media'] });
      const previousMedia = queryClient.getQueryData<{ data: Media[] }>(['media']);
      queryClient.setQueryData<{ data: Media[] }>(['media'], (old) => {
        if (!old) return old;
        return {
          ...old,
          data: old.data.map((item: Media) => {
            if (item.id === id) {
              return { ...item, status: MediaStatus.APPROVED };
            }
            return item;
          })
        };
      });
      return { previousMedia };
    },
    onError: (err, id, context) => {
      queryClient.setQueryData(['media'], context?.previousMedia);
      toast.error('Failed to approve media');
    },
    onSuccess: () => {
      toast.success('Media approved successfully');
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['media'] });
    },
  });

  // Optimistic update for rejecting media
  const rejectMutation = useMutation({
    mutationFn: (id: string) => mediaService.rejectMedia(id),
    onMutate: async (id: string) => {
      await queryClient.cancelQueries({ queryKey: ['media'] });
      const previousMedia = queryClient.getQueryData<{ data: Media[] }>(['media']);
      queryClient.setQueryData<{ data: Media[] }>(['media'], (old) => {
        if (!old) return old;
        return {
          ...old,
          data: old.data.map((item: Media) => {
            if (item.id === id) {
              return { ...item, status: MediaStatus.REJECTED };
            }
            return item;
          })
        };
      });
      return { previousMedia };
    },
    onError: (err, id, context) => {
      queryClient.setQueryData(['media'], context?.previousMedia);
      toast.error('Failed to reject media');
    },
    onSuccess: () => {
      toast.success('Media rejected successfully');
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['media'] });
    },
  });

  const handleDelete = (mediaItem: Media) => {
    setMediaToDelete(mediaItem);
    setDeleteDialogOpen(true);
  };

  const confirmDelete = () => {
    if (mediaToDelete) {
      deleteMutation.mutate(mediaToDelete.id);
    }
  };

  const handleApprove = (id: string) => {
    approveMutation.mutate(id);
  };

  const handleReject = (id: string) => {
    rejectMutation.mutate(id);
  };

  const handlePreview = (mediaItem: Media) => {
    setPreviewMedia(mediaItem);
  };

  if (isLoading) {
    return <LoadingSpinner />;
  }

  if (isError) {
    return <p className="text-red-500">{error.message}</p>;
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <h2 className="text-2xl font-bold">Media Management</h2>
      </div>
      
      <GridFilters
        searchTerm={searchTerm}
        setSearchTerm={setSearchTerm}
        statusFilter={statusFilter}
        setStatusFilter={setStatusFilter}
      />

      {paginatedMedia.length > 0 ? (
        <>
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
            {paginatedMedia.map((item) => (
              <MediaCard
                key={item.id}
                item={item}
                onPreview={handlePreview}
                onApprove={handleApprove}
                onReject={handleReject}
                onDelete={handleDelete}
                isActionPending={approveMutation.isPending || rejectMutation.isPending || deleteMutation.isPending}
              />
            ))}
          </div>

          {totalPages > 1 && (
            <div className="flex items-center justify-between">
              <div className="text-sm text-muted-foreground">
                Showing {Math.min((currentPage - 1) * itemsPerPage + 1, filteredMedia.length)} to{' '}
                {Math.min(currentPage * itemsPerPage, filteredMedia.length)} of {filteredMedia.length} results
              </div>
              <div className="flex space-x-2">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setCurrentPage(prev => Math.max(prev - 1, 1))}
                  disabled={currentPage === 1}
                >
                  Previous
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setCurrentPage(prev => Math.min(prev + 1, totalPages))}
                  disabled={currentPage === totalPages}
                >
                  Next
                </Button>
              </div>
            </div>
          )}
        </>
      ) : (
        <div className="text-center py-10">
          <p className="text-muted-foreground">No media files found.</p>
        </div>
      )}

      <MediaPreview
        previewMedia={previewMedia}
        onClose={() => setPreviewMedia(null)}
      />

      <DeleteConfirmation
        open={deleteDialogOpen}
        onOpenChange={setDeleteDialogOpen}
        onConfirm={confirmDelete}
        isPending={deleteMutation.isPending}
      />
    </div>
  );
};

export default MediaGrid;
