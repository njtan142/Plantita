'use client';

import React from 'react';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog';

interface UserManagementDialogsProps {
  suspendDialogOpen: boolean;
  setSuspendDialogOpen: (open: boolean) => void;
  handleSuspendUser: () => void;
  banDialogOpen: boolean;
  setBanDialogOpen: (open: boolean) => void;
  handleBanUser: () => void;
  resetPasswordDialogOpen: boolean;
  setResetPasswordDialogOpen: (open: boolean) => void;
  handleResetPassword: () => void;
}

export const UserManagementDialogs = ({
  suspendDialogOpen,
  setSuspendDialogOpen,
  handleSuspendUser,
  banDialogOpen,
  setBanDialogOpen,
  handleBanUser,
  resetPasswordDialogOpen,
  setResetPasswordDialogOpen,
  handleResetPassword,
}: UserManagementDialogsProps) => {
  return (
    <>
      {/* Suspend User Dialog */}
      <AlertDialog open={suspendDialogOpen} onOpenChange={setSuspendDialogOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Suspend User</AlertDialogTitle>
            <AlertDialogDescription>
              Are you sure you want to suspend this user? They will be unable to access their account 
              until manually reactivated. This action can be reversed.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={handleSuspendUser}>Suspend User</AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      {/* Ban User Dialog */}
      <AlertDialog open={banDialogOpen} onOpenChange={setBanDialogOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Ban User</AlertDialogTitle>
            <AlertDialogDescription>
              Are you sure you want to ban this user? They will be permanently blocked from accessing 
              their account. This action can be reversed but should only be used for serious violations.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={handleBanUser} className="bg-red-600 hover:bg-red-700">
              Ban User
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      {/* Reset Password Dialog */}
      <AlertDialog open={resetPasswordDialogOpen} onOpenChange={setResetPasswordDialogOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Reset User Password</AlertDialogTitle>
            <AlertDialogDescription>
              Are you sure you want to reset this user&#39;s password? A temporary password will be 
              generated and the user will be required to change it on their next login.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={handleResetPassword}>Reset Password</AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </>
  );
};
