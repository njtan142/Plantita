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
import { toast } from 'sonner';
import { ArrowLeft } from 'lucide-react';
import { UserActionHeader } from '@/components/users/user-management/UserActionHeader';
import { UserManagementDialogs } from '@/components/users/user-management/UserManagementDialogs';

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

      const userResponse = await userContentService.getUserById(userId);
      if (!userResponse.success || !userResponse.data) {
        throw new Error(userResponse.message || 'Failed to fetch user profile');
      }
      setUser(userResponse.data);

      const activitiesResponse = await userContentService.getUserActivityHistory(userId);
      if (!activitiesResponse.success) {
        throw new Error(activitiesResponse.message || 'Failed to fetch user activities');
      }
      setActivities(activitiesResponse.data || []);

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

  if (error || !user) {
    return (
      <div className="space-y-6">
        <div className="flex items-center justify-between">
          <Button variant="outline" onClick={handleGoBack}>
            <ArrowLeft className="h-4 w-4 mr-2" />
            Back
          </Button>
        </div>
        
        <Alert variant="destructive">
          <AlertTitle>{error ? 'Error' : 'User not found'}</AlertTitle>
          <AlertDescription>
            {error || 'No user data available for the provided ID.'}
          </AlertDescription>
        </Alert>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <UserActionHeader
        onBack={handleGoBack}
        onSuspend={() => setSuspendDialogOpen(true)}
        onBan={() => setBanDialogOpen(true)}
        onResetPassword={() => setResetPasswordDialogOpen(true)}
      />

      <UserContentProfile userId={userId} />
      <UserActivityTimeline userId={userId} activities={activities} />
      <UserMediaGallery userId={userId} media={media} />

      <UserManagementDialogs
        suspendDialogOpen={suspendDialogOpen}
        setSuspendDialogOpen={setSuspendDialogOpen}
        handleSuspendUser={handleSuspendUser}
        banDialogOpen={banDialogOpen}
        setBanDialogOpen={setBanDialogOpen}
        handleBanUser={handleBanUser}
        resetPasswordDialogOpen={resetPasswordDialogOpen}
        setResetPasswordDialogOpen={setResetPasswordDialogOpen}
        handleResetPassword={handleResetPassword}
      />
    </div>
  );
}
