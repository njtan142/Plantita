import { render, screen, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import SettingsPage from '../app/dashboard/settings/page';

// Mock the withAuth HOC
jest.mock('../components/auth/with-auth', () => ({
  __esModule: true,
  default: (Component: React.ComponentType) => (props: any) => (
    <Component {...props} />
  ),
}));

// Mock the usePlatformSettings hook
jest.mock('../hooks/useSettings', () => ({
  usePlatformSettings: () => ({
    data: {
      siteName: 'Plantita Admin',
      siteDescription: 'Admin dashboard for the Plantita platform',
      contactEmail: 'admin@plantita.com',
      maxFileSize: 10485760,
      allowedFileTypes: ['image/jpeg', 'image/png', 'image/gif', 'video/mp4'],
      userRegistration: true,
      emailVerification: true,
      maxLoginAttempts: 5,
    },
    isLoading: false,
    isError: false,
    error: null,
    refetch: jest.fn(),
  }),
}));

describe('SettingsPage Integration', () => {
  const queryClient = new QueryClient();

  const renderWithProviders = (component: React.ReactElement) => {
    return render(
      <QueryClientProvider client={queryClient}>
        {component}
      </QueryClientProvider>
    );
  };

  it('should render settings page with form', async () => {
    renderWithProviders(<SettingsPage />);

    // Check that page header is rendered
    expect(screen.getByText('Settings')).toBeInTheDocument();
    expect(
      screen.getByText('Manage platform configuration and settings.')
    ).toBeInTheDocument();

    // Check that settings form is rendered
    expect(screen.getByText('General Settings')).toBeInTheDocument();
    expect(screen.getByText('File Upload Settings')).toBeInTheDocument();
    expect(screen.getByText('User Management')).toBeInTheDocument();

    // Check that form fields are present
    expect(screen.getByLabelText('Site Name')).toBeInTheDocument();
    expect(screen.getByLabelText('Contact Email')).toBeInTheDocument();
    expect(screen.getByLabelText('Max File Size (bytes)')).toBeInTheDocument();
    expect(screen.getByLabelText('User Registration')).toBeInTheDocument();
  });

  it('should display loading state', async () => {
    // Mock loading state
    jest.mock('../hooks/useSettings', () => ({
      usePlatformSettings: () => ({
        data: undefined,
        isLoading: true,
        isError: false,
        error: null,
        refetch: jest.fn(),
      }),
    }));

    renderWithProviders(<SettingsPage />);

    // Check that loading spinner is displayed
    await waitFor(() => {
      expect(screen.getByTestId('loading-spinner')).toBeInTheDocument();
    });
  });

  it('should display error state', async () => {
    // Mock error state
    jest.mock('../hooks/useSettings', () => ({
      usePlatformSettings: () => ({
        data: undefined,
        isLoading: false,
        isError: true,
        error: new Error('Failed to load platform settings'),
        refetch: jest.fn(),
      }),
    }));

    renderWithProviders(<SettingsPage />);

    // Check that error alert is displayed
    await waitFor(() => {
      expect(screen.getByText('Failed to load platform settings')).toBeInTheDocument();
    });
  });
});