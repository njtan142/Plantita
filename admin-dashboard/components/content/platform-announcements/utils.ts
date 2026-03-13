import { PlatformAnnouncement } from '@/types/api';

export const getPriorityVariant = (priority: string): "default" | "destructive" | "secondary" | "outline" | null | undefined => {
  switch (priority) {
    case 'high': return 'destructive';
    case 'medium': return 'default';
    case 'low': return 'secondary';
    default: return 'secondary';
  }
};

export const getStatus = (announcement: PlatformAnnouncement) => {
  const now = new Date();
  const start = new Date(announcement.startDate);
  const end = new Date(announcement.endDate);
  
  if (now < start) return 'Scheduled';
  if (now > end) return 'Expired';
  return 'Active';
};

export const getStatusVariant = (status: string): "default" | "secondary" | "outline" | "destructive" | null | undefined => {
  switch (status) {
    case 'Active': return 'default';
    case 'Scheduled': return 'secondary';
    case 'Expired': return 'outline';
    default: return 'secondary';
  }
};
