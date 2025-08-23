# Admin Dashboard Feature Enhancement

## 1. Introduction

This document outlines the requirements for enhancing the Admin Dashboard of the Plantita application. The goal is to build upon the existing dashboard structure to create a fully functional and dynamic interface for managing users and media, as well as providing insightful analytics. This will involve replacing static data with live data from the backend API, implementing comprehensive management features, and ensuring the application is robust, secure, and performant.

## 2. Requirements

### 2.1. Dynamic Dashboard Overview

*   **User Story:** As an admin, I want to see a real-time overview of the platform's key metrics on the main dashboard page, so that I can quickly assess the health and activity of the application.
*   **Acceptance Criteria:**
    1.  **While viewing the dashboard overview page, the system shall** fetch and display the total number of users from the backend API.
    2.  **While viewing the dashboard overview page, the system shall** fetch and display the number of active users (e.g., active in the last 30 days) from the backend API.
    3.  **While viewing the dashboard overview page, the system shall** fetch and display the total number of media files from the backend API.
    4.  **While viewing the dashboard overview page, the system shall** fetch and display the total storage used by media files from the backend API.
    5.  **While viewing the dashboard overview page, the system shall** fetch and display data for the user growth and media upload charts from the backend API.
    6.  **While viewing the dashboard overview page, the system shall** fetch and display a list of recent activities (e.g., new user registrations, media uploads) from the backend API.

### 2.2. User Management

*   **User Story:** As an admin, I want to manage users effectively, so that I can maintain a healthy and secure user base.
*   **Acceptance Criteria:**
    1.  **When I navigate to the user management page, the system shall** display a paginated and sortable table of all users.
    2.  **The user table shall** include columns for user avatar, name, email, registration date, last active date, and status (e.g., active, inactive, suspended).
    3.  **The system shall** provide a search input to filter users by name or email.
    4.  **The system shall** provide an interface for creating a new user with a specified role.
    5.  **The system shall** provide an interface for editing an existing user's details, including their role and status.
    6.  **The system shall** provide a mechanism to delete one or more users.
    7.  **The system shall** display a confirmation dialog before deleting a user.

### 2.3. Media Management

*   **User Story:** As an admin, I want to manage media content, so that I can ensure it adheres to the platform's guidelines and policies.
*   **Acceptance Criteria:**
    1.  **When I navigate to the media management page, the system shall** display a paginated and sortable list or grid of all media files.
    2.  **The media list/grid shall** include a thumbnail, filename, type, size, upload date, and the user who uploaded it.
    3.  **The system shall** provide search and filtering options for media based on file type, upload date, and user.
    4.  **The system shall** allow me to preview images and videos in a modal or a dedicated viewer.
    5.  **The system shall** provide a mechanism to approve or reject pending media files.
    6.  **The system shall** provide a mechanism to delete one or more media files.
    7.  **The system shall** display a confirmation dialog before deleting media.

### 2.4. Authentication and Authorization

*   **User Story:** As an admin, I want a secure login system and role-based access, so that only authorized personnel can access the admin dashboard.
*   **Acceptance Criteria:**
    1.  **The system shall** provide a dedicated login page for administrators.
    2.  **The system shall** authenticate users against the backend and, upon successful authentication, grant access to the dashboard.
    3.  **The system shall** use secure session management (e.g., JWT in httpOnly cookies) to protect against unauthorized access.
    4.  **The system shall** implement role-based access control, restricting certain features to specific admin roles (e.g., super-admin vs. moderator).
    5.  **The system shall** provide a logout mechanism that securely terminates the user's session.

### 2.5. State Management, Error Handling, and Performance

*   **User Story:** As an admin, I want a fast, reliable, and responsive application, so that I can perform my tasks efficiently.
*   **Acceptance Criteria:**
    1.  **The system shall** use TanStack Query for all server-side state management, including data fetching, caching, and mutations.
    2.  **The system shall** implement optimistic updates for create, update, and delete operations to provide a smoother user experience.
    3.  **The system shall** display clear loading indicators (e.g., skeletons, spinners) while data is being fetched.
    4.  **The system shall** display user-friendly error messages and provide a "retry" option when API calls fail.
    5.  **The system shall** use toast notifications to provide feedback for actions (e.g., "User created successfully," "Failed to delete media").
    6.  **The system shall** implement code splitting and lazy loading for routes and heavy components to improve initial load times.
