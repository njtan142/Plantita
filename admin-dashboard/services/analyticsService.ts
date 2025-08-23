import { AnalyticsData, AnalyticsQueryParams, ApiResponse } from '@/types/api';

export class AnalyticsService {
  // Mock data for analytics
  private mockAnalyticsData: AnalyticsData = {
    userGrowth: [
      { date: '2024-01-01', count: 100 },
      { date: '2024-01-02', count: 120 },
      { date: '2024-01-03', count: 145 },
      { date: '2024-01-04', count: 180 },
      { date: '2024-01-05', count: 210 },
      { date: '2024-01-06', count: 250 },
      { date: '2024-01-07', count: 300 },
    ],
    mediaUploads: [
      { date: '2024-01-01', count: 50 },
      { date: '2024-01-02', count: 65 },
      { date: '2024-01-03', count: 78 },
      { date: '2024-01-04', count: 90 },
      { date: '2024-01-05', count: 110 },
      { date: '2024-01-06', count: 130 },
      { date: '2024-01-07', count: 150 },
    ],
    engagementMetrics: [
      { date: '2024-01-01', likes: 200, comments: 50, shares: 30 },
      { date: '2024-01-02', likes: 250, comments: 60, shares: 35 },
      { date: '2024-01-03', likes: 300, comments: 75, shares: 40 },
      { date: '2024-01-04', likes: 350, comments: 80, shares: 45 },
      { date: '2024-01-05', likes: 400, comments: 90, shares: 50 },
      { date: '2024-01-06', likes: 450, comments: 100, shares: 55 },
      { date: '2024-01-07', likes: 500, comments: 110, shares: 60 },
    ],
    platformMetrics: {
      totalUsers: 1250,
      activeUsers: 850,
      totalMedia: 3500,
      storageUsed: 125000000000, // 125 GB in bytes
    },
  };

  // Simulate API delay
  private async simulateDelay(ms: number = 500): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  // Get analytics data
  async getAnalyticsData(params?: AnalyticsQueryParams): Promise<ApiResponse<AnalyticsData>> {
    await this.simulateDelay(800);
    
    // In a real implementation, we would filter the data based on params
    // For now, we'll just return the mock data
    return {
      success: true,
      data: this.mockAnalyticsData,
    };
  }

  // Get analytics data with error simulation (for testing error handling)
  async getAnalyticsDataWithError(): Promise<ApiResponse<AnalyticsData>> {
    await this.simulateDelay(800);
    
    // Simulate an error
    return {
      success: false,
      error: 'Failed to fetch analytics data',
      message: 'Unable to retrieve analytics data at this time. Please try again later.',
    };
  }
}

// Export singleton instance
export const analyticsService = new AnalyticsService();
export default analyticsService;