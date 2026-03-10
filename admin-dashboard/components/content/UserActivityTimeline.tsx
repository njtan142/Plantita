'use client';

import { useState, useEffect } from 'react';
import { UserActivity } from '@/types/api';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { 
  LogIn, 
  Upload, 
  MessageSquare, 
  Heart, 
  Share2, 
  Filter,
  Calendar
} from 'lucide-react';
import { format, parseISO } from 'date-fns';

interface UserActivityTimelineProps {
  userId: string;
  activities: UserActivity[];
}

export function UserActivityTimeline({ userId, activities }: UserActivityTimelineProps) {
  const [filteredActivities, setFilteredActivities] = useState<UserActivity[]>(activities);
  const [activityFilter, setActivityFilter] = useState<string>('all');
  const [expanded, setExpanded] = useState(false);

  // Activity type to icon mapping
  const getActivityIcon = (type: string) => {
    switch (type) {
      case 'login':
        return <LogIn className="h-4 w-4" />;
      case 'upload':
        return <Upload className="h-4 w-4" />;
      case 'comment':
        return <MessageSquare className="h-4 w-4" />;
      case 'like':
        return <Heart className="h-4 w-4" />;
      case 'share':
        return <Share2 className="h-4 w-4" />;
      default:
        return <LogIn className="h-4 w-4" />;
    }
  };

  // Activity type to label mapping
  const getActivityLabel = (type: string) => {
    switch (type) {
      case 'login':
        return 'Login';
      case 'upload':
        return 'Upload';
      case 'comment':
        return 'Comment';
      case 'like':
        return 'Like';
      case 'share':
        return 'Share';
      default:
        return type;
    }
  };

  // Activity type to badge variant mapping
  const getActivityBadgeVariant = (type: string) => {
    switch (type) {
      case 'login':
        return 'default';
      case 'upload':
        return 'secondary';
      case 'comment':
        return 'secondary';
      case 'like':
        return 'destructive';
      case 'share':
        return 'outline';
      default:
        return 'secondary';
    }
  };

  // Filter activities based on selected filter
  useEffect(() => {
    if (activityFilter === 'all') {
      setFilteredActivities(activities);
    } else {
      setFilteredActivities(activities.filter(activity => activity.type === activityFilter));
    }
  }, [activityFilter, activities]);

  // Toggle expanded view
  const toggleExpanded = () => {
    setExpanded(!expanded);
  };

  // Get unique activity types for filter options
  const activityTypes = Array.from(new Set(activities.map(activity => activity.type)));

  // Limit displayed activities in collapsed view
  const displayedActivities = expanded ? filteredActivities : filteredActivities.slice(0, 5);

  return (
    <Card>
      <CardHeader>
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <CardTitle>User Activity Timeline</CardTitle>
          <div className="flex flex-wrap gap-2">
            <Button
              variant="outline"
              size="sm"
              onClick={() => setActivityFilter('all')}
              className={activityFilter === 'all' ? 'bg-gray-100' : ''}
            >
              <Filter className="h-4 w-4 mr-2" />
              All
            </Button>
            {activityTypes.map(type => (
              <Button
                key={type}
                variant="outline"
                size="sm"
                onClick={() => setActivityFilter(type)}
                className={activityFilter === type ? 'bg-gray-100' : ''}
              >
                {getActivityIcon(type)}
                <span className="ml-2">{getActivityLabel(type)}</span>
              </Button>
            ))}
          </div>
        </div>
      </CardHeader>
      <CardContent>
        {displayedActivities.length === 0 ? (
          <div className="text-center py-8 text-gray-500">
            <Calendar className="h-12 w-12 mx-auto text-gray-300 mb-2" />
            <p>No activities found</p>
            {activityFilter !== 'all' && (
              <p className="text-sm mt-1">Try selecting a different filter</p>
            )}
          </div>
        ) : (
          <div className="space-y-4">
            <div className="relative">
              {/* Timeline line */}
              <div className="absolute left-4 top-0 bottom-0 w-0.5 bg-gray-200"></div>
              
              <div className="space-y-6">
                {displayedActivities.map((activity) => (
                  <div key={activity.id} className="relative flex items-start space-x-4">
                    {/* Activity icon */}
                    <div className="flex-shrink-0 z-10 flex items-center justify-center h-8 w-8 rounded-full bg-white border-2 border-gray-200">
                      <div className={`p-1 rounded-full ${activity.type === 'login' ? 'bg-blue-100 text-blue-600' : activity.type === 'upload' ? 'bg-green-100 text-green-600' : activity.type === 'comment' ? 'bg-purple-100 text-purple-600' : activity.type === 'like' ? 'bg-red-100 text-red-600' : activity.type === 'share' ? 'bg-yellow-100 text-yellow-600' : 'bg-gray-100 text-gray-600'}`}>
                        {getActivityIcon(activity.type)}
                      </div>
                    </div>
                    
                    {/* Activity content */}
                    <div className="flex-1 min-w-0">
                      <div className="flex items-center justify-between">
                        <div className="flex items-center space-x-2">
                          <Badge variant={getActivityBadgeVariant(activity.type)}>
                            {getActivityLabel(activity.type)}
                          </Badge>
                          <span className="text-sm text-gray-500">
                            {format(parseISO(activity.timestamp), 'MMM d, yyyy h:mm a')}
                          </span>
                        </div>
                      </div>
                      <p className="mt-1 text-sm text-gray-700">{activity.description}</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
            
            {/* Expand/Collapse button */}
            {filteredActivities.length > 5 && (
              <div className="pt-4 text-center">
                <Button variant="outline" size="sm" onClick={toggleExpanded}>
                  {expanded ? 'Show less' : `Show ${filteredActivities.length - 5} more`}
                </Button>
              </div>
            )}
          </div>
        )}
      </CardContent>
    </Card>
  );
}