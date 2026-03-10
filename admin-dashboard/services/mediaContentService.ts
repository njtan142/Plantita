import { 
  Media, 
  MediaMetadata, 
  MediaEngagement, 
  MediaModeration,
  ApiResponse 
} from '@/types/api';
import { MOCK_MEDIAS } from '@/types/api';

export class MediaContentService {
  // Simulate API delay for mock data
  private async simulateDelay(ms: number = 500): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  // Fetch media by ID with all details
  async getMediaById(id: string): Promise<ApiResponse<Media>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(300);
    
    const media = MOCK_MEDIAS.find(m => m.id === id);
    
    if (media) {
      return {
        success: true,
        data: media
      };
    } else {
      return {
        success: false,
        error: 'Media not found',
        message: `Media with ID ${id} not found`
      };
    }
  }

  // Fetch detailed media metadata
  async getMediaMetadata(mediaId: string): Promise<ApiResponse<MediaMetadata>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(300);
    
    const media = MOCK_MEDIAS.find(m => m.id === mediaId);
    
    if (media && media.metadata) {
      return {
        success: true,
        data: media.metadata
      };
    } else if (media) {
      // Return empty metadata if not available
      return {
        success: true,
        data: {}
      };
    } else {
      return {
        success: false,
        error: 'Media not found',
        message: `Media with ID ${mediaId} not found`
      };
    }
  }

  // Fetch media engagement metrics
  async getMediaEngagement(mediaId: string): Promise<ApiResponse<MediaEngagement>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(300);
    
    const media = MOCK_MEDIAS.find(m => m.id === mediaId);
    
    if (media && media.engagement) {
      return {
        success: true,
        data: media.engagement
      };
    } else if (media) {
      // Return default engagement metrics if not available
      return {
        success: true,
        data: {
          views: 0,
          likes: 0,
          comments: 0,
          shares: 0,
          engagementRate: 0
        }
      };
    } else {
      return {
        success: false,
        error: 'Media not found',
        message: `Media with ID ${mediaId} not found`
      };
    }
  }

  // Get media moderation status
  async getMediaModeration(mediaId: string): Promise<ApiResponse<MediaModeration>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(300);
    
    const media = MOCK_MEDIAS.find(m => m.id === mediaId);
    
    if (media && media.moderation) {
      return {
        success: true,
        data: media.moderation
      };
    } else if (media) {
      // Return default moderation status if not available
      return {
        success: true,
        data: {
          status: 'pending',
          flags: [],
          warnings: [],
          category: 'uncategorized'
        }
      };
    } else {
      return {
        success: false,
        error: 'Media not found',
        message: `Media with ID ${mediaId} not found`
      };
    }
  }

  // Update media moderation status
  async updateMediaModeration(
    mediaId: string,
    moderationData: Partial<MediaModeration>
  ): Promise<ApiResponse<Media>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(300);

    const mediaIndex = MOCK_MEDIAS.findIndex(m => m.id === mediaId);

    if (mediaIndex === -1) {
      return {
        success: false,
        error: 'Media not found',
        message: `Media with ID ${mediaId} not found`
      };
    }

    // Update the moderation data
    const currentModeration = MOCK_MEDIAS[mediaIndex].moderation;
    if (!currentModeration) {
      return {
        success: false,
        error: 'Invalid media state',
        message: `Media with ID ${mediaId} has invalid moderation state`
      };
    }
    MOCK_MEDIAS[mediaIndex] = {
      ...MOCK_MEDIAS[mediaIndex],
      moderation: {
        status: moderationData.status ?? currentModeration.status,
        flags: moderationData.flags ?? currentModeration.flags,
        warnings: moderationData.warnings ?? currentModeration.warnings,
        category: moderationData.category ?? currentModeration.category,
      },
      updatedAt: new Date().toISOString()
    };
    
    return {
      success: true,
      data: MOCK_MEDIAS[mediaIndex]
    };
  }

  // Flag media content
  async flagMediaContent(
    mediaId: string, 
    flagType: string, 
    reason: string
  ): Promise<ApiResponse<Media>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(300);
    
    const mediaIndex = MOCK_MEDIAS.findIndex(m => m.id === mediaId);
    
    if (mediaIndex === -1) {
      return {
        success: false,
        error: 'Media not found',
        message: `Media with ID ${mediaId} not found`
      };
    }

    // Add flag to the media item
    const newFlag = {
      type: flagType,
      reason,
      timestamp: new Date().toISOString()
    };

    const currentModeration = MOCK_MEDIAS[mediaIndex].moderation;
    if (!currentModeration) {
      return {
        success: false,
        error: 'Invalid media state',
        message: `Media with ID ${mediaId} has invalid moderation state`
      };
    }
    MOCK_MEDIAS[mediaIndex] = {
      ...MOCK_MEDIAS[mediaIndex],
      moderation: {
        status: 'flagged',
        flags: [
          ...currentModeration.flags,
          newFlag
        ],
        warnings: currentModeration.warnings,
        category: currentModeration.category,
      },
      updatedAt: new Date().toISOString()
    };
    
    return {
      success: true,
      data: MOCK_MEDIAS[mediaIndex]
    };
  }

  // Add content warning
  async addContentWarning(mediaId: string, warning: string): Promise<ApiResponse<Media>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(300);

    const mediaIndex = MOCK_MEDIAS.findIndex(m => m.id === mediaId);

    if (mediaIndex === -1) {
      return {
        success: false,
        error: 'Media not found',
        message: `Media with ID ${mediaId} not found`
      };
    }

    const currentModeration = MOCK_MEDIAS[mediaIndex].moderation;
    if (!currentModeration) {
      return {
        success: false,
        error: 'Invalid media state',
        message: `Media with ID ${mediaId} has invalid moderation state`
      };
    }
    // Add warning to the media item
    MOCK_MEDIAS[mediaIndex] = {
      ...MOCK_MEDIAS[mediaIndex],
      moderation: {
        status: currentModeration.status,
        flags: currentModeration.flags,
        warnings: [
          ...currentModeration.warnings,
          warning
        ],
        category: currentModeration.category,
      },
      updatedAt: new Date().toISOString()
    };
    
    return {
      success: true,
      data: MOCK_MEDIAS[mediaIndex]
    };
  }

  // Batch update media items
  async batchUpdateMedia(
    mediaIds: string[], 
    updates: Partial<Media>
  ): Promise<ApiResponse<Media[]>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(500);
    
    const updatedMedia: Media[] = [];
    const errors: string[] = [];
    const updatedAt = new Date().toISOString();
    
    for (const mediaId of mediaIds) {
      const mediaIndex = MOCK_MEDIAS.findIndex(m => m.id === mediaId);
      
      if (mediaIndex === -1) {
        errors.push(`Media with ID ${mediaId} not found`);
        continue;
      }
      
      // Update the media item
      MOCK_MEDIAS[mediaIndex] = {
        ...MOCK_MEDIAS[mediaIndex],
        ...updates,
        updatedAt
      };
      
      updatedMedia.push(MOCK_MEDIAS[mediaIndex]);
    }
    
    if (errors.length > 0 && updatedMedia.length === 0) {
      return {
        success: false,
        error: 'Batch update failed',
        message: errors.join(', ')
      };
    }
    
    return {
      success: true,
      data: updatedMedia,
      message: errors.length > 0 
        ? `Successfully updated ${updatedMedia.length} items. Errors: ${errors.join(', ')}` 
        : `Successfully updated ${updatedMedia.length} items`
    };
  }

  // Batch moderate media items
  async batchModerateMedia(
    mediaIds: string[], 
    moderationStatus: 'approved' | 'rejected' | 'flagged'
  ): Promise<ApiResponse<Media[]>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(500);
    
    const updatedMedia: Media[] = [];
    const errors: string[] = [];
    const updatedAt = new Date().toISOString();
    
    for (const mediaId of mediaIds) {
      const mediaIndex = MOCK_MEDIAS.findIndex(m => m.id === mediaId);

      if (mediaIndex === -1) {
        errors.push(`Media with ID ${mediaId} not found`);
        continue;
      }

      const currentModeration = MOCK_MEDIAS[mediaIndex].moderation;
      if (!currentModeration) {
        errors.push(`Media with ID ${mediaId} has invalid moderation state`);
        continue;
      }
      // Update the moderation status
      MOCK_MEDIAS[mediaIndex] = {
        ...MOCK_MEDIAS[mediaIndex],
        moderation: {
          status: moderationStatus,
          flags: currentModeration.flags,
          warnings: currentModeration.warnings,
          category: currentModeration.category,
        },
        updatedAt
      };
      
      updatedMedia.push(MOCK_MEDIAS[mediaIndex]);
    }
    
    if (errors.length > 0 && updatedMedia.length === 0) {
      return {
        success: false,
        error: 'Batch moderation failed',
        message: errors.join(', ')
      };
    }
    
    return {
      success: true,
      data: updatedMedia,
      message: errors.length > 0 
        ? `Successfully moderated ${updatedMedia.length} items. Errors: ${errors.join(', ')}` 
        : `Successfully moderated ${updatedMedia.length} items`
    };
  }
}

// Export singleton instance
export const mediaContentService = new MediaContentService();
export default mediaContentService;