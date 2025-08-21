import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import {
  Users,
  Image,
  FileText,
  Settings,
  Plus,
  RefreshCw,
  Download,
  Upload
} from 'lucide-react';

interface QuickActionsProps {
  onRefresh: () => void;
  loading?: boolean;
}

export function QuickActions({ onRefresh, loading = false }: QuickActionsProps) {
  const actions = [
    {
      title: 'Add User',
      description: 'Create a new user account',
      icon: Users,
      variant: 'default' as const,
      href: '/dashboard/users/new'
    },
    {
      title: 'Upload Media',
      description: 'Add new media files',
      icon: Upload,
      variant: 'default' as const,
      href: '/dashboard/media/upload'
    },
    {
      title: 'Generate Report',
      description: 'Export system reports',
      icon: FileText,
      variant: 'outline' as const,
      href: '/dashboard/reports'
    },
    {
      title: 'System Settings',
      description: 'Configure system preferences',
      icon: Settings,
      variant: 'outline' as const,
      href: '/dashboard/settings'
    }
  ];

  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between">
        <CardTitle>Quick Actions</CardTitle>
        <Button
          variant="outline"
          size="sm"
          onClick={onRefresh}
          disabled={loading}
        >
          <RefreshCw className={`h-4 w-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
          Refresh
        </Button>
      </CardHeader>
      <CardContent>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {actions.map((action) => {
            const Icon = action.icon;
            return (
              <Button
                key={action.title}
                variant={action.variant}
                className="h-auto p-4 justify-start"
                asChild
              >
                <a href={action.href} className="flex flex-col items-start space-y-2">
                  <div className="flex items-center space-x-2">
                    <Icon className="h-5 w-5" />
                    <span className="font-medium">{action.title}</span>
                  </div>
                  <p className="text-sm text-muted-foreground text-left">
                    {action.description}
                  </p>
                </a>
              </Button>
            );
          })}
        </div>

        <div className="mt-6 p-4 bg-muted rounded-lg">
          <div className="flex items-center justify-between">
            <div>
              <h4 className="font-medium">System Status</h4>
              <p className="text-sm text-muted-foreground">All systems operational</p>
            </div>
            <Badge variant="default" className="bg-green-100 text-green-800">
              Healthy
            </Badge>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}