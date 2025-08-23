# Admin Dashboard - Design Document

## 1. Overview

This document outlines the technical design for enhancing the Plantita Admin Dashboard. The primary goal is to transform the current static dashboard into a fully dynamic, feature-rich, and secure platform for managing users and media. The design focuses on creating a robust architecture, reusable components, and a seamless user experience, leveraging the existing technology stack including Next.js, ShadCN UI, and TanStack Query.

## 2. Architecture

The application will follow a client-server architecture. The Next.js frontend will be the client, and the existing system backend will be the server. Communication between the client and server will be handled through a RESTful API.

### Frontend Architecture

*   **Framework:** Next.js with the App Router.
*   **UI Components:** ShadCN UI, which provides a set of accessible and customizable components.
*   **State Management:** TanStack Query will be used for server-state management (caching, fetching, and updating data). Client-side state will be managed with React's built-in state management (useState, useReducer, useContext) for local component state.
*   **Styling:** Tailwind CSS for utility-first styling.
*   **Authentication:** A custom JWT-based authentication solution will be implemented.

### Backend Architecture

The design assumes the system backend provides the necessary RESTful API endpoints for user and media management, as well as for fetching dashboard analytics. The frontend will interact with these endpoints via the API service layer.

## 3. Components and Interfaces

### 3.1. Data Tables

For both user and media management, we will use `TanStack Table` integrated with ShadCN UI components. This will provide a flexible and powerful data table with the following features:

*   **Sorting:** Clicking on a column header will sort the data in ascending or descending order.
*   **Filtering:** A search input will be provided to filter the data based on user or media attributes.
*   **Pagination:** "Next" and "Previous" buttons will be available to navigate through large datasets.
*   **Row Selection:** Checkboxes will be used to select one or more rows for bulk operations.
*   **Row Actions:** A dropdown menu on each row will provide actions like "Edit," "Delete," and "View Details."

### 3.2. Forms

Forms for creating and editing users and media will be built using `React Hook Form` for performance and `Zod` for validation. ShadCN UI form components will be used for the UI elements.

### 3.3. Modals and Dialogs

ShadCN UI's `Dialog` and `AlertDialog` components will be used for:

*   Displaying user or media details.
*   Confirmation before performing destructive actions like deleting a user or media file.
*   Previewing media content.

### 3.4. Charts

We will use a charting library like `Recharts` or `Chart.js` to display the user growth and media upload charts on the dashboard overview page. These charts will be rendered with data fetched from the backend.

## 4. Data Models

The frontend will use the following TypeScript interfaces to model the data received from the API.

```typescript
// types/api.ts

export interface User {
  id: string;
  name: string;
  email: string;
  avatar?: string;
  role: 'admin' | 'moderator' | 'user';
  status: 'active' | 'inactive' | 'suspended';
  createdAt: string;
  lastActiveAt: string;
}

export interface Media {
  id: string;
  filename: string;
  thumbnailUrl?: string;
  url: string;
  type: 'image' | 'video';
  size: number;
  status: 'pending' | 'approved' | 'rejected';
  uploadedBy: Pick<User, 'id' | 'name'>;
  createdAt: string;
}

export interface DashboardStats {
  totalUsers: number;
  activeUsers: number;
  totalMedia: number;
  storageUsed: number;
  userGrowth: { date: string; count: number }[];
  mediaUploads: { date: string; count: number }[];
  recentActivities: Activity[];
}

export interface Activity {
  id: string;
  type: string;
  description: string;
  timestamp: string;
}
```

## 5. Authentication and Authorization

We will implement a JWT-based authentication flow:

1.  **Login Page:** A dedicated login page (`/login`) will have a form for admins to enter their credentials.
2.  **API Route for Login:** A Next.js API route (`/api/auth/login`) will receive the credentials, validate them with the backend, and if successful, the backend will return a JWT.
3.  **Secure Cookie Storage:** The JWT will be stored in an `HttpOnly` cookie to protect against XSS attacks.
4.  **Middleware:** Next.js middleware will protect all routes under `/dashboard`. It will check for the presence and validity of the JWT in the cookie on each request. If the token is missing or invalid, the user will be redirected to the login page.
5.  **Logout:** A logout button will call an API route (`/api/auth/logout`) that clears the authentication cookie.
6.  **Role-Based Access Control (RBAC):** The user's role will be included in the JWT payload. The frontend will use this information to conditionally render UI elements and restrict access to certain pages or features.

## 6. Error Handling

*   **API Errors:** The API service layer will use interceptors to handle API errors globally. When an error occurs, it will be propagated to the UI.
*   **Component-Level Errors:** React Error Boundaries will be used to catch rendering errors in components and display a fallback UI.
*   **User Feedback:** Toast notifications will be used to provide non-intrusive feedback to the user for actions like success, error, and warning.
*   **Loading States:** Skeletons and spinners will be displayed while data is being fetched to provide visual feedback to the user.

## 7. Testing Strategy

*   **Unit Tests:** We will use Jest and React Testing Library to write unit tests for individual components, utility functions, and API services.
*   **Integration Tests:** We will write integration tests to verify that different parts of the application work together as expected. For example, testing the entire user creation flow from form submission to the user appearing in the data table.
*   **End-to-End (E2E) Tests:** We will use a framework like Cypress or Playwright to simulate user interactions and test critical user flows from end to end.
