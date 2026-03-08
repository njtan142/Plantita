'use client';

import withAuth from '@/components/auth/with-auth';
import { usePlatformSettings } from '@/hooks/useSettings';
import { LoadingSpinner } from '@/components/layout/LoadingSpinner';
import { ErrorAlert } from '@/components/layout/ErrorAlert';
import { SettingsForm } from '@/components/settings';

function SettingsPage() {
  // Fetch platform settings using custom hook
  const { 
    data: settingsData, 
    isLoading, 
    isError, 
    error,
    refetch 
  } = usePlatformSettings();

  const handleRefresh = () => {
    refetch();
  };

  const handleSave = () => {
    // Refetch the data after saving to ensure we have the latest
    refetch();
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-96">
        <LoadingSpinner />
      </div>
    );
  }

  if (isError) {
    return (
      <div className="py-12">
        <ErrorAlert 
          title="Failed to load platform settings" 
          message={error?.message || 'An error occurred while loading platform settings. Please try again.'}
        />
        <div className="text-center mt-4">
          <button
            onClick={handleRefresh}
            className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
          >
            Retry
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Page Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Settings</h1>
        <p className="text-gray-600">Manage platform configuration and settings.</p>
      </div>

      {/* Settings Form */}
      <SettingsForm 
        initialData={settingsData} 
        onSave={handleSave}
      />
    </div>
  );
}

export default withAuth(SettingsPage);