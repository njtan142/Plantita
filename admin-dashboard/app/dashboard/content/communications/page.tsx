'use client';

import { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { 
  Mail, 
  Bell, 
  FileText, 
  BarChart,
  Calendar
} from 'lucide-react';
import { UserMessagingPanel } from '@/components/content/UserMessagingPanel';
import { PlatformAnnouncements } from '@/components/content/PlatformAnnouncements';
import { CommunicationTemplates } from '@/components/content/CommunicationTemplates';
import { toast } from 'sonner';

export default function UserCommunicationPage() {
  const [activeTab, setActiveTab] = useState('messaging');

  const handleMessageSent = () => {
    toast.success('Message Sent', {
      description: 'Your message has been sent successfully.',
    });
  };

  const handleAnnouncementCreated = () => {
    toast.success('Announcement Created', {
      description: 'Platform announcement has been created successfully.',
    });
  };

  const handleAnnouncementUpdated = () => {
    toast.success('Announcement Updated', {
      description: 'Platform announcement has been updated successfully.',
    });
  };

  const handleAnnouncementDeleted = () => {
    toast.success('Announcement Deleted', {
      description: 'Platform announcement has been deleted successfully.',
    });
  };

  const handleTemplateCreated = () => {
    toast.success('Template Created', {
      description: 'Communication template has been created successfully.',
    });
  };

  const handleTemplateUpdated = () => {
    toast.success('Template Updated', {
      description: 'Communication template has been updated successfully.',
    });
  };

  const handleTemplateDeleted = () => {
    toast.success('Template Deleted', {
      description: 'Communication template has been deleted successfully.',
    });
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">User Communications</h1>
        <p className="text-muted-foreground">
          Manage user messaging, platform announcements, and communication templates
        </p>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-6">
        <TabsList className="grid w-full grid-cols-4">
          <TabsTrigger value="messaging" className="flex items-center gap-2">
            <Mail className="h-4 w-4" />
            Messaging
          </TabsTrigger>
          <TabsTrigger value="announcements" className="flex items-center gap-2">
            <Bell className="h-4 w-4" />
            Announcements
          </TabsTrigger>
          <TabsTrigger value="templates" className="flex items-center gap-2">
            <FileText className="h-4 w-4" />
            Templates
          </TabsTrigger>
          <TabsTrigger value="tracking" className="flex items-center gap-2">
            <BarChart className="h-4 w-4" />
            Tracking
          </TabsTrigger>
        </TabsList>
        
        <TabsContent value="messaging" className="space-y-6">
          <UserMessagingPanel onMessageSent={handleMessageSent} />
        </TabsContent>
        
        <TabsContent value="announcements" className="space-y-6">
          <PlatformAnnouncements 
            onAnnouncementCreated={handleAnnouncementCreated}
            onAnnouncementUpdated={handleAnnouncementUpdated}
            onAnnouncementDeleted={handleAnnouncementDeleted}
          />
        </TabsContent>
        
        <TabsContent value="templates" className="space-y-6">
          <CommunicationTemplates 
            onTemplateCreated={handleTemplateCreated}
            onTemplateUpdated={handleTemplateUpdated}
            onTemplateDeleted={handleTemplateDeleted}
          />
        </TabsContent>
        
        <TabsContent value="tracking" className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <BarChart className="h-5 w-5" />
                Communication Tracking
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-center py-12">
                <BarChart className="h-16 w-16 mx-auto text-muted-foreground" />
                <h3 className="mt-4 text-lg font-semibold">Communication Analytics</h3>
                <p className="text-muted-foreground mt-2">
                  Track the performance of your messages and announcements.
                </p>
                <p className="text-sm text-muted-foreground mt-2">
                  Detailed analytics and reporting will be available here.
                </p>
                
                <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-8">
                  <Card>
                    <CardContent className="p-6 text-center">
                      <div className="text-3xl font-bold">1,247</div>
                      <div className="text-sm text-muted-foreground mt-1">Messages Sent</div>
                    </CardContent>
                  </Card>
                  <Card>
                    <CardContent className="p-6 text-center">
                      <div className="text-3xl font-bold">876</div>
                      <div className="text-sm text-muted-foreground mt-1">Messages Opened</div>
                    </CardContent>
                  </Card>
                  <Card>
                    <CardContent className="p-6 text-center">
                      <div className="text-3xl font-bold">70.3%</div>
                      <div className="text-sm text-muted-foreground mt-1">Open Rate</div>
                    </CardContent>
                  </Card>
                </div>
                
                <div className="mt-8">
                  <Button variant="outline" className="flex items-center gap-2 mx-auto">
                    <Calendar className="h-4 w-4" />
                    Schedule Report
                  </Button>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
      
      <div className="text-center text-sm text-muted-foreground">
        <p>Communication data is updated in real-time. Last updated: Just now</p>
      </div>
    </div>
  );
}