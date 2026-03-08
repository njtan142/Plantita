'use client';

import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { 
  Select, 
  SelectContent, 
  SelectItem, 
  SelectTrigger, 
  SelectValue 
} from '@/components/ui/select';
import { 
  Tabs, 
  TabsContent, 
  TabsList, 
  TabsTrigger 
} from '@/components/ui/tabs';
import { 
  Skeleton 
} from '@/components/ui/skeleton';
import { 
  Alert, 
  AlertTitle, 
  AlertDescription 
} from '@/components/ui/alert';
import { 
  Send, 
  Users, 
  User, 
  FileText, 
  BarChart,
  RotateCcw
} from 'lucide-react';
import { communicationService } from '@/services/communicationService';
import { 
  CommunicationTemplate, 
  MessageTracking 
} from '@/types/api';
import { toast } from 'sonner';

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
  const [trackingData, setTrackingData] = useState<MessageTracking | null>(null);

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
            <div className="space-y-4">
              <div className="flex items-center space-x-2">
                <Button
                  variant={recipientType === 'individual' ? 'default' : 'outline'}
                  onClick={() => setRecipientType('individual')}
                  disabled={!!userId}
                >
                  <User className="h-4 w-4 mr-2" />
                  Individual
                </Button>
                <Button
                  variant={recipientType === 'bulk' ? 'default' : 'outline'}
                  onClick={() => setRecipientType('bulk')}
                >
                  <Users className="h-4 w-4 mr-2" />
                  Bulk Message
                </Button>
              </div>
              
              {recipientType === 'bulk' && (
                <div className="space-y-2">
                  <Label htmlFor="bulk-recipients">Recipient User IDs (comma separated)</Label>
                  <Textarea
                    id="bulk-recipients"
                    placeholder="user1,user2,user3"
                    value={bulkRecipients}
                    onChange={(e) => setBulkRecipients(e.target.value)}
                    rows={3}
                  />
                </div>
              )}
              
              <div className="space-y-2">
                <Label htmlFor="template">Template (Optional)</Label>
                {isLoading ? (
                  <Skeleton className="h-10 w-full" />
                ) : (
                  <Select value={selectedTemplate} onValueChange={handleTemplateChange}>
                    <SelectTrigger id="template">
                      <SelectValue placeholder="Select a template" />
                    </SelectTrigger>
                    <SelectContent>
                      {templates.map((template) => (
                        <SelectItem key={template.id} value={template.id}>
                          {template.name}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                )}
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="subject">Subject</Label>
                <Input
                  id="subject"
                  placeholder="Message subject"
                  value={messageSubject}
                  onChange={(e) => setMessageSubject(e.target.value)}
                />
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="message-type">Message Type</Label>
                <Select value={messageType} onValueChange={(value) => setMessageType(value as 'email' | 'notification')}>
                  <SelectTrigger id="message-type">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="email">Email</SelectItem>
                    <SelectItem value="notification">In-App Notification</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="body">Message Body</Label>
                <Textarea
                  id="body"
                  placeholder="Enter your message here..."
                  value={messageBody}
                  onChange={(e) => setMessageBody(e.target.value)}
                  rows={6}
                />
              </div>
              
              <div className="flex flex-wrap gap-2">
                <Button 
                  onClick={handleSendMessage} 
                  disabled={isSending}
                  className="flex items-center gap-2"
                >
                  {isSending ? (
                    <>
                      <div className="h-4 w-4 rounded-full border-2 border-t-2 border-t-primary animate-spin" />
                      Sending...
                    </>
                  ) : (
                    <>
                      <Send className="h-4 w-4" />
                      Send Message
                    </>
                  )}
                </Button>
                <Button 
                  variant="outline" 
                  onClick={handlePreviewMessage}
                >
                  Preview
                </Button>
              </div>
            </div>
          </TabsContent>
          
          <TabsContent value="tracking" className="space-y-4">
            <div className="text-center py-8 text-muted-foreground">
              <BarChart className="h-12 w-12 mx-auto mb-4" />
              <p>Message tracking data will appear here after sending messages.</p>
              <p className="text-sm mt-2">Select a message from the list to view detailed tracking information.</p>
            </div>
            
            <div className="space-y-4">
              <div className="rounded-lg border p-4">
                <h3 className="font-medium mb-2">Recent Messages</h3>
                <div className="space-y-3">
                  {isLoading ? (
                    <>
                      <Skeleton className="h-16 w-full" />
                      <Skeleton className="h-16 w-full" />
                      <Skeleton className="h-16 w-full" />
                    </>
                  ) : (
                    <>
                      <div className="flex justify-between items-center p-3 bg-muted rounded-lg">
                        <div>
                          <p className="font-medium">Welcome Message</p>
                          <p className="text-sm text-muted-foreground">Sent to 1,247 users</p>
                        </div>
                        <div className="text-right">
                          <p className="text-sm">876 opened</p>
                          <p className="text-xs text-muted-foreground">70.3% open rate</p>
                        </div>
                      </div>
                      <div className="flex justify-between items-center p-3 bg-muted rounded-lg">
                        <div>
                          <p className="font-medium">Content Violation Notice</p>
                          <p className="text-sm text-muted-foreground">Sent to 24 users</p>
                        </div>
                        <div className="text-right">
                          <p className="text-sm">18 opened</p>
                          <p className="text-xs text-muted-foreground">75% open rate</p>
                        </div>
                      </div>
                      <div className="flex justify-between items-center p-3 bg-muted rounded-lg">
                        <div>
                          <p className="font-medium">Platform Update</p>
                          <p className="text-sm text-muted-foreground">Sent to 876 users</p>
                        </div>
                        <div className="text-right">
                          <p className="text-sm">642 opened</p>
                          <p className="text-xs text-muted-foreground">73.3% open rate</p>
                        </div>
                      </div>
                    </>
                  )}
                </div>
              </div>
            </div>
          </TabsContent>
        </Tabs>
      </CardContent>
    </Card>
  );
}