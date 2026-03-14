'use client';

import React from 'react';
import { MediaMetadata } from '@/types/api';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { 
  Image as ImageIcon,
  Calendar,
  Camera,
  Film,
  Info,
  FileText
} from 'lucide-react';
import { format, parseISO } from 'date-fns';

interface MediaTechnicalMetadataProps {
  metadata: MediaMetadata | null;
}

export const MediaTechnicalMetadata = ({ metadata }: MediaTechnicalMetadataProps) => {
  if (!metadata || Object.keys(metadata).length === 0) return null;

  return (
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
  );
};
