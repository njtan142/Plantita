'use client';

import React, { useState } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { mediaService } from '@/services/mediaService';
import { Media, MediaStatus } from '@/types/api';
import { LoadingSpinner } from '@/components/layout/LoadingSpinner';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Badge } from '@/components/ui/badge';
import { Trash2, Eye, Check, X } from 'lucide-react';
import { toast } from 'sonner';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog';

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

  const deleteMutation = useMutation({
    mutationFn: (id: string) => mediaService.deleteMedia(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['media'] });
      toast.success('Media deleted successfully');
      setDeleteDialogOpen(false);
      setMediaToDelete(null);
    },
    onError: () => {
      toast.error('Failed to delete media');
    },
  });

  const approveMutation = useMutation({
    mutationFn: (id: string) => mediaService.approveMedia(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['media'] });
      toast.success('Media approved successfully');
    },
    onError: () => {
      toast.error('Failed to approve media');
    },
  });

  const rejectMutation = useMutation({
    mutationFn: (id: string) => mediaService.rejectMedia(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['media'] });
      toast.success('Media rejected successfully');
    },
    onError: () => {
      toast.error('Failed to reject media');
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
      
      {/* Filters */}
      <div className="flex flex-col sm:flex-row gap-4">
        <div className="flex-1">
          <Input
            placeholder="Search by filename..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="max-w-sm"
          />
        </div>
        <Select value={statusFilter} onValueChange={setStatusFilter}>
          <SelectTrigger className="w-[180px]">
            <SelectValue placeholder="Filter by status" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Statuses</SelectItem>
            <SelectItem value={MediaStatus.PENDING}>Pending</SelectItem>
            <SelectItem value={MediaStatus.APPROVED}>Approved</SelectItem>
            <SelectItem value={MediaStatus.REJECTED}>Rejected</SelectItem>
          </SelectContent>
        </Select>
      </div>

      {/* Media Grid */}
      {paginatedMedia.length > 0 ? (
        <>
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
            {paginatedMedia.map((item) => (
              <Card key={item.id} className="overflow-hidden">
                <CardContent className="p-0">
                  <div className="relative">
                    <img 
                      src={item.thumbnailUrl || item.url} 
                      alt={item.filename} 
                      className="w-full h-48 object-cover cursor-pointer"
                      onClick={() => handlePreview(item)}
                    />
                    <Button
                      variant="secondary"
                      size="sm"
                      className="absolute top-2 right-2"
                      onClick={() => handlePreview(item)}
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
                              onClick={() => handleApprove(item.id)}
                              disabled={approveMutation.isPending}
                            >
                              <Check className="h-4 w-4" />
                            </Button>
                            <Button
                              variant="outline"
                              size="sm"
                              onClick={() => handleReject(item.id)}
                              disabled={rejectMutation.isPending}
                            >
                              <X className="h-4 w-4" />
                            </Button>
                          </>
                        )}
                      </div>
                      <Button
                        variant="destructive"
                        size="sm"
                        onClick={() => handleDelete(item)}
                        disabled={deleteMutation.isPending}
                      >
                        <Trash2 className="h-4 w-4" />
                      </Button>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>

          {/* Pagination */}
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

      {/* Media Preview Dialog */}
      <Dialog open={!!previewMedia} onOpenChange={() => setPreviewMedia(null)}>
        <DialogContent className="max-w-3xl">
          <DialogHeader>
            <DialogTitle>{previewMedia?.filename}</DialogTitle>
          </DialogHeader>
          <div className="flex flex-col items-center">
            {previewMedia && (
              <>
                {previewMedia.mimeType.startsWith('image/') ? (
                  <img 
                    src={previewMedia.url} 
                    alt={previewMedia.filename} 
                    className="max-w-full max-h-[70vh] object-contain"
                  />
                ) : previewMedia.mimeType.startsWith('video/') ? (
                  <video 
                    src={previewMedia.url} 
                    controls 
                    className="max-w-full max-h-[70vh]"
                  />
                ) : (
                  <div className="flex flex-col items-center justify-center p-10">
                    <p className="text-muted-foreground">Preview not available for this file type.</p>
                    <a 
                      href={previewMedia.url} 
                      target="_blank" 
                      rel="noopener noreferrer"
                      className="mt-4 text-primary hover:underline"
                    >
                      Download file
                    </a>
                  </div>
                )}
                <div className="mt-4 text-sm text-muted-foreground">
                  <p>Uploaded: {new Date(previewMedia.createdAt).toLocaleDateString()}</p>
                  <p>Size: {(previewMedia.size / 1024 / 1024).toFixed(2)} MB</p>
                  <p>Type: {previewMedia.mimeType}</p>
                </div>
              </>
            )}
          </div>
        </DialogContent>
      </Dialog>

      {/* Delete Confirmation Dialog */}
      <AlertDialog open={deleteDialogOpen} onOpenChange={setDeleteDialogOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Are you sure?</AlertDialogTitle>
            <AlertDialogDescription>
              This action cannot be undone. This will permanently delete the media file.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={confirmDelete}
              className="bg-destructive hover:bg-destructive/90"
              disabled={deleteMutation.isPending}
            >
              {deleteMutation.isPending ? 'Deleting...' : 'Delete'}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
};

export default MediaGrid;