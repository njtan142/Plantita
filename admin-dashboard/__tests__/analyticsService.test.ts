import { analyticsService } from '../services/analyticsService';
import { AnalyticsData } from '../types/api';

describe('AnalyticsService', () => {
  beforeEach(() => {
    jest.useFakeTimers();
  });

  afterEach(() => {
    jest.useRealTimers();
    jest.clearAllMocks();
  });

  describe('getAnalyticsData', () => {
    it('should return mock analytics data', async () => {
      const result = await analyticsService.getAnalyticsData();
      
      expect(result.success).toBe(true);
      expect(result.data).toBeDefined();
      
      const data = result.data as AnalyticsData;
      expect(data.userGrowth).toHaveLength(7);
      expect(data.mediaUploads).toHaveLength(7);
      expect(data.engagementMetrics).toHaveLength(7);
      expect(data.platformMetrics).toBeDefined();
      
      // Check that the data has the expected structure
      expect(data.userGrowth[0]).toHaveProperty('date');
      expect(data.userGrowth[0]).toHaveProperty('count');
      expect(data.mediaUploads[0]).toHaveProperty('date');
      expect(data.mediaUploads[0]).toHaveProperty('count');
      expect(data.engagementMetrics[0]).toHaveProperty('date');
      expect(data.engagementMetrics[0]).toHaveProperty('likes');
      expect(data.engagementMetrics[0]).toHaveProperty('comments');
      expect(data.engagementMetrics[0]).toHaveProperty('shares');
      expect(data.platformMetrics).toHaveProperty('totalUsers');
      expect(data.platformMetrics).toHaveProperty('activeUsers');
      expect(data.platformMetrics).toHaveProperty('totalMedia');
      expect(data.platformMetrics).toHaveProperty('storageUsed');
    });

    it('should simulate API delay', async () => {
      const promise = analyticsService.getAnalyticsData();
      
      // Advance timers by 800ms (default delay)
      jest.advanceTimersByTime(800);
      
      const result = await promise;
      expect(result.success).toBe(true);
    });
  });

  describe('getAnalyticsDataWithError', () => {
    it('should return error response', async () => {
      const result = await analyticsService.getAnalyticsDataWithError();
      
      expect(result.success).toBe(false);
      expect(result.error).toBe('Failed to fetch analytics data');
      expect(result.message).toBe('Unable to retrieve analytics data at this time. Please try again later.');
    });

    it('should simulate API delay', async () => {
      const promise = analyticsService.getAnalyticsDataWithError();
      
      // Advance timers by 800ms (default delay)
      jest.advanceTimersByTime(800);
      
      const result = await promise;
      expect(result.success).toBe(false);
    });
  });
});