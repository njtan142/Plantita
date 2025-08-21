// Base API response structure
export interface ApiResponse<T = any> {
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
  recentUploads: number;
  storageUsed: number;
  systemHealth: 'healthy' | 'warning' | 'error';
}

// Error types
export interface ApiError {
  message: string;
  code?: string;
  statusCode: number;
  details?: any;
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