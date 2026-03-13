'use client';

import { 
  Table, 
  TableBody, 
  TableCell, 
  TableHead, 
  TableHeader, 
  TableRow 
} from '@/components/ui/table';
import { Checkbox } from '@/components/ui/checkbox';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { Badge } from '@/components/ui/badge';
import { 
  DropdownMenu, 
  DropdownMenuContent, 
  DropdownMenuItem, 
  DropdownMenuTrigger 
} from '@/components/ui/dropdown-menu';
import { Button } from '@/components/ui/button';
import { MoreHorizontal } from 'lucide-react';
import { LoadingSpinner } from '@/components/layout/LoadingSpinner';
import { User, UserRole, UserStatus } from '@/types/api';

interface UserTableProps {
  users: User[];
  isLoading: boolean;
  selectedUsers: Set<string>;
  onSelectUser: (userId: string, checked: boolean) => void;
  onSelectAll: (checked: boolean) => void;
  sortBy: string;
  sortOrder: 'asc' | 'desc';
  onSort: (column: string) => void;
  onEditUser: (user: User) => void;
  onDeleteUser: (user: User) => void;
}

export function UserTable({
  users,
  isLoading,
  selectedUsers,
  onSelectUser,
  onSelectAll,
  sortBy,
  sortOrder,
  onSort,
  onEditUser,
  onDeleteUser
}: UserTableProps) {
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

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
    });
  };

  const getUserDisplayName = (user: User) => {
    if (user.firstName && user.lastName) {
      return `${user.firstName} ${user.lastName}`;
    }
    return user.username;
  };

  return (
    <div className="rounded-md border">
      <Table>
        <TableHeader>
          <TableRow>
            <TableHead className="w-12">
              <Checkbox
                checked={selectedUsers.size === users.length && users.length > 0}
                onCheckedChange={(checked) => onSelectAll(checked as boolean)}
              />
            </TableHead>
            <TableHead
              className="cursor-pointer hover:bg-gray-50"
              onClick={() => onSort('username')}
            >
              User {sortBy === 'username' && (sortOrder === 'asc' ? '↑' : '↓')}
            </TableHead>
            <TableHead>Email</TableHead>
            <TableHead
              className="cursor-pointer hover:bg-gray-50"
              onClick={() => onSort('createdAt')}
            >
              Registration Date {sortBy === 'createdAt' && (sortOrder === 'asc' ? '↑' : '↓')}
            </TableHead>
            <TableHead
              className="cursor-pointer hover:bg-gray-50"
              onClick={() => onSort('lastLoginAt')}
            >
              Last Active {sortBy === 'lastLoginAt' && (sortOrder === 'asc' ? '↑' : '↓')}
            </TableHead>
            <TableHead>Status</TableHead>
            <TableHead>Role</TableHead>
            <TableHead className="w-12">Actions</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {isLoading ? (
            <TableRow>
              <TableCell colSpan={8} className="text-center py-8">
                <LoadingSpinner />
              </TableCell>
            </TableRow>
          ) : users.length === 0 ? (
            <TableRow>
              <TableCell colSpan={8} className="text-center py-8 text-gray-500">
                No users found
              </TableCell>
            </TableRow>
          ) : (
            users.map((user) => (
              <TableRow key={user.id}>
                <TableCell>
                  <Checkbox
                    checked={selectedUsers.has(user.id)}
                    onCheckedChange={(checked) => onSelectUser(user.id, checked as boolean)}
                  />
                </TableCell>
                <TableCell>
                  <div className="flex items-center gap-3">
                    <Avatar className="h-8 w-8">
                      <AvatarImage src={user.avatar} alt={getUserDisplayName(user)} />
                      <AvatarFallback>
                        {user.firstName?.[0] || user.username[0].toUpperCase()}
                      </AvatarFallback>
                    </Avatar>
                    <div>
                      <div className="font-medium">{getUserDisplayName(user)}</div>
                      <div className="text-sm text-gray-500">@{user.username}</div>
                    </div>
                  </div>
                </TableCell>
                <TableCell>
                  <div className="flex items-center gap-2">
                    {user.email}
                    {user.emailVerified && (
                      <Badge variant="outline" className="text-xs">
                        ✓
                      </Badge>
                    )}
                  </div>
                </TableCell>
                <TableCell>{formatDate(user.createdAt)}</TableCell>
                <TableCell>
                  {user.lastLoginAt ? formatDate(user.lastLoginAt) : 'Never'}
                </TableCell>
                <TableCell>
                  <Badge variant={getStatusBadgeVariant(user.status)}>
                    {user.status}
                  </Badge>
                </TableCell>
                <TableCell>
                  <Badge variant={getRoleBadgeVariant(user.role)}>
                    {user.role}
                  </Badge>
                </TableCell>
                <TableCell>
                  <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                      <Button variant="ghost" className="h-8 w-8 p-0">
                        <MoreHorizontal className="h-4 w-4" />
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end">
                      <DropdownMenuItem>View Details</DropdownMenuItem>
                      <DropdownMenuItem onClick={() => onEditUser(user)}>Edit User</DropdownMenuItem>
                      <DropdownMenuItem>Reset Password</DropdownMenuItem>
                      {user.status === UserStatus.ACTIVE ? (
                        <DropdownMenuItem>Suspend User</DropdownMenuItem>
                      ) : (
                        <DropdownMenuItem>Activate User</DropdownMenuItem>
                      )}
                      <DropdownMenuItem className="text-red-600" onClick={() => onDeleteUser(user)}>
                        Delete User
                      </DropdownMenuItem>
                    </DropdownMenuContent>
                  </DropdownMenu>
                </TableCell>
              </TableRow>
            ))
          )}
        </TableBody>
      </Table>
    </div>
  );
}
