import axios, { AxiosInstance, AxiosRequestConfig, AxiosResponse, AxiosError, InternalAxiosRequestConfig } from 'axios';
import { ApiResponse, ApiError } from '@/types/api';

// API base configuration
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001/api/v1';
const API_TIMEOUT = 10000;

// Create axios instance with default configuration
const axiosInstance: AxiosInstance = axios.create({
  baseURL: API_BASE_URL,
  timeout: API_TIMEOUT,
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
});

// Request interceptor
axiosInstance.interceptors.request.use(
  (config: InternalAxiosRequestConfig): InternalAxiosRequestConfig => {
    // Add auth token if available
    const token = getAuthToken();
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`;
    }

    // Log requests in development
    if (process.env.NODE_ENV === 'development') {
      console.log('API Request:', {
        method: config.method?.toUpperCase(),
        url: config.url,
        data: config.data,
      });
    }

    return config;
  },
  (error: AxiosError): Promise<AxiosError> => {
    console.error('Request interceptor error:', error);
    return Promise.reject(error);
  }
);

// Response interceptor
axiosInstance.interceptors.response.use(
  (response: AxiosResponse): AxiosResponse => {
    // Log responses in development
    if (process.env.NODE_ENV === 'development') {
      console.log('API Response:', {
        status: response.status,
        url: response.config.url,
        data: response.data,
      });
    }

    return response;
  },
  (error: AxiosError): Promise<ApiError> => {
    // Handle different types of errors
    let apiError: ApiError = {
      message: 'An unexpected error occurred',
      statusCode: 500,
    };

    if (error.response) {
      // Server responded with error status
      const { status, data } = error.response;

      apiError = {
        message: getErrorMessage(data, status),
        statusCode: status,
        code: getErrorCode(data),
        details: getErrorDetails(data),
      };

      // Handle specific status codes
      switch (status) {
        case 401:
          handleUnauthorizedError();
          break;
        case 403:
          handleForbiddenError();
          break;
        case 429:
          handleRateLimitError();
          break;
        default:
          break;
      }
    } else if (error.request) {
      // Request was made but no response received
      apiError = {
        message: 'Network error - please check your connection',
        statusCode: 0,
      };
    } else if (error.code === 'ECONNABORTED') {
      // Request timeout
      apiError = {
        message: 'Request timeout - please try again',
        statusCode: 408,
      };
    }

    // Log error in development
    if (process.env.NODE_ENV === 'development') {
      console.error('API Error:', {
        message: apiError.message,
        status: apiError.statusCode,
        originalError: error,
      });
    }

    return Promise.reject(apiError);
  }
);

// Helper functions
function getAuthToken(): string | null {
  if (typeof window === 'undefined') return null;

  // Try to get token from localStorage, sessionStorage, or cookies
  return localStorage.getItem('auth_token') ||
         sessionStorage.getItem('auth_token') ||
         getCookie('auth_token');
}

function getCookie(name: string): string | null {
  if (typeof window === 'undefined') return null;

  const value = `; ${document.cookie}`;
  const parts = value.split(`; ${name}=`);
  if (parts.length === 2) return parts.pop()?.split(';').shift() || null;
  return null;
}

function getErrorMessage(data: unknown, status: number): string {
  if (data && typeof data === 'object' && 'message' in data && typeof data.message === 'string') {
    return data.message;
  }
  if (data && typeof data === 'object' && 'error' in data && typeof data.error === 'string') {
    return data.error;
  }
  if (typeof data === 'string') return data;

  // Default messages based on status code
  switch (status) {
    case 400: return 'Bad request - please check your input';
    case 401: return 'Unauthorized - please log in again';
    case 403: return 'Access denied - insufficient permissions';
    case 404: return 'Resource not found';
    case 409: return 'Conflict - resource already exists';
    case 422: return 'Validation error - please check your input';
    case 429: return 'Too many requests - please try again later';
    case 500: return 'Internal server error - please try again later';
    case 503: return 'Service unavailable - please try again later';
    default: return 'An error occurred - please try again';
  }
}

function getErrorCode(data: unknown): string | undefined {
  if (data && typeof data === 'object' && 'code' in data && typeof data.code === 'string') {
    return data.code;
  }
  return undefined;
}

function getErrorDetails(data: unknown): Record<string, string | string[]> | undefined {
  if (data && typeof data === 'object') {
    if ('details' in data) {
      const details = data.details;
      if (details && typeof details === 'object' && !Array.isArray(details)) {
        return details as Record<string, string | string[]>;
      }
    }
    if ('errors' in data) {
      const errors = data.errors;
      if (errors && typeof errors === 'object' && !Array.isArray(errors)) {
        return errors as Record<string, string | string[]>;
      }
    }
  }
  return undefined;
}

function handleUnauthorizedError(): void {
  if (typeof window === 'undefined') return;

  // Clear auth token
  localStorage.removeItem('auth_token');
  sessionStorage.removeItem('auth_token');
  document.cookie = 'auth_token=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';

  // Redirect to login page if not already there
  if (!window.location.pathname.includes('/login')) {
    window.location.href = '/login';
  }
}

function handleForbiddenError(): void {
  if (typeof window === 'undefined') return;

  // Show permission error or redirect to dashboard
  console.warn('Access forbidden - insufficient permissions');
}

function handleRateLimitError(): void {
  if (typeof window === 'undefined') return;

  // Show rate limit message
  console.warn('Rate limit exceeded - please wait before making more requests');
}

// API client class
class ApiClient {
  private axiosInstance: AxiosInstance;

  constructor() {
    this.axiosInstance = axiosInstance;
  }

  // Generic HTTP methods
  async get<T = unknown>(url: string, config?: AxiosRequestConfig): Promise<ApiResponse<T>> {
    const response = await this.axiosInstance.get<ApiResponse<T>>(url, config);
    return response.data;
  }

  async post<T = unknown>(url: string, data?: unknown, config?: AxiosRequestConfig): Promise<ApiResponse<T>> {
    const response = await this.axiosInstance.post<ApiResponse<T>>(url, data, config);
    return response.data;
  }

  async put<T = unknown>(url: string, data?: unknown, config?: AxiosRequestConfig): Promise<ApiResponse<T>> {
    const response = await this.axiosInstance.put<ApiResponse<T>>(url, data, config);
    return response.data;
  }

  async patch<T = unknown>(url: string, data?: unknown, config?: AxiosRequestConfig): Promise<ApiResponse<T>> {
    const response = await this.axiosInstance.patch<ApiResponse<T>>(url, data, config);
    return response.data;
  }

  async delete<T = unknown>(url: string, config?: AxiosRequestConfig): Promise<ApiResponse<T>> {
    const response = await this.axiosInstance.delete<ApiResponse<T>>(url, config);
    return response.data;
  }

  // File upload method
  async upload<T = unknown>(url: string, formData: FormData, config?: AxiosRequestConfig): Promise<ApiResponse<T>> {
    const uploadConfig = {
      ...config,
      headers: {
        'Content-Type': 'multipart/form-data',
        ...config?.headers,
      },
    };

    const response = await this.axiosInstance.post<ApiResponse<T>>(url, formData, uploadConfig);
    return response.data;
  }

  // Get the underlying axios instance for advanced usage
  getAxiosInstance(): AxiosInstance {
    return this.axiosInstance;
  }
}

// Export singleton instance
export const apiClient = new ApiClient();
export default apiClient;

// Export axios instance for direct usage if needed
export { axiosInstance };