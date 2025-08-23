'use client';

import { useState } from 'react';
import { Button } from '@/components/ui/button';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { 
  Download, 
  FileText, 
  FileSpreadsheet, 
  Settings,
  Check
} from 'lucide-react';
import { reportingService } from '@/services/reportingService';
import { toast } from 'sonner';

interface ReportExportToolbarProps {
  className?: string;
  onExportStart?: () => void;
  onExportComplete?: () => void;
  onExportError?: (error: string) => void;
}

interface ExportOptions {
  format: 'csv' | 'pdf';
  includeCharts: boolean;
  includeRawData: boolean;
  dateRange?: {
    start: string;
    end: string;
  };
}

export function ReportExportToolbar({ 
  className, 
  onExportStart, 
  onExportComplete, 
  onExportError 
}: ReportExportToolbarProps) {
  const [exportOptions, setExportOptions] = useState<ExportOptions>({
    format: 'csv',
    includeCharts: true,
    includeRawData: true,
  });
  
  const [isExporting, setIsExporting] = useState(false);

  const handleExport = async (format: 'csv' | 'pdf') => {
    try {
      setIsExporting(true);
      onExportStart?.();
      
      // Update format in options
      setExportOptions(prev => ({ ...prev, format }));
      
      // In a real implementation, this would trigger the actual export
      // For now, we'll use the mock service
      let response;
      
      switch (format) {
        case 'csv':
          response = await reportingService.exportReportAsCSV('userGrowth');
          break;
        case 'pdf':
          response = await reportingService.exportReportAsPDF('userGrowth');
          break;
        default:
          throw new Error('Unsupported format');
      }
      
      if (response.success && response.data) {
        // Create a download link for the exported file
        const url = window.URL.createObjectURL(response.data);
        const a = document.createElement('a');
        a.href = url;
        a.download = `report.${format}`;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        window.URL.revokeObjectURL(url);
        
        toast.success(`Report exported successfully as ${format.toUpperCase()}`, {
          description: 'Your report has been downloaded.',
        });
        
        onExportComplete?.();
      } else {
        throw new Error(response.message || 'Failed to export report');
      }
    } catch (error) {
      console.error('Export error:', error);
      const errorMessage = error instanceof Error ? error.message : 'An unknown error occurred';
      toast.error('Export failed', {
        description: errorMessage,
      });
      onExportError?.(errorMessage);
    } finally {
      setIsExporting(false);
    }
  };

  const toggleOption = (option: keyof Pick<ExportOptions, 'includeCharts' | 'includeRawData'>) => {
    setExportOptions(prev => ({
      ...prev,
      [option]: !prev[option]
    }));
  };

  return (
    <div className={className}>
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button 
            variant="outline" 
            disabled={isExporting}
            className="flex items-center gap-2"
          >
            <Download className="h-4 w-4" />
            Export
            {isExporting && <div className="h-4 w-4 rounded-full border-2 border-t-2 border-t-primary animate-spin" />}
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent className="w-56" align="end">
          <DropdownMenuLabel>Export Report</DropdownMenuLabel>
          <DropdownMenuSeparator />
          <DropdownMenuGroup>
            <DropdownMenuItem onClick={() => handleExport('csv')}>
              <FileSpreadsheet className="mr-2 h-4 w-4" />
              <span>Export as CSV</span>
            </DropdownMenuItem>
            <DropdownMenuItem onClick={() => handleExport('pdf')}>
              <FileText className="mr-2 h-4 w-4" />
              <span>Export as PDF</span>
            </DropdownMenuItem>
          </DropdownMenuGroup>
          
          <DropdownMenuSeparator />
          
          <DropdownMenuLabel>Export Options</DropdownMenuLabel>
          <DropdownMenuGroup>
            <DropdownMenuItem onClick={() => toggleOption('includeCharts')}>
              {exportOptions.includeCharts ? (
                <Check className="mr-2 h-4 w-4" />
              ) : (
                <div className="mr-2 h-4 w-4" />
              )}
              <span>Include Charts</span>
            </DropdownMenuItem>
            <DropdownMenuItem onClick={() => toggleOption('includeRawData')}>
              {exportOptions.includeRawData ? (
                <Check className="mr-2 h-4 w-4" />
              ) : (
                <div className="mr-2 h-4 w-4" />
              )}
              <span>Include Raw Data</span>
            </DropdownMenuItem>
          </DropdownMenuGroup>
          
          <DropdownMenuSeparator />
          
          <DropdownMenuItem>
            <Settings className="mr-2 h-4 w-4" />
            <span>Advanced Settings</span>
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    </div>
  );
}