# Admin Dashboard Analytics and Settings Enhancement Design

## 1. Overview

This document outlines the design for implementing the missing Analytics and Settings pages in the Plantita Admin Dashboard. These pages will provide administrators with insights into platform performance and tools to configure system-wide settings. The design follows the existing patterns and architecture of the dashboard to ensure consistency and maintainability.

## 2. Architecture

The implementation will follow the existing Next.js App Router structure with:
- Page components in `/app/dashboard/analytics/page.tsx` and `/app/dashboard/settings/page.tsx`
- Service layer functions for API communication
- TanStack Query for server state management
- Reusable UI components from the existing component library
- TypeScript for type safety

## 3. Components and Interfaces

### 3.1. Analytics Page Components

- `AnalyticsPage`: Main page component
- `AnalyticsChart`: Reusable chart component for displaying metrics
- `MetricCard`: Component for displaying key metrics
- `DateRangeSelector`: Component for selecting date ranges for analytics

### 3.2. Settings Page Components

- `SettingsPage`: Main page component
- `SettingsSection`: Component for organizing settings into sections
- `SettingItem`: Component for individual settings with label, control, and description
- `SettingsForm`: Form component for managing settings updates

## 4. Data Models

### 4.1. Analytics Data Models

```typescript
interface AnalyticsData {
  userGrowth: {
    date: string;
    count: number;
  }[];
  mediaUploads: {
    date: string;
    count: number;
  }[];
  engagementMetrics: {
    date: string;
    likes: number;
    comments: number;
    shares: number;
  }[];
  platformMetrics: {
    totalUsers: number;
    activeUsers: number;
    totalMedia: number;
    storageUsed: number;
  };
}

interface AnalyticsQueryParams {
  startDate?: string;
  endDate?: string;
  interval?: 'day' | 'week' | 'month';
}
```

### 4.2. Settings Data Models

```typescript
interface PlatformSettings {
  siteName: string;
  siteDescription: string;
  contactEmail: string;
  maxFileSize: number;
  allowedFileTypes: string[];
  userRegistration: boolean;
  emailVerification: boolean;
  maxLoginAttempts: number;
}

interface SettingsUpdatePayload {
  [key: string]: any;
}
```

## 5. Error Handling

- Both pages will implement loading states using the existing `LoadingSpinner` component
- Error handling will be implemented using TanStack Query's error handling capabilities
- User-friendly error messages will be displayed using the existing `ErrorAlert` component
- Failed API requests will provide retry functionality

## 6. Testing Strategy

- Unit tests for service layer functions
- Component tests for UI components using Jest and React Testing Library
- Integration tests for page components
- Manual testing of user flows:
  - Navigating to Analytics page
  - Viewing analytics charts and metrics
  - Navigating to Settings page
  - Viewing current settings
  - Updating settings