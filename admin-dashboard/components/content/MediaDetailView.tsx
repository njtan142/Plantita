'use client';

import { useState, useEffect } from 'react';
import { Media, MediaMetadata, MediaEngagement } from '@/types/api';
import { mediaContentService } from '@/services/mediaContentService';
import { LoadingSpinner } from '@/components/layout/LoadingSpinner';
import { Alert, AlertTitle, AlertDescription } from '@/components/ui/alert';
import { MediaDetailHeader } from './media-detail/MediaDetailHeader';
import { MediaDetailPreview } from './media-detail/MediaDetailPreview';
import { MediaDescriptionTags } from './media-detail/MediaDescriptionTags';
import { MediaEngagementMetrics } from './media-detail/MediaEngagementMetrics';
import { MediaTechnicalMetadata } from './media-detail/MediaTechnicalMetadata';

interface MediaDetailViewProps {
  mediaId: string;
}

export function MediaDetailView({ mediaId }: MediaDetailViewProps) {
  const [media, setMedia] = useState<Media | null>(null);
  const [metadata, setMetadata] = useState<MediaMetadata | null>(null);
  const [engagement, setEngagement] = useState<MediaEngagement | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchMediaDetails();
  }, [mediaId]);

  const fetchMediaDetails = async () => {
    try {
      setLoading(true);
      setError(null);

      const mediaResponse = await mediaContentService.getMediaById(mediaId);
      if (!mediaResponse.success || !mediaResponse.data) {
        throw new Error(mediaResponse.message || 'Failed to fetch media details');
      }
      setMedia(mediaResponse.data);

      const metadataResponse = await mediaContentService.getMediaMetadata(mediaId);
      if (metadataResponse.success && metadataResponse.data) {
        setMetadata(metadataResponse.data);
      }

      const engagementResponse = await mediaContentService.getMediaEngagement(mediaId);
      if (engagementResponse.success && engagementResponse.data) {
        setEngagement(engagementResponse.data);
      }
    } catch (err) {
      console.error('Error fetching media details:', err);
      setError(err instanceof Error ? err.message : 'An unexpected error occurred');
    } finally {
      setLoading(false);
    }
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
      <Alert variant="destructive">
        <AlertTitle>Error</AlertTitle>
        <AlertDescription>{error}</AlertDescription>
      </Alert>
    );
  }

  if (!media) {
    return (
      <Alert variant="destructive">
        <AlertTitle>Media not found</AlertTitle>
        <AlertDescription>No media data available for the provided ID.</AlertDescription>
      </Alert>
    );
  }

  return (
    <div className="space-y-6">
      <MediaDetailHeader media={media} />
      <MediaDetailPreview media={media} />
      <MediaDescriptionTags media={media} />
      <MediaEngagementMetrics engagement={engagement} />
      <MediaTechnicalMetadata metadata={metadata} />
    </div>
  );
}
