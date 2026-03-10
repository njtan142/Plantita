import apiClient from '@/lib/api-client';
import {
  User,
  UserActivity,
  UserStatistics,
  Media,
  ApiResponse,
  UserStatus
} from '@/types/api';
import { MOCK_USERS, MOCK_USER_ACTIVITIES, MOCK_USER_STATISTICS, MOCK_MEDIAS } from '@/types/api';

export class UserContentService {
  // Simulate API delay for mock data
  private async simulateDelay(ms: number = 500): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  // Fetch user by ID
  async getUserById(id: string): Promise<ApiResponse<User>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(300);
    
    const user = MOCK_USERS.find(u => u.id === id);
    
    if (user) {
      return {
        success: true,
        data: user
      };
    } else {
      return {
        success: false,
        error: 'User not found',
        message: `User with ID ${id} not found`
      };
    }
  }

  // Fetch user activity history
  async getUserActivityHistory(userId: string): Promise<ApiResponse<UserActivity[]>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(300);
    
    const activities = MOCK_USER_ACTIVITIES.filter(activity => activity.userId === userId);
    
    return {
      success: true,
      data: activities
    };
  }

  // Fetch user media content
  async getUserMediaContent(userId: string): Promise<ApiResponse<Media[]>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(300);
    
    const media = MOCK_MEDIAS.filter(m => m.uploadedBy === userId);
    
    return {
      success: true,
      data: media
    };
  }

  // Calculate user statistics
  async getUserStatistics(userId: string): Promise<ApiResponse<UserStatistics>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(300);
    
    const statistics = MOCK_USER_STATISTICS[userId];
    
    if (statistics) {
      return {
        success: true,
        data: statistics
      };
    } else {
      // Return default statistics if not found
      return {
        success: true,
        data: {
          totalUploads: 0,
          totalLikes: 0,
          totalComments: 0,
          totalViews: 0,
          engagementRate: 0,
          reportedContent: 0
        }
      };
    }
  }

  // Get complete user content profile (combines all data)
  async getUserContentProfile(userId: string): Promise<ApiResponse<{
    user: User;
    activity: UserActivity[];
    media: Media[];
    statistics: UserStatistics;
  }>> {
    // In a real implementation, these would be parallel API calls
    // For now, we'll use mock data
    
    // Get user
    const userResponse = await this.getUserById(userId);
    if (!userResponse.success || !userResponse.data) {
      return {
        success: false,
        error: 'User not found',
        message: `User with ID ${userId} not found`
      };
    }
    
    // Get user activity
    const activityResponse = await this.getUserActivityHistory(userId);
    if (!activityResponse.success || !activityResponse.data) {
      return {
        success: false,
        error: 'Failed to fetch user activity',
        message: activityResponse.message || 'Unable to retrieve user activity history'
      };
    }

    // Get user media
    const mediaResponse = await this.getUserMediaContent(userId);
    if (!mediaResponse.success || !mediaResponse.data) {
      return {
        success: false,
        error: 'Failed to fetch user media',
        message: mediaResponse.message || 'Unable to retrieve user media content'
      };
    }

    // Get user statistics
    const statsResponse = await this.getUserStatistics(userId);
    if (!statsResponse.success || !statsResponse.data) {
      return {
        success: false,
        error: 'Failed to fetch user statistics',
        message: statsResponse.message || 'Unable to retrieve user statistics'
      };
    }

    return {
      success: true,
      data: {
        user: userResponse.data,
        activity: activityResponse.data,
        media: mediaResponse.data,
        statistics: statsResponse.data
      }
    };
  }

  // Suspend user
  async suspendUser(id: string, reason?: string): Promise<ApiResponse<User>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(300);
    
    const userIndex = MOCK_USERS.findIndex(u => u.id === id);
    if (userIndex === -1) {
      return {
        success: false,
        error: 'User not found',
        message: `User with ID ${id} not found`
      };
    }

    MOCK_USERS[userIndex].status = UserStatus.SUSPENDED;
    MOCK_USERS[userIndex].updatedAt = new Date().toISOString();

    return {
      success: true,
      data: MOCK_USERS[userIndex]
    };
  }

  // Ban user
  async banUser(id: string, reason?: string): Promise<ApiResponse<User>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(300);

    const userIndex = MOCK_USERS.findIndex(u => u.id === id);
    if (userIndex === -1) {
      return {
        success: false,
        error: 'User not found',
        message: `User with ID ${id} not found`
      };
    }

    MOCK_USERS[userIndex].status = UserStatus.BANNED;
    MOCK_USERS[userIndex].updatedAt = new Date().toISOString();

    return {
      success: true,
      data: MOCK_USERS[userIndex]
    };
  }

  // Reset user password
  async resetUserPassword(id: string, newPassword: string): Promise<ApiResponse<void>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(300);
    
    const user = MOCK_USERS.find(u => u.id === id);
    if (!user) {
      return {
        success: false,
        error: 'User not found',
        message: `User with ID ${id} not found`
      };
    }
    
    // In a real implementation, we would hash the password and update it in the database
    // For mock purposes, we'll just return success
    
    return {
      success: true,
      message: 'Password reset successfully'
    };
  }
}

// Export singleton instance
export const userContentService = new UserContentService();
export default userContentService;