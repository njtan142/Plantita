'use client';

import { useState, useEffect, useCallback } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { User, UserActivity, Media } from '@/types/api';
import { userContentService } from '@/services/userContentService';
import { UserContentProfile } from '@/components/content/UserContentProfile';
import { UserActivityTimeline } from '@/components/content/UserActivityTimeline';
import { UserMediaGallery } from '@/components/content/UserMediaGallery';
import { LoadingSpinner } from '@/components/layout/LoadingSpinner';
import { Alert, AlertTitle, AlertDescription } from '@/components/ui/alert';
import { Button } from '@/components/ui/button';
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
import { toast } from 'sonner';
import { 
  ShieldAlert, 
  Lock, 
  Key, 
  ArrowLeft,
  MoreHorizontal
} from 'lucide-react';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';

export default function UserContentManagementPage() {
  const params = useParams();
  const router = useRouter();
  const userId = params.userId as string;
  
  const [user, setUser] = useState<User | null>(null);
  const [activities, setActivities] = useState<UserActivity[]>([]);
  const [media, setMedia] = useState<Media[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [suspendDialogOpen, setSuspendDialogOpen] = useState(false);
  const [banDialogOpen, setBanDialogOpen] = useState(false);
  const [resetPasswordDialogOpen, setResetPasswordDialogOpen] = useState(false);

  const fetchUserContent = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);

      // Fetch user profile
      const userResponse = await userContentService.getUserById(userId);
      if (!userResponse.success || !userResponse.data) {
        throw new Error(userResponse.message || 'Failed to fetch user profile');
      }
      setUser(userResponse.data);

      // Fetch user activities
      const activitiesResponse = await userContentService.getUserActivityHistory(userId);
      if (!activitiesResponse.success) {
        throw new Error(activitiesResponse.message || 'Failed to fetch user activities');
      }
      setActivities(activitiesResponse.data || []);

      // Fetch user media
      const mediaResponse = await userContentService.getUserMediaContent(userId);
      if (!mediaResponse.success) {
        throw new Error(mediaResponse.message || 'Failed to fetch user media');
      }
      setMedia(mediaResponse.data || []);
    } catch (err) {
      console.error('Error fetching user content:', err);
      setError(err instanceof Error ? err.message : 'An unexpected error occurred');
    } finally {
      setLoading(false);
    }
  }, [userId]);

  useEffect(() => {
    if (userId) {
      fetchUserContent();
    }
  }, [userId, fetchUserContent]);

  const handleSuspendUser = async () => {
    if (!user) return;
    
    try {
      const response = await userContentService.suspendUser(user.id);
      if (response.success && response.data) {
        setUser(response.data);
        toast.success('User suspended successfully');
        // Refresh the user content to get updated status
        fetchUserContent();
      } else {
        throw new Error(response.message || 'Failed to suspend user');
      }
    } catch (err) {
      console.error('Error suspending user:', err);
      toast.error(err instanceof Error ? err.message : 'Failed to suspend user');
    } finally {
      setSuspendDialogOpen(false);
    }
  };

  const handleBanUser = async () => {
    if (!user) return;
    
    try {
      const response = await userContentService.banUser(user.id);
      if (response.success && response.data) {
        setUser(response.data);
        toast.success('User banned successfully');
        // Refresh the user content to get updated status
        fetchUserContent();
      } else {
        throw new Error(response.message || 'Failed to ban user');
      }
    } catch (err) {
      console.error('Error banning user:', err);
      toast.error(err instanceof Error ? err.message : 'Failed to ban user');
    } finally {
      setBanDialogOpen(false);
    }
  };

  const handleResetPassword = async () => {
    if (!user) return;
    
    try {
      // In a real implementation, we would generate a random password or send a reset link
      // For this demo with mock data, we'll just show a success message
      const response = await userContentService.resetUserPassword(user.id, 'temporaryPassword123');
      if (response.success) {
        toast.success('Password reset successfully. A temporary password has been generated.');
      } else {
        throw new Error(response.message || 'Failed to reset password');
      }
    } catch (err) {
      console.error('Error resetting password:', err);
      toast.error(err instanceof Error ? err.message : 'Failed to reset password');
    } finally {
      setResetPasswordDialogOpen(false);
    }
  };

  const handleGoBack = () => {
    router.back();
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center py-12">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <Button variant="outline" onClick={handleGoBack}>
            <ArrowLeft className="h-4 w-4 mr-2" />
            Back
          </Button>
        </div>
        
        <Alert variant="destructive">
          <AlertTitle>Error</AlertTitle>
          <AlertDescription>{error}</AlertDescription>
        </Alert>
      </div>
    );
  }

  if (!user) {
    return (
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <Button variant="outline" onClick={handleGoBack}>
            <ArrowLeft className="h-4 w-4 mr-2" />
            Back
          </Button>
        </div>
        
        <Alert variant="destructive">
          <AlertTitle>User not found</AlertTitle>
          <AlertDescription>No user data available for the provided ID.</AlertDescription>
        </Alert>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header with back button and actions */}
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div className="flex items-center space-x-4">
          <Button variant="outline" onClick={handleGoBack}>
            <ArrowLeft className="h-4 w-4" />
          </Button>
          <h1 className="text-2xl font-bold">User Content Management</h1>
        </div>
        
        <div className="flex items-center space-x-2">
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="outline">
                <MoreHorizontal className="h-4 w-4 mr-2" />
                Actions
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
              <DropdownMenuItem onClick={() => setSuspendDialogOpen(true)}>
                <ShieldAlert className="h-4 w-4 mr-2" />
                Suspend User
              </DropdownMenuItem>
              <DropdownMenuItem onClick={() => setBanDialogOpen(true)}>
                <Lock className="h-4 w-4 mr-2" />
                Ban User
              </DropdownMenuItem>
              <DropdownMenuItem onClick={() => setResetPasswordDialogOpen(true)}>
                <Key className="h-4 w-4 mr-2" />
                Reset Password
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>

      {/* User Profile Section */}
      <UserContentProfile userId={userId} />

      {/* User Activity Timeline */}
      <UserActivityTimeline userId={userId} activities={activities} />

      {/* User Media Gallery */}
      <UserMediaGallery userId={userId} media={media} />

      {/* Suspend User Dialog */}
      <AlertDialog open={suspendDialogOpen} onOpenChange={setSuspendDialogOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Suspend User</AlertDialogTitle>
            <AlertDialogDescription>
              Are you sure you want to suspend this user? They will be unable to access their account 
              until manually reactivated. This action can be reversed.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={handleSuspendUser}>Suspend User</AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      {/* Ban User Dialog */}
      <AlertDialog open={banDialogOpen} onOpenChange={setBanDialogOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Ban User</AlertDialogTitle>
            <AlertDialogDescription>
              Are you sure you want to ban this user? They will be permanently blocked from accessing 
              their account. This action can be reversed but should only be used for serious violations.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={handleBanUser} className="bg-red-600 hover:bg-red-700">
              Ban User
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      {/* Reset Password Dialog */}
      <AlertDialog open={resetPasswordDialogOpen} onOpenChange={setResetPasswordDialogOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Reset User Password</AlertDialogTitle>
            <AlertDialogDescription>
              Are you sure you want to reset this user&#39;s password? A temporary password will be 
              generated and the user will be required to change it on their next login.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={handleResetPassword}>Reset Password</AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}