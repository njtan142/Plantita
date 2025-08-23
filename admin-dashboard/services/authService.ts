import apiClient from '@/lib/api-client';
import { LoginCredentials, AuthResponse, ApiResponse } from '@/types/api';

export class AuthService {
  // Login user
  async login(credentials: LoginCredentials): Promise<ApiResponse<AuthResponse>> {
    return apiClient.post<AuthResponse>('/auth/login', credentials);
  }

  // Logout user
  async logout(): Promise<ApiResponse<void>> {
    return apiClient.post<void>('/auth/logout');
  }

  // Refresh token
  async refreshToken(): Promise<ApiResponse<AuthResponse>> {
    return apiClient.post<AuthResponse>('/auth/refresh');
  }

  // Get current user profile
  async getCurrentUser(): Promise<ApiResponse<AuthResponse['user']>> {
    return apiClient.get<AuthResponse['user']>('/auth/profile');
  }
}

// Export singleton instance
export const authService = new AuthService();
export default authService;