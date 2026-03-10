import { render, screen } from '@testing-library/react';
import { AnalyticsChart } from '../components/analytics/AnalyticsChart';

// Mock Recharts to avoid SVG/Canvas rendering issues in JSDOM
jest.mock('recharts', () => ({
  ResponsiveContainer: ({ children }: any) => <div data-testid="responsive-container">{children}</div>,
  LineChart: ({ children }: any) => <div data-testid="line-chart">{children}</div>,
  BarChart: ({ children }: any) => <div data-testid="bar-chart">{children}</div>,
  Line: () => <div data-testid="line" />,
  Bar: () => <div data-testid="bar" />,
  XAxis: () => <div data-testid="x-axis" />,
  YAxis: () => <div data-testid="y-axis" />,
  CartesianGrid: () => <div data-testid="cartesian-grid" />,
  Tooltip: () => <div data-testid="tooltip" />,
  Legend: () => <div data-testid="legend" />,
}));

describe('AnalyticsChart', () => {
  const defaultProps = {
    title: 'Test Chart',
    data: [
      { date: '2023-01-01', value: 100 },
      { date: '2023-01-02', value: 200 }
    ],
    dataKeys: [
      { key: 'value', name: 'Value', color: '#000000' }
    ]
  };

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('Rendering States', () => {
    it('should render loading skeleton when loading prop is true', () => {
      const { container } = render(<AnalyticsChart {...defaultProps} loading={true} />);

      // Skeletons don't have distinct roles by default in this setup,
      // but they are rendered within the Card
      // We can look for the card layout rendering the skeletons via container.querySelector.
      const card = container.querySelector('[data-slot="card"]');
      expect(card).toBeInTheDocument();
      // The actual title text shouldn't be rendered in loading state
      expect(screen.queryByText('Test Chart')).not.toBeInTheDocument();

      // We can select the skeleton elements by finding elements with the "animate-pulse" or similar class
      // typically used in Skeleton.
      const skeletons = container.querySelectorAll('.animate-pulse');
      expect(skeletons.length).toBeGreaterThan(0);
    });

    it('should render empty state message when data is empty', () => {
      render(<AnalyticsChart {...defaultProps} data={[]} />);

      expect(screen.getByText('Test Chart')).toBeInTheDocument();
      expect(screen.getByText('No data available')).toBeInTheDocument();
      expect(screen.queryByTestId('responsive-container')).not.toBeInTheDocument();
    });

    it('should render empty state message when data is undefined', () => {
      render(<AnalyticsChart {...defaultProps} data={undefined as any} />);

      expect(screen.getByText('Test Chart')).toBeInTheDocument();
      expect(screen.getByText('No data available')).toBeInTheDocument();
      expect(screen.queryByTestId('responsive-container')).not.toBeInTheDocument();
    });
  });

  describe('Chart Types', () => {
    it('should render a line chart by default', () => {
      render(<AnalyticsChart {...defaultProps} />);

      expect(screen.getByText('Test Chart')).toBeInTheDocument();
      expect(screen.getByTestId('responsive-container')).toBeInTheDocument();
      expect(screen.getByTestId('line-chart')).toBeInTheDocument();
      expect(screen.getByTestId('line')).toBeInTheDocument();
      expect(screen.queryByTestId('bar-chart')).not.toBeInTheDocument();
    });

    it('should render a line chart when chartType="line"', () => {
      render(<AnalyticsChart {...defaultProps} chartType="line" />);

      expect(screen.getByTestId('line-chart')).toBeInTheDocument();
      expect(screen.getByTestId('line')).toBeInTheDocument();
    });

    it('should render a bar chart when chartType="bar"', () => {
      render(<AnalyticsChart {...defaultProps} chartType="bar" />);

      expect(screen.getByText('Test Chart')).toBeInTheDocument();
      expect(screen.getByTestId('responsive-container')).toBeInTheDocument();
      expect(screen.getByTestId('bar-chart')).toBeInTheDocument();
      expect(screen.getByTestId('bar')).toBeInTheDocument();
      expect(screen.queryByTestId('line-chart')).not.toBeInTheDocument();
    });
  });
});
