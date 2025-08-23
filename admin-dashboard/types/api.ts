// Base API response structure
export interface ApiResponse<T = unknown> {
  success: boolean;
  data?: T;
  message?: string;
  error?: string;
  errors?: Record<string, string[]>;
}

// Pagination parameters
export interface PaginationParams {
  page?: number;
  limit?: number;
  sort?: string;
  order?: 'asc' | 'desc';
}

// Pagination metadata
export interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
  hasNext: boolean;
  hasPrev: boolean;
}

// Paginated response
export interface PaginatedResponse<T> extends ApiResponse<T[]> {
  meta: PaginationMeta;
}

// User types
export interface User {
  id: string;
  email: string;
  username: string;
  firstName?: string;
  lastName?: string;
  avatar?: string;
  role: UserRole;
  status: UserStatus;
  emailVerified: boolean;
  createdAt: string;
  updatedAt: string;
  lastLoginAt?: string;
  reportedContentCount?: number; // For tracking content reported by user
}

// User Activity types
export interface UserActivity {
  id: string;
  userId: string;
  type: 'login' | 'upload' | 'comment' | 'like' | 'share';
  description: string;
  timestamp: string;
  relatedMediaId?: string;
}

export interface UserStatistics {
  totalUploads: number;
  totalLikes: number;
  totalComments: number;
  totalViews: number;
  engagementRate: number;
  reportedContent: number;
}

export interface UserContentProfile {
  user: User;
  activity: UserActivity[];
  media: Media[];
  statistics: UserStatistics;
}

export enum UserRole {
  ADMIN = 'admin',
  MODERATOR = 'moderator',
  USER = 'user'
}

export enum UserStatus {
  ACTIVE = 'active',
  INACTIVE = 'inactive',
  SUSPENDED = 'suspended',
  BANNED = 'banned'
}

export interface CreateUserData {
  email: string;
  username: string;
  password: string;
  firstName?: string;
  lastName?: string;
  role?: UserRole;
}

export interface UpdateUserData {
  email?: string;
  username?: string;
  firstName?: string;
  lastName?: string;
  role?: UserRole;
  status?: UserStatus;
}

export interface UserQueryParams extends PaginationParams {
  search?: string;
  role?: UserRole;
  status?: UserStatus;
  emailVerified?: boolean;
  createdAfter?: string;
  createdBefore?: string;
}

// Media types
export interface Media {
  id: string;
  filename: string;
  originalName: string;
  mimeType: string;
  size: number;
  url: string;
  thumbnailUrl?: string;
  uploadedBy: string;
  uploadedByUser?: User;
  tags?: string[];
  description?: string;
  status: MediaStatus;
  createdAt: string;
  updatedAt: string;
  metadata?: MediaMetadata;
}

export enum MediaStatus {
  PENDING = 'pending',
  APPROVED = 'approved',
  REJECTED = 'rejected',
  DELETED = 'deleted'
}

export interface MediaMetadata {
  width?: number;
  height?: number;
  duration?: number;
  bitrate?: number;
  codec?: string;
  format?: string;
}

export interface CreateMediaData {
  file: File;
  description?: string;
  tags?: string[];
}

export interface UpdateMediaData {
  description?: string;
  tags?: string[];
  status?: MediaStatus;
}

export interface MediaQueryParams extends PaginationParams {
  search?: string;
  type?: 'image' | 'video' | 'audio' | 'document';
  status?: MediaStatus;
  uploadedBy?: string;
  tags?: string[];
  createdAfter?: string;
  createdBefore?: string;
  sizeMin?: number;
  sizeMax?: number;
}

// Media statistics
export interface MediaStats {
  totalCount: number;
  totalSize: number;
  countByType: Record<string, number>;
  countByStatus: Record<MediaStatus, number>;
  recentUploads: number; // last 30 days
  storageUsageTrend: Array<{
    date: string;
    size: number;
  }>;
}

// Dashboard statistics
export interface DashboardStats {
  totalUsers: number;
  activeUsers: number;
  totalMedia: number;
  storageUsed: number;
  userGrowth: { date: string; count: number }[];
  mediaUploads: { date: string; count: number }[];
  recentActivities: Activity[];
}

export interface Activity {
  id: string;
  type: string;
  description: string;
  timestamp: string;
}

// Analytics data
export interface AnalyticsData {
  userGrowth: {
    date: string;
    count: number;
  }[];
  mediaUploads: {
    date: string;
    count: number;
  }[];
  engagementMetrics: {
    date: string;
    likes: number;
    comments: number;
    shares: number;
  }[];
  platformMetrics: {
    totalUsers: number;
    activeUsers: number;
    totalMedia: number;
    storageUsed: number;
  };
}

export interface AnalyticsQueryParams {
  startDate?: string;
  endDate?: string;
  interval?: 'day' | 'week' | 'month';
}

// Error types
export interface ApiError {
  message: string;
  code?: string;
  statusCode: number;
  details?: Record<string, string | string[]>;
}

// Auth types (for future use)
export interface LoginCredentials {
  email: string;
  password: string;
}

export interface AuthResponse {
  user: User;
  token: string;
  refreshToken: string;
  expiresIn: number;
}

// Platform settings
export interface PlatformSettings {
  siteName: string;
  siteDescription: string;
  contactEmail: string;
  maxFileSize: number;
  allowedFileTypes: string[];
  userRegistration: boolean;
  emailVerification: boolean;
  maxLoginAttempts: number;
}

export interface SettingsUpdatePayload {
  [key: string]: any;
}

// Mock data structures for development
export const MOCK_USERS: User[] = [
  {
    id: '1',
    email: 'john.doe@example.com',
    username: 'johndoe',
    firstName: 'John',
    lastName: 'Doe',
    avatar: 'https://example.com/avatar1.jpg',
    role: UserRole.USER,
    status: UserStatus.ACTIVE,
    emailVerified: true,
    createdAt: '2024-01-15T08:30:00Z',
    updatedAt: '2024-01-20T10:15:00Z',
    lastLoginAt: '2024-01-22T14:20:00Z',
    reportedContentCount: 2
  },
  {
    id: '2',
    email: 'jane.smith@example.com',
    username: 'janesmith',
    firstName: 'Jane',
    lastName: 'Smith',
    avatar: 'https://example.com/avatar2.jpg',
    role: UserRole.MODERATOR,
    status: UserStatus.ACTIVE,
    emailVerified: true,
    createdAt: '2024-01-10T12:45:00Z',
    updatedAt: '2024-01-18T09:30:00Z',
    lastLoginAt: '2024-01-22T16:45:00Z',
    reportedContentCount: 0
  },
  {
    id: '3',
    email: 'admin@example.com',
    username: 'admin',
    firstName: 'Admin',
    lastName: 'User',
    avatar: 'https://example.com/avatar3.jpg',
    role: UserRole.ADMIN,
    status: UserStatus.ACTIVE,
    emailVerified: true,
    createdAt: '2024-01-01T00:00:00Z',
    updatedAt: '2024-01-01T00:00:00Z',
    lastLoginAt: '2024-01-22T18:00:00Z',
    reportedContentCount: 0
  }
];

export const MOCK_USER_ACTIVITIES: UserActivity[] = [
  {
    id: 'activity-1',
    userId: '1',
    type: 'login',
    description: 'User logged in',
    timestamp: '2024-01-22T14:20:00Z'
  },
  {
    id: 'activity-2',
    userId: '1',
    type: 'upload',
    description: 'Uploaded a new photo',
    timestamp: '2024-01-22T15:30:00Z',
    relatedMediaId: 'media-1'
  },
  {
    id: 'activity-3',
    userId: '1',
    type: 'comment',
    description: 'Commented on a post',
    timestamp: '2024-01-22T16:45:00Z'
  },
  {
    id: 'activity-4',
    userId: '2',
    type: 'login',
    description: 'User logged in',
    timestamp: '2024-01-22T16:45:00Z'
  },
  {
    id: 'activity-5',
    userId: '2',
    type: 'upload',
    description: 'Uploaded a new video',
    timestamp: '2024-01-22T17:15:00Z',
    relatedMediaId: 'media-2'
  }
];

export const MOCK_USER_STATISTICS: Record<string, UserStatistics> = {
  '1': {
    totalUploads: 15,
    totalLikes: 87,
    totalComments: 23,
    totalViews: 456,
    engagementRate: 0.78,
    reportedContent: 2
  },
  '2': {
    totalUploads: 8,
    totalLikes: 124,
    totalComments: 42,
    totalViews: 789,
    engagementRate: 0.85,
    reportedContent: 0
  },
  '3': {
    totalUploads: 0,
    totalLikes: 0,
    totalComments: 0,
    totalViews: 0,
    engagementRate: 0,
    reportedContent: 0
  }
};

export const MOCK_MEDIAS: Media[] = [
  {
    id: 'media-1',
    filename: 'photo1.jpg',
    originalName: 'vacation-photo.jpg',
    mimeType: 'image/jpeg',
    size: 2048576,
    url: 'https://example.com/media/photo1.jpg',
    thumbnailUrl: 'https://example.com/media/thumb/photo1.jpg',
    uploadedBy: '1',
    uploadedByUser: MOCK_USERS[0],
    tags: ['vacation', 'beach'],
    description: 'Beautiful beach view from our vacation',
    status: MediaStatus.APPROVED,
    createdAt: '2024-01-22T15:30:00Z',
    updatedAt: '2024-01-22T15:35:00Z',
    metadata: {
      width: 1920,
      height: 1080
    }
  },
  {
    id: 'media-2',
    filename: 'video1.mp4',
    originalName: 'family-video.mp4',
    mimeType: 'video/mp4',
    size: 10485760,
    url: 'https://example.com/media/video1.mp4',
    thumbnailUrl: 'https://example.com/media/thumb/video1.jpg',
    uploadedBy: '2',
    uploadedByUser: MOCK_USERS[1],
    tags: ['family', 'event'],
    description: 'Our family gathering last weekend',
    status: MediaStatus.APPROVED,
    createdAt: '2024-01-22T17:15:00Z',
    updatedAt: '2024-01-22T17:20:00Z',
    metadata: {
      duration: 300,
      bitrate: 5000000,
      codec: 'H.264'
    }
  }
];