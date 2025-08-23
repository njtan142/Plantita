'use client';

import { useState, useEffect } from 'react';
import { Calendar, Mail, User as UserIcon, Shield, Clock, Activity } from 'lucide-react';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Badge } from '@/components/ui/badge';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Separator } from '@/components/ui/separator';
import { LoadingSpinner } from '@/components/layout/LoadingSpinner';
import { userService } from '@/services/userService';
import { User, UserRole, UserStatus } from '@/types/api';

interface UserDetailModalProps {
  userId: string | null;
  open: boolean;
  onClose: () => void;
}

interface UserActivity {
  id: string;
  type: 'login' | 'media_upload' | 'profile_update' | 'status_change';
  description: string;
  timestamp: string;
  metadata?: Record<string, string | number | boolean>;
}

export function UserDetailModal({ userId, open, onClose }: UserDetailModalProps) {
  const [user, setUser] = useState<User | null>(null);
  const [activities, setActivities] = useState<UserActivity[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (userId && open) {
      fetchUserDetails();
    }
  }, [userId, open, fetchUserDetails]);

  const fetchUserDetails = async () => {
    if (!userId) return;

    try {
      setLoading(true);

      // Fetch user details
      const userResponse = await userService.getUserById(userId);
      if (userResponse.success && userResponse.data) {
        setUser(userResponse.data);
      }

      // Mock activity data (in a real app, this would come from an API)
      const mockActivities: UserActivity[] = [
        {
          id: '1',
          type: 'login',
          description: 'User logged in',
          timestamp: new Date(Date.now() - 1000 * 60 * 30).toISOString(),
        },
        {
          id: '2',
          type: 'media_upload',
          description: 'Uploaded new media file',
          timestamp: new Date(Date.now() - 1000 * 60 * 60 * 2).toISOString(),
          metadata: { filename: 'image.jpg' },
        },
        {
          id: '3',
          type: 'profile_update',
          description: 'Updated profile information',
          timestamp: new Date(Date.now() - 1000 * 60 * 60 * 24).toISOString(),
        },
        {
          id: '4',
          type: 'status_change',
          description: 'Account status changed to active',
          timestamp: new Date(Date.now() - 1000 * 60 * 60 * 24 * 3).toISOString(),
        },
      ];

      setActivities(mockActivities);
    } catch (err) {
      console.error('Error fetching user details:', err);
    } finally {
      setLoading(false);
    }
  };

  const getStatusBadgeVariant = (status: UserStatus) => {
    switch (status) {
      case UserStatus.ACTIVE:
        return 'default';
      case UserStatus.INACTIVE:
        return 'secondary';
      case UserStatus.SUSPENDED:
        return 'destructive';
      case UserStatus.BANNED:
        return 'destructive';
      default:
        return 'secondary';
    }
  };

  const getRoleBadgeVariant = (role: UserRole) => {
    switch (role) {
      case UserRole.ADMIN:
        return 'destructive';
      case UserRole.MODERATOR:
        return 'default';
      case UserRole.USER:
        return 'secondary';
      default:
        return 'secondary';
    }
  };

  const getActivityIcon = (type: UserActivity['type']) => {
    switch (type) {
      case 'login':
        return <UserIcon className="h-4 w-4" />;
      case 'media_upload':
        return <Activity className="h-4 w-4" />;
      case 'profile_update':
        return <UserIcon className="h-4 w-4" />;
      case 'status_change':
        return <Shield className="h-4 w-4" />;
      default:
        return <Activity className="h-4 w-4" />;
    }
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });
  };

  const getUserDisplayName = (user: User) => {
    if (user.firstName && user.lastName) {
      return `${user.firstName} ${user.lastName}`;
    }
    return user.username;
  };

  if (loading) {
    return (
      <Dialog open={open} onOpenChange={onClose}>
        <DialogContent className="sm:max-w-[700px]">
          <div className="flex items-center justify-center py-12">
            <LoadingSpinner />
          </div>
        </DialogContent>
      </Dialog>
    );
  }

  if (!user) {
    return null;
  }

  return (
    <Dialog open={open} onOpenChange={onClose}>
      <DialogContent className="sm:max-w-[700px] max-h-[80vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>User Details</DialogTitle>
        </DialogHeader>

        <div className="space-y-6">
          {/* User Profile Section */}
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-start space-x-4">
                <Avatar className="h-16 w-16">
                  <AvatarImage src={user.avatar} alt={getUserDisplayName(user)} />
                  <AvatarFallback className="text-lg">
                    {user.firstName?.[0] || user.username[0].toUpperCase()}
                  </AvatarFallback>
                </Avatar>

                <div className="flex-1 space-y-2">
                  <div>
                    <h3 className="text-xl font-semibold">{getUserDisplayName(user)}</h3>
                    <p className="text-sm text-gray-500">@{user.username}</p>
                  </div>

                  <div className="flex items-center space-x-2">
                    <Badge variant={getStatusBadgeVariant(user.status)}>
                      {user.status}
                    </Badge>
                    <Badge variant={getRoleBadgeVariant(user.role)}>
                      {user.role}
                    </Badge>
                    {user.emailVerified && (
                      <Badge variant="outline" className="text-green-600">
                        ✓ Verified
                      </Badge>
                    )}
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* User Information */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Contact Information</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="flex items-center space-x-2">
                  <Mail className="h-4 w-4 text-gray-500" />
                  <span className="text-sm">{user.email}</span>
                </div>
                {user.firstName && (
                  <div className="flex items-center space-x-2">
                    <UserIcon className="h-4 w-4 text-gray-500" />
                    <span className="text-sm">
                      {user.firstName} {user.lastName}
                    </span>
                  </div>
                )}
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-lg">Account Information</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                <div className="flex items-center space-x-2">
                  <Calendar className="h-4 w-4 text-gray-500" />
                  <span className="text-sm">
                    Joined {formatDate(user.createdAt)}
                  </span>
                </div>
                {user.lastLoginAt && (
                  <div className="flex items-center space-x-2">
                    <Clock className="h-4 w-4 text-gray-500" />
                    <span className="text-sm">
                      Last login {formatDate(user.lastLoginAt)}
                    </span>
                  </div>
                )}
                <div className="flex items-center space-x-2">
                  <Shield className="h-4 w-4 text-gray-500" />
                  <span className="text-sm">Role: {user.role}</span>
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Recent Activity */}
          <Card>
            <CardHeader>
              <CardTitle className="text-lg">Recent Activity</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {activities.length === 0 ? (
                  <p className="text-sm text-gray-500 text-center py-4">
                    No recent activity
                  </p>
                ) : (
                  activities.map((activity, index) => (
                    <div key={activity.id}>
                      <div className="flex items-start space-x-3">
                        <div className="flex-shrink-0 mt-1">
                          {getActivityIcon(activity.type)}
                        </div>
                        <div className="flex-1 min-w-0">
                          <p className="text-sm font-medium text-gray-900">
                            {activity.description}
                          </p>
                          <p className="text-xs text-gray-500">
                            {formatDate(activity.timestamp)}
                          </p>
                          {activity.metadata && (
                            <p className="text-xs text-gray-400 mt-1">
                              {Object.entries(activity.metadata).map(([key, value]) => (
                                <span key={key} className="mr-2">
                                  {key}: {String(value)}
                                </span>
                              ))}
                            </p>
                          )}
                        </div>
                      </div>
                      {index < activities.length - 1 && (
                        <Separator className="mt-4" />
                      )}
                    </div>
                  ))
                )}
              </div>
            </CardContent>
          </Card>
        </div>
      </DialogContent>
    </Dialog>
  );
}