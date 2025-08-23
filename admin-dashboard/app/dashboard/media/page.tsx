import dynamic from 'next/dynamic';
import { LoadingSpinner } from '@/components/layout/LoadingSpinner';

// Lazy load the MediaGrid component
const MediaGrid = dynamic(
  () => import('@/components/media/media-grid'),
  { 
    ssr: false,
    loading: () => (
      <div className="flex items-center justify-center min-h-96">
        <LoadingSpinner />
      </div>
    )
  }
);

const MediaPage = () => {
  return (
    <MediaGrid />
  );
};

export default MediaPage;
