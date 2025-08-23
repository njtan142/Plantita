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

  const getPriorityVariant = (priority: string) => {
    switch (priority) {
      case 'high': return 'destructive';
      case 'medium': return 'default';
      case 'low': return 'secondary';
      default: return 'secondary';
    }
  };

  const getStatus = (announcement: PlatformAnnouncement) => {
    const now = new Date();
    const start = new Date(announcement.startDate);
    const end = new Date(announcement.endDate);
    
    if (now < start) return 'Scheduled';
    if (now > end) return 'Expired';
    return 'Active';
  };

  const getStatusVariant = (status: string) => {
    switch (status) {
      case 'Active': return 'default';
      case 'Scheduled': return 'secondary';
      case 'Expired': return 'outline';
      default: return 'secondary';
    }
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
            <div className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="title">Title</Label>
                <Input
                  id="title"
                  placeholder="Enter announcement title"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                />
              </div>
              
              <div className="space-y-2">
                <Label htmlFor="content">Content</Label>
                <Textarea
                  id="content"
                  placeholder="Enter announcement content"
                  value={content}
                  onChange={(e) => setContent(e.target.value)}
                  rows={4}
                />
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="start-date">Start Date</Label>
                  <Input
                    id="start-date"
                    type="datetime-local"
                    value={startDate}
                    onChange={(e) => setStartDate(e.target.value)}
                  />
                </div>
                
                <div className="space-y-2">
                  <Label htmlFor="end-date">End Date</Label>
                  <Input
                    id="end-date"
                    type="datetime-local"
                    value={endDate}
                    onChange={(e) => setEndDate(e.target.value)}
                  />
                </div>
              </div>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="priority">Priority</Label>
                  <Select value={priority} onValueChange={(value) => setPriority(value as any)}>
                    <SelectTrigger id="priority">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="low">Low</SelectItem>
                      <SelectItem value="medium">Medium</SelectItem>
                      <SelectItem value="high">High</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                
                <div className="space-y-2">
                  <Label htmlFor="target-users">Target Users</Label>
                  <Select value={targetUsers} onValueChange={(value) => setTargetUsers(value as any)}>
                    <SelectTrigger id="target-users">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All Users</SelectItem>
                      <SelectItem value="active">Active Users Only</SelectItem>
                      <SelectItem value="specific">Specific Users</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>
            </div>
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
              <div className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="edit-title">Title</Label>
                  <Input
                    id="edit-title"
                    placeholder="Enter announcement title"
                    value={editingAnnouncement.title}
                    onChange={(e) => setEditingAnnouncement({...editingAnnouncement, title: e.target.value})}
                  />
                </div>
                
                <div className="space-y-2">
                  <Label htmlFor="edit-content">Content</Label>
                  <Textarea
                    id="edit-content"
                    placeholder="Enter announcement content"
                    value={editingAnnouncement.content}
                    onChange={(e) => setEditingAnnouncement({...editingAnnouncement, content: e.target.value})}
                    rows={4}
                  />
                </div>
                
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="edit-start-date">Start Date</Label>
                    <Input
                      id="edit-start-date"
                      type="datetime-local"
                      value={editingAnnouncement.startDate}
                      onChange={(e) => setEditingAnnouncement({...editingAnnouncement, startDate: e.target.value})}
                    />
                  </div>
                  
                  <div className="space-y-2">
                    <Label htmlFor="edit-end-date">End Date</Label>
                    <Input
                      id="edit-end-date"
                      type="datetime-local"
                      value={editingAnnouncement.endDate}
                      onChange={(e) => setEditingAnnouncement({...editingAnnouncement, endDate: e.target.value})}
                    />
                  </div>
                </div>
                
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="edit-priority">Priority</Label>
                    <Select 
                      value={editingAnnouncement.priority} 
                      onValueChange={(value) => setEditingAnnouncement({...editingAnnouncement, priority: value as any})}
                    >
                      <SelectTrigger id="edit-priority">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="low">Low</SelectItem>
                        <SelectItem value="medium">Medium</SelectItem>
                        <SelectItem value="high">High</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  
                  <div className="space-y-2">
                    <Label htmlFor="edit-target-users">Target Users</Label>
                    <Select 
                      value={editingAnnouncement.targetUsers} 
                      onValueChange={(value) => setEditingAnnouncement({...editingAnnouncement, targetUsers: value as any})}
                    >
                      <SelectTrigger id="edit-target-users">
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="all">All Users</SelectItem>
                        <SelectItem value="active">Active Users Only</SelectItem>
                        <SelectItem value="specific">Specific Users</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>
              </div>
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
              <div className="space-y-4">
                <div className="prose max-w-none">
                  <p className="whitespace-pre-wrap">{previewAnnouncement.content}</p>
                </div>
                <div className="text-sm text-muted-foreground flex flex-wrap gap-4">
                  <div className="flex items-center gap-1">
                    <Calendar className="h-4 w-4" />
                    <span>Start: {format(parseISO(previewAnnouncement.startDate), 'MMM d, yyyy h:mm a')}</span>
                  </div>
                  <div className="flex items-center gap-1">
                    <Clock className="h-4 w-4" />
                    <span>End: {format(parseISO(previewAnnouncement.endDate), 'MMM d, yyyy h:mm a')}</span>
                  </div>
                </div>
              </div>
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
              {announcements.map((announcement) => {
                const status = getStatus(announcement);
                return (
                  <Card key={announcement.id} className="p-4">
                    <div className="flex justify-between items-start">
                      <div className="flex-1">
                        <div className="flex items-start justify-between">
                          <h4 className="font-semibold">{announcement.title}</h4>
                          <div className="flex flex-wrap gap-1 ml-2">
                            <Badge variant={getPriorityVariant(announcement.priority)}>
                              {announcement.priority}
                            </Badge>
                            <Badge variant={getStatusVariant(status)}>
                              {status}
                            </Badge>
                          </div>
                        </div>
                        <p className="text-sm text-muted-foreground mt-2 line-clamp-2">
                          {announcement.content}
                        </p>
                        <div className="text-xs text-muted-foreground mt-2 flex flex-wrap gap-4">
                          <div className="flex items-center gap-1">
                            <Calendar className="h-3 w-3" />
                            <span>{format(parseISO(announcement.startDate), 'MMM d, yyyy')}</span>
                          </div>
                          <div className="flex items-center gap-1">
                            <Clock className="h-3 w-3" />
                            <span>{format(parseISO(announcement.endDate), 'MMM d, yyyy')}</span>
                          </div>
                        </div>
                      </div>
                      <div className="flex gap-1 ml-2">
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => setPreviewAnnouncement(announcement)}
                        >
                          <Eye className="h-4 w-4" />
                        </Button>
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => setEditingAnnouncement(announcement)}
                        >
                          <Edit className="h-4 w-4" />
                        </Button>
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={() => setDeletingAnnouncement(announcement)}
                        >
                          <Trash2 className="h-4 w-4" />
                        </Button>
                      </div>
                    </div>
                  </Card>
                );
              })}
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  );
}