import { 
  UserGrowthReport, 
  MediaTrendsReport, 
  ModerationStats,
  ApiResponse 
} from '@/types/api';
import { 
  MOCK_USER_GROWTH_REPORT, 
  MOCK_MEDIA_TRENDS_REPORT, 
  MOCK_MODERATION_STATS 
} from '@/types/api';

export class ReportingService {
  // Simulate API delay for mock data
  private async simulateDelay(ms: number = 500): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  // Generate user growth report
  async getUserGrowthReport(): Promise<ApiResponse<UserGrowthReport>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(800);
    
    return {
      success: true,
      data: MOCK_USER_GROWTH_REPORT
    };
  }

  // Generate media trends report
  async getMediaTrendsReport(): Promise<ApiResponse<MediaTrendsReport>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(800);
    
    return {
      success: true,
      data: MOCK_MEDIA_TRENDS_REPORT
    };
  }

  // Generate moderation statistics report
  async getModerationStats(): Promise<ApiResponse<ModerationStats>> {
    // In a real implementation, this would call an API
    // For now, we'll use mock data
    await this.simulateDelay(800);
    
    return {
      success: true,
      data: MOCK_MODERATION_STATS
    };
  }

  // Export report as CSV (mock implementation)
  async exportReportAsCSV(reportType: 'userGrowth' | 'mediaTrends' | 'moderation'): Promise<ApiResponse<Blob>> {
    // In a real implementation, this would generate and return a CSV file
    // For now, we'll simulate the operation
    await this.simulateDelay(1000);
    
    // Create a simple mock CSV content
    let csvContent = '';
    switch (reportType) {
      case 'userGrowth':
        csvContent = 'Date,Registrations\n2024-01-01,15\n2024-01-02,12\n2024-01-03,18';
        break;
      case 'mediaTrends':
        csvContent = 'Category,Uploads\nNature,124\nFamily,87\nPlants,203';
        break;
      case 'moderation':
        csvContent = 'Status,Count\nFlagged,24\nResolved,18\nPending,6';
        break;
    }
    
    // Create a Blob with the CSV content
    const blob = new Blob([csvContent], { type: 'text/csv' });
    
    return {
      success: true,
      data: blob
    };
  }

  // Export report as PDF (mock implementation)
  async exportReportAsPDF(reportType: 'userGrowth' | 'mediaTrends' | 'moderation'): Promise<ApiResponse<Blob>> {
    // In a real implementation, this would generate and return a PDF file
    // For now, we'll simulate the operation
    await this.simulateDelay(1200);
    
    // Create a simple mock PDF content (in reality, this would be actual PDF data)
    const pdfContent = `%PDF-1.4
%âãÏÓ
1 0 obj
<<
/Type /Catalog
/Pages 2 0 R
>>
endobj
2 0 obj
<<
/Type /Pages
/Kids [3 0 R]
/Count 1
>>
endobj
3 0 obj
<<
/Type /Page
/Parent 2 0 R
/MediaBox [0 0 612 792]
/Contents 4 0 R
/Resources <<
/Font <<
/F1 5 0 R
>>
>>
>>
endobj
4 0 obj
<<
/Length 44
>>
stream
BT
/F1 12 Tf
72 720 Td
(Report: ${reportType}) Tj
ET
endstream
endobj
5 0 obj
<<
/Type /Font
/Subtype /Type1
/BaseFont /Helvetica
>>
endobj
xref
0 6
0000000000 65535 f 
0000000010 00000 n 
0000000053 00000 n 
0000000114 00000 n 
0000000228 00000 n 
0000000325 00000 n 
trailer
<<
/Size 6
/Root 1 0 R
>>
startxref
431
%%EOF`;
    
    // Create a Blob with the PDF content
    const blob = new Blob([pdfContent], { type: 'application/pdf' });
    
    return {
      success: true,
      data: blob
    };
  }

  // Generate user growth report with error simulation (for testing error handling)
  async getUserGrowthReportWithError(): Promise<ApiResponse<UserGrowthReport>> {
    await this.simulateDelay(800);
    
    // Simulate an error
    return {
      success: false,
      error: 'Failed to fetch user growth report',
      message: 'Unable to retrieve user growth report at this time. Please try again later.'
    };
  }

  // Generate media trends report with error simulation (for testing error handling)
  async getMediaTrendsReportWithError(): Promise<ApiResponse<MediaTrendsReport>> {
    await this.simulateDelay(800);
    
    // Simulate an error
    return {
      success: false,
      error: 'Failed to fetch media trends report',
      message: 'Unable to retrieve media trends report at this time. Please try again later.'
    };
  }

  // Generate moderation stats with error simulation (for testing error handling)
  async getModerationStatsWithError(): Promise<ApiResponse<ModerationStats>> {
    await this.simulateDelay(800);
    
    // Simulate an error
    return {
      success: false,
      error: 'Failed to fetch moderation statistics',
      message: 'Unable to retrieve moderation statistics at this time. Please try again later.'
    };
  }
}

// Export singleton instance
export const reportingService = new ReportingService();
export default reportingService;