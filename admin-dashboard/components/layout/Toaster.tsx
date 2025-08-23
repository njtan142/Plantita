'use client';

import { Toaster as SonnerToaster } from 'sonner';

export function Toaster() {
  return (
    <SonnerToaster
      position="top-right"
      toastOptions={{
        duration: 5000,
        classNames: {
          toast: 'bg-white border border-gray-200 shadow-lg',
          title: 'font-medium text-gray-900',
          description: 'text-gray-500',
          actionButton: 'bg-gray-900 text-white',
          cancelButton: 'bg-gray-100 text-gray-900',
          success: 'bg-green-50 border-green-200',
          error: 'bg-red-50 border-red-200',
          warning: 'bg-yellow-50 border-yellow-200',
          info: 'bg-blue-50 border-blue-200',
        },
      }}
    />
  );
}