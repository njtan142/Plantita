import { settingsService } from '../services/settingsService';
import { PlatformSettings } from '../types/api';

describe('SettingsService', () => {
  beforeEach(() => {
    jest.useFakeTimers();
  });

  afterEach(() => {
    jest.useRealTimers();
    jest.clearAllMocks();
  });

  describe('getPlatformSettings', () => {
    it('should return mock platform settings', async () => {
      const result = await settingsService.getPlatformSettings();
      
      expect(result.success).toBe(true);
      expect(result.data).toBeDefined();
      
      const data = result.data as PlatformSettings;
      expect(data.siteName).toBe('Plantita Admin');
      expect(data.siteDescription).toBe('Admin dashboard for the Plantita platform');
      expect(data.contactEmail).toBe('admin@plantita.com');
      expect(data.maxFileSize).toBe(10485760);
      expect(data.allowedFileTypes).toEqual(['image/jpeg', 'image/png', 'image/gif', 'video/mp4']);
      expect(data.userRegistration).toBe(true);
      expect(data.emailVerification).toBe(true);
      expect(data.maxLoginAttempts).toBe(5);
    });

    it('should simulate API delay', async () => {
      const promise = settingsService.getPlatformSettings();
      
      // Advance timers by 800ms (default delay)
      jest.advanceTimersByTime(800);
      
      const result = await promise;
      expect(result.success).toBe(true);
    });
  });

  describe('updatePlatformSettings', () => {
    it('should update platform settings', async () => {
      const updateData = {
        siteName: 'Updated Plantita Admin',
        maxLoginAttempts: 10
      };
      
      const result = await settingsService.updatePlatformSettings(updateData);
      
      expect(result.success).toBe(true);
      expect(result.data).toBeDefined();
      
      const data = result.data as PlatformSettings;
      expect(data.siteName).toBe('Updated Plantita Admin');
      expect(data.maxLoginAttempts).toBe(10);
    });

    it('should simulate API delay', async () => {
      const updateData = { siteName: 'Test' };
      const promise = settingsService.updatePlatformSettings(updateData);
      
      // Advance timers by 1000ms (update delay)
      jest.advanceTimersByTime(1000);
      
      const result = await promise;
      expect(result.success).toBe(true);
    });
  });

  describe('getPlatformSettingsWithError', () => {
    it('should return error response', async () => {
      const result = await settingsService.getPlatformSettingsWithError();
      
      expect(result.success).toBe(false);
      expect(result.error).toBe('Failed to fetch platform settings');
      expect(result.message).toBe('Unable to retrieve platform settings at this time. Please try again later.');
    });

    it('should simulate API delay', async () => {
      const promise = settingsService.getPlatformSettingsWithError();
      
      // Advance timers by 800ms (default delay)
      jest.advanceTimersByTime(800);
      
      const result = await promise;
      expect(result.success).toBe(false);
    });
  });

  describe('updatePlatformSettingsWithError', () => {
    it('should return error response', async () => {
      const updateData = { siteName: 'Test' };
      const result = await settingsService.updatePlatformSettingsWithError(updateData);
      
      expect(result.success).toBe(false);
      expect(result.error).toBe('Failed to update platform settings');
      expect(result.message).toBe('Unable to update platform settings at this time. Please try again later.');
    });

    it('should simulate API delay', async () => {
      const updateData = { siteName: 'Test' };
      const promise = settingsService.updatePlatformSettingsWithError(updateData);
      
      // Advance timers by 1000ms (update delay)
      jest.advanceTimersByTime(1000);
      
      const result = await promise;
      expect(result.success).toBe(false);
    });
  });
});