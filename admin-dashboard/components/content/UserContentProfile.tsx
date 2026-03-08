'use client';

import { useState, useEffect } from 'react';
import { User, UserStatistics, UserActivity, Media } from '@/types/api';
import { userContentService } from '@/services/userContentService';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Badge } from '@/components/ui/badge';
import { LoadingSpinner } from '@/components/layout/LoadingSpinner';
import { Alert, AlertTitle, AlertDescription } from '@/components/ui/alert';
import { User as UserIcon, Mail, Calendar, Image, Heart, MessageCircle, Eye, Flag } from 'lucide-react';

interface UserContentProfileProps {
  userId: string;
}

export function UserContentProfile({ userId }: UserContentProfileProps) {
  const [user, setUser] = useState<User | null>(null);
  const [statistics, setStatistics] = useState<UserStatistics | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchUserContentProfile();
  }, [userId]);

  const fetchUserContentProfile = async () => {
    try {
      setLoading(true);
      setError(null);

      const response = await userContentService.getUserContentProfile(userId);
      
      if (response.success && response.data) {
        setUser(response.data.user);
        setStatistics(response.data.statistics);
      } else {
        setError(response.message || 'Failed to fetch user profile');
      }
    } catch (err) {
      console.error('Error fetching user content profile:', err);
      setError('An unexpected error occurred while fetching user profile');
    } finally {
      setLoading(false);
    }
  };

  const getUserDisplayName = (user: User) => {
    if (user.firstName && user.lastName) {
      return `${user.firstName} ${user.lastName}`;
    }
    return user.username;
  };

  const getStatusBadgeVariant = (status: string) => {
    switch (status) {
      case 'active':
        return 'default';
      case 'inactive':
        return 'secondary';
      case 'suspended':
        return 'destructive';
      case 'banned':
        return 'destructive';
      default:
        return 'secondary';
    }
  };

  const getRoleBadgeVariant = (role: string) => {
    switch (role) {
      case 'admin':
        return 'destructive';
      case 'moderator':
        return 'default';
      case 'user':
        return 'secondary';
      default:
        return 'secondary';
    }
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
      <Alert variant="destructive">
        <AlertTitle>Error</AlertTitle>
        <AlertDescription>{error}</AlertDescription>
      </Alert>
    );
  }

  if (!user || !statistics) {
    return (
      <Alert variant="destructive">
        <AlertTitle>User not found</AlertTitle>
        <AlertDescription>No user data available for the provided ID.</AlertDescription>
      </Alert>
    );
  }

  return (
    <div className="space-y-6">
      {/* User Profile Section */}
      <Card>
        <CardHeader>
          <CardTitle>User Profile</CardTitle>
        </CardHeader>
        <CardContent>
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

              <div className="flex flex-wrap items-center gap-2">
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

          <div className="mt-6 grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="flex items-center space-x-2">
              <Mail className="h-4 w-4 text-gray-500" />
              <span className="text-sm">{user.email}</span>
            </div>
            <div className="flex items-center space-x-2">
              <Calendar className="h-4 w-4 text-gray-500" />
              <span className="text-sm">
                Joined {new Date(user.createdAt).toLocaleDateString()}
              </span>
            </div>
            {user.lastLoginAt && (
              <div className="flex items-center space-x-2">
                <UserIcon className="h-4 w-4 text-gray-500" />
                <span className="text-sm">
                  Last login {new Date(user.lastLoginAt).toLocaleDateString()}
                </span>
              </div>
            )}
          </div>
        </CardContent>
      </Card>

      {/* User Statistics Section */}
      <Card>
        <CardHeader>
          <CardTitle>User Statistics</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
            <StatCard 
              icon={<Image className="h-4 w-4" />} 
              label="Uploads" 
              value={statistics.totalUploads} 
            />
            <StatCard 
              icon={<Heart className="h-4 w-4" />} 
              label="Likes" 
              value={statistics.totalLikes} 
            />
            <StatCard 
              icon={<MessageCircle className="h-4 w-4" />} 
              label="Comments" 
              value={statistics.totalComments} 
            />
            <StatCard 
              icon={<Eye className="h-4 w-4" />} 
              label="Views" 
              value={statistics.totalViews} 
            />
            <StatCard 
              icon={<Flag className="h-4 w-4" />} 
              label="Reported" 
              value={statistics.reportedContent} 
            />
            <StatCard 
              icon={<UserIcon className="h-4 w-4" />} 
              label="Engagement" 
              value={`${(statistics.engagementRate * 100).toFixed(1)}%`} 
            />
          </div>
        </CardContent>
      </Card>
    </div>
  );
}

interface StatCardProps {
  icon: React.ReactNode;
  label: string;
  value: string | number;
}

function StatCard({ icon, label, value }: StatCardProps) {
  return (
    <div className="flex flex-col items-center justify-center p-4 bg-gray-50 rounded-lg">
      <div className="flex items-center space-x-2 text-gray-500 mb-1">
        {icon}
        <span className="text-xs font-medium">{label}</span>
      </div>
      <span className="text-lg font-bold">{value}</span>
    </div>
  );
}