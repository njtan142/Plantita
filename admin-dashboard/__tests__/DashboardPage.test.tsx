import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import DashboardPage from '../app/dashboard/page';

// Mock the withAuth HOC
jest.mock('../components/auth/with-auth', () => ({
  __esModule: true,
  default: (Component: React.ComponentType) => (props: any) => (
    <Component {...props} />
  ),
}));

// Setup default mock values
const mockDashboardStats = {
  totalUsers: 1000,
  activeUsers: 500,
  totalMedia: 2000,
  storageUsed: 1024 * 1024 * 10, // 10 MB
  userGrowth: [{ date: '2024-01-01', count: 100 }],
  mediaUploads: [{ date: '2024-01-01', count: 50 }],
  recentActivities: []
};

// We will mock the useQuery hook since DashboardPage uses multiple useQuery calls
// and it's cleaner to mock the library directly for complex pages
jest.mock('@tanstack/react-query', () => {
  const originalModule = jest.requireActual('@tanstack/react-query');
  return {
    ...originalModule,
    useQuery: jest.fn(),
  };
});

import { useQuery } from '@tanstack/react-query';

describe('DashboardPage', () => {
  const queryClient = new QueryClient();

  const renderWithProviders = (component: React.ReactElement) => {
    return render(
      <QueryClientProvider client={queryClient}>
        {component}
      </QueryClientProvider>
    );
  };

  beforeEach(() => {
    jest.clearAllMocks();

    // Default implementation for useQuery
    (useQuery as jest.Mock).mockImplementation(({ queryKey }) => {
      if (queryKey[0] === 'dashboardStats') {
        return { data: mockDashboardStats, isLoading: false, isError: false, refetch: jest.fn() };
      }
      if (queryKey[0] === 'recentActivities') {
        return { data: [], isLoading: false, isError: false, refetch: jest.fn() };
      }
      if (queryKey[0] === 'userGrowth') {
        return { data: [], isLoading: false, isError: false, refetch: jest.fn() };
      }
      if (queryKey[0] === 'mediaUploads') {
        return { data: [], isLoading: false, isError: false, refetch: jest.fn() };
      }
      return { data: null, isLoading: false, isError: false, refetch: jest.fn() };
    });
  });

  it('renders all components on happy path', async () => {
    renderWithProviders(<DashboardPage />);

    expect(screen.getByText('Dashboard')).toBeInTheDocument();
    expect(screen.getByText('Total Users')).toBeInTheDocument();
    expect(screen.getByText('Active Users')).toBeInTheDocument();
    expect(screen.getByText('Total Media')).toBeInTheDocument();
    expect(screen.getByText('Storage Used')).toBeInTheDocument();
  });

  it('shows loading state when data is loading', async () => {
    (useQuery as jest.Mock).mockImplementation(({ queryKey }) => {
      if (queryKey[0] === 'dashboardStats') {
        return { isLoading: true, isError: false, refetch: jest.fn() };
      }
      return { data: [], isLoading: false, isError: false, refetch: jest.fn() };
    });

    renderWithProviders(<DashboardPage />);

    expect(screen.getByTestId('loading-spinner')).toBeInTheDocument();
  });

  it('shows error state when stats fail to load', async () => {
    (useQuery as jest.Mock).mockImplementation(({ queryKey }) => {
      if (queryKey[0] === 'dashboardStats') {
        return { isLoading: false, isError: true, error: new Error('Failed to load stats'), refetch: jest.fn() };
      }
      return { data: [], isLoading: false, isError: false, refetch: jest.fn() };
    });

    renderWithProviders(<DashboardPage />);

    expect(screen.getByText('Failed to load dashboard data')).toBeInTheDocument();
    expect(screen.getByText('Failed to load stats')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Retry' })).toBeInTheDocument();
  });

  it('calls refetch functions when Retry button is clicked', async () => {
    const refetchStatsMock = jest.fn();
    const refetchActivitiesMock = jest.fn();
    const refetchUserGrowthMock = jest.fn();
    const refetchMediaUploadsMock = jest.fn();

    (useQuery as jest.Mock).mockImplementation(({ queryKey }) => {
      if (queryKey[0] === 'dashboardStats') {
        return { isLoading: false, isError: true, error: new Error('Failed to load stats'), refetch: refetchStatsMock };
      }
      if (queryKey[0] === 'recentActivities') {
        return { isLoading: false, isError: false, refetch: refetchActivitiesMock };
      }
      if (queryKey[0] === 'userGrowth') {
        return { isLoading: false, isError: false, refetch: refetchUserGrowthMock };
      }
      if (queryKey[0] === 'mediaUploads') {
        return { isLoading: false, isError: false, refetch: refetchMediaUploadsMock };
      }
      return { data: [], isLoading: false, isError: false, refetch: jest.fn() };
    });

    renderWithProviders(<DashboardPage />);

    const retryButton = screen.getByRole('button', { name: 'Retry' });
    await userEvent.click(retryButton);

    expect(refetchStatsMock).toHaveBeenCalled();
    expect(refetchActivitiesMock).toHaveBeenCalled();
    expect(refetchUserGrowthMock).toHaveBeenCalled();
    expect(refetchMediaUploadsMock).toHaveBeenCalled();
  });
});
