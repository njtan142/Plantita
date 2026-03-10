'use client';

import { useState } from 'react';
import { Media, MediaModeration } from '@/types/api';
import { mediaContentService } from '@/services/mediaContentService';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Textarea } from '@/components/ui/textarea';
import { Label } from '@/components/ui/label';
import { 
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Badge } from '@/components/ui/badge';
import { 
  Flag,
  AlertTriangle,
  CheckCircle,
  XCircle,
  Eye,
  Calendar,
  User
} from 'lucide-react';
import { toast } from 'sonner';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from '@/components/ui/alert-dialog';
import { format, parseISO } from 'date-fns';

interface MediaModerationToolsProps {
  media: Media;
  onMediaUpdate?: (updatedMedia: Media) => void;
}

export function MediaModerationTools({ media, onMediaUpdate }: MediaModerationToolsProps) {
  const [flagDialogOpen, setFlagDialogOpen] = useState(false);
  const [warningDialogOpen, setWarningDialogOpen] = useState(false);
  const [flagType, setFlagType] = useState('');
  const [flagReason, setFlagReason] = useState('');
  const [warningText, setWarningText] = useState('');
  const [isProcessing, setIsProcessing] = useState(false);

  const handleFlagContent = async () => {
    if (!flagType || !flagReason) {
      toast.error('Please provide both flag type and reason');
      return;
    }

    try {
      setIsProcessing(true);
      const response = await mediaContentService.flagMediaContent(
        media.id,
        flagType,
        flagReason
      );

      if (response.success && response.data) {
        toast.success('Content flagged successfully');
        onMediaUpdate?.(response.data);
        setFlagDialogOpen(false);
        setFlagType('');
        setFlagReason('');
      } else {
        throw new Error(response.message || 'Failed to flag content');
      }
    } catch (err) {
      console.error('Error flagging content:', err);
      toast.error(err instanceof Error ? err.message : 'Failed to flag content');
    } finally {
      setIsProcessing(false);
    }
  };

  const handleAddWarning = async () => {
    if (!warningText) {
      toast.error('Please provide a warning message');
      return;
    }

    try {
      setIsProcessing(true);
      const response = await mediaContentService.addContentWarning(
        media.id,
        warningText
      );

      if (response.success && response.data) {
        toast.success('Warning added successfully');
        onMediaUpdate?.(response.data);
        setWarningDialogOpen(false);
        setWarningText('');
      } else {
        throw new Error(response.message || 'Failed to add warning');
      }
    } catch (err) {
      console.error('Error adding warning:', err);
      toast.error(err instanceof Error ? err.message : 'Failed to add warning');
    } finally {
      setIsProcessing(false);
    }
  };

  const handleModerationAction = async (action: 'approve' | 'reject' | 'warn') => {
    try {
      setIsProcessing(true);
      
      // For approve/reject actions, we'll use the batch moderate function
      const response = await mediaContentService.batchModerateMedia(
        [media.id],
        action === 'approve' ? 'approved' : action === 'reject' ? 'rejected' : 'flagged'
      );

      if (response.success && response.data && response.data.length > 0) {
        const updatedMedia = response.data[0];
        toast.success(`Content ${action}d successfully`);
        onMediaUpdate?.(updatedMedia);
      } else {
        throw new Error(response.message || `Failed to ${action} content`);
      }
    } catch (err) {
      console.error(`Error ${action}ing content:`, err);
      toast.error(err instanceof Error ? err.message : `Failed to ${action} content`);
    } finally {
      setIsProcessing(false);
    }
  };

  const getStatusBadgeVariant = (status: string) => {
    switch (status) {
      case 'approved':
        return 'default';
      case 'pending':
        return 'secondary';
      case 'rejected':
        return 'destructive';
      case 'flagged':
        return 'destructive';
      default:
        return 'secondary';
    }
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle>Moderation Tools</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-6">
          {/* Current Status */}
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-2">
              <span className="font-medium">Current Status:</span>
              <Badge variant={getStatusBadgeVariant(media.moderation?.status || 'pending')}>
                {media.moderation?.status || 'pending'}
              </Badge>
            </div>
            <div className="text-sm text-gray-500">
              Last updated: {format(parseISO(media.updatedAt), 'MMM d, yyyy h:mm a')}
            </div>
          </div>

          {/* Moderation Actions */}
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
            <AlertDialog>
              <AlertDialogTrigger asChild>
                <Button 
                  variant="outline" 
                  className="w-full"
                  disabled={isProcessing}
                >
                  <CheckCircle className="h-4 w-4 mr-2 text-green-500" />
                  Approve
                </Button>
              </AlertDialogTrigger>
              <AlertDialogContent>
                <AlertDialogHeader>
                  <AlertDialogTitle>Approve Content</AlertDialogTitle>
                  <AlertDialogDescription>
                    Are you sure you want to approve this content? This will make it visible to all users.
                  </AlertDialogDescription>
                </AlertDialogHeader>
                <AlertDialogFooter>
                  <AlertDialogCancel>Cancel</AlertDialogCancel>
                  <AlertDialogAction 
                    onClick={() => handleModerationAction('approve')}
                    className="bg-green-600 hover:bg-green-700"
                  >
                    Approve
                  </AlertDialogAction>
                </AlertDialogFooter>
              </AlertDialogContent>
            </AlertDialog>

            <AlertDialog>
              <AlertDialogTrigger asChild>
                <Button 
                  variant="outline" 
                  className="w-full"
                  disabled={isProcessing}
                >
                  <XCircle className="h-4 w-4 mr-2 text-red-500" />
                  Reject
                </Button>
              </AlertDialogTrigger>
              <AlertDialogContent>
                <AlertDialogHeader>
                  <AlertDialogTitle>Reject Content</AlertDialogTitle>
                  <AlertDialogDescription>
                    Are you sure you want to reject this content? This will hide it from users.
                  </AlertDialogDescription>
                </AlertDialogHeader>
                <AlertDialogFooter>
                  <AlertDialogCancel>Cancel</AlertDialogCancel>
                  <AlertDialogAction 
                    onClick={() => handleModerationAction('reject')}
                    className="bg-red-600 hover:bg-red-700"
                  >
                    Reject
                  </AlertDialogAction>
                </AlertDialogFooter>
              </AlertDialogContent>
            </AlertDialog>

            <Dialog open={flagDialogOpen} onOpenChange={setFlagDialogOpen}>
              <DialogTrigger asChild>
                <Button 
                  variant="outline" 
                  className="w-full"
                  disabled={isProcessing}
                >
                  <Flag className="h-4 w-4 mr-2 text-yellow-500" />
                  Flag
                </Button>
              </DialogTrigger>
              <DialogContent>
                <DialogHeader>
                  <DialogTitle>Flag Content</DialogTitle>
                </DialogHeader>
                <div className="space-y-4">
                  <div>
                    <Label htmlFor="flagType">Flag Type</Label>
                    <Select value={flagType} onValueChange={setFlagType}>
                      <SelectTrigger>
                        <SelectValue placeholder="Select flag type" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="inappropriate">Inappropriate Content</SelectItem>
                        <SelectItem value="copyright">Copyright Violation</SelectItem>
                        <SelectItem value="spam">Spam</SelectItem>
                        <SelectItem value="violence">Violence</SelectItem>
                        <SelectItem value="harassment">Harassment</SelectItem>
                        <SelectItem value="other">Other</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div>
                    <Label htmlFor="flagReason">Reason</Label>
                    <Textarea
                      id="flagReason"
                      value={flagReason}
                      onChange={(e) => setFlagReason(e.target.value)}
                      placeholder="Provide a reason for flagging this content"
                    />
                  </div>
                  <div className="flex justify-end space-x-2">
                    <Button
                      variant="outline"
                      onClick={() => setFlagDialogOpen(false)}
                      disabled={isProcessing}
                    >
                      Cancel
                    </Button>
                    <Button
                      onClick={handleFlagContent}
                      disabled={isProcessing || !flagType || !flagReason}
                    >
                      {isProcessing ? 'Flagging...' : 'Flag Content'}
                    </Button>
                  </div>
                </div>
              </DialogContent>
            </Dialog>
          </div>

          {/* Add Warning Button */}
          <div>
            <Dialog open={warningDialogOpen} onOpenChange={setWarningDialogOpen}>
              <DialogTrigger asChild>
                <Button 
                  variant="outline" 
                  className="w-full"
                  disabled={isProcessing}
                >
                  <AlertTriangle className="h-4 w-4 mr-2 text-orange-500" />
                  Add Warning
                </Button>
              </DialogTrigger>
              <DialogContent>
                <DialogHeader>
                  <DialogTitle>Add Content Warning</DialogTitle>
                </DialogHeader>
                <div className="space-y-4">
                  <div>
                    <Label htmlFor="warningText">Warning Message</Label>
                    <Textarea
                      id="warningText"
                      value={warningText}
                      onChange={(e) => setWarningText(e.target.value)}
                      placeholder="Enter a warning message for this content"
                    />
                  </div>
                  <div className="flex justify-end space-x-2">
                    <Button
                      variant="outline"
                      onClick={() => setWarningDialogOpen(false)}
                      disabled={isProcessing}
                    >
                      Cancel
                    </Button>
                    <Button
                      onClick={handleAddWarning}
                      disabled={isProcessing || !warningText}
                    >
                      {isProcessing ? 'Adding...' : 'Add Warning'}
                    </Button>
                  </div>
                </div>
              </DialogContent>
            </Dialog>
          </div>

          {/* Existing Flags and Warnings */}
          {media.moderation && (
            <div className="space-y-4">
              {media.moderation.flags && media.moderation.flags.length > 0 && (
                <div>
                  <h3 className="font-medium mb-2 flex items-center">
                    <Flag className="h-4 w-4 mr-2 text-yellow-500" />
                    Content Flags
                  </h3>
                  <div className="space-y-2">
                    {media.moderation.flags.map((flag, index) => (
                      <div key={index} className="p-3 bg-yellow-50 border border-yellow-200 rounded-md">
                        <div className="flex justify-between">
                          <span className="font-medium">{flag.type}</span>
                          <span className="text-sm text-gray-500">
                            {format(parseISO(flag.timestamp), 'MMM d, yyyy h:mm a')}
                          </span>
                        </div>
                        <p className="text-sm mt-1">{flag.reason}</p>
                        {flag.moderatorId && (
                          <div className="flex items-center mt-2 text-xs text-gray-500">
                            <User className="h-3 w-3 mr-1" />
                            Moderator: {flag.moderatorId}
                          </div>
                        )}
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {media.moderation.warnings && media.moderation.warnings.length > 0 && (
                <div>
                  <h3 className="font-medium mb-2 flex items-center">
                    <AlertTriangle className="h-4 w-4 mr-2 text-orange-500" />
                    Content Warnings
                  </h3>
                  <div className="space-y-2">
                    {media.moderation.warnings.map((warning, index) => (
                      <div key={index} className="p-3 bg-orange-50 border border-orange-200 rounded-md">
                        <p className="text-sm">{warning}</p>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {media.moderation.category && (
                <div>
                  <h3 className="font-medium mb-2">Category</h3>
                  <Badge variant="secondary">{media.moderation.category}</Badge>
                </div>
              )}
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  );
}