import { renderHook, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import {
  useAnalyticsData,
  useAnalyticsDataWithError,
  useInvalidateAnalyticsData
} from '../hooks/useAnalytics';
import { analyticsService } from '@/services/analyticsService';

// Mock the analytics service
jest.mock('@/services/analyticsService', () => ({
  analyticsService: {
    getAnalyticsData: jest.fn(),
    getAnalyticsDataWithError: jest.fn(),
  },
}));

describe('useAnalytics hooks', () => {
  beforeEach(() => {
    jest.clearAllMocks();

    // Silence console.error for react-query expected errors in tests
    jest.spyOn(console, 'error').mockImplementation(() => {});
  });

  afterEach(() => {
    (console.error as jest.Mock).mockRestore();
  });

  const createWrapper = () => {
    const qc = new QueryClient({
      defaultOptions: {
        queries: {
          retry: false, // Disabling retry allows it to fail immediately
        },
      },
    });
    return ({ children }: { children: React.ReactNode }) => (
      <QueryClientProvider client={qc}>
        {children}
      </QueryClientProvider>
    );
  };

  const mockAnalyticsData = {
    userGrowth: [{ date: '2024-01-01', count: 100 }],
    mediaUploads: [{ date: '2024-01-01', count: 50 }],
    engagementMetrics: [{ date: '2024-01-01', likes: 200, comments: 50, shares: 30 }],
    platformMetrics: {
      totalUsers: 1250,
      activeUsers: 850,
      totalMedia: 3500,
      storageUsed: 125000000000,
    },
  };

  describe('useAnalyticsData', () => {
    it('should fetch and return analytics data on success', async () => {
      (analyticsService.getAnalyticsData as jest.Mock).mockResolvedValue({
        success: true,
        data: mockAnalyticsData,
      });

      const { result } = renderHook(() => useAnalyticsData(), { wrapper: createWrapper() });

      expect(result.current.isLoading).toBe(true);

      await waitFor(() => {
        expect(result.current.isSuccess).toBe(true);
      });

      expect(result.current.data).toEqual(mockAnalyticsData);
      expect(analyticsService.getAnalyticsData).toHaveBeenCalledTimes(1);
    });

    it('should handle API success false responses as errors', async () => {
      // Create a specific QueryClient with short retry times
      const qc = new QueryClient({
        defaultOptions: {
          queries: {
            retryDelay: 1, // extremely short delay to speed up retries
          }
        }
      });

      const specificWrapper = ({ children }: { children: React.ReactNode }) => (
        <QueryClientProvider client={qc}>
          {children}
        </QueryClientProvider>
      );

      (analyticsService.getAnalyticsData as jest.Mock).mockResolvedValue({
        success: false,
        error: 'Custom API Error',
      });

      const { result } = renderHook(() => useAnalyticsData(), { wrapper: specificWrapper });

      await waitFor(() => {
        expect(result.current.isError).toBe(true);
      });

      expect(result.current.error?.message).toBe('Custom API Error');
    });

    it('should provide default error message if missing from API', async () => {
      const qc = new QueryClient({
        defaultOptions: {
          queries: {
            retryDelay: 1,
          }
        }
      });

      const specificWrapper = ({ children }: { children: React.ReactNode }) => (
        <QueryClientProvider client={qc}>
          {children}
        </QueryClientProvider>
      );

      (analyticsService.getAnalyticsData as jest.Mock).mockResolvedValue({
        success: false,
      });

      const { result } = renderHook(() => useAnalyticsData(), { wrapper: specificWrapper });

      await waitFor(() => {
        expect(result.current.isError).toBe(true);
      });

      expect(result.current.error?.message).toBe('Failed to fetch analytics data');
    });

    it('should fetch with provided params', async () => {
      (analyticsService.getAnalyticsData as jest.Mock).mockResolvedValue({
        success: true,
        data: mockAnalyticsData,
      });

      const params = { period: '7d', platform: 'ios' };
      const { result } = renderHook(() => useAnalyticsData(params as any), { wrapper: createWrapper() });

      await waitFor(() => {
        expect(result.current.isSuccess).toBe(true);
      });

      expect(analyticsService.getAnalyticsData).toHaveBeenCalledWith(params);
    });
  });

  describe('useAnalyticsDataWithError', () => {
    it('should call getAnalyticsDataWithError and handle the error', async () => {
      (analyticsService.getAnalyticsDataWithError as jest.Mock).mockResolvedValue({
        success: false,
        error: 'Simulated failure',
      });

      const { result } = renderHook(() => useAnalyticsDataWithError(), { wrapper: createWrapper() });

      await waitFor(() => {
        expect(result.current.isError).toBe(true);
      });

      expect(result.current.error?.message).toBe('Simulated failure');
      expect(analyticsService.getAnalyticsDataWithError).toHaveBeenCalledTimes(1);
    });

    it('should handle successful case even though its an error simulation hook', async () => {
      (analyticsService.getAnalyticsDataWithError as jest.Mock).mockResolvedValue({
        success: true,
        data: mockAnalyticsData
      });

      const { result } = renderHook(() => useAnalyticsDataWithError(), { wrapper: createWrapper() });

      await waitFor(() => {
        expect(result.current.isSuccess).toBe(true);
      });

      expect(result.current.data).toEqual(mockAnalyticsData);
    });
  });

  describe('useInvalidateAnalyticsData', () => {
    it('should provide a function that invalidates the analyticsData query', () => {
      // Need a shared queryClient for this specific test so we can spy on it
      const qc = new QueryClient({
        defaultOptions: {
          queries: {
            retry: false,
          },
        },
      });
      const localWrapper = ({ children }: { children: React.ReactNode }) => (
        <QueryClientProvider client={qc}>
          {children}
        </QueryClientProvider>
      );

      const invalidateQueriesSpy = jest.spyOn(qc, 'invalidateQueries');

      const { result } = renderHook(() => useInvalidateAnalyticsData(), { wrapper: localWrapper });

      expect(typeof result.current.invalidateAnalyticsData).toBe('function');

      // Call the invalidate function
      result.current.invalidateAnalyticsData();

      // Verify queryClient.invalidateQueries was called with the correct queryKey
      expect(invalidateQueriesSpy).toHaveBeenCalledWith({ queryKey: ['analyticsData'] });

      invalidateQueriesSpy.mockRestore();
    });
  });
});
