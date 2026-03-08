'use client';

import { useState, useEffect, useCallback } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { Media } from '@/types/api';
import { mediaContentService } from '@/services/mediaContentService';
import { MediaDetailView } from '@/components/content/MediaDetailView';
import { MediaModerationTools } from '@/components/content/MediaModerationTools';
import { MediaEngagementMetrics } from '@/components/content/MediaEngagementMetrics';
import { LoadingSpinner } from '@/components/layout/LoadingSpinner';
import { Alert, AlertTitle, AlertDescription } from '@/components/ui/alert';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { toast } from 'sonner';
import { 
  ArrowLeft,
  Tag,
  Folder,
  MoreHorizontal
} from 'lucide-react';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';

export default function MediaContentManagementPage() {
  const params = useParams();
  const router = useRouter();
  const mediaId = params.mediaId as string;
  
  const [media, setMedia] = useState<Media | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [categoryDialogOpen, setCategoryDialogOpen] = useState(false);
  const [selectedCategory, setSelectedCategory] = useState('');

  const fetchMediaContent = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);

      // Fetch media details
      const response = await mediaContentService.getMediaById(mediaId);
      if (response.success && response.data) {
        setMedia(response.data);
        setSelectedCategory(response.data.moderation?.category || '');
      } else {
        throw new Error(response.message || 'Failed to fetch media content');
      }
    } catch (err) {
      console.error('Error fetching media content:', err);
      setError(err instanceof Error ? err.message : 'An unexpected error occurred');
    } finally {
      setLoading(false);
    }
  }, [mediaId]);

  useEffect(() => {
    if (mediaId) {
      fetchMediaContent();
    }
  }, [mediaId, fetchMediaContent]);

  const handleGoBack = () => {
    router.back();
  };

  const handleCategoryUpdate = async () => {
    if (!media) return;
    
    try {
      const response = await mediaContentService.updateMediaModeration(
        media.id,
        { category: selectedCategory }
      );
      
      if (response.success && response.data) {
        setMedia(response.data);
        toast.success('Category updated successfully');
        setCategoryDialogOpen(false);
      } else {
        throw new Error(response.message || 'Failed to update category');
      }
    } catch (err) {
      console.error('Error updating category:', err);
      toast.error(err instanceof Error ? err.message : 'Failed to update category');
    }
  };

  const handleMediaUpdate = (updatedMedia: Media) => {
    setMedia(updatedMedia);
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center py-12">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <Button variant="outline" onClick={handleGoBack}>
            <ArrowLeft className="h-4 w-4 mr-2" />
            Back
          </Button>
        </div>
        
        <Alert variant="destructive">
          <AlertTitle>Error</AlertTitle>
          <AlertDescription>{error}</AlertDescription>
        </Alert>
      </div>
    );
  }

  if (!media) {
    return (
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <Button variant="outline" onClick={handleGoBack}>
            <ArrowLeft className="h-4 w-4 mr-2" />
            Back
          </Button>
        </div>
        
        <Alert variant="destructive">
          <AlertTitle>Media not found</AlertTitle>
          <AlertDescription>No media data available for the provided ID.</AlertDescription>
        </Alert>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header with back button and actions */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div className="flex items-center space-x-4">
          <Button variant="outline" onClick={handleGoBack}>
            <ArrowLeft className="h-4 w-4" />
          </Button>
          <h1 className="text-2xl font-bold">Media Content Management</h1>
        </div>
        
        <div className="flex items-center space-x-2">
          <Dialog open={categoryDialogOpen} onOpenChange={setCategoryDialogOpen}>
            <DialogTrigger asChild>
              <Button variant="outline">
                <Folder className="h-4 w-4 mr-2" />
                Category
              </Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Assign Category</DialogTitle>
              </DialogHeader>
              <div className="space-y-4">
                <div>
                  <Label htmlFor="category">Category</Label>
                  <Select value={selectedCategory} onValueChange={setSelectedCategory}>
                    <SelectTrigger>
                      <SelectValue placeholder="Select a category" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="nature">Nature</SelectItem>
                      <SelectItem value="family">Family</SelectItem>
                      <SelectItem value="travel">Travel</SelectItem>
                      <SelectItem value="food">Food</SelectItem>
                      <SelectItem value="pets">Pets</SelectItem>
                      <SelectItem value="art">Art</SelectItem>
                      <SelectItem value="tutorial">Tutorial</SelectItem>
                      <SelectItem value="other">Other</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div className="flex justify-end space-x-2">
                  <Button
                    variant="outline"
                    onClick={() => setCategoryDialogOpen(false)}
                  >
                    Cancel
                  </Button>
                  <Button
                    onClick={handleCategoryUpdate}
                  >
                    Update Category
                  </Button>
                </div>
              </div>
            </DialogContent>
          </Dialog>
        </div>
      </div>

      {/* Media Detail View */}
      <MediaDetailView mediaId={mediaId} />

      {/* Media Moderation Tools */}
      <MediaModerationTools media={media} onMediaUpdate={handleMediaUpdate} />

      {/* Media Engagement Metrics */}
      <MediaEngagementMetrics mediaId={mediaId} />

      {/* Category Display */}
      {media.moderation?.category && (
        <div className="flex items-center space-x-2">
          <Tag className="h-4 w-4 text-gray-500" />
          <span className="text-sm font-medium">Category:</span>
          <span className="text-sm bg-gray-100 px-2 py-1 rounded">
            {media.moderation.category}
          </span>
        </div>
      )}
    </div>
  );
}