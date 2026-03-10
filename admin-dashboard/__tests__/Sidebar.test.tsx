import { render, screen, fireEvent } from '@testing-library/react';
import { Sidebar } from '../components/layout/Sidebar';
import { usePathname } from 'next/navigation';

// Mock next/navigation
jest.mock('next/navigation', () => ({
  usePathname: jest.fn(),
}));

// Mock Lucide icons
jest.mock('lucide-react', () => ({
  LayoutDashboard: () => <div data-testid="layout-dashboard-icon" />,
  Users: () => <div data-testid="users-icon" />,
  Image: () => <div data-testid="image-icon" />,
  BarChart3: () => <div data-testid="bar-chart-icon" />,
  Settings: () => <div data-testid="settings-icon" />,
  X: () => <div data-testid="x-icon" />,
}));

describe('Sidebar', () => {
  const mockUsePathname = usePathname as jest.Mock;

  beforeEach(() => {
    jest.clearAllMocks();
    mockUsePathname.mockReturnValue('/dashboard');
  });

  describe('Rendering', () => {
    it('should render the header and footer', () => {
      render(<Sidebar />);
      expect(screen.getByText('Admin Panel')).toBeInTheDocument();
      expect(screen.getByText('© 2024 Plantita Admin')).toBeInTheDocument();
    });

    it('should render all navigation items', () => {
      render(<Sidebar />);
      const navItems = ['Dashboard', 'Users', 'Media', 'Analytics', 'Settings'];
      navItems.forEach((item) => {
        expect(screen.getByText(item)).toBeInTheDocument();
      });
    });

    it('should not render the close button if onClose is not provided', () => {
      render(<Sidebar />);
      expect(screen.queryByTestId('x-icon')).not.toBeInTheDocument();
    });

    it('should render the close button if onClose is provided', () => {
      render(<Sidebar onClose={jest.fn()} />);
      expect(screen.getByTestId('x-icon')).toBeInTheDocument();
    });
  });

  describe('Active States', () => {
    it('should set the exact match path as active (Dashboard)', () => {
      mockUsePathname.mockReturnValue('/dashboard');
      render(<Sidebar />);

      const dashboardLink = screen.getByText('Dashboard').closest('a');
      expect(dashboardLink).toHaveClass('bg-blue-100', 'text-blue-700', 'border-r-2', 'border-blue-700');

      const usersLink = screen.getByText('Users').closest('a');
      expect(usersLink).toHaveClass('text-gray-600');
      expect(usersLink).not.toHaveClass('bg-blue-100');
    });

    it('should set a partial match path as active (Users)', () => {
      mockUsePathname.mockReturnValue('/dashboard/users');
      render(<Sidebar />);

      const usersLink = screen.getByText('Users').closest('a');
      expect(usersLink).toHaveClass('bg-blue-100', 'text-blue-700', 'border-r-2', 'border-blue-700');

      const dashboardLink = screen.getByText('Dashboard').closest('a');
      expect(dashboardLink).toHaveClass('text-gray-600');
      expect(dashboardLink).not.toHaveClass('bg-blue-100');
    });
  });

  describe('Interactions', () => {
    it('should call onClose when the close button is clicked', () => {
      const mockOnClose = jest.fn();
      render(<Sidebar onClose={mockOnClose} />);

      const closeButton = screen.getByTestId('x-icon').closest('button');
      if (closeButton) {
        fireEvent.click(closeButton);
      }

      expect(mockOnClose).toHaveBeenCalledTimes(1);
    });

    it('should call onClose when a navigation link is clicked', () => {
      const mockOnClose = jest.fn();
      render(<Sidebar onClose={mockOnClose} />);

      const usersLink = screen.getByText('Users').closest('a');
      if (usersLink) {
        fireEvent.click(usersLink);
      }

      expect(mockOnClose).toHaveBeenCalledTimes(1);
    });
  });
});
