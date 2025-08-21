import apiClient from '@/lib/api-client';
import {
  User,
  CreateUserData,
  UpdateUserData,
  UserQueryParams,
  PaginatedResponse,
  ApiResponse
} from '@/types/api';

export class UserService {
  // Get paginated list of users
  async getUsers(params?: UserQueryParams): Promise<PaginatedResponse<User>> {
    const queryParams = new URLSearchParams();

    if (params?.page) queryParams.append('page', params.page.toString());
    if (params?.limit) queryParams.append('limit', params.limit.toString());
    if (params?.sort) queryParams.append('sort', params.sort);
    if (params?.order) queryParams.append('order', params.order);
    if (params?.search) queryParams.append('search', params.search);
    if (params?.role) queryParams.append('role', params.role);
    if (params?.status) queryParams.append('status', params.status);
    if (params?.emailVerified !== undefined) queryParams.append('emailVerified', params.emailVerified.toString());
    if (params?.createdAfter) queryParams.append('createdAfter', params.createdAfter);
    if (params?.createdBefore) queryParams.append('createdBefore', params.createdBefore);

    const url = `/users${queryParams.toString() ? `?${queryParams.toString()}` : ''}`;
    return apiClient.get<User[]>(url);
  }

  // Get user by ID
  async getUserById(id: string): Promise<ApiResponse<User>> {
    return apiClient.get<User>(`/users/${id}`);
  }

  // Create new user
  async createUser(userData: CreateUserData): Promise<ApiResponse<User>> {
    return apiClient.post<User>('/users', userData);
  }

  // Update user
  async updateUser(id: string, userData: UpdateUserData): Promise<ApiResponse<User>> {
    return apiClient.put<User>(`/users/${id}`, userData);
  }

  // Delete user
  async deleteUser(id: string): Promise<ApiResponse<void>> {
    return apiClient.delete<void>(`/users/${id}`);
  }

  // Bulk delete users
  async bulkDeleteUsers(userIds: string[]): Promise<ApiResponse<{ deletedCount: number }>> {
    return apiClient.post<{ deletedCount: number }>('/users/bulk-delete', { userIds });
  }

  // Activate user
  async activateUser(id: string): Promise<ApiResponse<User>> {
    return apiClient.patch<User>(`/users/${id}/activate`, {});
  }

  // Deactivate user
  async deactivateUser(id: string): Promise<ApiResponse<User>> {
    return apiClient.patch<User>(`/users/${id}/deactivate`, {});
  }

  // Suspend user
  async suspendUser(id: string, reason?: string): Promise<ApiResponse<User>> {
    return apiClient.patch<User>(`/users/${id}/suspend`, { reason });
  }

  // Ban user
  async banUser(id: string, reason?: string): Promise<ApiResponse<User>> {
    return apiClient.patch<User>(`/users/${id}/ban`, { reason });
  }

  // Unban user
  async unbanUser(id: string): Promise<ApiResponse<User>> {
    return apiClient.patch<User>(`/users/${id}/unban`, {});
  }

  // Change user role
  async changeUserRole(id: string, role: string): Promise<ApiResponse<User>> {
    return apiClient.patch<User>(`/users/${id}/role`, { role });
  }

  // Reset user password
  async resetUserPassword(id: string, newPassword: string): Promise<ApiResponse<void>> {
    return apiClient.patch<void>(`/users/${id}/reset-password`, { newPassword });
  }

  // Get user statistics
  async getUserStats(): Promise<ApiResponse<{
    totalUsers: number;
    activeUsers: number;
    inactiveUsers: number;
    suspendedUsers: number;
    bannedUsers: number;
    usersByRole: Record<string, number>;
    recentRegistrations: number;
  }>> {
    return apiClient.get('/users/stats');
  }

  // Export users
  async exportUsers(params?: UserQueryParams): Promise<Blob> {
    const queryParams = new URLSearchParams();

    if (params?.page) queryParams.append('page', params.page.toString());
    if (params?.limit) queryParams.append('limit', params.limit.toString());
    if (params?.sort) queryParams.append('sort', params.sort);
    if (params?.order) queryParams.append('order', params.order);
    if (params?.search) queryParams.append('search', params.search);
    if (params?.role) queryParams.append('role', params.role);
    if (params?.status) queryParams.append('status', params.status);

    const url = `/users/export${queryParams.toString() ? `?${queryParams.toString()}` : ''}`;

    const response = await apiClient.getAxiosInstance().get(url, {
      responseType: 'blob',
    });

    return response.data;
  }
}

// Export singleton instance
export const userService = new UserService();
export default userService;