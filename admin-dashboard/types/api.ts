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
  engagement?: MediaEngagement;
  moderation?: MediaModeration;
}

export enum MediaStatus {
  PENDING = 'pending',
  APPROVED = 'approved',
  REJECTED = 'rejected',
  FLAGGED = 'flagged',
  DELETED = 'deleted'
}

export interface MediaMetadata {
  // Image metadata
  width?: number;
  height?: number;
  camera?: string;
  lens?: string;
  iso?: number;
  aperture?: string;
  shutterSpeed?: string;
  focalLength?: string;
  
  // Video metadata
  duration?: number;
  bitrate?: number;
  codec?: string;
  format?: string;
  
  // General metadata
  fileSize?: number;
  uploadDate?: string;
  lastModified?: string;
}

export interface MediaEngagement {
  views: number;
  likes: number;
  comments: number;
  shares: number;
  engagementRate: number;
}

export interface MediaModeration {
  status: 'pending' | 'approved' | 'rejected' | 'flagged';
  flags: Array<{
    type: string;
    reason: string;
    timestamp: string;
    moderatorId?: string;
  }>;
  warnings: string[];
  category: string;
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

// User Growth Report
export interface UserGrowthReport {
  dailyRegistrations: Array<{
    date: string;
    count: number;
  }>;
  retentionRate: {
    day1: number;
    day7: number;
    day30: number;
  };
  activeUsers: {
    daily: number;
    weekly: number;
    monthly: number;
  };
}

// Media Trends Report
export interface MediaTrendsReport {
  uploadsByCategory: Record<string, number>;
  uploadsByType: Record<string, number>;
  popularTags: Array<{
    tag: string;
    count: number;
  }>;
  peakUploadTimes: Array<{
    hour: number;
    count: number;
  }>;
}

// Moderation Statistics
export interface ModerationStats {
  totalFlagged: number;
  resolved: number;
  pending: number;
  actions: {
    approved: number;
    rejected: number;
    warned: number;
  };
  moderatorActivity: Array<{
    moderatorId: string;
    actions: number;
  }>;
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
  [key: string]: string | number | boolean | string[] | undefined;
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
    uploadedByUser: {
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
    tags: ['vacation', 'beach'],
    description: 'Beautiful beach view from our vacation',
    status: MediaStatus.APPROVED,
    createdAt: '2024-01-22T15:30:00Z',
    updatedAt: '2024-01-22T15:35:00Z',
    metadata: {
      width: 1920,
      height: 1080,
      camera: 'Canon EOS R5',
      lens: 'RF 24-70mm f/2.8L IS USM',
      iso: 100,
      aperture: 'f/8',
      shutterSpeed: '1/250s',
      focalLength: '35mm'
    },
    engagement: {
      views: 1245,
      likes: 87,
      comments: 23,
      shares: 12,
      engagementRate: 0.78
    },
    moderation: {
      status: 'approved',
      flags: [],
      warnings: [],
      category: 'nature'
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
    uploadedByUser: {
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
    tags: ['family', 'event'],
    description: 'Our family gathering last weekend',
    status: MediaStatus.APPROVED,
    createdAt: '2024-01-22T17:15:00Z',
    updatedAt: '2024-01-22T17:20:00Z',
    metadata: {
      duration: 300,
      bitrate: 5000000,
      codec: 'H.264',
      format: 'MP4'
    },
    engagement: {
      views: 2156,
      likes: 124,
      comments: 42,
      shares: 35,
      engagementRate: 0.85
    },
    moderation: {
      status: 'approved',
      flags: [],
      warnings: [],
      category: 'family'
    }
  },
  {
    id: 'media-3',
    filename: 'photo2.jpg',
    originalName: 'garden-plants.jpg',
    mimeType: 'image/jpeg',
    size: 3048576,
    url: 'https://example.com/media/photo2.jpg',
    thumbnailUrl: 'https://example.com/media/thumb/photo2.jpg',
    uploadedBy: '1',
    uploadedByUser: {
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
    tags: ['plants', 'garden', 'flowers'],
    description: 'My beautiful garden with blooming flowers',
    status: MediaStatus.PENDING,
    createdAt: '2024-01-23T10:30:00Z',
    updatedAt: '2024-01-23T10:30:00Z',
    metadata: {
      width: 3840,
      height: 2160,
      camera: 'Sony A7R IV',
      lens: 'FE 85mm f/1.4 GM',
      iso: 200,
      aperture: 'f/1.4',
      shutterSpeed: '1/500s',
      focalLength: '85mm'
    },
    engagement: {
      views: 0,
      likes: 0,
      comments: 0,
      shares: 0,
      engagementRate: 0
    },
    moderation: {
      status: 'pending',
      flags: [],
      warnings: [],
      category: 'plants'
    }
  },
  {
    id: 'media-4',
    filename: 'video2.mp4',
    originalName: 'plant-care-tutorial.mp4',
    mimeType: 'video/mp4',
    size: 25485760,
    url: 'https://example.com/media/video2.mp4',
    thumbnailUrl: 'https://example.com/media/thumb/video2.jpg',
    uploadedBy: '2',
    uploadedByUser: {
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
    tags: ['tutorial', 'plant care', 'tips'],
    description: 'Step-by-step guide to caring for your indoor plants',
    status: MediaStatus.FLAGGED,
    createdAt: '2024-01-23T14:15:00Z',
    updatedAt: '2024-01-23T16:20:00Z',
    metadata: {
      duration: 620,
      bitrate: 8000000,
      codec: 'H.265',
      format: 'MP4'
    },
    engagement: {
      views: 876,
      likes: 65,
      comments: 18,
      shares: 22,
      engagementRate: 0.62
    },
    moderation: {
      status: 'flagged',
      flags: [
        {
          type: 'inappropriate_content',
          reason: 'Contains misleading information about plant care',
          timestamp: '2024-01-23T16:20:00Z',
          moderatorId: '3'
        }
      ],
      warnings: ['Content may contain inaccurate information'],
      category: 'tutorial'
    }
  }
];

// Mock data for reporting models
export const MOCK_USER_GROWTH_REPORT: UserGrowthReport = {
  dailyRegistrations: [
    { date: '2024-01-01', count: 15 },
    { date: '2024-01-02', count: 12 },
    { date: '2024-01-03', count: 18 },
    { date: '2024-01-04', count: 9 },
    { date: '2024-01-05', count: 22 },
    { date: '2024-01-06', count: 31 },
    { date: '2024-01-07', count: 14 }
  ],
  retentionRate: {
    day1: 0.78,
    day7: 0.62,
    day30: 0.45
  },
  activeUsers: {
    daily: 1247,
    weekly: 3421,
    monthly: 8765
  }
};

export const MOCK_MEDIA_TRENDS_REPORT: MediaTrendsReport = {
  uploadsByCategory: {
    nature: 124,
    family: 87,
    plants: 203,
    tutorial: 45,
    event: 67
  },
  uploadsByType: {
    image: 342,
    video: 78,
    audio: 12,
    document: 5
  },
  popularTags: [
    { tag: 'plants', count: 203 },
    { tag: 'garden', count: 156 },
    { tag: 'vacation', count: 87 },
    { tag: 'family', count: 134 },
    { tag: 'tutorial', count: 45 }
  ],
  peakUploadTimes: [
    { hour: 9, count: 45 },
    { hour: 12, count: 67 },
    { hour: 15, count: 89 },
    { hour: 18, count: 123 },
    { hour: 21, count: 98 }
  ]
};

export const MOCK_MODERATION_STATS: ModerationStats = {
  totalFlagged: 24,
  resolved: 18,
  pending: 6,
  actions: {
    approved: 7,
    rejected: 11,
    warned: 4
  },
  moderatorActivity: [
    { moderatorId: '2', actions: 15 },
    { moderatorId: '3', actions: 9 }
  ]
};

// Communication Models
export interface CommunicationTemplate {
  id: string;
  name: string;
  subject: string;
  body: string;
  type: 'email' | 'notification';
  variables: string[];
}

export interface PlatformAnnouncement {
  id: string;
  title: string;
  content: string;
  startDate: string;
  endDate: string;
  priority: 'low' | 'medium' | 'high';
  targetUsers: 'all' | 'active' | 'specific';
}

export interface MessageTracking {
  messageId: string;
  sentAt: string;
  delivered: number;
  opened: number;
  clicked: number;
}

// Mock data for communication models
export const MOCK_COMMUNICATION_TEMPLATES: CommunicationTemplate[] = [
  {
    id: 'template-1',
    name: 'Content Violation Notice',
    subject: 'Notice: Content Violation on Your Post',
    body: 'Dear {{username}},\n\nWe noticed that your recent post "{{postTitle}}" violates our community guidelines. Specifically, it contains {{violationType}}.\n\nPlease review our guidelines and consider editing or removing the content.\n\nThank you for your understanding.\n\nBest regards,\nThe {{platformName}} Team',
    type: 'email',
    variables: ['username', 'postTitle', 'violationType', 'platformName']
  },
  {
    id: 'template-2',
    name: 'Account Suspension Notice',
    subject: 'Important: Account Suspension',
    body: 'Dear {{username}},\n\nYour account has been suspended due to repeated violations of our community guidelines.\n\nSuspension details:\n- Reason: {{reason}}\n- Start Date: {{startDate}}\n- End Date: {{endDate}}\n\nDuring this period, you will not be able to access your account or post new content.\n\nIf you believe this suspension was made in error, please contact our support team.\n\nBest regards,\nThe {{platformName}} Team',
    type: 'email',
    variables: ['username', 'reason', 'startDate', 'endDate', 'platformName']
  },
  {
    id: 'template-3',
    name: 'Welcome Message',
    subject: 'Welcome to {{platformName}}!',
    body: 'Welcome {{username}}!\n\nThank you for joining {{platformName}}. We\'re excited to have you as part of our community.\n\nHere are some tips to get started:\n1. Complete your profile\n2. Explore content\n3. Connect with other users\n\nIf you have any questions, feel free to reach out to our support team.\n\nHappy sharing!\n\nThe {{platformName}} Team',
    type: 'email',
    variables: ['username', 'platformName']
  },
  {
    id: 'template-4',
    name: 'New Feature Announcement',
    subject: 'Exciting New Features Available!',
    body: 'Hi {{username}},\n\nWe\'ve just launched some exciting new features on {{platformName}} that we think you\'ll love!\n\nWhat\'s new:\n- {{feature1}}\n- {{feature2}}\n- {{feature3}}\n\nCheck them out and let us know what you think!\n\nThe {{platformName}} Team',
    type: 'notification',
    variables: ['username', 'platformName', 'feature1', 'feature2', 'feature3']
  }
];

export const MOCK_PLATFORM_ANNOUNCEMENTS: PlatformAnnouncement[] = [
  {
    id: 'announcement-1',
    title: 'Scheduled Maintenance',
    content: 'We will be performing scheduled maintenance on our platform this Sunday from 2:00 AM to 6:00 AM EST. During this time, the service may be temporarily unavailable. We apologize for any inconvenience this may cause.',
    startDate: '2024-02-04T02:00:00Z',
    endDate: '2024-02-04T06:00:00Z',
    priority: 'medium',
    targetUsers: 'all'
  },
  {
    id: 'announcement-2',
    title: 'New Features Launched',
    content: 'We\'re excited to announce the launch of our new photo editing tools! Now you can enhance your photos directly on our platform with our easy-to-use editing suite. Try it out and let us know what you think!',
    startDate: '2024-01-15T00:00:00Z',
    endDate: '2024-03-15T00:00:00Z',
    priority: 'high',
    targetUsers: 'all'
  },
  {
    id: 'announcement-3',
    title: 'Community Guidelines Update',
    content: 'We\'ve updated our community guidelines to better reflect our commitment to creating a safe and welcoming environment for all users. Please take a moment to review the updated guidelines, which include new sections on respectful communication and content sharing best practices.',
    startDate: '2024-01-20T00:00:00Z',
    endDate: '2024-04-20T00:00:00Z',
    priority: 'medium',
    targetUsers: 'all'
  }
];

export const MOCK_MESSAGE_TRACKING: MessageTracking[] = [
  {
    messageId: 'msg-1',
    sentAt: '2024-01-15T10:30:00Z',
    delivered: 1247,
    opened: 876,
    clicked: 245
  },
  {
    messageId: 'msg-2',
    sentAt: '2024-01-16T14:15:00Z',
    delivered: 987,
    opened: 723,
    clicked: 189
  },
  {
    messageId: 'msg-3',
    sentAt: '2024-01-17T09:45:00Z',
    delivered: 1542,
    opened: 1123,
    clicked: 356
  },
  {
    messageId: 'msg-4',
    sentAt: '2024-01-18T16:20:00Z',
    delivered: 876,
    opened: 642,
    clicked: 156
  }
];

// Content Moderation Models
export interface ModerationAction {
  id: string;
  mediaId: string;
  moderatorId: string;
  action: 'approve' | 'reject' | 'flag' | 'warn' | 'delete';
  reason?: string;
  note?: string;
  timestamp: string;
}

export interface ModerationNote {
  id: string;
  mediaId: string;
  moderatorId: string;
  content: string;
  timestamp: string;
}

export interface RepeatOffender {
  userId: string;
  flagCount: number;
  warningCount: number;
  rejectionCount: number;
  lastOffenseDate: string;
}

export interface CollaborativeModeration {
  mediaId: string;
  notes: ModerationNote[];
  actions: ModerationAction[];
}

// Mock data for moderation models
export const MOCK_MODERATION_ACTIONS: ModerationAction[] = [
  {
    id: 'action-1',
    mediaId: 'media-1',
    moderatorId: '2',
    action: 'approve',
    note: 'Appropriate content, good quality photo',
    timestamp: '2024-01-22T16:00:00Z'
  },
  {
    id: 'action-2',
    mediaId: 'media-2',
    moderatorId: '3',
    action: 'flag',
    reason: 'Inappropriate content',
    note: 'Contains misleading information',
    timestamp: '2024-01-23T16:30:00Z'
  },
  {
    id: 'action-3',
    mediaId: 'media-3',
    moderatorId: '2',
    action: 'warn',
    reason: 'Poor quality',
    note: 'Low resolution image, consider reuploading',
    timestamp: '2024-01-23T11:00:00Z'
  },
  {
    id: 'action-4',
    mediaId: 'media-4',
    moderatorId: '3',
    action: 'reject',
    reason: 'Copyright violation',
    note: 'Image appears to be copyrighted material',
    timestamp: '2024-01-24T09:15:00Z'
  }
];

export const MOCK_MODERATION_NOTES: ModerationNote[] = [
  {
    id: 'note-1',
    mediaId: 'media-2',
    moderatorId: '2',
    content: 'This content needs additional review for accuracy',
    timestamp: '2024-01-23T16:25:00Z'
  },
  {
    id: 'note-2',
    mediaId: 'media-4',
    moderatorId: '3',
    content: 'User has been warned about copyright violations before',
    timestamp: '2024-01-24T09:10:00Z'
  }
];

export const MOCK_REPEAT_OFFENDERS: RepeatOffender[] = [
  {
    userId: '1',
    flagCount: 3,
    warningCount: 2,
    rejectionCount: 1,
    lastOffenseDate: '2024-01-23T16:30:00Z'
  },
  {
    userId: '2',
    flagCount: 5,
    warningCount: 3,
    rejectionCount: 2,
    lastOffenseDate: '2024-01-24T09:15:00Z'
  }
];

export const MOCK_COLLABORATIVE_MODERATION: CollaborativeModeration[] = [
  {
    mediaId: 'media-2',
    notes: [
      {
        id: 'note-1',
        mediaId: 'media-2',
        moderatorId: '2',
        content: 'This content needs additional review for accuracy',
        timestamp: '2024-01-23T16:25:00Z'
      }
    ],
    actions: [
      {
        id: 'action-2',
        mediaId: 'media-2',
        moderatorId: '3',
        action: 'flag',
        reason: 'Inappropriate content',
        note: 'Contains misleading information',
        timestamp: '2024-01-23T16:30:00Z'
      }
    ]
  },
  {
    mediaId: 'media-4',
    notes: [
      {
        id: 'note-2',
        mediaId: 'media-4',
        moderatorId: '3',
        content: 'User has been warned about copyright violations before',
        timestamp: '2024-01-24T09:10:00Z'
      }
    ],
    actions: [
      {
        id: 'action-4',
        mediaId: 'media-4',
        moderatorId: '3',
        action: 'reject',
        reason: 'Copyright violation',
        note: 'Image appears to be copyrighted material',
        timestamp: '2024-01-24T09:15:00Z'
      }
    ]
  }
];
