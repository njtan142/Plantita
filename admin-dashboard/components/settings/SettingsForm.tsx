'use client';

import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import * as z from 'zod';
import { usePlatformSettings, useUpdateSettings } from '@/hooks/useSettings';
import { Button } from '@/components/ui/button';
import { toast } from 'sonner';
import { SettingItem } from '@/components/settings';
import { SettingsSection } from '@/components/settings';
import { PlatformSettings } from '@/types/api';

// Define the form schema for validation
const settingsFormSchema = z.object({
  siteName: z.string().min(1, 'Site name is required'),
  siteDescription: z.string(),
  contactEmail: z.string().email('Invalid email address'),
  maxFileSize: z.number().min(1, 'Max file size must be greater than 0'),
  allowedFileTypes: z.array(z.string()),
  userRegistration: z.boolean(),
  emailVerification: z.boolean(),
  maxLoginAttempts: z.number().min(1, 'Max login attempts must be at least 1').max(20, 'Max login attempts cannot exceed 20'),
});

type SettingsFormValues = z.infer<typeof settingsFormSchema>;

interface SettingsFormProps {
  initialData?: PlatformSettings;
  onSave?: (data: PlatformSettings) => void;
  onCancel?: () => void;
}

export function SettingsForm({
  initialData,
  onSave,
  onCancel
}: SettingsFormProps) {
  const { data: settingsData, isLoading: isSettingsLoading } = usePlatformSettings();
  const { mutate: updateSettings, isPending: isUpdating } = useUpdateSettings();
  
  const [isDirty, setIsDirty] = useState(false);
  
  const form = useForm<SettingsFormValues>({
    resolver: zodResolver(settingsFormSchema),
    defaultValues: {
      siteName: initialData?.siteName || settingsData?.siteName || '',
      siteDescription: initialData?.siteDescription || settingsData?.siteDescription || '',
      contactEmail: initialData?.contactEmail || settingsData?.contactEmail || '',
      maxFileSize: initialData?.maxFileSize || settingsData?.maxFileSize || 10485760,
      allowedFileTypes: initialData?.allowedFileTypes || settingsData?.allowedFileTypes || [],
      userRegistration: initialData?.userRegistration ?? settingsData?.userRegistration ?? true,
      emailVerification: initialData?.emailVerification ?? settingsData?.emailVerification ?? true,
      maxLoginAttempts: initialData?.maxLoginAttempts || settingsData?.maxLoginAttempts || 5,
    },
    mode: 'onChange',
  });

  // Watch for form changes to enable/disable save button
  const watchAllFields = form.watch();
  const hasChanges = form.formState.isDirty;

  const onSubmit = (data: SettingsFormValues) => {
    updateSettings(data, {
      onSuccess: (updatedData) => {
        toast.success('Settings updated successfully');
        form.reset(data);
        onSave?.(updatedData);
      },
      onError: (error) => {
        toast.error(`Failed to update settings: ${error.message}`);
      },
    });
  };

  const handleCancel = () => {
    form.reset();
    onCancel?.();
  };

  const handleFieldChange = (fieldName: keyof SettingsFormValues, value: string | number | boolean | string[]) => {
    form.setValue(fieldName, value, { shouldDirty: true });
    setIsDirty(true);
  };

  // If we're loading initial data, show a loading state
  if (isSettingsLoading && !initialData) {
    return (
      <div className="space-y-6">
        <SettingsSection title="General Settings" description="Manage basic platform configuration">
          <div className="space-y-4">
            {[...Array(3)].map((_, i) => (
              <div key={i} className="h-16 bg-gray-100 rounded animate-pulse" />
            ))}
          </div>
        </SettingsSection>
      </div>
    );
  }

  return (
    <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
      <SettingsSection 
        title="General Settings" 
        description="Manage basic platform configuration"
      >
        <SettingItem
          id="siteName"
          label="Site Name"
          description="The name of your platform"
          type="text"
          value={form.watch('siteName')}
          onChange={(value) => handleFieldChange('siteName', value)}
          placeholder="Enter site name"
          disabled={isUpdating}
        />
        
        <SettingItem
          id="siteDescription"
          label="Site Description"
          description="A brief description of your platform"
          type="textarea"
          value={form.watch('siteDescription')}
          onChange={(value) => handleFieldChange('siteDescription', value)}
          placeholder="Enter site description"
          disabled={isUpdating}
        />
        
        <SettingItem
          id="contactEmail"
          label="Contact Email"
          description="Email address for platform inquiries"
          type="email"
          value={form.watch('contactEmail')}
          onChange={(value) => handleFieldChange('contactEmail', value)}
          placeholder="Enter contact email"
          disabled={isUpdating}
        />
      </SettingsSection>

      <SettingsSection 
        title="File Upload Settings" 
        description="Configure file upload restrictions"
      >
        <SettingItem
          id="maxFileSize"
          label="Max File Size (bytes)"
          description="Maximum file size allowed for uploads"
          type="number"
          value={form.watch('maxFileSize')}
          onChange={(value) => handleFieldChange('maxFileSize', Number(value))}
          placeholder="Enter max file size"
          disabled={isUpdating}
        />
        
        <SettingItem
          id="allowedFileTypes"
          label="Allowed File Types"
          description="Comma-separated list of allowed file types"
          type="text"
          value={form.watch('allowedFileTypes').join(', ')}
          onChange={(value) => handleFieldChange('allowedFileTypes', (value as string).split(',').map(type => type.trim()))}
          placeholder="e.g., image/jpeg, image/png, video/mp4"
          disabled={isUpdating}
        />
      </SettingsSection>

      <SettingsSection 
        title="User Management" 
        description="Configure user registration and authentication settings"
      >
        <SettingItem
          id="userRegistration"
          label="User Registration"
          description="Allow new users to register accounts"
          type="checkbox"
          value={form.watch('userRegistration')}
          onChange={(value) => handleFieldChange('userRegistration', value)}
          disabled={isUpdating}
        />
        
        <SettingItem
          id="emailVerification"
          label="Email Verification"
          description="Require email verification for new accounts"
          type="checkbox"
          value={form.watch('emailVerification')}
          onChange={(value) => handleFieldChange('emailVerification', value)}
          disabled={isUpdating}
        />
        
        <SettingItem
          id="maxLoginAttempts"
          label="Max Login Attempts"
          description="Maximum number of failed login attempts before account lockout"
          type="number"
          value={form.watch('maxLoginAttempts')}
          onChange={(value) => handleFieldChange('maxLoginAttempts', Number(value))}
          placeholder="Enter max login attempts"
          disabled={isUpdating}
        />
      </SettingsSection>

      <div className="flex justify-end gap-3 pt-4">
        <Button
          type="button"
          variant="outline"
          onClick={handleCancel}
          disabled={isUpdating}
        >
          Cancel
        </Button>
        <Button
          type="submit"
          disabled={!hasChanges || isUpdating}
        >
          {isUpdating ? 'Saving...' : 'Save Changes'}
        </Button>
      </div>
    </form>
  );
}