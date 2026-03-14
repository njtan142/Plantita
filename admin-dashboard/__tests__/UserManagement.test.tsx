import React from 'react';
import { render, screen, waitFor, fireEvent, act, type RenderResult } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import UsersPage from '../app/dashboard/users/page';
import { userService } from '../services/userService';
import { MOCK_USERS } from '../types/api';

// Mock the user service
jest.mock('../services/userService', () => ({
  userService: {
    getUsers: jest.fn(),
    deleteUser: jest.fn(),
    bulkDeleteUsers: jest.fn(),
    activateUser: jest.fn(),
    deactivateUser: jest.fn(),
    exportUsers: jest.fn(),
  },
}));

// Mock the sonner toast
jest.mock('sonner', () => ({
  toast: {
    success: jest.fn(),
    error: jest.fn(),
  },
}));

// Mock next/navigation
jest.mock('next/navigation', () => ({
  useRouter: () => ({
    push: jest.fn(),
  }),
  useParams: () => ({}),
}));

const createQueryClient = () => new QueryClient({
  defaultOptions: {
    queries: {
      retry: false,
    },
  },
});

describe('UsersPage', () => {
  let queryClient: QueryClient;

  beforeEach(() => {
    jest.clearAllMocks();
    queryClient = createQueryClient();
    (userService.getUsers as jest.Mock).mockResolvedValue({
      success: true,
      data: MOCK_USERS,
      meta: {
        total: MOCK_USERS.length,
        page: 1,
        limit: 10,
        totalPages: 1,
      },
    });
  });

  const renderUsersPage = async () => {
    let result: RenderResult;
    await act(async () => {
      result = render(
        <QueryClientProvider client={queryClient}>
          <UsersPage />
        </QueryClientProvider>
      );
    });
    return result;
  };

  it('renders user management header and table', async () => {
    await renderUsersPage();

    expect(await screen.findByText('User Management')).toBeInTheDocument();
    
    await waitFor(() => {
      expect(userService.getUsers).toHaveBeenCalled();
    });

    // Debug the output to see what is actually rendered
    // screen.debug();

    // The usernames in MOCK_USERS are 'johndoe', 'janesmith', 'admin'
    // They appear as @johndoe in the table
    expect(await screen.findByText(/@johndoe/i)).toBeInTheDocument();
    expect(await screen.findByText(/@janesmith/i)).toBeInTheDocument();
  });

  it('shows create user form when "Add User" is clicked', async () => {
    await renderUsersPage();

    const addBtn = await screen.findByText('Add User');
    
    await act(async () => {
      fireEvent.click(addBtn);
    });

    expect(await screen.findByText('Create New User')).toBeInTheDocument();
  });
});
