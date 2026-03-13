'use client';

import { Button } from '@/components/ui/button';
import { 
  CheckCircle, 
  XCircle, 
  Flag, 
  AlertTriangle 
} from 'lucide-react';
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
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';
import { Label } from '@/components/ui/label';
import { 
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Textarea } from '@/components/ui/textarea';

interface ModerationActionsProps {
  isProcessing: boolean;
  onAction: (action: 'approve' | 'reject' | 'warn') => void;
  flagDialogOpen: boolean;
  setFlagDialogOpen: (open: boolean) => void;
  flagType: string;
  setFlagType: (type: string) => void;
  flagReason: string;
  setFlagReason: (reason: string) => void;
  onFlag: () => void;
  warningDialogOpen: boolean;
  setWarningDialogOpen: (open: boolean) => void;
  warningText: string;
  setWarningText: (text: string) => void;
  onWarn: () => void;
}

export function ModerationActions({
  isProcessing,
  onAction,
  flagDialogOpen,
  setFlagDialogOpen,
  flagType,
  setFlagType,
  flagReason,
  setFlagReason,
  onFlag,
  warningDialogOpen,
  setWarningDialogOpen,
  warningText,
  setWarningText,
  onWarn
}: ModerationActionsProps) {
  return (
    <div className="space-y-3">
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
                onClick={() => onAction('approve')}
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
                onClick={() => onAction('reject')}
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
                  onClick={onFlag}
                  disabled={isProcessing || !flagType || !flagReason}
                >
                  {isProcessing ? 'Flagging...' : 'Flag Content'}
                </Button>
              </div>
            </div>
          </DialogContent>
        </Dialog>
      </div>

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
                  onClick={onWarn}
                  disabled={isProcessing || !warningText}
                >
                  {isProcessing ? 'Adding...' : 'Add Warning'}
                </Button>
              </div>
            </div>
          </DialogContent>
        </Dialog>
      </div>
    </div>
  );
}
