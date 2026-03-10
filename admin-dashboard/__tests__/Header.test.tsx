import { render, screen, fireEvent } from '@testing-library/react';
import { Header } from '../components/layout/Header';

// Mock Lucide icons
jest.mock('lucide-react', () => ({
  Menu: () => <div data-testid="menu-icon" />,
  Bell: () => <div data-testid="bell-icon" />,
  User: () => <div data-testid="user-icon" />,
  LogOut: () => <div data-testid="logout-icon" />,
  Settings: () => <div data-testid="settings-icon" />,
}));

describe('Header', () => {
  const mockOnMenuClick = jest.fn();

  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('Rendering', () => {
    it('should render the brand name', () => {
      render(<Header />);
      expect(screen.getByText('Plantita Admin')).toBeInTheDocument();
    });

    it('should render the notifications button with badge', () => {
      render(<Header />);
      expect(screen.getByTestId('bell-icon')).toBeInTheDocument();
      expect(screen.getByText('3')).toBeInTheDocument(); // Badge count
    });

    it('should render the user avatar with fallback', () => {
      render(<Header />);
      // User name is 'Admin User', fallback should be 'AU'
      expect(screen.getByText('AU')).toBeInTheDocument();
    });
  });

  describe('Interactions', () => {
    it('should call onMenuClick when mobile menu button is clicked', () => {
      render(<Header onMenuClick={mockOnMenuClick} />);

      // The menu button is the one with the Menu icon and lg:hidden class
      const menuButton = screen.getByTestId('menu-icon').closest('button');
      if (menuButton) {
        fireEvent.click(menuButton);
      }

      expect(mockOnMenuClick).toHaveBeenCalledTimes(1);
    });

    it('should open user menu when avatar is clicked', () => {
      render(<Header />);

      const avatarButton = screen.getByText('AU').closest('button');
      if (avatarButton) {
        fireEvent.click(avatarButton);
      }

      // Check if dropdown content is visible
      expect(screen.getByText('Admin User')).toBeInTheDocument();
      expect(screen.getByText('admin@plantita.com')).toBeInTheDocument();
      expect(screen.getByText('Profile')).toBeInTheDocument();
      expect(screen.getByText('Settings')).toBeInTheDocument();
      expect(screen.getByText('Log out')).toBeInTheDocument();
    });

    it('should call handleLogout when Log out is clicked', () => {
      const consoleSpy = jest.spyOn(console, 'log').mockImplementation();
      render(<Header />);

      // Open the menu first
      const avatarButton = screen.getByText('AU').closest('button');
      if (avatarButton) {
        fireEvent.click(avatarButton);
      }

      const logoutButton = screen.getByText('Log out').closest('div[role="menuitem"]');
      if (logoutButton) {
        fireEvent.click(logoutButton);
      }

      expect(consoleSpy).toHaveBeenCalledWith('Logout clicked');
      consoleSpy.mockRestore();
    });
  });
});
