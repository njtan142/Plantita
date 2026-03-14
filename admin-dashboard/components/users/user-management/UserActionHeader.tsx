'use client';

import React from 'react';
import { Button } from '@/components/ui/button';
import { ArrowLeft, MoreHorizontal, ShieldAlert, Lock, Key } from 'lucide-react';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';

interface UserActionHeaderProps {
  onBack: () => void;
  onSuspend: () => void;
  onBan: () => void;
  onResetPassword: () => void;
}

export const UserActionHeader = ({
  onBack,
  onSuspend,
  onBan,
  onResetPassword,
}: UserActionHeaderProps) => {
  return (
    <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <div className="flex items-center space-x-4">
        <Button variant="outline" onClick={onBack}>
          <ArrowLeft className="h-4 w-4" />
        </Button>
        <h1 className="text-2xl font-bold">User Content Management</h1>
      </div>
      
      <div className="flex items-center space-x-2">
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="outline">
              <MoreHorizontal className="h-4 w-4 mr-2" />
              Actions
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            <DropdownMenuItem onClick={onSuspend}>
              <ShieldAlert className="h-4 w-4 mr-2" />
              Suspend User
            </DropdownMenuItem>
            <DropdownMenuItem onClick={onBan}>
              <Lock className="h-4 w-4 mr-2" />
              Ban User
            </DropdownMenuItem>
            <DropdownMenuItem onClick={onResetPassword}>
              <Key className="h-4 w-4 mr-2" />
              Reset Password
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </div>
  );
};
