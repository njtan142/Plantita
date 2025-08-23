import { useQuery, useQueryClient, UseQueryResult } from '@tanstack/react-query';
import { analyticsService } from '@/services/analyticsService';
import { AnalyticsData, AnalyticsQueryParams, ApiResponse } from '@/types/api';

// Custom hook to fetch analytics data
export const useAnalyticsData = (
  params?: AnalyticsQueryParams
): UseQueryResult<AnalyticsData, Error> => {
  return useQuery<AnalyticsData, Error>({
    queryKey: ['analyticsData', params],
    queryFn: async () => {
      const response = await analyticsService.getAnalyticsData(params);
      
      if (!response.success) {
        throw new Error(response.error || 'Failed to fetch analytics data');
      }
      
      return response.data!;
    },
    // Retry failed queries up to 3 times
    retry: 3,
    // Cache data for 5 minutes
    staleTime: 1000 * 60 * 5,
    // Keep data in cache for 10 minutes after it's no longer active
    gcTime: 1000 * 60 * 10,
  });
};

// Custom hook to fetch analytics data with error simulation (for testing)
export const useAnalyticsDataWithError = (): UseQueryResult<AnalyticsData, Error> => {
  return useQuery<AnalyticsData, Error>({
    queryKey: ['analyticsDataWithError'],
    queryFn: async () => {
      const response = await analyticsService.getAnalyticsDataWithError();
      
      if (!response.success) {
        throw new Error(response.error || 'Failed to fetch analytics data');
      }
      
      return response.data!;
    },
    // Don't retry failed queries for error testing
    retry: false,
    // Cache data for 1 minute
    staleTime: 1000 * 60,
    // Keep data in cache for 2 minutes after it's no longer active
    gcTime: 1000 * 60 * 2,
  });
};

// Custom hook to invalidate analytics data queries
export const useInvalidateAnalyticsData = () => {
  const queryClient = useQueryClient();
  
  return {
    invalidateAnalyticsData: () => {
      queryClient.invalidateQueries({ queryKey: ['analyticsData'] });
    },
  };
};