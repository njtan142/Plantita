'use client';

import dynamic from 'next/dynamic';
import { LoadingSpinner } from '@/components/layout/LoadingSpinner';

// Lazy load the UserGrowthChart component
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

// Wrapper component to handle props properly
export function UserGrowthChartWrapper({ data, loading }: { data: Array<{ date: string; users: number }>; loading: boolean }) {
  return <UserGrowthChart data={data} loading={loading} />;
}