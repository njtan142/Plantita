# Step 3: Create Admin Dashboard

## Overview
This step implements the admin dashboard using Next.js and ShadCN UI components. The admin dashboard will serve as the administrative interface for managing users and media content, communicating with the system backend APIs that were established in Step 2. The dashboard will provide a clean, modern interface for administrators to monitor and manage the social media platform.

## Prerequisites and Dependencies

### System Requirements
- **Node.js**: Version 18.0.0 or higher
- **npm**: Version 9.0.0 or higher (comes with Node.js)
- **System Backend**: Must be completed and running (Step 2)
- **Git**: Version 2.34.0 or higher

### Required Dependencies
- **Next.js**: React framework for the web application
- **React**: Frontend library (comes with Next.js)
- **TypeScript**: Type-safe development
- **ShadCN UI**: Modern UI component library
- **Axios**: HTTP client for API communication
- **Tailwind CSS**: Utility-first CSS framework
- **Lucide React**: Icon library
- **React Hook Form**: Form management
- **Zod**: Schema validation
- **TanStack Query**: Data fetching and caching
- **NextAuth.js**: Authentication (optional, for admin auth)

### Installation Commands
```bash
# Install Next.js with TypeScript
npx create-next-app@latest admin-dashboard --typescript --tailwind --eslint --app

# Navigate to admin-dashboard directory
cd admin-dashboard

# Install additional dependencies
npm install axios @radix-ui/react-dialog @radix-ui/react-dropdown-menu @radix-ui/react-select @radix-ui/react-tabs @radix-ui/react-toast @radix-ui/react-avatar @radix-ui/react-badge @radix-ui/react-button @radix-ui/react-card @radix-ui/react-input @radix-ui/react-label @radix-ui/react-table @radix-ui/react-textarea @radix-ui/react-checkbox @radix-ui/react-switch @radix-ui/react-slider @radix-ui/react-progress @radix-ui/react-separator @radix-ui/react-accordion @radix-ui/react-collapsible @radix-ui/react-popover @radix-ui/react-tooltip @radix-ui/react-scroll-area @radix-ui/react-navigation-menu @radix-ui/react-menubar @radix-ui/react-hover-card @radix-ui/react-alert-dialog @radix-ui/react-sheet @radix-ui/react-aspect-ratio @radix-ui/react-calendar @radix-ui/react-command @radix-ui/react-context-menu @radix-ui/react-data-table @radix-ui/react-form @radix-ui/react-skeleton @radix-ui/react-toggle @radix-ui/react-toggle-group @radix-ui/react-toolbar class-variance-authority clsx tailwind-merge lucide-react @tanstack/react-query react-hook-form @hookform/resolvers zod date-fns

# Install development dependencies
npm install -D @types/node @types/react @types/react-dom
```

## Comprehensive Implementation Checklist

### [x] 1. Initialize Next.js Project with ShadCN UI
**Objective**: Set up the Next.js project with ShadCN UI components and configuration

**Detailed Instructions**:
1. Create Next.js project with TypeScript and Tailwind CSS
2. Initialize ShadCN UI configuration
3. Set up component library structure
4. Configure Tailwind CSS with ShadCN UI theme
5. Set up TypeScript configuration for the project
6. Configure ESLint and Prettier

**Expected Files**:
```
admin-dashboard/
├── app/
│   ├── globals.css
│   ├── layout.tsx
│   ├── page.tsx
│   └── components/
│       └── ui/          # ShadCN UI components
├── components/
│   ├── ui/             # ShadCN UI components
│   └── layout/         # Layout components
├── lib/
│   ├── utils.ts        # Utility functions
│   └── hooks/          # Custom React hooks
├── services/           # API service layer
├── types/              # TypeScript type definitions
├── package.json
├── tailwind.config.js
├── components.json     # ShadCN UI configuration
└── tsconfig.json
```

**ShadCN UI Setup Commands**:
```bash
# Initialize ShadCN UI
npx shadcn@latest init --yes

# Add essential components
npx shadcn@latest add button card input label table tabs dialog dropdown-menu avatar badge toast
npx shadcn@latest add form select checkbox switch slider progress separator skeleton
npx shadcn@latest add navigation-menu menubar command popover tooltip hover-card
npx shadcn@latest add alert-dialog sheet scroll-area resizable aspect-ratio
```

**Verification Steps**:
- Run `npm run dev` and verify the app starts
- Check that ShadCN UI components render correctly
- Verify Tailwind CSS is working with custom styles

### [x] 2. Set up API Service Layer
**Objective**: Create the service layer for communicating with the system backend

**Detailed Instructions**:
1. Create Axios instance with base configuration
2. Set up API service classes for different endpoints
3. Implement error handling and response interceptors
4. Configure environment variables for API base URL
5. Set up TypeScript interfaces for API responses
6. Implement authentication headers if needed

**API Service Structure**:
```typescript
// services/api.ts
export class ApiService {
  private axiosInstance = axios.create({
    baseURL: process.env.NEXT_PUBLIC_API_URL,
    timeout: 10000,
  });

  // User management endpoints
  async getUsers(params?: UserQueryParams): Promise<User[]> {
    // Implementation
  }

  async createUser(userData: CreateUserData): Promise<User> {
    // Implementation
  }

  async updateUser(id: string, userData: UpdateUserData): Promise<User> {
    // Implementation
  }

  async deleteUser(id: string): Promise<void> {
    // Implementation
  }

  // Media management endpoints
  async getMedia(params?: MediaQueryParams): Promise<Media[]> {
    // Implementation
  }

  async deleteMedia(id: string): Promise<void> {
    // Implementation
  }

  async getMediaStats(): Promise<MediaStats> {
    // Implementation
  }
}
```

**Verification Steps**:
- Test API connection to system backend
- Verify error handling works correctly
- Check that TypeScript types are properly defined

### [x] 3. Implement Dashboard Layout
**Objective**: Create the main dashboard layout with navigation and sidebar

**Detailed Instructions**:
1. Create main layout component with sidebar navigation
2. Implement responsive design for mobile and desktop
3. Add header with user info and logout functionality
4. Set up navigation menu with active state indicators
5. Implement breadcrumb navigation
6. Add loading states and error boundaries

**Layout Components**:
- `DashboardLayout`: Main layout wrapper
- `Sidebar`: Navigation sidebar with menu items
- `Header`: Top navigation bar
- `Breadcrumb`: Navigation breadcrumb component
- `LoadingSpinner`: Loading state component

**Navigation Structure**:
```typescript
const navigationItems = [
  { name: 'Dashboard', href: '/dashboard', icon: 'LayoutDashboard' },
  { name: 'Users', href: '/dashboard/users', icon: 'Users' },
  { name: 'Media', href: '/dashboard/media', icon: 'Image' },
  { name: 'Analytics', href: '/dashboard/analytics', icon: 'BarChart3' },
  { name: 'Settings', href: '/dashboard/settings', icon: 'Settings' }
];
```

**Verification Steps**:
- Test responsive behavior on different screen sizes
- Verify navigation works correctly
- Check that active states are properly highlighted

### [ ] 4. Create Dashboard Overview Page
**Objective**: Implement the main dashboard page with key metrics and charts

**Detailed Instructions**:
1. Create overview page with key performance indicators
2. Implement statistics cards for users, media, and activity
3. Add charts for user growth and media uploads
4. Create recent activity feed
5. Implement quick actions for common tasks
6. Add data refresh functionality

**Dashboard Components**:
- `StatsCard`: Reusable card for displaying metrics
- `UserGrowthChart`: Chart showing user registration trends
- `MediaUploadChart`: Chart showing media upload statistics
- `RecentActivity`: List of recent system activities
- `QuickActions`: Buttons for common administrative tasks

**Key Metrics to Display**:
- Total users count
- Active users (last 30 days)
- Total media files
- Media uploaded this month
- System health status
- Storage usage

**Verification Steps**:
- Verify data loads correctly from API
- Check that charts render properly
- Test refresh functionality

### [ ] 5. Implement User Management Interface
**Objective**: Create comprehensive user management functionality

**Detailed Instructions**:
1. Create users listing page with data table
2. Implement user search and filtering
3. Add user creation and editing forms
4. Create user detail view with activity history
5. Implement bulk user operations (activate/deactivate/delete)
6. Add user role management if applicable
7. Implement user export functionality

**User Management Components**:
- `UsersTable`: Data table with sorting and pagination
- `UserForm`: Form for creating/editing users
- `UserDetailModal`: Modal for viewing user details
- `UserFilters`: Search and filter controls
- `BulkActions`: Bulk operation controls

**User Table Columns**:
- Avatar/Name
- Email
- Registration Date
- Last Active
- Status (Active/Inactive)
- Role
- Actions (Edit/Delete/View)

**Verification Steps**:
- Test CRUD operations for users
- Verify search and filtering work correctly
- Check bulk operations functionality
- Test form validation

### [ ] 6. Implement Media Management Interface
**Objective**: Create media content management functionality

**Detailed Instructions**:
1. Create media gallery/listing page
2. Implement media search and filtering by type, user, date
3. Add media preview functionality (images, videos)
4. Create media detail view with metadata
5. Implement bulk media operations (delete, approve/reject)
6. Add media analytics and usage statistics
7. Implement media export functionality

**Media Management Components**:
- `MediaGrid`: Grid layout for media thumbnails
- `MediaTable`: Table view for media management
- `MediaPreview`: Modal for previewing media content
- `MediaFilters`: Search and filter controls
- `MediaStats`: Media usage statistics component

**Media Table Columns**:
- Thumbnail
- Filename
- Type (Image/Video)
- Size
- Upload Date
- Uploaded By
- Status
- Actions

**Verification Steps**:
- Test media loading and display
- Verify preview functionality works
- Check bulk operations
- Test filtering and search

### [ ] 7. Set up State Management
**Objective**: Implement efficient state management for the dashboard

**Detailed Instructions**:
1. Set up TanStack Query for server state management
2. Configure React Query client with proper defaults
3. Implement optimistic updates for better UX
4. Set up error handling and retry logic
5. Configure caching strategies for different data types
6. Implement background refetching

**Query Configuration**:
```typescript
// lib/queryClient.ts
export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // 5 minutes
      gcTime: 10 * 60 * 1000, // 10 minutes
      retry: (failureCount, error) => {
        // Custom retry logic
        return failureCount < 3;
      },
    },
  },
});
```

**Verification Steps**:
- Test data fetching and caching
- Verify error states are handled properly
- Check loading states work correctly

### [ ] 8. Implement Authentication and Authorization
**Objective**: Set up admin authentication and role-based access control

**Detailed Instructions**:
1. Implement admin login functionality
2. Set up session management
3. Create protected routes for admin-only access
4. Implement role-based permissions
5. Add logout functionality
6. Configure authentication middleware

**Authentication Flow**:
- Login form with email/password
- JWT token storage in httpOnly cookies
- Automatic token refresh
- Protected route wrapper component
- Role-based route protection

**Verification Steps**:
- Test login/logout functionality
- Verify protected routes work correctly
- Check role-based access control

### [ ] 9. Add Error Handling and Loading States
**Objective**: Implement comprehensive error handling and loading states

**Detailed Instructions**:
1. Create error boundary components
2. Implement loading spinners and skeletons
3. Add error messages and retry functionality
4. Set up global error handling
5. Implement toast notifications for user feedback
6. Add offline detection and handling

**Error Handling Components**:
- `ErrorBoundary`: Catches React errors
- `LoadingSpinner`: Generic loading component
- `ErrorMessage`: Error display component
- `ToastContainer`: Toast notification container

**Verification Steps**:
- Test error scenarios
- Verify loading states appear correctly
- Check toast notifications work

### [ ] 10. Optimize Performance
**Objective**: Optimize the dashboard for performance and user experience

**Detailed Instructions**:
1. Implement code splitting and lazy loading
2. Add image optimization for media thumbnails
3. Set up proper caching strategies
4. Implement virtualization for large lists
5. Add service worker for caching
6. Optimize bundle size

**Performance Optimizations**:
- Lazy load route components
- Implement image lazy loading
- Use React.memo for expensive components
- Optimize re-renders with proper key usage
- Implement pagination for large datasets

**Verification Steps**:
- Test page load times
- Verify lazy loading works
- Check bundle size and analyze with build tools

## Expected Outcomes

### User Experience
- Clean, modern admin interface with ShadCN UI components
- Responsive design that works on desktop and mobile
- Intuitive navigation and user-friendly forms
- Real-time data updates and loading states
- Comprehensive error handling and user feedback

### Functionality
- Complete user management (CRUD operations)
- Media content management and moderation
- Dashboard analytics and reporting
- Search and filtering capabilities
- Bulk operations for efficiency
- Export functionality for data

### Technical Implementation
- TypeScript for type safety
- Modern React patterns and hooks
- Efficient state management with TanStack Query
- Proper error handling and loading states
- Optimized performance and bundle size

## Verification Checklist

### [ ] Next.js project initializes successfully
### [ ] ShadCN UI components are properly configured
### [ ] API service layer connects to system backend
### [ ] Dashboard layout renders correctly
### [ ] User management functionality works
### [ ] Media management functionality works
### [ ] Authentication and authorization work
### [ ] Error handling and loading states work
### [ ] Performance optimizations are implemented
### [ ] Responsive design works on all screen sizes

## Troubleshooting

### Common Issues
1. **API Connection Issues**: Verify system backend is running and CORS is configured
2. **ShadCN UI Styling Issues**: Check Tailwind CSS configuration and component imports
3. **TypeScript Errors**: Verify type definitions and API response interfaces
4. **Performance Issues**: Check for unnecessary re-renders and optimize queries

### Getting Help
- [Next.js Documentation](https://nextjs.org/docs)
- [ShadCN UI Documentation](https://ui.shadcn.com/)
- [TanStack Query Documentation](https://tanstack.com/query/)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)

## Next Steps
After completing this admin dashboard implementation, proceed to:
- Step 4: Develop Flutter uploader app
- Step 5: Build Flutter user app
- Step 6: Implement Docker configuration

## Resources and Documentation

### Official Documentation
- [Next.js Guide](https://nextjs.org/docs/getting-started)
- [ShadCN UI Components](https://ui.shadcn.com/docs)
- [Tailwind CSS](https://tailwindcss.com/docs)
- [TanStack Query](https://tanstack.com/query/latest/docs/react/overview)
- [React Hook Form](https://react-hook-form.com/)

### Best Practices
- [Next.js Performance Optimization](https://nextjs.org/docs/advanced-features/optimize-performance)
- [React Admin Dashboard Patterns](https://www.patterns.dev/posts/admin-dashboard)
- [Modern React Development](https://www.patterns.dev/posts/modern-react-development)

---

*This document provides comprehensive guidance for implementing the admin dashboard. Review and adapt as needed based on specific project requirements and team preferences.*