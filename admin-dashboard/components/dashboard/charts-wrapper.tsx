'use client';

import dynamic from 'next/dynamic';
import { LoadingSpinner } from '@/components/layout/LoadingSpinner';

// Lazy load the chart components
const UserGrowthChart = dynamic(
  () => import('@/components/dashboard/UserGrowthChart'),
  { 
    ssr: false,
    loading: () => (
      <div className="h-64 flex items-center justify-center">
        <LoadingSpinner />
      </div>
    )
  }
);

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

export { UserGrowthChart, MediaUploadChart };