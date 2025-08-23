# Admin Dashboard Analytics and Settings Implementation Plan

Convert the feature design into a series of prompts for a code-generation LLM that will implement each step in a test-driven manner. Prioritize best practices, incremental progress, and early testing, ensuring no big jumps in complexity at any stage. Make sure that each prompt builds on the previous prompts, and ends with wiring things together. There should be no hanging or orphaned code that isn't integrated into a previous step. Focus ONLY on tasks that involve writing, modifying, or testing code.

## 1. Analytics Page Implementation

- [x] 1.1. Create the analytics service and mock data
  - *Requirements: 2.1.3*
  - Create `src/services/analyticsService.ts` file
  - Implement mock data structure based on the AnalyticsData interface
  - Create functions to fetch analytics data with simulated API delay
  - Export functions that will be used by TanStack Query hooks

- [x] 1.2. Create the analytics page component
  - *Requirements: 2.1.1, 2.1.6*
  - Create `/app/dashboard/analytics/page.tsx` with basic page structure
  - Implement withAuth HOC for authentication protection
  - Add page header with title "Analytics" and description
  - Import and set up TanStack Query provider if needed
  - Implement basic loading state using existing `LoadingSpinner` component

- [x] 1.3. Implement analytics data fetching with TanStack Query
  - *Requirements: 2.1.3, 2.1.4, 2.1.5*
  - Create custom hooks in `src/hooks/useAnalytics.ts`
  - Implement useAnalyticsData hook using TanStack Query
  - Add error handling with retry functionality
  - Connect hooks to the analytics service functions
  - Display appropriate error messages using existing `ErrorAlert` component

- [x] 1.4. Create MetricCard component
  - *Requirements: 2.1.2*
  - Create `src/components/analytics/MetricCard.tsx`
  - Implement component that displays a single metric with title, value, and trend
  - Add proper TypeScript interfaces for props
  - Style according to existing dashboard design patterns
  - Write component tests

- [x] 1.5. Create DateRangeSelector component
  - *Requirements: 2.1.2*
  - Create `src/components/analytics/DateRangeSelector.tsx`
  - Implement dropdown or calendar-based date range selector
  - Add proper TypeScript interfaces for props
  - Ensure it follows existing UI component patterns
  - Write component tests

- [x] 1.6. Create AnalyticsChart component
  - *Requirements: 2.1.2*
  - Create `src/components/analytics/AnalyticsChart.tsx`
  - Implement chart using existing charting library (check what's already used in project)
  - Support different chart types (line, bar) for different data
  - Add proper TypeScript interfaces for props
  - Write component tests

- [x] 1.7. Integrate components into analytics page
  - *Requirements: 2.1.2, 2.1.6*
  - Connect all analytics components to the analytics page
  - Implement responsive grid layout for metric cards
  - Wire up DateRangeSelector to filter analytics data
  - Ensure all components display data from TanStack Query hooks
  - Test responsive behavior on different screen sizes

## 2. Settings Page Implementation

- [x] 2.1. Create the settings service and mock data
  - *Requirements: 2.2.3*
  - Create `src/services/settingsService.ts` file
  - Implement mock platform settings data structure
  - Create functions to fetch and update settings with simulated API delay
  - Export functions that will be used by TanStack Query hooks

- [x] 2.2. Create the settings page component
  - *Requirements: 2.2.1, 2.2.7*
  - Create `/app/dashboard/settings/page.tsx` with basic page structure
  - Implement withAuth HOC for authentication protection
  - Add page header with title "Settings" and description
  - Import and set up TanStack Query provider if needed
  - Implement basic loading state using existing `LoadingSpinner` component

- [x] 2.3. Implement settings data fetching and updating with TanStack Query
  - *Requirements: 2.2.3, 2.2.4, 2.2.5*
  - Create custom hooks in `src/hooks/useSettings.ts`
  - Implement usePlatformSettings hook for fetching data
  - Implement useUpdateSettings hook for updating data
  - Add error handling with retry functionality
  - Connect hooks to the settings service functions
  - Display appropriate error messages using existing `ErrorAlert` component

- [x] 2.4. Create SettingItem component
  - *Requirements: 2.2.2*
  - Create `src/components/settings/SettingItem.tsx`
  - Implement component that displays a single setting with label, control, and description
  - Support different input types (text, number, checkbox, select)
  - Add proper TypeScript interfaces for props
  - Style according to existing dashboard design patterns
  - Write component tests

- [x] 2.5. Create SettingsSection component
  - *Requirements: 2.2.2*
  - Create `src/components/settings/SettingsSection.tsx`
  - Implement component that groups related settings
  - Include section title and description
  - Add proper TypeScript interfaces for props
  - Ensure it follows existing UI component patterns
  - Write component tests

- [x] 2.6. Create SettingsForm component
  - *Requirements: 2.2.4*
  - Create `src/components/settings/SettingsForm.tsx`
  - Implement form handling for settings updates
  - Connect to TanStack Query hooks for data fetching and updating
  - Add form validation if needed
  - Implement save/cancel functionality
  - Add proper TypeScript interfaces for props
  - Write component tests

- [x] 2.7. Integrate components into settings page
  - *Requirements: 2.2.2, 2.2.6, 2.2.7*
  - Connect all settings components to the settings page
  - Organize settings into logical sections using SettingsSection
  - Wire up SettingsForm to handle data updates
  - Ensure all components display data from TanStack Query hooks
  - Test form submission and error handling

## 3. Integration and Testing

- [x] 3.1. Verify navigation and routing
  - *Requirements: 2.1.1, 2.2.1*
  - Test that analytics and settings pages are accessible through sidebar navigation
  - Verify that direct URL access works correctly
  - Confirm that authentication protection is working
  - Check that 404 errors are resolved

- [ ] 3.2. Conduct component testing
  - *Requirements: All components*
  - Write unit tests for all new service functions
  - Write unit tests for all new components with mock data
  - Write integration tests for page components
  - Verify that all components render correctly with mock data
  - Test error states and loading states

- [ ] 3.3. Conduct end-to-end testing
  - *Requirements: 2.1.1, 2.2.1*
  - Test full user flow for accessing analytics page
  - Test full user flow for accessing and updating settings
  - Verify responsive design works on different screen sizes
  - Test error handling scenarios