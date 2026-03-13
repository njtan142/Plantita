'use client';

import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { 
  Select, 
  SelectContent, 
  SelectItem, 
  SelectTrigger, 
  SelectValue 
} from '@/components/ui/select';

interface AnnouncementFormProps {
  title: string;
  setTitle: (title: string) => void;
  content: string;
  setContent: (content: string) => void;
  startDate: string;
  setStartDate: (startDate: string) => void;
  endDate: string;
  setEndDate: (endDate: string) => void;
  priority: 'low' | 'medium' | 'high';
  setPriority: (priority: 'low' | 'medium' | 'high') => void;
  targetUsers: 'all' | 'active' | 'specific';
  setTargetUsers: (targetUsers: 'all' | 'active' | 'specific') => void;
  idPrefix?: string;
}

export function AnnouncementForm({
  title,
  setTitle,
  content,
  setContent,
  startDate,
  setStartDate,
  endDate,
  setEndDate,
  priority,
  setPriority,
  targetUsers,
  setTargetUsers,
  idPrefix = 'announcement'
}: AnnouncementFormProps) {
  return (
    <div className="space-y-4">
      <div className="space-y-2">
        <Label htmlFor={`${idPrefix}-title`}>Title</Label>
        <Input
          id={`${idPrefix}-title`}
          placeholder="Enter announcement title"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
        />
      </div>
      
      <div className="space-y-2">
        <Label htmlFor={`${idPrefix}-content`}>Content</Label>
        <Textarea
          id={`${idPrefix}-content`}
          placeholder="Enter announcement content"
          value={content}
          onChange={(e) => setContent(e.target.value)}
          rows={4}
        />
      </div>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div className="space-y-2">
          <Label htmlFor={`${idPrefix}-start-date`}>Start Date</Label>
          <Input
            id={`${idPrefix}-start-date`}
            type="datetime-local"
            value={startDate}
            onChange={(e) => setStartDate(e.target.value)}
          />
        </div>
        
        <div className="space-y-2">
          <Label htmlFor={`${idPrefix}-end-date`}>End Date</Label>
          <Input
            id={`${idPrefix}-end-date`}
            type="datetime-local"
            value={endDate}
            onChange={(e) => setEndDate(e.target.value)}
          />
        </div>
      </div>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div className="space-y-2">
          <Label htmlFor={`${idPrefix}-priority`}>Priority</Label>
          <Select value={priority} onValueChange={(value) => setPriority(value as 'low' | 'medium' | 'high')}>
            <SelectTrigger id={`${idPrefix}-priority`}>
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="low">Low</SelectItem>
              <SelectItem value="medium">Medium</SelectItem>
              <SelectItem value="high">High</SelectItem>
            </SelectContent>
          </Select>
        </div>

        <div className="space-y-2">
          <Label htmlFor={`${idPrefix}-target-users`}>Target Users</Label>
          <Select value={targetUsers} onValueChange={(value) => setTargetUsers(value as 'all' | 'active' | 'specific')}>
            <SelectTrigger id={`${idPrefix}-target-users`}>
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Users</SelectItem>
              <SelectItem value="active">Active Users Only</SelectItem>
              <SelectItem value="specific">Specific Users</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </div>
    </div>
  );
}
