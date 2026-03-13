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
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog';
import { 
  Badge 
} from '@/components/ui/badge';
import { 
  Skeleton 
} from '@/components/ui/skeleton';
import { 
  Alert, 
  AlertTitle, 
  AlertDescription 
} from '@/components/ui/alert';
import { 
  Bell, 
  Calendar, 
  Clock, 
  Plus, 
  Edit, 
  Trash2, 
  Eye,
  RotateCcw
} from 'lucide-react';
import { communicationService } from '@/services/communicationService';
import { 
  PlatformAnnouncement 
} from '@/types/api';
import { toast } from 'sonner';
import { format, parseISO } from 'date-fns';
import { AnnouncementListItem } from './platform-announcements/AnnouncementListItem';
import { AnnouncementPreview } from './platform-announcements/AnnouncementPreview';
import { AnnouncementForm } from './platform-announcements/AnnouncementForm';
import { getPriorityVariant, getStatus, getStatusVariant } from './platform-announcements/utils';

interface PlatformAnnouncementsProps {
  className?: string;
  onAnnouncementCreated?: () => void;
  onAnnouncementUpdated?: () => void;
  onAnnouncementDeleted?: () => void;
}

export function PlatformAnnouncements({ 
  className, 
  onAnnouncementCreated,
  onAnnouncementUpdated,
  onAnnouncementDeleted
}: PlatformAnnouncementsProps) {
  const [announcements, setAnnouncements] = useState<PlatformAnnouncement[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [isCreating, setIsCreating] = useState(false);
  const [editingAnnouncement, setEditingAnnouncement] = useState<PlatformAnnouncement | null>(null);
  const [deletingAnnouncement, setDeletingAnnouncement] = useState<PlatformAnnouncement | null>(null);
  
  // Form state
  const [title, setTitle] = useState('');
  const [content, setContent] = useState('');
  const [startDate, setStartDate] = useState('');
  const [endDate, setEndDate] = useState('');
  const [priority, setPriority] = useState<'low' | 'medium' | 'high'>('medium');
  const [targetUsers, setTargetUsers] = useState<'all' | 'active' | 'specific'>('all');
  
  // Preview state
  const [previewAnnouncement, setPreviewAnnouncement] = useState<PlatformAnnouncement | null>(null);

  useEffect(() => {
    fetchAnnouncements();
  }, []);

  const fetchAnnouncements = async () => {
    try {
      setIsLoading(true);
      setError(null);

      const response = await communicationService.getPlatformAnnouncements();
      
      if (response.success && response.data) {
        setAnnouncements(response.data);
      } else {
        setError(response.message || 'Failed to fetch platform announcements');
      }
    } catch (err) {
      console.error('Error fetching announcements:', err);
      setError('An unexpected error occurred while fetching announcements');
    } finally {
      setIsLoading(false);
    }
  };

  const handleCreateAnnouncement = async () => {
    if (!title.trim() || !content.trim()) {
      toast.error('Validation Error', {
        description: 'Please enter both title and content for the announcement',
      });
      return;
    }
    
    if (!startDate || !endDate) {
      toast.error('Validation Error', {
        description: 'Please select both start and end dates',
      });
      return;
    }
    
    if (new Date(startDate) >= new Date(endDate)) {
      toast.error('Validation Error', {
        description: 'End date must be after start date',
      });
      return;
    }
    
    try {
      setIsCreating(true);
      
      const newAnnouncement = {
        title,
        content,
        startDate,
        endDate,
        priority,
        targetUsers
      };
      
      const response = await communicationService.createPlatformAnnouncement(newAnnouncement);
      
      if (response.success && response.data) {
        toast.success('Announcement Created', {
          description: 'Platform announcement has been created successfully',
        });
        
        // Reset form
        setTitle('');
        setContent('');
        setStartDate('');
        setEndDate('');
        setPriority('medium');
        setTargetUsers('all');
        
        // Refresh announcements
        fetchAnnouncements();
        onAnnouncementCreated?.();
      } else {
        throw new Error(response.message || 'Failed to create announcement');
      }
    } catch (err) {
      console.error('Error creating announcement:', err);
      const errorMessage = err instanceof Error ? err.message : 'An unknown error occurred';
      toast.error('Creation Failed', {
        description: errorMessage,
      });
    } finally {
      setIsCreating(false);
    }
  };

  const handleUpdateAnnouncement = async () => {
    if (!editingAnnouncement) return;
    
    if (!editingAnnouncement.title.trim() || !editingAnnouncement.content.trim()) {
      toast.error('Validation Error', {
        description: 'Please enter both title and content for the announcement',
      });
      return;
    }
    
    if (!editingAnnouncement.startDate || !editingAnnouncement.endDate) {
      toast.error('Validation Error', {
        description: 'Please select both start and end dates',
      });
      return;
    }
    
    if (new Date(editingAnnouncement.startDate) >= new Date(editingAnnouncement.endDate)) {
      toast.error('Validation Error', {
        description: 'End date must be after start date',
      });
      return;
    }
    
    try {
      const response = await communicationService.updatePlatformAnnouncement(
        editingAnnouncement.id,
        {
          title: editingAnnouncement.title,
          content: editingAnnouncement.content,
          startDate: editingAnnouncement.startDate,
          endDate: editingAnnouncement.endDate,
          priority: editingAnnouncement.priority,
          targetUsers: editingAnnouncement.targetUsers
        }
      );
      
      if (response.success && response.data) {
        toast.success('Announcement Updated', {
          description: 'Platform announcement has been updated successfully',
        });
        
        // Close edit dialog and refresh announcements
        setEditingAnnouncement(null);
        fetchAnnouncements();
        onAnnouncementUpdated?.();
      } else {
        throw new Error(response.message || 'Failed to update announcement');
      }
    } catch (err) {
      console.error('Error updating announcement:', err);
      const errorMessage = err instanceof Error ? err.message : 'An unknown error occurred';
      toast.error('Update Failed', {
        description: errorMessage,
      });
    }
  };

  const handleDeleteAnnouncement = async () => {
    if (!deletingAnnouncement) return;
    
    try {
      const response = await communicationService.deletePlatformAnnouncement(deletingAnnouncement.id);
      
      if (response.success) {
        toast.success('Announcement Deleted', {
          description: 'Platform announcement has been deleted successfully',
        });
        
        // Close delete dialog and refresh announcements
        setDeletingAnnouncement(null);
        fetchAnnouncements();
        onAnnouncementDeleted?.();
      } else {
        throw new Error(response.message || 'Failed to delete announcement');
      }
    } catch (err) {
      console.error('Error deleting announcement:', err);
      const errorMessage = err instanceof Error ? err.message : 'An unknown error occurred';
      toast.error('Deletion Failed', {
        description: errorMessage,
      });
    }
  };

  const handleRetry = () => {
    fetchAnnouncements();
  };

  if (error) {
    return (
      <Card className={className}>
        <CardHeader>
          <CardTitle className="flex items-center justify-between">
            <span className="flex items-center gap-2">
              <Bell className="h-5 w-5" />
              Platform Announcements
            </span>
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
        <CardTitle className="flex items-center justify-between">
          <span className="flex items-center gap-2">
            <Bell className="h-5 w-5" />
            Platform Announcements
          </span>
          <Button onClick={() => setIsCreating(true)} className="flex items-center gap-2">
            <Plus className="h-4 w-4" />
            New Announcement
          </Button>
        </CardTitle>
      </CardHeader>
      <CardContent>
        {/* Create Announcement Dialog */}
        <AlertDialog open={isCreating} onOpenChange={setIsCreating}>
          <AlertDialogContent className="max-w-2xl">
            <AlertDialogHeader>
              <AlertDialogTitle>Create New Announcement</AlertDialogTitle>
              <AlertDialogDescription>
                Create a new platform announcement that will be visible to users.
              </AlertDialogDescription>
            </AlertDialogHeader>
            <AnnouncementForm
              title={title}
              setTitle={setTitle}
              content={content}
              setContent={setContent}
              startDate={startDate}
              setStartDate={setStartDate}
              endDate={endDate}
              setEndDate={setEndDate}
              priority={priority}
              setPriority={setPriority}
              targetUsers={targetUsers}
              setTargetUsers={setTargetUsers}
              idPrefix="create-announcement"
            />
            <AlertDialogFooter>
              <AlertDialogCancel>Cancel</AlertDialogCancel>
              <AlertDialogAction 
                onClick={handleCreateAnnouncement} 
                disabled={isCreating}
                className="flex items-center gap-2"
              >
                {isCreating ? (
                  <>
                    <div className="h-4 w-4 rounded-full border-2 border-t-2 border-t-primary animate-spin" />
                    Creating...
                  </>
                ) : (
                  'Create Announcement'
                )}
              </AlertDialogAction>
            </AlertDialogFooter>
          </AlertDialogContent>
        </AlertDialog>
        
        {/* Edit Announcement Dialog */}
        <AlertDialog open={!!editingAnnouncement} onOpenChange={(open) => !open && setEditingAnnouncement(null)}>
          <AlertDialogContent className="max-w-2xl">
            <AlertDialogHeader>
              <AlertDialogTitle>Edit Announcement</AlertDialogTitle>
              <AlertDialogDescription>
                Edit the platform announcement details.
              </AlertDialogDescription>
            </AlertDialogHeader>
            {editingAnnouncement && (
              <AnnouncementForm
                title={editingAnnouncement.title}
                setTitle={(title) => setEditingAnnouncement({...editingAnnouncement, title})}
                content={editingAnnouncement.content}
                setContent={(content) => setEditingAnnouncement({...editingAnnouncement, content})}
                startDate={editingAnnouncement.startDate}
                setStartDate={(startDate) => setEditingAnnouncement({...editingAnnouncement, startDate})}
                endDate={editingAnnouncement.endDate}
                setEndDate={(endDate) => setEditingAnnouncement({...editingAnnouncement, endDate})}
                priority={editingAnnouncement.priority}
                setPriority={(priority) => setEditingAnnouncement({...editingAnnouncement, priority})}
                targetUsers={editingAnnouncement.targetUsers}
                setTargetUsers={(targetUsers) => setEditingAnnouncement({...editingAnnouncement, targetUsers})}
                idPrefix="edit-announcement"
              />
            )}
            <AlertDialogFooter>
              <AlertDialogCancel>Cancel</AlertDialogCancel>
              <AlertDialogAction 
                onClick={handleUpdateAnnouncement}
                className="flex items-center gap-2"
              >
                Update Announcement
              </AlertDialogAction>
            </AlertDialogFooter>
          </AlertDialogContent>
        </AlertDialog>
        
        {/* Delete Confirmation Dialog */}
        <AlertDialog open={!!deletingAnnouncement} onOpenChange={(open) => !open && setDeletingAnnouncement(null)}>
          <AlertDialogContent>
            <AlertDialogHeader>
              <AlertDialogTitle>Delete Announcement</AlertDialogTitle>
              <AlertDialogDescription>
                Are you sure you want to delete this announcement? This action cannot be undone.
              </AlertDialogDescription>
            </AlertDialogHeader>
            <AlertDialogFooter>
              <AlertDialogCancel>Cancel</AlertDialogCancel>
              <AlertDialogAction 
                onClick={handleDeleteAnnouncement}
                className="bg-destructive hover:bg-destructive/90"
              >
                Delete
              </AlertDialogAction>
            </AlertDialogFooter>
          </AlertDialogContent>
        </AlertDialog>
        
        {/* Preview Dialog */}
        <AlertDialog open={!!previewAnnouncement} onOpenChange={(open) => !open && setPreviewAnnouncement(null)}>
          <AlertDialogContent>
            <AlertDialogHeader>
              <AlertDialogTitle className="flex items-center gap-2">
                <Bell className="h-5 w-5" />
                {previewAnnouncement?.title}
              </AlertDialogTitle>
              {previewAnnouncement && (
                <div className="flex flex-wrap gap-2">
                  <Badge variant={getPriorityVariant(previewAnnouncement.priority)}>
                    {previewAnnouncement.priority}
                  </Badge>
                  <Badge variant={getStatusVariant(getStatus(previewAnnouncement))}>
                    {getStatus(previewAnnouncement)}
                  </Badge>
                </div>
              )}
            </AlertDialogHeader>
            {previewAnnouncement && (
              <AnnouncementPreview announcement={previewAnnouncement} />
            )}
            <AlertDialogFooter>
              <AlertDialogAction onClick={() => setPreviewAnnouncement(null)}>
                Close
              </AlertDialogAction>
            </AlertDialogFooter>
          </AlertDialogContent>
        </AlertDialog>
        
        {/* Active Announcements */}
        <div className="space-y-4">
          <h3 className="text-lg font-semibold">Active Announcements</h3>
          
          {isLoading ? (
            <div className="space-y-3">
              <Skeleton className="h-24 w-full" />
              <Skeleton className="h-24 w-full" />
              <Skeleton className="h-24 w-full" />
            </div>
          ) : announcements.length === 0 ? (
            <div className="text-center py-8 text-muted-foreground">
              <Bell className="h-12 w-12 mx-auto mb-4" />
              <p>No announcements found</p>
              <p className="text-sm mt-2">Create your first announcement to keep users informed.</p>
            </div>
          ) : (
            <div className="space-y-3">
              {announcements.map((announcement) => (
                <AnnouncementListItem
                  key={announcement.id}
                  announcement={announcement}
                  onPreview={setPreviewAnnouncement}
                  onEdit={setEditingAnnouncement}
                  onDelete={setDeletingAnnouncement}
                />
              ))}
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  );
}