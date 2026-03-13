'use client';

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
import { Skeleton } from '@/components/ui/skeleton';
import { 
  Send, 
  Users, 
  User, 
} from 'lucide-react';
import { CommunicationTemplate } from '@/types/api';

interface MessageComposeTabProps {
  userId?: string;
  templates: CommunicationTemplate[];
  selectedTemplate: string;
  handleTemplateChange: (templateId: string) => void;
  messageSubject: string;
  setMessageSubject: (subject: string) => void;
  messageBody: string;
  setMessageBody: (body: string) => void;
  messageType: 'email' | 'notification';
  setMessageType: (type: 'email' | 'notification') => void;
  recipientType: 'individual' | 'bulk';
  setRecipientType: (type: 'individual' | 'bulk') => void;
  bulkRecipients: string;
  setBulkRecipients: (recipients: string) => void;
  isLoading: boolean;
  isSending: boolean;
  handleSendMessage: () => void;
  handlePreviewMessage: () => void;
}

export function MessageComposeTab({
  userId,
  templates,
  selectedTemplate,
  handleTemplateChange,
  messageSubject,
  setMessageSubject,
  messageBody,
  setMessageBody,
  messageType,
  setMessageType,
  recipientType,
  setRecipientType,
  bulkRecipients,
  setBulkRecipients,
  isLoading,
  isSending,
  handleSendMessage,
  handlePreviewMessage
}: MessageComposeTabProps) {
  return (
    <div className="space-y-6">
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
    </div>
  );
}
