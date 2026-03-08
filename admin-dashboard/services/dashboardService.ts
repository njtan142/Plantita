import apiClient from '@/lib/api-client';
import {
  DashboardStats,
  Activity,
  ApiResponse
} from '@/types/api';

export class DashboardService {
  // Get dashboard statistics
  async getDashboardStats(): Promise<ApiResponse<DashboardStats>> {
    return apiClient.get<DashboardStats>('/dashboard/stats');
  }

  // Get recent activities
  async getRecentActivities(): Promise<ApiResponse<Activity[]>> {
    return apiClient.get<Activity[]>('/dashboard/activities');
  }
}

// Export singleton instance
export const dashboardService = new DashboardService();
export default dashboardService;