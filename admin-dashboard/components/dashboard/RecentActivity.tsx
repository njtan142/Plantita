import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { ScrollArea } from '@/components/ui/scroll-area';
import { Skeleton } from '@/components/ui/skeleton';
import { formatDistanceToNow } from 'date-fns';

interface Activity {
  id: string;
  type: 'user_registered' | 'media_uploaded' | 'user_login' | 'media_approved' | 'media_rejected';
  title: string;
  description: string;
  timestamp: string;
  user?: {
    id: string;
    name: string;
    avatar?: string;
  };
}

interface RecentActivityProps {
  activities: Activity[];
  loading?: boolean;
}

const getActivityIcon = (type: Activity['type']) => {
  switch (type) {
    case 'user_registered':
      return '👤';
    case 'media_uploaded':
      return '📁';
    case 'user_login':
      return '🔑';
    case 'media_approved':
      return '✅';
    case 'media_rejected':
      return '❌';
    default:
      return '📋';
  }
};

const getActivityColor = (type: Activity['type']) => {
  switch (type) {
    case 'user_registered':
      return 'bg-blue-100 text-blue-800';
    case 'media_uploaded':
      return 'bg-green-100 text-green-800';
    case 'user_login':
      return 'bg-gray-100 text-gray-800';
    case 'media_approved':
      return 'bg-green-100 text-green-800';
    case 'media_rejected':
      return 'bg-red-100 text-red-800';
    default:
      return 'bg-gray-100 text-gray-800';
  }
};

export function RecentActivity({ activities, loading = false }: RecentActivityProps) {
  if (loading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>
            <Skeleton className="h-6 w-32" />
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {[1, 2, 3, 4, 5].map((i) => (
              <div key={i} className="flex items-center space-x-4">
                <Skeleton className="h-10 w-10 rounded-full" />
                <div className="flex-1 space-y-2">
                  <Skeleton className="h-4 w-3/4" />
                  <Skeleton className="h-3 w-1/2" />
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Recent Activity</CardTitle>
      </CardHeader>
      <CardContent>
        <ScrollArea className="h-80">
          <div className="space-y-4">
            {activities.length === 0 ? (
              <p className="text-sm text-muted-foreground text-center py-8">
                No recent activity
              </p>
            ) : (
              activities.map((activity) => (
                <div key={activity.id} className="flex items-start space-x-4">
                  <Avatar className="h-10 w-10">
                    <AvatarImage src={activity.user?.avatar} alt={activity.user?.name} />
                    <AvatarFallback>
                      {activity.user?.name?.charAt(0) || getActivityIcon(activity.type)}
                    </AvatarFallback>
                  </Avatar>
                  <div className="flex-1 space-y-1">
                    <div className="flex items-center justify-between">
                      <p className="text-sm font-medium">{activity.title}</p>
                      <Badge className={`text-xs ${getActivityColor(activity.type)}`}>
                        {activity.type.replace('_', ' ')}
                      </Badge>
                    </div>
                    <p className="text-xs text-muted-foreground">{activity.description}</p>
                    <p className="text-xs text-muted-foreground">
                      {formatDistanceToNow(new Date(activity.timestamp), { addSuffix: true })}
                    </p>
                  </div>
                </div>
              ))
            )}
          </div>
        </ScrollArea>
      </CardContent>
    </Card>
  );
}