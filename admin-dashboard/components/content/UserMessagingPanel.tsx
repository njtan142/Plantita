'use client';

import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { 
  Tabs, 
  TabsContent, 
  TabsList, 
  TabsTrigger 
} from '@/components/ui/tabs';
import { 
  Alert, 
  AlertTitle, 
  AlertDescription 
} from '@/components/ui/alert';
import { 
  Send, 
  RotateCcw,
  FileText,
  BarChart
} from 'lucide-react';
import { communicationService } from '@/services/communicationService';
import { 
  CommunicationTemplate
} from '@/types/api';
import { toast } from 'sonner';
import { MessageComposeTab } from './user-messaging-panel/MessageComposeTab';
import { MessageTrackingTab } from './user-messaging-panel/MessageTrackingTab';

interface UserMessagingPanelProps {
  userId?: string;
  className?: string;
  onMessageSent?: () => void;
}

export function UserMessagingPanel({ userId, className, onMessageSent }: UserMessagingPanelProps) {
  const [templates, setTemplates] = useState<CommunicationTemplate[]>([]);
  const [selectedTemplate, setSelectedTemplate] = useState<string>('');
  const [messageSubject, setMessageSubject] = useState('');
  const [messageBody, setMessageBody] = useState('');
  const [messageType, setMessageType] = useState<'email' | 'notification'>('email');
  const [recipientType, setRecipientType] = useState<'individual' | 'bulk'>('individual');
  const [bulkRecipients, setBulkRecipients] = useState('');
  const [isLoading, setIsLoading] = useState(true);
  const [isSending, setIsSending] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchTemplates();
  }, []);

  const fetchTemplates = async () => {
    try {
      setIsLoading(true);
      setError(null);

      const response = await communicationService.getAllTemplates();
      
      if (response.success && response.data) {
        setTemplates(response.data);
      } else {
        setError(response.message || 'Failed to fetch communication templates');
      }
    } catch (err) {
      console.error('Error fetching templates:', err);
      setError('An unexpected error occurred while fetching templates');
    } finally {
      setIsLoading(false);
    }
  };

  const handleTemplateChange = async (templateId: string) => {
    setSelectedTemplate(templateId);
    
    if (!templateId) {
      setMessageSubject('');
      setMessageBody('');
      return;
    }
    
    try {
      const response = await communicationService.getTemplateById(templateId);
      
      if (response.success && response.data) {
        const template = response.data;
        setMessageSubject(template.subject);
        setMessageBody(template.body);
        setMessageType(template.type);
      } else {
        toast.error('Template Error', {
          description: response.message || 'Failed to load template',
        });
      }
    } catch (err) {
      console.error('Error loading template:', err);
      toast.error('Template Error', {
        description: 'Failed to load template',
      });
    }
  };

  const handleSendMessage = async () => {
    if (!messageSubject.trim() || !messageBody.trim()) {
      toast.error('Validation Error', {
        description: 'Please enter both subject and message body',
      });
      return;
    }
    
    if (recipientType === 'individual' && !userId) {
      toast.error('Validation Error', {
        description: 'User ID is required for individual messages',
      });
      return;
    }
    
    if (recipientType === 'bulk' && !bulkRecipients.trim()) {
      toast.error('Validation Error', {
        description: 'Please enter recipient user IDs for bulk messages',
      });
      return;
    }
    
    try {
      setIsSending(true);
      
      let response;
      
      if (recipientType === 'individual' && userId) {
        // Send individual message
        response = await communicationService.sendIndividualMessage(
          userId,
          messageSubject,
          messageBody,
          messageType
        );
      } else {
        // Send bulk message
        const userIds = bulkRecipients
          .split(',')
          .map(id => id.trim())
          .filter(id => id.length > 0);
          
        response = await communicationService.sendBulkMessages(
          userIds,
          messageSubject,
          messageBody,
          messageType
        );
      }
      
      if (response.success) {
        toast.success('Message Sent', {
          description: recipientType === 'individual' 
            ? 'Message sent successfully to user' 
            : `Message sent successfully to ${bulkRecipients.split(',').length} users`,
        });
        
        // Reset form
        setMessageSubject('');
        setMessageBody('');
        setSelectedTemplate('');
        setBulkRecipients('');
        
        onMessageSent?.();
      } else {
        throw new Error(response.message || 'Failed to send message');
      }
    } catch (err) {
      console.error('Error sending message:', err);
      const errorMessage = err instanceof Error ? err.message : 'An unknown error occurred';
      toast.error('Send Failed', {
        description: errorMessage,
      });
    } finally {
      setIsSending(false);
    }
  };

  const handleRetry = () => {
    fetchTemplates();
  };

  const handlePreviewMessage = () => {
    // In a real implementation, this would show a preview modal
    // For now, we'll just show a toast with the message details
    toast.info('Message Preview', {
      description: (
        <div className="space-y-2">
          <div><strong>Subject:</strong> {messageSubject}</div>
          <div><strong>Type:</strong> {messageType}</div>
          <div><strong>Body:</strong></div>
          <div className="whitespace-pre-wrap text-sm">{messageBody.substring(0, 100)}...</div>
        </div>
      ),
    });
  };

  if (error) {
    return (
      <Card className={className}>
        <CardHeader>
          <CardTitle className="flex items-center justify-between">
            <span>User Messaging</span>
          </CardTitle>
        </CardHeader>
        <CardContent>
          <Alert variant="destructive">
            <AlertTitle>Error</AlertTitle>
            <AlertDescription className="flex items-center justify-between">
              <span>{error}</span>
              <Button variant="outline" size="sm" onClick={handleRetry}>
                <RotateCcw className="h-4 w-4 mr-2" />
                Retry
              </Button>
            </AlertDescription>
          </Alert>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className={className}>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Send className="h-5 w-5" />
          User Messaging
        </CardTitle>
      </CardHeader>
      <CardContent>
        <Tabs defaultValue="compose" className="w-full">
          <TabsList className="grid w-full grid-cols-2">
            <TabsTrigger value="compose" className="flex items-center gap-2">
              <FileText className="h-4 w-4" />
              Compose Message
            </TabsTrigger>
            <TabsTrigger value="tracking" className="flex items-center gap-2">
              <BarChart className="h-4 w-4" />
              Message Tracking
            </TabsTrigger>
          </TabsList>
          
          <TabsContent value="compose" className="space-y-6">
            <MessageComposeTab
              userId={userId}
              templates={templates}
              selectedTemplate={selectedTemplate}
              handleTemplateChange={handleTemplateChange}
              messageSubject={messageSubject}
              setMessageSubject={setMessageSubject}
              messageBody={messageBody}
              setMessageBody={setMessageBody}
              messageType={messageType}
              setMessageType={setMessageType}
              recipientType={recipientType}
              setRecipientType={setRecipientType}
              bulkRecipients={bulkRecipients}
              setBulkRecipients={setBulkRecipients}
              isLoading={isLoading}
              isSending={isSending}
              handleSendMessage={handleSendMessage}
              handlePreviewMessage={handlePreviewMessage}
            />
          </TabsContent>
          
          <TabsContent value="tracking" className="space-y-4">
            <MessageTrackingTab isLoading={isLoading} />
          </TabsContent>
        </Tabs>
      </CardContent>
    </Card>
  );
}
