'use client';

import dynamic from 'next/dynamic';
import { LoadingSpinner } from '@/components/layout/LoadingSpinner';

// Lazy load the MediaUploadChart component
const MediaUploadChart = dynamic(
  () => import('@/components/dashboard/MediaUploadChart'),
  { 
    ssr: false,
    loading: () => (
      <div className="h-64 flex items-center justify-center">
        <LoadingSpinner />
      </div>
    )
  }
);

// Wrapper component to handle props properly
export function MediaUploadChartWrapper({ data, loading }: { data: Array<{ date: string; uploads: number }>; loading: boolean }) {
  return <MediaUploadChart data={data} loading={loading} />;
}