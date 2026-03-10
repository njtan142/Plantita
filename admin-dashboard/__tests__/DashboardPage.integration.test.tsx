import { render, screen, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import userEvent from '@testing-library/user-event';
import DashboardPage from '../app/dashboard/page';
import { dashboardService } from '../services/dashboardService';

// Mock the withAuth HOC
jest.mock('../components/auth/with-auth', () => ({
  __esModule: true,
  default: (Component: React.ComponentType) => (props: any) => (
    <Component {...props} />
  ),
}));

// Mock the dashboardService
jest.mock('../services/dashboardService', () => ({
  dashboardService: {
    getDashboardStats: jest.fn(),
    getRecentActivities: jest.fn(),
  },
}));

// Mock the UI charts (recharts often causes issues in JSDOM)
jest.mock('../components/dashboard/UserGrowthChart', () => ({
  UserGrowthChart: () => <div data-testid="user-growth-chart">User Growth Chart Mock</div>,
}));

jest.mock('../components/dashboard/MediaUploadChart', () => ({
  MediaUploadChart: () => <div data-testid="media-upload-chart">Media Upload Chart Mock</div>,
}));

describe('DashboardPage Integration', () => {
  let queryClient: QueryClient;

  beforeEach(() => {
    jest.clearAllMocks();
    queryClient = new QueryClient({
      defaultOptions: {
        queries: {
          retry: false, // disable retries for testing
        },
      },
    });
  });

  const renderWithProviders = (component: React.ReactElement) => {
    return render(
      <QueryClientProvider client={queryClient}>
        {component}
      </QueryClientProvider>
    );
  };

  it('should render loading state initially', () => {
    // Return pending promises to keep it in loading state
    (dashboardService.getDashboardStats as jest.Mock).mockReturnValue(new Promise(() => {}));
    (dashboardService.getRecentActivities as jest.Mock).mockReturnValue(new Promise(() => {}));

    renderWithProviders(<DashboardPage />);

    // Check for the loading spinner (StatsCard uses Skeleton, but page shows LoadingSpinner if overall loading)
    // Actually the page uses <LoadingSpinner /> which renders a div with specific classes
    // We can check if the loading wrapper is present
    expect(document.querySelector('.animate-spin')).toBeInTheDocument();
  });

  it('should render dashboard with all components on successful data fetch', async () => {
    // Mock successful API responses
    const mockStats = {
      success: true,
      data: {
        totalUsers: 1500,
        activeUsers: 900,
        totalMedia: 6000,
        storageUsed: 2147483648, // 2 GB
        userGrowth: [{ date: '2024-01-01', count: 1500 }],
        mediaUploads: [{ date: '2024-01-01', count: 6000 }],
      },
    };

    const mockActivities = {
      success: true,
      data: [
        {
          id: '1',
          type: 'user_login',
          description: 'User John logged in',
          timestamp: '2024-01-01T12:00:00Z',
        },
      ],
    };

    (dashboardService.getDashboardStats as jest.Mock).mockResolvedValue(mockStats);
    (dashboardService.getRecentActivities as jest.Mock).mockResolvedValue(mockActivities);

    renderWithProviders(<DashboardPage />);

    // Wait for the page header to appear, indicating loading is done
    await waitFor(() => {
      expect(screen.getByText('Dashboard')).toBeInTheDocument();
    });

    expect(screen.getByText("Welcome back! Here's what's happening with your platform today.")).toBeInTheDocument();

    // Check stats cards
    expect(screen.getByText('Total Users')).toBeInTheDocument();
    expect(screen.getByText('1,500')).toBeInTheDocument();

    expect(screen.getByText('Active Users')).toBeInTheDocument();
    expect(screen.getByText('900')).toBeInTheDocument();

    expect(screen.getByText('Total Media')).toBeInTheDocument();
    expect(screen.getByText('6,000')).toBeInTheDocument();

    expect(screen.getByText('Storage Used')).toBeInTheDocument();
    expect(screen.getByText('2 GB')).toBeInTheDocument();

    // Check charts
    expect(screen.getByTestId('user-growth-chart')).toBeInTheDocument();
    expect(screen.getByTestId('media-upload-chart')).toBeInTheDocument();

    // Check Recent Activity
    expect(screen.getByText('Recent Activity')).toBeInTheDocument();
    expect(screen.getByText('User John logged in')).toBeInTheDocument();

    // Check Quick Actions
    expect(screen.getByText('Quick Actions')).toBeInTheDocument();
    expect(screen.getByText('Add User')).toBeInTheDocument();
  });

  it('should render error state and retry successfully', async () => {
    const user = userEvent.setup();

    // Initial failure
    (dashboardService.getDashboardStats as jest.Mock).mockRejectedValue(new Error('API Error'));
    (dashboardService.getRecentActivities as jest.Mock).mockRejectedValue(new Error('API Error'));

    renderWithProviders(<DashboardPage />);

    // Wait for error message
    await waitFor(() => {
      expect(screen.getByText('Failed to load dashboard data')).toBeInTheDocument();
    });

    // Mock successful response for the retry
    const mockStats = {
      success: true,
      data: {
        totalUsers: 1500,
        activeUsers: 900,
        totalMedia: 6000,
        storageUsed: 2147483648,
        userGrowth: [],
        mediaUploads: [],
      },
    };

    const mockActivities = {
      success: true,
      data: [],
    };

    (dashboardService.getDashboardStats as jest.Mock).mockResolvedValue(mockStats);
    (dashboardService.getRecentActivities as jest.Mock).mockResolvedValue(mockActivities);

    // Click retry button
    const retryButton = screen.getByRole('button', { name: /retry/i });
    await user.click(retryButton);

    // Wait for successful render
    await waitFor(() => {
      expect(screen.getByText('Dashboard')).toBeInTheDocument();
      expect(screen.getByText('Total Users')).toBeInTheDocument();
    });
  });
});
