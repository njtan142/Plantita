import { render, screen, waitFor, fireEvent } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import DashboardPage from '../app/dashboard/page';
import { dashboardService } from '../services/dashboardService';

// Mock the withAuth HOC
jest.mock('../components/auth/with-auth', () => ({
  __esModule: true,
  default: (Component: React.ComponentType) => (props: Record<string, unknown>) => (
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

const MOCK_STATS = {
  totalUsers: 2000,
  activeUsers: 1500,
  totalMedia: 8000,
  storageUsed: 250000000, // 250 MB
  userGrowth: [
    { date: '2023-01-01', count: 1000 },
    { date: '2023-02-01', count: 2000 },
  ],
  mediaUploads: [
    { date: '2023-01-01', count: 300 },
    { date: '2023-02-01', count: 600 },
  ],
};

const MOCK_ACTIVITIES = [
  {
    id: '1',
    type: 'user_registered',
    description: 'A new user joined',
    timestamp: '2023-10-01T10:00:00.000Z',
  },
  {
    id: '2',
    type: 'media_uploaded',
    description: 'A new photo was uploaded',
    timestamp: '2023-10-01T11:00:00.000Z',
  },
];

describe('DashboardPage', () => {
  let queryClient: QueryClient;

  beforeEach(() => {
    queryClient = new QueryClient({
      defaultOptions: {
        queries: {
          retry: false,
        },
      },
    });
    jest.clearAllMocks();
  });

  const renderWithProviders = (component: React.ReactElement) => {
    return render(
      <QueryClientProvider client={queryClient}>
        {component}
      </QueryClientProvider>
    );
  };

  it('renders successfully with data', async () => {
    (dashboardService.getDashboardStats as jest.Mock).mockResolvedValue({
      success: true,
      data: MOCK_STATS,
    });
    (dashboardService.getRecentActivities as jest.Mock).mockResolvedValue({
      success: true,
      data: MOCK_ACTIVITIES,
    });

    renderWithProviders(<DashboardPage />);

    // Wait for the data to load
    await waitFor(() => {
      expect(screen.getByText('Dashboard')).toBeInTheDocument();
    });

    // Check stats are displayed
    expect(screen.getByText('2,000')).toBeInTheDocument(); // totalUsers
    expect(screen.getByText('1,500')).toBeInTheDocument(); // activeUsers
    expect(screen.getByText('8,000')).toBeInTheDocument(); // totalMedia
    expect(screen.getByText('238.42 MB')).toBeInTheDocument(); // storageUsed

    // Check components render text (just partial checks for child components)
    expect(screen.getByText('Recent Activity')).toBeInTheDocument();
    expect(screen.getByText('Quick Actions')).toBeInTheDocument();
    expect(screen.getByText('User Growth')).toBeInTheDocument();
    expect(screen.getByText('Media Uploads')).toBeInTheDocument();
  });

  it('renders loading state initially', () => {
    // Return unresolved promises to keep it in loading state
    (dashboardService.getDashboardStats as jest.Mock).mockReturnValue(new Promise(() => {}));
    (dashboardService.getRecentActivities as jest.Mock).mockReturnValue(new Promise(() => {}));

    const { container } = renderWithProviders(<DashboardPage />);

    // Check for loading spinner (by inspecting classes or standard roles)
    // The LoadingSpinner component usually renders an svg with specific classes or a div
    expect(container.querySelector('svg.animate-spin')).toBeInTheDocument();
  });

  // Since the component catches API errors and uses mock data instead of triggering TanStack Query's isError state,
  // we will test that it falls back to mock data on error
  it('uses mock data when API throws an error', async () => {
    (dashboardService.getDashboardStats as jest.Mock).mockRejectedValue(new Error('Network Error'));
    (dashboardService.getRecentActivities as jest.Mock).mockRejectedValue(new Error('Network Error'));

    renderWithProviders(<DashboardPage />);

    // Wait for the mock data to load
    await waitFor(() => {
      expect(screen.getByText('1,240')).toBeInTheDocument(); // MOCK_DASHBOARD_STATS.totalUsers from page.tsx fallback
    });

    expect(screen.getByText('860')).toBeInTheDocument(); // activeUsers
  });

  it('uses mock data when API returns success: false', async () => {
    (dashboardService.getDashboardStats as jest.Mock).mockResolvedValue({
      success: false,
      error: 'API Error',
    });
    (dashboardService.getRecentActivities as jest.Mock).mockResolvedValue({
      success: false,
      error: 'API Error',
    });

    renderWithProviders(<DashboardPage />);

    // Wait for the mock data to load
    await waitFor(() => {
      expect(screen.getByText('1,240')).toBeInTheDocument(); // MOCK_DASHBOARD_STATS.totalUsers from page.tsx fallback
    });

    expect(screen.getByText('860')).toBeInTheDocument(); // activeUsers
    expect(screen.getByText('5,420')).toBeInTheDocument(); // totalMedia
    expect(screen.getByText('119.21 MB')).toBeInTheDocument(); // storageUsed
  });
});
