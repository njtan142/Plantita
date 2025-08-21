'use client';

import { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Checkbox } from '@/components/ui/checkbox';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog';
import { Label } from '@/components/ui/label';
import { LoadingSpinner } from '@/components/layout/LoadingSpinner';
import { userService } from '@/services/userService';
import { User, UserRole, CreateUserData, UpdateUserData } from '@/types/api';
import { toast } from 'sonner';

interface UserFormData {
  email: string;
  username: string;
  password: string;
  firstName: string;
  lastName: string;
  role: UserRole;
  emailVerified: boolean;
}

interface UserFormProps {
  user?: User | null;
  open: boolean;
  onClose: () => void;
  onSuccess: () => void;
}

export function UserForm({ user, open, onClose, onSuccess }: UserFormProps) {
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState<UserFormData>({
    email: '',
    username: '',
    password: '',
    firstName: '',
    lastName: '',
    role: UserRole.USER,
    emailVerified: false,
  });

  const isEditing = !!user;

  // Reset form when user changes or dialog opens/closes
  useEffect(() => {
    if (open) {
      if (user) {
        setFormData({
          email: user.email,
          username: user.username,
          password: '', // Don't populate password for security
          firstName: user.firstName || '',
          lastName: user.lastName || '',
          role: user.role,
          emailVerified: user.emailVerified,
        });
      } else {
        setFormData({
          email: '',
          username: '',
          password: '',
          firstName: '',
          lastName: '',
          role: UserRole.USER,
          emailVerified: false,
        });
      }
    }
  }, [user, open]);

  const handleInputChange = (field: keyof UserFormData, value: string | boolean) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  const onSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    try {
      setLoading(true);

      if (isEditing && user) {
        const updateData: UpdateUserData = {
          email: formData.email,
          username: formData.username,
          firstName: formData.firstName || undefined,
          lastName: formData.lastName || undefined,
          role: formData.role,
        };

        const response = await userService.updateUser(user.id, updateData);

        if (response.success) {
          toast.success('User updated successfully');
          onSuccess();
          onClose();
        } else {
          toast.error(response.message || 'Failed to update user');
        }
      } else {
        const createData: CreateUserData = {
          email: formData.email,
          username: formData.username,
          password: formData.password,
          firstName: formData.firstName || undefined,
          lastName: formData.lastName || undefined,
          role: formData.role,
        };

        const response = await userService.createUser(createData);

        if (response.success) {
          toast.success('User created successfully');
          onSuccess();
          onClose();
        } else {
          toast.error(response.message || 'Failed to create user');
        }
      }
    } catch (err) {
      console.error('Error saving user:', err);
      toast.error(isEditing ? 'Failed to update user' : 'Failed to create user');
    } finally {
      setLoading(false);
    }
  };

  const handleClose = () => {
    setFormData({
      email: '',
      username: '',
      password: '',
      firstName: '',
      lastName: '',
      role: UserRole.USER,
      emailVerified: false,
    });
    onClose();
  };

  return (
    <Dialog open={open} onOpenChange={handleClose}>
      <DialogContent className="sm:max-w-[500px]">
        <DialogHeader>
          <DialogTitle>
            {isEditing ? 'Edit User' : 'Create New User'}
          </DialogTitle>
        </DialogHeader>

        <form onSubmit={onSubmit} className="space-y-4">
          <div>
            <Label htmlFor="email">Email</Label>
            <Input
              id="email"
              type="email"
              placeholder="Enter email address"
              value={formData.email}
              onChange={(e) => handleInputChange('email', e.target.value)}
              required
            />
          </div>

          <div>
            <Label htmlFor="username">Username</Label>
            <Input
              id="username"
              placeholder="Enter username"
              value={formData.username}
              onChange={(e) => handleInputChange('username', e.target.value)}
              required
            />
          </div>

          {!isEditing && (
            <div>
              <Label htmlFor="password">Password</Label>
              <Input
                id="password"
                type="password"
                placeholder="Enter password"
                value={formData.password}
                onChange={(e) => handleInputChange('password', e.target.value)}
                required
              />
            </div>
          )}

          <div className="grid grid-cols-2 gap-4">
            <div>
              <Label htmlFor="firstName">First Name</Label>
              <Input
                id="firstName"
                placeholder="First name"
                value={formData.firstName}
                onChange={(e) => handleInputChange('firstName', e.target.value)}
              />
            </div>

            <div>
              <Label htmlFor="lastName">Last Name</Label>
              <Input
                id="lastName"
                placeholder="Last name"
                value={formData.lastName}
                onChange={(e) => handleInputChange('lastName', e.target.value)}
              />
            </div>
          </div>

          <div>
            <Label htmlFor="role">Role</Label>
            <Select
              value={formData.role}
              onValueChange={(value) => handleInputChange('role', value as UserRole)}
            >
              <SelectTrigger>
                <SelectValue placeholder="Select a role" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value={UserRole.USER}>User</SelectItem>
                <SelectItem value={UserRole.MODERATOR}>Moderator</SelectItem>
                <SelectItem value={UserRole.ADMIN}>Admin</SelectItem>
              </SelectContent>
            </Select>
          </div>

          <div className="flex items-center space-x-2">
            <Checkbox
              id="emailVerified"
              checked={formData.emailVerified}
              onCheckedChange={(checked) => handleInputChange('emailVerified', checked as boolean)}
            />
            <Label htmlFor="emailVerified">Email Verified</Label>
          </div>

          <DialogFooter>
            <Button
              type="button"
              variant="outline"
              onClick={handleClose}
              disabled={loading}
            >
              Cancel
            </Button>
            <Button type="submit" disabled={loading}>
              {loading && <LoadingSpinner className="mr-2 h-4 w-4" />}
              {isEditing ? 'Update User' : 'Create User'}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
}