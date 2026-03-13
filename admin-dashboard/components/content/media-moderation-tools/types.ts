import { Media } from '@/types/api';

export interface MediaModerationToolsProps {
  media: Media;
  onMediaUpdate?: (updatedMedia: Media) => void;
}
