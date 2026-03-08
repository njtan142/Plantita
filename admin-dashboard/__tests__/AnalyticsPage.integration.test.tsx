import { render, screen, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import AnalyticsPage from '../app/dashboard/analytics/page';

// Mock the withAuth HOC
jest.mock('../components/auth/with-auth', () => ({
  __esModule: true,
  default: (Component: React.ComponentType) => (props: any) => (
    <Component {...props} />
  ),
}));

// Mock the useAnalyticsData hook
jest.mock('../hooks/useAnalytics', () => ({
  useAnalyticsData: () => ({
    data: {
      userGrowth: [
        { date: '2024-01-01', count: 100 },
        { date: '2024-01-02', count: 120 },
      ],
      mediaUploads: [
        { date: '2024-01-01', count: 50 },
        { date: '2024-01-02', count: 65 },
      ],
      engagementMetrics: [
        { date: '2024-01-01', likes: 200, comments: 50, shares: 30 },
        { date: '2024-01-02', likes: 250, comments: 60, shares: 35 },
      ],
      platformMetrics: {
        totalUsers: 1250,
        activeUsers: 850,
        totalMedia: 3500,
        storageUsed: 125000000000,
      },
    },
    isLoading: false,
    isError: false,
    error: null,
    refetch: jest.fn(),
  }),
}));

describe('AnalyticsPage Integration', () => {
  const queryClient = new QueryClient();

  const renderWithProviders = (component: React.ReactElement) => {
    return render(
      <QueryClientProvider client={queryClient}>
        {component}
      </QueryClientProvider>
    );
  };

  it('should render analytics page with all components', async () => {
    renderWithProviders(<AnalyticsPage />);

    // Check that page header is rendered
    expect(screen.getByText('Analytics')).toBeInTheDocument();
    expect(
      screen.getByText('View platform analytics and insights.')
    ).toBeInTheDocument();

    // Check that metric cards are rendered
    expect(screen.getByText('Total Users')).toBeInTheDocument();
    expect(screen.getByText('Active Users')).toBeInTheDocument();
    expect(screen.getByText('Total Media')).toBeInTheDocument();
    expect(screen.getByText('Storage Used')).toBeInTheDocument();

    // Check that charts are rendered
    expect(screen.getByText('User Growth')).toBeInTheDocument();
    expect(screen.getByText('Media Uploads')).toBeInTheDocument();
    expect(screen.getByText('Engagement Metrics')).toBeInTheDocument();
  });

  it('should display loading state', async () => {
    // Mock loading state
    jest.mock('../hooks/useAnalytics', () => ({
      useAnalyticsData: () => ({
        data: undefined,
        isLoading: true,
        isError: false,
        error: null,
        refetch: jest.fn(),
      }),
    }));

    renderWithProviders(<AnalyticsPage />);

    // Check that loading spinner is displayed
    await waitFor(() => {
      expect(screen.getByTestId('loading-spinner')).toBeInTheDocument();
    });
  });

  it('should display error state', async () => {
    // Mock error state
    jest.mock('../hooks/useAnalytics', () => ({
      useAnalyticsData: () => ({
        data: undefined,
        isLoading: false,
        isError: true,
        error: new Error('Failed to load analytics data'),
        refetch: jest.fn(),
      }),
    }));

    renderWithProviders(<AnalyticsPage />);

    // Check that error alert is displayed
    await waitFor(() => {
      expect(screen.getByText('Failed to load analytics data')).toBeInTheDocument();
    });
  });
});