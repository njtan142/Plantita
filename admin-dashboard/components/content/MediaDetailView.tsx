'use client';

import { useState, useEffect } from 'react';
import { Media, MediaMetadata, MediaEngagement } from '@/types/api';
import { mediaContentService } from '@/services/mediaContentService';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Separator } from '@/components/ui/separator';
import { 
  Image as ImageIcon,
  Video,
  FileText,
  Calendar,
  Eye,
  Heart,
  MessageCircle,
  Share2,
  Camera,
  Film,
  Info,
  Hash,
  User
} from 'lucide-react';
import { format, parseISO } from 'date-fns';
import { LoadingSpinner } from '@/components/layout/LoadingSpinner';
import { Alert, AlertTitle, AlertDescription } from '@/components/ui/alert';

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

      // Fetch media details
      const mediaResponse = await mediaContentService.getMediaById(mediaId);
      if (!mediaResponse.success || !mediaResponse.data) {
        throw new Error(mediaResponse.message || 'Failed to fetch media details');
      }
      setMedia(mediaResponse.data);

      // Fetch metadata
      const metadataResponse = await mediaContentService.getMediaMetadata(mediaId);
      if (metadataResponse.success && metadataResponse.data) {
        setMetadata(metadataResponse.data);
      }

      // Fetch engagement metrics
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

  const getMediaTypeIcon = (mimeType: string) => {
    if (mimeType.startsWith('image/')) {
      return <ImageIcon className="h-4 w-4" />;
    } else if (mimeType.startsWith('video/')) {
      return <Video className="h-4 w-4" />;
    } else {
      return <FileText className="h-4 w-4" />;
    }
  };

  const getMediaTypeLabel = (mimeType: string) => {
    if (mimeType.startsWith('image/')) {
      return 'Image';
    } else if (mimeType.startsWith('video/')) {
      return 'Video';
    } else {
      return 'File';
    }
  };

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
      {/* Media Header */}
      <Card>
        <CardHeader>
          <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
            <div className="flex items-center space-x-3">
              <div className="p-2 rounded-full bg-gray-100">
                {getMediaTypeIcon(media.mimeType)}
              </div>
              <div>
                <h2 className="text-xl font-bold">{media.filename}</h2>
                <p className="text-sm text-gray-500">{media.originalName}</p>
              </div>
            </div>
            <Badge variant={getStatusBadgeVariant(media.status)}>
              {media.status}
            </Badge>
          </div>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="flex items-center space-x-2">
              <User className="h-4 w-4 text-gray-500" />
              <span className="text-sm">Uploaded by: {media.uploadedBy}</span>
            </div>
            <div className="flex items-center space-x-2">
              <Calendar className="h-4 w-4 text-gray-500" />
              <span className="text-sm">
                Uploaded: {format(parseISO(media.createdAt), 'MMM d, yyyy h:mm a')}
              </span>
            </div>
            <div className="flex items-center space-x-2">
              <Info className="h-4 w-4 text-gray-500" />
              <span className="text-sm">
                Size: {Math.round(media.size / 1024)} KB
              </span>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Media Preview */}
      <Card>
        <CardHeader>
          <CardTitle>Media Preview</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="flex justify-center">
            {media.mimeType.startsWith('image/') ? (
              // eslint-disable-next-line @next/next/no-img-element
              <img
                src={media.url}
                alt={media.description || media.filename}
                className="max-w-full h-auto max-h-[500px] object-contain rounded-lg"
              />
            ) : media.mimeType.startsWith('video/') ? (
              <video
                src={media.url}
                controls
                className="max-w-full h-auto max-h-[500px] rounded-lg"
              />
            ) : (
              <div className="flex flex-col items-center justify-center p-8 bg-gray-100 rounded-lg">
                <FileText className="h-12 w-12 text-gray-400 mb-2" />
                <p className="text-gray-500">Preview not available for this file type</p>
                <Button variant="outline" className="mt-4" asChild>
                  <a href={media.url} download>
                    Download File
                  </a>
                </Button>
              </div>
            )}
          </div>
        </CardContent>
      </Card>

      {/* Media Description and Tags */}
      {(media.description || (media.tags && media.tags.length > 0)) && (
        <Card>
          <CardHeader>
            <CardTitle>Description & Tags</CardTitle>
          </CardHeader>
          <CardContent>
            {media.description && (
              <p className="text-gray-700 mb-4">{media.description}</p>
            )}
            {media.tags && media.tags.length > 0 && (
              <div className="flex flex-wrap gap-2">
                <Hash className="h-4 w-4 text-gray-500 mt-1" />
                {media.tags.map((tag, index) => (
                  <Badge key={index} variant="secondary">
                    {tag}
                  </Badge>
                ))}
              </div>
            )}
          </CardContent>
        </Card>
      )}

      {/* Engagement Metrics */}
      {engagement && (
        <Card>
          <CardHeader>
            <CardTitle>Engagement Metrics</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
              <div className="flex flex-col items-center p-4 bg-gray-50 rounded-lg">
                <Eye className="h-6 w-6 text-blue-500 mb-2" />
                <span className="text-2xl font-bold">{engagement.views}</span>
                <span className="text-sm text-gray-500">Views</span>
              </div>
              <div className="flex flex-col items-center p-4 bg-gray-50 rounded-lg">
                <Heart className="h-6 w-6 text-red-500 mb-2" />
                <span className="text-2xl font-bold">{engagement.likes}</span>
                <span className="text-sm text-gray-500">Likes</span>
              </div>
              <div className="flex flex-col items-center p-4 bg-gray-50 rounded-lg">
                <MessageCircle className="h-6 w-6 text-green-500 mb-2" />
                <span className="text-2xl font-bold">{engagement.comments}</span>
                <span className="text-sm text-gray-500">Comments</span>
              </div>
              <div className="flex flex-col items-center p-4 bg-gray-50 rounded-lg">
                <Share2 className="h-6 w-6 text-yellow-500 mb-2" />
                <span className="text-2xl font-bold">{engagement.shares}</span>
                <span className="text-sm text-gray-500">Shares</span>
              </div>
              <div className="flex flex-col items-center p-4 bg-gray-50 rounded-lg">
                <div className="h-6 w-6 mb-2 flex items-center justify-center">
                  <span className="text-lg">%</span>
                </div>
                <span className="text-2xl font-bold">
                  {Math.round(engagement.engagementRate * 100)}%
                </span>
                <span className="text-sm text-gray-500">Engagement</span>
              </div>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Technical Metadata */}
      {metadata && Object.keys(metadata).length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>Technical Metadata</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              {/* Image Metadata */}
              {metadata.width && metadata.height && (
                <div className="flex items-center space-x-2">
                  <ImageIcon className="h-4 w-4 text-gray-500" />
                  <span className="text-sm">
                    Dimensions: {metadata.width} × {metadata.height} pixels
                  </span>
                </div>
              )}
              {metadata.camera && (
                <div className="flex items-center space-x-2">
                  <Camera className="h-4 w-4 text-gray-500" />
                  <span className="text-sm">Camera: {metadata.camera}</span>
                </div>
              )}
              {metadata.lens && (
                <div className="flex items-center space-x-2">
                  <Camera className="h-4 w-4 text-gray-500" />
                  <span className="text-sm">Lens: {metadata.lens}</span>
                </div>
              )}
              {metadata.iso && (
                <div className="flex items-center space-x-2">
                  <Info className="h-4 w-4 text-gray-500" />
                  <span className="text-sm">ISO: {metadata.iso}</span>
                </div>
              )}
              {metadata.aperture && (
                <div className="flex items-center space-x-2">
                  <Info className="h-4 w-4 text-gray-500" />
                  <span className="text-sm">Aperture: {metadata.aperture}</span>
                </div>
              )}
              {metadata.shutterSpeed && (
                <div className="flex items-center space-x-2">
                  <Info className="h-4 w-4 text-gray-500" />
                  <span className="text-sm">Shutter Speed: {metadata.shutterSpeed}</span>
                </div>
              )}
              {metadata.focalLength && (
                <div className="flex items-center space-x-2">
                  <Info className="h-4 w-4 text-gray-500" />
                  <span className="text-sm">Focal Length: {metadata.focalLength}</span>
                </div>
              )}

              {/* Video Metadata */}
              {metadata.duration && (
                <div className="flex items-center space-x-2">
                  <Film className="h-4 w-4 text-gray-500" />
                  <span className="text-sm">
                    Duration: {Math.floor(metadata.duration / 60)}:{String(Math.floor(metadata.duration % 60)).padStart(2, '0')}
                  </span>
                </div>
              )}
              {metadata.bitrate && (
                <div className="flex items-center space-x-2">
                  <Info className="h-4 w-4 text-gray-500" />
                  <span className="text-sm">Bitrate: {Math.round(metadata.bitrate / 1000)} kbps</span>
                </div>
              )}
              {metadata.codec && (
                <div className="flex items-center space-x-2">
                  <Info className="h-4 w-4 text-gray-500" />
                  <span className="text-sm">Codec: {metadata.codec}</span>
                </div>
              )}
              {metadata.format && (
                <div className="flex items-center space-x-2">
                  <FileText className="h-4 w-4 text-gray-500" />
                  <span className="text-sm">Format: {metadata.format}</span>
                </div>
              )}

              {/* General Metadata */}
              {metadata.fileSize && (
                <div className="flex items-center space-x-2">
                  <Info className="h-4 w-4 text-gray-500" />
                  <span className="text-sm">File Size: {Math.round(metadata.fileSize / 1024)} KB</span>
                </div>
              )}
              {metadata.uploadDate && (
                <div className="flex items-center space-x-2">
                  <Calendar className="h-4 w-4 text-gray-500" />
                  <span className="text-sm">
                    Upload Date: {format(parseISO(metadata.uploadDate), 'MMM d, yyyy h:mm a')}
                  </span>
                </div>
              )}
              {metadata.lastModified && (
                <div className="flex items-center space-x-2">
                  <Calendar className="h-4 w-4 text-gray-500" />
                  <span className="text-sm">
                    Last Modified: {format(parseISO(metadata.lastModified), 'MMM d, yyyy h:mm a')}
                  </span>
                </div>
              )}
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );
}