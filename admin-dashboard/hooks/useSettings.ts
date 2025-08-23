import { useQuery, useMutation, useQueryClient, UseQueryResult, UseMutationResult } from '@tanstack/react-query';
import { settingsService } from '@/services/settingsService';
import { PlatformSettings, SettingsUpdatePayload, ApiResponse } from '@/types/api';

// Custom hook to fetch platform settings
export const usePlatformSettings = (): UseQueryResult<PlatformSettings, Error> => {
  return useQuery<PlatformSettings, Error>({
    queryKey: ['platformSettings'],
    queryFn: async () => {
      const response = await settingsService.getPlatformSettings();
      
      if (!response.success) {
        throw new Error(response.error || 'Failed to fetch platform settings');
      }
      
      return response.data!;
    },
    // Retry failed queries up to 3 times
    retry: 3,
    // Cache data for 5 minutes
    staleTime: 1000 * 60 * 5,
    // Keep data in cache for 10 minutes after it's no longer active
    cacheTime: 1000 * 60 * 10,
  });
};

// Custom hook to update platform settings
export const useUpdateSettings = (): UseMutationResult<
  PlatformSettings,
  Error,
  SettingsUpdatePayload
> => {
  const queryClient = useQueryClient();
  
  return useMutation<PlatformSettings, Error, SettingsUpdatePayload>({
    mutationFn: async (payload: SettingsUpdatePayload) => {
      const response = await settingsService.updatePlatformSettings(payload);
      
      if (!response.success) {
        throw new Error(response.error || 'Failed to update platform settings');
      }
      
      return response.data!;
    },
    // Update the cache with the new data after successful mutation
    onSuccess: (data) => {
      queryClient.setQueryData(['platformSettings'], data);
    },
    // Invalidate the query to force a refetch after successful mutation
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['platformSettings'] });
    },
  });
};

// Custom hook to fetch platform settings with error simulation (for testing)
export const usePlatformSettingsWithError = (): UseQueryResult<PlatformSettings, Error> => {
  return useQuery<PlatformSettings, Error>({
    queryKey: ['platformSettingsWithError'],
    queryFn: async () => {
      const response = await settingsService.getPlatformSettingsWithError();
      
      if (!response.success) {
        throw new Error(response.error || 'Failed to fetch platform settings');
      }
      
      return response.data!;
    },
    // Don't retry failed queries for error testing
    retry: false,
    // Cache data for 1 minute
    staleTime: 1000 * 60,
  });
};

// Custom hook to update platform settings with error simulation (for testing)
export const useUpdateSettingsWithError = (): UseMutationResult<
  PlatformSettings,
  Error,
  SettingsUpdatePayload
> => {
  return useMutation<PlatformSettings, Error, SettingsUpdatePayload>({
    mutationFn: async (payload: SettingsUpdatePayload) => {
      const response = await settingsService.updatePlatformSettingsWithError(payload);
      
      if (!response.success) {
        throw new Error(response.error || 'Failed to update platform settings');
      }
      
      return response.data!;
    },
  });
};