'use client';

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { 
  Select, 
  SelectContent, 
  SelectItem, 
  SelectTrigger, 
  SelectValue 
} from '@/components/ui/select';
import { UserRole, UserStatus } from '@/types/api';

export interface UserFiltersData {
  search: string;
  role: UserRole | '';
  status: UserStatus | '';
  emailVerified: boolean | '';
}

interface UserFiltersProps {
  filters: UserFiltersData;
  onFilterChange: (key: keyof UserFiltersData, value: string | boolean) => void;
}

export function UserFilters({ filters, onFilterChange }: UserFiltersProps) {
  return (
    <Card>
      <CardHeader>
        <CardTitle>Filters</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div>
            <Input
              placeholder="Search users..."
              value={filters.search}
              onChange={(e) => onFilterChange('search', e.target.value)}
            />
          </div>
          <div>
            <Select
              value={filters.role}
              onValueChange={(value) => onFilterChange('role', value as UserRole | '')}
            >
              <SelectTrigger>
                <SelectValue placeholder="Filter by role" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all-roles">All Roles</SelectItem>
                <SelectItem value={UserRole.ADMIN}>Admin</SelectItem>
                <SelectItem value={UserRole.MODERATOR}>Moderator</SelectItem>
                <SelectItem value={UserRole.USER}>User</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div>
            <Select
              value={filters.status}
              onValueChange={(value) => onFilterChange('status', value as UserStatus | '')}
            >
              <SelectTrigger>
                <SelectValue placeholder="Filter by status" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all-status">All Status</SelectItem>
                <SelectItem value={UserStatus.ACTIVE}>Active</SelectItem>
                <SelectItem value={UserStatus.INACTIVE}>Inactive</SelectItem>
                <SelectItem value={UserStatus.SUSPENDED}>Suspended</SelectItem>
                <SelectItem value={UserStatus.BANNED}>Banned</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div>
            <Select
              value={filters.emailVerified === '' ? 'all' : filters.emailVerified.toString()}
              onValueChange={(value) => onFilterChange('emailVerified', value === 'all' ? '' : value === 'true')}
            >
              <SelectTrigger>
                <SelectValue placeholder="Email verification" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All</SelectItem>
                <SelectItem value="true">Verified</SelectItem>
                <SelectItem value="false">Unverified</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
