'use client';

import { useState } from 'react';
import { mediaContentService } from '@/services/mediaContentService';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { toast } from 'sonner';

import { MediaModerationToolsProps } from './media-moderation-tools/types';
import { ModerationStatus } from './media-moderation-tools/ModerationStatus';
import { ModerationActions } from './media-moderation-tools/ModerationActions';
import { FlagsAndWarnings } from './media-moderation-tools/FlagsAndWarnings';

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

  return (
    <Card>
      <CardHeader>
        <CardTitle>Moderation Tools</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="space-y-6">
          <ModerationStatus 
            status={media.moderation?.status || 'pending'} 
            updatedAt={media.updatedAt} 
          />

          <ModerationActions
            isProcessing={isProcessing}
            onAction={handleModerationAction}
            flagDialogOpen={flagDialogOpen}
            setFlagDialogOpen={setFlagDialogOpen}
            flagType={flagType}
            setFlagType={setFlagType}
            flagReason={flagReason}
            setFlagReason={setFlagReason}
            onFlag={handleFlagContent}
            warningDialogOpen={warningDialogOpen}
            setWarningDialogOpen={setWarningDialogOpen}
            warningText={warningText}
            setWarningText={setWarningText}
            onWarn={handleAddWarning}
          />

          <FlagsAndWarnings moderation={media.moderation} />
        </div>
      </CardContent>
    </Card>
  );
}