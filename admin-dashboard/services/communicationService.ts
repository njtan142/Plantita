import { 
  CommunicationTemplate, 
  PlatformAnnouncement, 
  MessageTracking,
  ApiResponse 
} from '@/types/api';
import { 
  MOCK_COMMUNICATION_TEMPLATES, 
  MOCK_PLATFORM_ANNOUNCEMENTS, 
  MOCK_MESSAGE_TRACKING 
} from '@/types/api';

export class CommunicationService {
  // Simulate API delay for mock data
  private async simulateDelay(ms: number = 500): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  // Send individual message
  async sendIndividualMessage(
    userId: string, 
    subject: string, 
    body: string, 
    type: 'email' | 'notification' = 'email'
  ): Promise<ApiResponse<{ messageId: string }>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(800);
    
    // Generate a mock message ID
    const messageId = `msg-${Date.now()}-${Math.floor(Math.random() * 1000)}`;
    
    console.log(`Sending ${type} to user ${userId}: ${subject}`);
    
    return {
      success: true,
      data: { messageId }
    };
  }

  // Send bulk messages
  async sendBulkMessages(
    userIds: string[], 
    subject: string, 
    body: string, 
    type: 'email' | 'notification' = 'email'
  ): Promise<ApiResponse<{ messageId: string; totalSent: number }>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(1500);
    
    // Generate a mock message ID
    const messageId = `msg-${Date.now()}-${Math.floor(Math.random() * 1000)}`;
    
    console.log(`Sending bulk ${type} to ${userIds.length} users: ${subject}`);
    
    return {
      success: true,
      data: { 
        messageId,
        totalSent: userIds.length
      }
    };
  }

  // Create platform announcement
  async createPlatformAnnouncement(
    announcement: Omit<PlatformAnnouncement, 'id'>
  ): Promise<ApiResponse<PlatformAnnouncement>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(800);
    
    // Generate a mock ID
    const id = `announcement-${Date.now()}-${Math.floor(Math.random() * 1000)}`;
    
    const newAnnouncement: PlatformAnnouncement = {
      ...announcement,
      id
    };
    
    console.log(`Creating platform announcement: ${announcement.title}`);
    
    return {
      success: true,
      data: newAnnouncement
    };
  }

  // Update platform announcement
  async updatePlatformAnnouncement(
    id: string,
    announcement: Partial<Omit<PlatformAnnouncement, 'id'>>
  ): Promise<ApiResponse<PlatformAnnouncement>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(800);
    
    // Find existing announcement
    const existing = MOCK_PLATFORM_ANNOUNCEMENTS.find(a => a.id === id);
    if (!existing) {
      return {
        success: false,
        error: 'Announcement not found',
        message: `Platform announcement with ID ${id} not found`
      };
    }
    
    const updatedAnnouncement: PlatformAnnouncement = {
      ...existing,
      ...announcement
    };
    
    console.log(`Updating platform announcement: ${id}`);
    
    return {
      success: true,
      data: updatedAnnouncement
    };
  }

  // Delete platform announcement
  async deletePlatformAnnouncement(id: string): Promise<ApiResponse<void>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(800);
    
    // Check if announcement exists
    const existing = MOCK_PLATFORM_ANNOUNCEMENTS.find(a => a.id === id);
    if (!existing) {
      return {
        success: false,
        error: 'Announcement not found',
        message: `Platform announcement with ID ${id} not found`
      };
    }
    
    console.log(`Deleting platform announcement: ${id}`);
    
    return {
      success: true
    };
  }

  // Get all platform announcements
  async getPlatformAnnouncements(): Promise<ApiResponse<PlatformAnnouncement[]>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(800);
    
    return {
      success: true,
      data: MOCK_PLATFORM_ANNOUNCEMENTS
    };
  }

  // Get communication template by ID
  async getTemplateById(id: string): Promise<ApiResponse<CommunicationTemplate>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(500);
    
    const template = MOCK_COMMUNICATION_TEMPLATES.find(t => t.id === id);
    
    if (template) {
      return {
        success: true,
        data: template
      };
    } else {
      return {
        success: false,
        error: 'Template not found',
        message: `Communication template with ID ${id} not found`
      };
    }
  }

  // Get all communication templates
  async getAllTemplates(): Promise<ApiResponse<CommunicationTemplate[]>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(800);
    
    return {
      success: true,
      data: MOCK_COMMUNICATION_TEMPLATES
    };
  }

  // Create communication template
  async createTemplate(
    template: Omit<CommunicationTemplate, 'id'>
  ): Promise<ApiResponse<CommunicationTemplate>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(800);
    
    // Generate a mock ID
    const id = `template-${Date.now()}-${Math.floor(Math.random() * 1000)}`;
    
    const newTemplate: CommunicationTemplate = {
      ...template,
      id
    };
    
    console.log(`Creating communication template: ${template.name}`);
    
    return {
      success: true,
      data: newTemplate
    };
  }

  // Update communication template
  async updateTemplate(
    id: string,
    template: Partial<Omit<CommunicationTemplate, 'id'>>
  ): Promise<ApiResponse<CommunicationTemplate>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(800);
    
    // Find existing template
    const existing = MOCK_COMMUNICATION_TEMPLATES.find(t => t.id === id);
    if (!existing) {
      return {
        success: false,
        error: 'Template not found',
        message: `Communication template with ID ${id} not found`
      };
    }
    
    const updatedTemplate: CommunicationTemplate = {
      ...existing,
      ...template
    };
    
    console.log(`Updating communication template: ${id}`);
    
    return {
      success: true,
      data: updatedTemplate
    };
  }

  // Delete communication template
  async deleteTemplate(id: string): Promise<ApiResponse<void>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(800);
    
    // Check if template exists
    const existing = MOCK_COMMUNICATION_TEMPLATES.find(t => t.id === id);
    if (!existing) {
      return {
        success: false,
        error: 'Template not found',
        message: `Communication template with ID ${id} not found`
      };
    }
    
    console.log(`Deleting communication template: ${id}`);
    
    return {
      success: true
    };
  }

  // Get message tracking data
  async getMessageTracking(messageId: string): Promise<ApiResponse<MessageTracking>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(500);
    
    const tracking = MOCK_MESSAGE_TRACKING.find(t => t.messageId === messageId);
    
    if (tracking) {
      return {
        success: true,
        data: tracking
      };
    } else {
      // Return default tracking data for a message that hasn't been tracked yet
      return {
        success: true,
        data: {
          messageId,
          sentAt: new Date().toISOString(),
          delivered: 0,
          opened: 0,
          clicked: 0
        }
      };
    }
  }

  // Get all message tracking data (for reporting)
  async getAllMessageTracking(): Promise<ApiResponse<MessageTracking[]>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(1000);
    
    return {
      success: true,
      data: MOCK_MESSAGE_TRACKING
    };
  }

  // Send message with template
  async sendMessageWithTemplate(
    userIds: string | string[], 
    templateId: string, 
    variables: Record<string, string>
  ): Promise<ApiResponse<{ messageId: string; totalSent?: number }>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(1000);
    
    // Get the template
    const templateResponse = await this.getTemplateById(templateId);
    if (!templateResponse.success || !templateResponse.data) {
      return {
        success: false,
        error: 'Template not found',
        message: templateResponse.message || 'Failed to retrieve template'
      };
    }
    
    const template = templateResponse.data;
    
    // Replace variables in the template
    let subject = template.subject;
    let body = template.body;
    
    for (const [key, value] of Object.entries(variables)) {
      const placeholder = `{{${key}}}`;
      subject = subject.replace(new RegExp(placeholder, 'g'), value);
      body = body.replace(new RegExp(placeholder, 'g'), value);
    }
    
    // Determine if this is a single or bulk message
    if (typeof userIds === 'string') {
      // Single message
      const response = await this.sendIndividualMessage(userIds, subject, body, template.type);
      return response;
    } else {
      // Bulk message
      const response = await this.sendBulkMessages(userIds, subject, body, template.type);
      return response;
    }
  }
}

// Export singleton instance
export const communicationService = new CommunicationService();
export default communicationService;