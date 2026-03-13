'use client';

import React from 'react';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { Media } from '@/types/api';

interface MediaPreviewProps {
  previewMedia: Media | null;
  onClose: () => void;
}

export const MediaPreview = ({ previewMedia, onClose }: MediaPreviewProps) => {
  return (
    <Dialog open={!!previewMedia} onOpenChange={onClose}>
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
  );
};
