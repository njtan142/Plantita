'use client';

import { useState } from 'react';
import { usePathname } from 'next/navigation';
import { Sidebar } from './Sidebar';
import { Header } from './Header';
import { Breadcrumb } from './Breadcrumb';
import { Toaster } from './Toaster';

interface ClientLayoutProps {
  children: React.ReactNode;
}

export function ClientLayout({ children }: ClientLayoutProps) {
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const pathname = usePathname();
  const isLoginPage = pathname === '/login';

  // If on login page, render only the children without sidebar, header, and breadcrumb
  if (isLoginPage) {
    return (
      <div className="min-h-screen bg-gray-50">
        {children}
        <Toaster />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Mobile sidebar overlay */}
      {sidebarOpen && (
        <div
          className="fixed inset-0 z-40 lg:hidden"
          onClick={() => setSidebarOpen(false)}
        >
          <div className="absolute inset-0 bg-gray-600 opacity-75"></div>
        </div>
      )}

      {/* Sidebar - fixed on all screens */}
      <div className={`
        fixed inset-y-0 left-0 z-50 w-64 bg-white shadow-lg transform transition-transform duration-300 ease-in-out
        ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'}
        lg:translate-x-0
      `}>
        <Sidebar onClose={() => setSidebarOpen(false)} />
      </div>

      {/* Main content wrapper - scrolls independently */}
      <div className="lg:pl-64">
        <div className="flex flex-col min-h-screen">
          {/* Header */}
          <Header onMenuClick={() => setSidebarOpen(true)} />

          {/* Breadcrumb */}
          <div className="px-4 sm:px-6 lg:px-8 py-4 bg-white border-b">
            <Breadcrumb />
          </div>

          {/* Page content - this is the scrollable area */}
          <main className="flex-1 overflow-auto px-4 sm:px-6 lg:px-8 py-8">
            {children}
          </main>
        </div>
      </div>
      <Toaster />
    </div>
  );
}