import { renderHook, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import React, { ReactNode } from 'react';
import {
  usePlatformSettings,
  useUpdateSettings,
  usePlatformSettingsWithError,
  useUpdateSettingsWithError
} from '../hooks/useSettings';
import { settingsService } from '../services/settingsService';
import { PlatformSettings } from '../types/api';

// Mock the settingsService
jest.mock('../services/settingsService', () => ({
  settingsService: {
    getPlatformSettings: jest.fn(),
    updatePlatformSettings: jest.fn(),
    getPlatformSettingsWithError: jest.fn(),
    updatePlatformSettingsWithError: jest.fn(),
  },
}));

const mockSettings: PlatformSettings = {
  siteName: 'Test Site',
  siteDescription: 'Test Description',
  contactEmail: 'test@example.com',
  maxFileSize: 5000000,
  allowedFileTypes: ['image/jpeg', 'image/png'],
  userRegistration: true,
  emailVerification: false,
  maxLoginAttempts: 3,
};

describe('useSettings hooks', () => {
  let queryClient: QueryClient;

  beforeEach(() => {
    jest.clearAllMocks();
    queryClient = new QueryClient({
      defaultOptions: {
        queries: {
          retry: false, // Disable retries for faster tests
        },
      },
    });
  });

  const wrapper = ({ children }: { children: ReactNode }) => (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  );

  describe('usePlatformSettings', () => {
    it('should fetch platform settings successfully', async () => {
      (settingsService.getPlatformSettings as jest.Mock).mockResolvedValueOnce({
        success: true,
        data: mockSettings,
      });

      const { result } = renderHook(() => usePlatformSettings(), { wrapper });

      expect(result.current.isLoading).toBe(true);

      await waitFor(() => {
        expect(result.current.isSuccess).toBe(true);
      });

      expect(result.current.data).toEqual(mockSettings);
      expect(settingsService.getPlatformSettings).toHaveBeenCalledTimes(1);
    });

    it('should handle fetch failure', async () => {
      const errorMessage = 'Network Error';
      // Because the hook explicitly sets retry: 3, mock needs to return error multiple times
      // for the waitfor to eventually catch the final error
      (settingsService.getPlatformSettings as jest.Mock)
        .mockResolvedValueOnce({
          success: false,
          error: errorMessage,
        })
        .mockResolvedValueOnce({
          success: false,
          error: errorMessage,
        })
        .mockResolvedValueOnce({
          success: false,
          error: errorMessage,
        })
        .mockResolvedValueOnce({
          success: false,
          error: errorMessage,
        });

      // The default behavior is to retry. The retry delay defaults to exponential backoff.
      // So we have to provide a custom retryDelay so it doesn't take forever, or we can clear query cache.
      const queryClientFastRetry = new QueryClient({
        defaultOptions: {
          queries: {
            retry: 3,
            retryDelay: 1,
          },
        },
      });

      const wrapperFastRetry = ({ children }: { children: ReactNode }) => (
        <QueryClientProvider client={queryClientFastRetry}>{children}</QueryClientProvider>
      );

      const { result } = renderHook(() => usePlatformSettings(), { wrapper: wrapperFastRetry });

      await waitFor(() => {
        expect(result.current.isError).toBe(true);
      });

      expect(result.current.error?.message).toBe(errorMessage);
    });

    it('should use default error message if error is empty', async () => {
      (settingsService.getPlatformSettings as jest.Mock)
        .mockResolvedValueOnce({
          success: false,
        })
        .mockResolvedValueOnce({
          success: false,
        })
        .mockResolvedValueOnce({
          success: false,
        })
        .mockResolvedValueOnce({
          success: false,
        });

      const queryClientFastRetry = new QueryClient({
        defaultOptions: {
          queries: {
            retry: 3,
            retryDelay: 1,
          },
        },
      });

      const wrapperFastRetry = ({ children }: { children: ReactNode }) => (
        <QueryClientProvider client={queryClientFastRetry}>{children}</QueryClientProvider>
      );

      const { result } = renderHook(() => usePlatformSettings(), { wrapper: wrapperFastRetry });

      await waitFor(() => {
        expect(result.current.isError).toBe(true);
      });

      expect(result.current.error?.message).toBe('Failed to fetch platform settings');
    });
  });

  describe('useUpdateSettings', () => {
    it('should update platform settings successfully', async () => {
      const payload = { siteName: 'Updated Site' };
      const updatedSettings = { ...mockSettings, ...payload };

      (settingsService.updatePlatformSettings as jest.Mock).mockResolvedValueOnce({
        success: true,
        data: updatedSettings,
      });

      const { result } = renderHook(() => useUpdateSettings(), { wrapper });

      result.current.mutate(payload);

      await waitFor(() => {
        expect(result.current.isSuccess).toBe(true);
      });

      expect(result.current.data).toEqual(updatedSettings);
      expect(settingsService.updatePlatformSettings).toHaveBeenCalledWith(payload);

      // Verify that queryClient updated the cache
      const cachedData = queryClient.getQueryData(['platformSettings']);
      expect(cachedData).toEqual(updatedSettings);
    });

    it('should handle update failure', async () => {
      const payload = { siteName: 'Failing Site' };
      const errorMessage = 'Failed to update';

      (settingsService.updatePlatformSettings as jest.Mock).mockResolvedValueOnce({
        success: false,
        error: errorMessage,
      });

      const { result } = renderHook(() => useUpdateSettings(), { wrapper });

      result.current.mutate(payload);

      await waitFor(() => {
        expect(result.current.isError).toBe(true);
      });

      expect(result.current.error?.message).toBe(errorMessage);
    });

    it('should use default error message if error is empty on update failure', async () => {
      const payload = { siteName: 'Failing Site' };

      (settingsService.updatePlatformSettings as jest.Mock).mockResolvedValueOnce({
        success: false,
      });

      const { result } = renderHook(() => useUpdateSettings(), { wrapper });

      result.current.mutate(payload);

      await waitFor(() => {
        expect(result.current.isError).toBe(true);
      });

      expect(result.current.error?.message).toBe('Failed to update platform settings');
    });
  });

  describe('usePlatformSettingsWithError', () => {
    it('should handle fetch failure simulation', async () => {
      const errorMessage = 'Simulated fetch error';
      (settingsService.getPlatformSettingsWithError as jest.Mock).mockResolvedValueOnce({
        success: false,
        error: errorMessage,
      });

      const { result } = renderHook(() => usePlatformSettingsWithError(), { wrapper });

      await waitFor(() => {
        expect(result.current.isError).toBe(true);
      });

      expect(result.current.error?.message).toBe(errorMessage);
      expect(settingsService.getPlatformSettingsWithError).toHaveBeenCalledTimes(1);
    });

    it('should handle fetch failure simulation with default message', async () => {
      (settingsService.getPlatformSettingsWithError as jest.Mock).mockResolvedValueOnce({
        success: false,
      });

      const { result } = renderHook(() => usePlatformSettingsWithError(), { wrapper });

      await waitFor(() => {
        expect(result.current.isError).toBe(true);
      });

      expect(result.current.error?.message).toBe('Failed to fetch platform settings');
    });

    it('should handle successful fetch simulation', async () => {
      (settingsService.getPlatformSettingsWithError as jest.Mock).mockResolvedValueOnce({
        success: true,
        data: mockSettings,
      });

      const { result } = renderHook(() => usePlatformSettingsWithError(), { wrapper });

      await waitFor(() => {
        expect(result.current.isSuccess).toBe(true);
      });

      expect(result.current.data).toEqual(mockSettings);
    });
  });

  describe('useUpdateSettingsWithError', () => {
    it('should handle update failure simulation', async () => {
      const payload = { siteName: 'Error Site' };
      const errorMessage = 'Simulated update error';

      (settingsService.updatePlatformSettingsWithError as jest.Mock).mockResolvedValueOnce({
        success: false,
        error: errorMessage,
      });

      const { result } = renderHook(() => useUpdateSettingsWithError(), { wrapper });

      result.current.mutate(payload);

      await waitFor(() => {
        expect(result.current.isError).toBe(true);
      });

      expect(result.current.error?.message).toBe(errorMessage);
      expect(settingsService.updatePlatformSettingsWithError).toHaveBeenCalledWith(payload);
    });

    it('should handle update failure simulation with default message', async () => {
      const payload = { siteName: 'Error Site' };

      (settingsService.updatePlatformSettingsWithError as jest.Mock).mockResolvedValueOnce({
        success: false,
      });

      const { result } = renderHook(() => useUpdateSettingsWithError(), { wrapper });

      result.current.mutate(payload);

      await waitFor(() => {
        expect(result.current.isError).toBe(true);
      });

      expect(result.current.error?.message).toBe('Failed to update platform settings');
    });

    it('should handle successful update simulation', async () => {
      const payload = { siteName: 'Simulated Success Site' };
      const updatedSettings = { ...mockSettings, ...payload };

      (settingsService.updatePlatformSettingsWithError as jest.Mock).mockResolvedValueOnce({
        success: true,
        data: updatedSettings,
      });

      const { result } = renderHook(() => useUpdateSettingsWithError(), { wrapper });

      result.current.mutate(payload);

      await waitFor(() => {
        expect(result.current.isSuccess).toBe(true);
      });

      expect(result.current.data).toEqual(updatedSettings);
    });
  });
});
