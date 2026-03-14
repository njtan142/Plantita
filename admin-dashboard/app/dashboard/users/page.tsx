'use client';

import { useState, useMemo } from 'react';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { Plus, Download } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { LoadingSpinner } from '@/components/layout/LoadingSpinner';
import { userService } from '@/services/userService';
import { User, UserStatus, UserQueryParams } from '@/types/api';
import { toast } from 'sonner';
import { CreateUserForm } from '@/components/users/CreateUserForm';
import { UserForm } from '@/components/users/UserForm';
import { UserFilters, UserFiltersData } from '@/components/users/management/UserFilters';
import { BulkActions } from '@/components/users/management/BulkActions';
import { UserTable } from '@/components/users/management/UserTable';
import { DeleteUserDialog } from '@/components/users/management/DeleteUserDialog';

export default function UsersPage() {
  const queryClient = useQueryClient();
  const [filters, setFilters] = useState<UserFiltersData>({
    search: '',
    role: '',
    status: '',
    emailVerified: '',
  });
  const [pagination, setPagination] = useState({
    page: 1,
    limit: 10,
  });
  const [sortBy, setSortBy] = useState<string>('createdAt');
  const [sortOrder, setSortOrder] = useState<'asc' | 'desc'>('desc');
  const [selectedUsers, setSelectedUsers] = useState<string[]>([]);
  const [showCreateUserForm, setShowCreateUserForm] = useState(false);
  const [editingUser, setEditingUser] = useState<User | null>(null);
  const [deleteUserDialogOpen, setDeleteUserDialogOpen] = useState(false);
  const [userToDelete, setUserToDelete] = useState<User | null>(null);

  const queryParams: UserQueryParams = {
    page: pagination.page,
    limit: pagination.limit,
    sort: sortBy,
    order: sortOrder,
    search: filters.search || undefined,
    role: filters.role || undefined,
    status: filters.status || undefined,
    emailVerified: filters.emailVerified !== '' ? filters.emailVerified : undefined,
  };

  const { data: usersData, isLoading, isError, error } = useQuery({
    queryKey: ['users', queryParams],
    queryFn: () => userService.getUsers(queryParams),
  });

  const users = usersData?.data || [];

  // Optimistic update for bulk actions
  const mutation = useMutation({
    mutationFn: async (action: 'activate' | 'deactivate' | 'delete') => {
      if (action === 'delete') {
        return userService.bulkDeleteUsers(selectedUsers);
      } else {
        const promises = selectedUsers.map(userId => {
          if (action === 'activate') {
            return userService.activateUser(userId);
          } else {
            return userService.deactivateUser(userId);
          }
        });
        return Promise.all(promises);
      }
    },
    onMutate: async (action: 'activate' | 'deactivate' | 'delete') => {
      await queryClient.cancelQueries({ queryKey: ['users'] });
      const previousUsers = queryClient.getQueryData<{ data: User[] }>(['users', queryParams]);
      const selectedUsersLookupSet = new Set(selectedUsers);

      if (action === 'delete') {
        queryClient.setQueryData<{ data: User[] }>(['users', queryParams], (old) => {
          if (!old) return old;
          return {
            ...old,
            data: old.data.filter((user: User) => !selectedUsersLookupSet.has(user.id))
          };
        });
      } else {
        queryClient.setQueryData<{ data: User[] }>(['users', queryParams], (old) => {
          if (!old) return old;
          return {
            ...old,
            data: old.data.map((user: User) => {
              if (selectedUsersLookupSet.has(user.id)) {
                return {
                  ...user,
                  status: action === 'activate' ? UserStatus.ACTIVE : UserStatus.INACTIVE
                };
              }
              return user;
            })
          };
        });
      }
      return { previousUsers };
    },
    onError: (err, action, context) => {
      queryClient.setQueryData(['users', queryParams], context?.previousUsers);
      toast.error('Bulk action failed');
    },
    onSuccess: () => {
      setSelectedUsers([]);
      toast.success('Bulk action successful');
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] });
    },
  });

  // Optimistic update for deleting a single user
  const deleteUserMutation = useMutation({
    mutationFn: (userId: string) => userService.deleteUser(userId),
    onMutate: async (userId: string) => {
      await queryClient.cancelQueries({ queryKey: ['users'] });
      const previousUsers = queryClient.getQueryData<{ data: User[] }>(['users', queryParams]);

      queryClient.setQueryData<{ data: User[] }>(['users', queryParams], (old) => {
        if (!old) return old;
        return {
          ...old,
          data: old.data.filter((user: User) => user.id !== userId)
        };
      });
      return { previousUsers };
    },
    onError: (err, userId, context) => {
      queryClient.setQueryData(['users', queryParams], context?.previousUsers);
      toast.error('Failed to delete user');
    },
    onSuccess: () => {
      toast.success('User deleted successfully');
      setDeleteUserDialogOpen(false);
      setUserToDelete(null);
    },
  });

  const handleFilterChange = (key: keyof UserFiltersData, value: string | boolean) => {
    setFilters(prev => ({ ...prev, [key]: value }));
    setPagination(prev => ({ ...prev, page: 1 }));
  };

  const handleSort = (column: string) => {
    if (sortBy === column) {
      setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc');
    } else {
      setSortBy(column);
      setSortOrder('asc');
    }
  };

  const handleSelectUser = (userId: string, checked: boolean) => {
    if (checked) {
      setSelectedUsers(prev => [...prev, userId]);
    } else {
      setSelectedUsers(prev => prev.filter(id => id !== userId));
    }
  };

  const handleSelectAll = (checked: boolean) => {
    if (checked) {
      setSelectedUsers(users.map(user => user.id));
    } else {
      setSelectedUsers([]);
    }
  };

  const handleBulkAction = (action: 'activate' | 'deactivate' | 'delete') => {
    if (selectedUsers.length === 0) {
      toast.error('Please select users to perform this action');
      return;
    }
    mutation.mutate(action);
  };

  const handleDeleteUser = (user: User) => {
    setUserToDelete(user);
    setDeleteUserDialogOpen(true);
  };

  const confirmDeleteUser = () => {
    if (userToDelete) {
      deleteUserMutation.mutate(userToDelete.id);
    }
  };

  const handleExport = async () => {
    try {
      const blob = await userService.exportUsers({
        search: filters.search || undefined,
        role: filters.role || undefined,
        status: filters.status || undefined,
      });

      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `users-export-${new Date().toISOString().split('T')[0]}.csv`;
      document.body.appendChild(a);
      a.click();
      window.URL.revokeObjectURL(url);
      document.body.removeChild(a);

      toast.success('Users exported successfully');
    } catch (err) {
      console.error('Error exporting users:', err);
      toast.error('Failed to export users');
    }
  };

  const handleEditUser = (user: User) => {
    setEditingUser(user);
  };

  const selectedUsersLookupSet = useMemo(() => new Set(selectedUsers), [selectedUsers]);

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-96">
        <LoadingSpinner />
      </div>
    );
  }

  if (isError) {
    return (
      <div className="text-center py-12">
        <p className="text-red-600 mb-4">{error instanceof Error ? error.message : 'Failed to fetch users'}</p>
        <Button onClick={() => queryClient.invalidateQueries({ queryKey: ['users'] })}>Retry</Button>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">User Management</h1>
          <p className="text-gray-600">Manage and monitor all platform users</p>
        </div>
        <div className="flex items-center gap-2">
          <Button onClick={handleExport} variant="outline">
            <Download className="h-4 w-4 mr-2" />
            Export
          </Button>
          <Button onClick={() => setShowCreateUserForm(true)}>
            <Plus className="h-4 w-4 mr-2" />
            Add User
          </Button>
        </div>
      </div>

      {showCreateUserForm && (
        <Card>
          <CardContent className="pt-6">
            <CreateUserForm 
              onUserCreated={() => {
                queryClient.invalidateQueries({ queryKey: ['users'] });
                setShowCreateUserForm(false);
              }}
              onCancel={() => setShowCreateUserForm(false)}
            />
          </CardContent>
        </Card>
      )}

      <UserForm
        user={editingUser}
        open={!!editingUser}
        onClose={() => setEditingUser(null)}
        onSuccess={() => {
          queryClient.invalidateQueries({ queryKey: ['users'] });
          setEditingUser(null);
        }}
      />

      <UserFilters 
        filters={filters} 
        onFilterChange={handleFilterChange} 
      />

      <BulkActions 
        selectedCount={selectedUsers.length} 
        isPending={mutation.isPending} 
        onBulkAction={handleBulkAction} 
      />

      <Card>
        <CardContent className="pt-6">
          <UserTable
            users={users}
            isLoading={isLoading}
            selectedUsers={selectedUsersLookupSet}
            onSelectUser={handleSelectUser}
            onSelectAll={handleSelectAll}
            sortBy={sortBy}
            sortOrder={sortOrder}
            onSort={handleSort}
            onEditUser={handleEditUser}
            onDeleteUser={handleDeleteUser}
          />

          {users.length > 0 && (
            <div className="flex items-center justify-between px-2 py-4">
              <div className="flex-1 text-sm text-gray-700">
                Showing {((pagination.page - 1) * pagination.limit) + 1} to{' '}
                {Math.min(pagination.page * pagination.limit, users.length)} of{' '}
                {users.length} results
              </div>
              <div className="flex items-center space-x-2">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setPagination(prev => ({ ...prev, page: prev.page - 1 }))}
                  disabled={pagination.page === 1}
                >
                  Previous
                </Button>
                <div className="flex items-center space-x-1">
                  {Array.from({ length: Math.min(5, Math.ceil(users.length / pagination.limit)) }, (_, i) => {
                    const pageNum = i + 1;
                    return (
                      <Button
                        key={pageNum}
                        variant={pagination.page === pageNum ? "default" : "outline"}
                        size="sm"
                        onClick={() => setPagination(prev => ({ ...prev, page: pageNum }))}
                      >
                        {pageNum}
                      </Button>
                    );
                  })}
                </div>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setPagination(prev => ({ ...prev, page: prev.page + 1 }))}
                  disabled={pagination.page === Math.ceil(users.length / pagination.limit)}
                >
                  Next
                </Button>
              </div>
            </div>
          )}
        </CardContent>
      </Card>
      
      <DeleteUserDialog
        open={deleteUserDialogOpen}
        onOpenChange={setDeleteUserDialogOpen}
        user={userToDelete}
        onConfirm={confirmDeleteUser}
        isPending={deleteUserMutation.isPending}
      />
    </div>
  );
}
