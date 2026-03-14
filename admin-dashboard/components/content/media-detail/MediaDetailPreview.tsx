'use client';

import React from 'react';
import { Media } from '@/types/api';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { FileText } from 'lucide-react';

interface MediaDetailPreviewProps {
  media: Media;
}

export const MediaDetailPreview = ({ media }: MediaDetailPreviewProps) => {
  return (
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
  );
};
