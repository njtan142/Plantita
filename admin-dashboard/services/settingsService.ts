import apiClient from '@/lib/api-client';
import {
  PlatformSettings,
  SettingsUpdatePayload,
  ApiResponse
} from '@/types/api';

export class SettingsService {
  // Mock data for platform settings
  private mockPlatformSettings: PlatformSettings = {
    siteName: 'Plantita Admin',
    siteDescription: 'Admin dashboard for the Plantita platform',
    contactEmail: 'admin@plantita.com',
    maxFileSize: 10485760, // 10 MB
    allowedFileTypes: ['image/jpeg', 'image/png', 'image/gif', 'video/mp4'],
    userRegistration: true,
    emailVerification: true,
    maxLoginAttempts: 5
  };

  // Simulate API delay
  private async simulateDelay(ms: number = 500): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  // Get platform settings
  async getPlatformSettings(): Promise<ApiResponse<PlatformSettings>> {
    await this.simulateDelay(800);
    
    // In a real implementation, this would fetch from the API
    return {
      success: true,
      data: this.mockPlatformSettings,
    };
  }

  // Update platform settings
  async updatePlatformSettings(payload: SettingsUpdatePayload): Promise<ApiResponse<PlatformSettings>> {
    await this.simulateDelay(1000);
    
    // In a real implementation, this would send to the API
    // For now, we'll just update our mock data
    this.mockPlatformSettings = {
      ...this.mockPlatformSettings,
      ...payload
    };
    
    return {
      success: true,
      data: this.mockPlatformSettings,
    };
  }

  // Get platform settings with error simulation (for testing)
  async getPlatformSettingsWithError(): Promise<ApiResponse<PlatformSettings>> {
    await this.simulateDelay(800);
    
    // Simulate an error
    return {
      success: false,
      error: 'Failed to fetch platform settings',
      message: 'Unable to retrieve platform settings at this time. Please try again later.',
    };
  }

  // Update platform settings with error simulation (for testing)
  async updatePlatformSettingsWithError(payload: SettingsUpdatePayload): Promise<ApiResponse<PlatformSettings>> {
    await this.simulateDelay(1000);
    
    // Simulate an error
    return {
      success: false,
      error: 'Failed to update platform settings',
      message: 'Unable to update platform settings at this time. Please try again later.',
    };
  }
}

// Export singleton instance
export const settingsService = new SettingsService();
export default settingsService;