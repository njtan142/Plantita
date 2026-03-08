'use client';

import { useState, useEffect } from 'react';
import { Media, MediaEngagement } from '@/types/api';
import { mediaContentService } from '@/services/mediaContentService';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { 
  BarChart,
  Bar,
  LineChart,
  Line,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer
} from 'recharts';
import { 
  Eye,
  Heart,
  MessageCircle,
  Share2,
  TrendingUp,
  BarChartIcon,
  PieChartIcon
} from 'lucide-react';
import { LoadingSpinner } from '@/components/layout/LoadingSpinner';
import { Alert, AlertTitle, AlertDescription } from '@/components/ui/alert';

interface MediaEngagementMetricsProps {
  mediaId: string;
}

// Define chart types
type ChartType = 'bar' | 'line' | 'pie';

export function MediaEngagementMetrics({ mediaId }: MediaEngagementMetricsProps) {
  const [engagement, setEngagement] = useState<MediaEngagement | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [chartType, setChartType] = useState<ChartType>('bar');

  useEffect(() => {
    fetchEngagementMetrics();
  }, [mediaId]);

  const fetchEngagementMetrics = async () => {
    try {
      setLoading(true);
      setError(null);

      const response = await mediaContentService.getMediaEngagement(mediaId);
      if (response.success && response.data) {
        setEngagement(response.data);
      } else {
        throw new Error(response.message || 'Failed to fetch engagement metrics');
      }
    } catch (err) {
      console.error('Error fetching engagement metrics:', err);
      setError(err instanceof Error ? err.message : 'An unexpected error occurred');
    } finally {
      setLoading(false);
    }
  };

  // Prepare data for charts
  const chartData = engagement ? [
    { name: 'Views', value: engagement.views },
    { name: 'Likes', value: engagement.likes },
    { name: 'Comments', value: engagement.comments },
    { name: 'Shares', value: engagement.shares }
  ] : [];

  // Colors for charts
  const COLORS = ['#3b82f6', '#ef4444', '#10b981', '#f59e0b'];

  if (loading) {
    return (
      <div className="flex items-center justify-center py-12">
        <LoadingSpinner size="lg" />
      </div>
    );
  }

  if (error) {
    return (
      <Alert variant="destructive">
        <AlertTitle>Error</AlertTitle>
        <AlertDescription>{error}</AlertDescription>
      </Alert>
    );
  }

  if (!engagement) {
    return (
      <Alert variant="destructive">
        <AlertTitle>Engagement data not found</AlertTitle>
        <AlertDescription>No engagement data available for the provided media ID.</AlertDescription>
      </Alert>
    );
  }

  return (
    <Card>
      <CardHeader>
        <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <CardTitle>Engagement Metrics</CardTitle>
          <div className="flex items-center space-x-2">
            <span className="text-sm text-gray-500">Chart Type:</span>
            <Button
              variant={chartType === 'bar' ? 'default' : 'outline'}
              size="sm"
              onClick={() => setChartType('bar')}
            >
              <BarChartIcon className="h-4 w-4 mr-1" />
              Bar
            </Button>
            <Button
              variant={chartType === 'line' ? 'default' : 'outline'}
              size="sm"
              onClick={() => setChartType('line')}
            >
              <TrendingUp className="h-4 w-4 mr-1" />
              Line
            </Button>
            <Button
              variant={chartType === 'pie' ? 'default' : 'outline'}
              size="sm"
              onClick={() => setChartType('pie')}
            >
              <PieChartIcon className="h-4 w-4 mr-1" />
              Pie
            </Button>
          </div>
        </div>
      </CardHeader>
      <CardContent>
        <div className="space-y-6">
          {/* Summary Stats */}
          <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
            <div className="flex flex-col items-center p-4 bg-gray-50 rounded-lg">
              <Eye className="h-6 w-6 text-blue-500 mb-2" />
              <span className="text-2xl font-bold">{engagement.views}</span>
              <span className="text-sm text-gray-500">Views</span>
            </div>
            <div className="flex flex-col items-center p-4 bg-gray-50 rounded-lg">
              <Heart className="h-6 w-6 text-red-500 mb-2" />
              <span className="text-2xl font-bold">{engagement.likes}</span>
              <span className="text-sm text-gray-500">Likes</span>
            </div>
            <div className="flex flex-col items-center p-4 bg-gray-50 rounded-lg">
              <MessageCircle className="h-6 w-6 text-green-500 mb-2" />
              <span className="text-2xl font-bold">{engagement.comments}</span>
              <span className="text-sm text-gray-500">Comments</span>
            </div>
            <div className="flex flex-col items-center p-4 bg-gray-50 rounded-lg">
              <Share2 className="h-6 w-6 text-yellow-500 mb-2" />
              <span className="text-2xl font-bold">{engagement.shares}</span>
              <span className="text-sm text-gray-500">Shares</span>
            </div>
            <div className="flex flex-col items-center p-4 bg-gray-50 rounded-lg">
              <div className="h-6 w-6 mb-2 flex items-center justify-center">
                <span className="text-lg">%</span>
              </div>
              <span className="text-2xl font-bold">
                {Math.round(engagement.engagementRate * 100)}%
              </span>
              <span className="text-sm text-gray-500">Engagement</span>
            </div>
          </div>

          {/* Chart Visualization */}
          <div className="h-80">
            <ResponsiveContainer width="100%" height="100%">
              {chartType === 'bar' ? (
                <BarChart data={chartData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="name" />
                  <YAxis />
                  <Tooltip />
                  <Legend />
                  <Bar dataKey="value" fill="#3b82f6" />
                </BarChart>
              ) : chartType === 'line' ? (
                <LineChart data={chartData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="name" />
                  <YAxis />
                  <Tooltip />
                  <Legend />
                  <Line 
                    type="monotone" 
                    dataKey="value" 
                    stroke="#3b82f6" 
                    activeDot={{ r: 8 }} 
                  />
                </LineChart>
              ) : (
                <PieChart>
                  <Pie
                    data={chartData}
                    cx="50%"
                    cy="50%"
                    labelLine={true}
                    label={({ name, percent }) => `${name}: ${(percent * 100).toFixed(0)}%`}
                    outerRadius={80}
                    fill="#8884d8"
                    dataKey="value"
                  >
                    {chartData.map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip />
                  <Legend />
                </PieChart>
              )}
            </ResponsiveContainer>
          </div>

          {/* Engagement Rate Info */}
          <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
            <div className="flex items-center">
              <TrendingUp className="h-5 w-5 text-blue-500 mr-2" />
              <h3 className="font-medium">Engagement Rate</h3>
            </div>
            <p className="mt-2 text-sm text-gray-700">
              Your content's engagement rate is <span className="font-bold">
                {Math.round(engagement.engagementRate * 100)}%
              </span>. This measures how actively users interact with your content.
            </p>
            <div className="mt-2">
              <Badge variant={engagement.engagementRate > 0.5 ? 'default' : 'secondary'}>
                {engagement.engagementRate > 0.5 ? 'High Engagement' : 
                 engagement.engagementRate > 0.2 ? 'Moderate Engagement' : 'Low Engagement'}
              </Badge>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}