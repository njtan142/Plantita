'use client';

import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { 
  LineChart, 
  Line, 
  BarChart, 
  Bar, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer,
  Legend
} from 'recharts';

interface ChartDataPoint {
  [key: string]: string | number;
}

interface AnalyticsChartProps {
  title: string;
  data: ChartDataPoint[];
  dataKeys: Array<{
    key: string;
    name: string;
    color: string;
  }>;
  chartType?: 'line' | 'bar';
  loading?: boolean;
  xAxisKey?: string;
}

export function AnalyticsChart({
  title,
  data,
  dataKeys,
  chartType = 'line',
  loading = false,
  xAxisKey = 'date'
}: AnalyticsChartProps) {
  if (loading) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>
            <Skeleton className="h-6 w-32" />
          </CardTitle>
        </CardHeader>
        <CardContent>
          <Skeleton className="h-64 w-full" />
        </CardContent>
      </Card>
    );
  }

  if (!data || data.length === 0) {
    return (
      <Card>
        <CardHeader>
          <CardTitle>{title}</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="h-64 flex items-center justify-center text-muted-foreground">
            No data available
          </div>
        </CardContent>
      </Card>
    );
  }

  const renderChart = () => {
    if (chartType === 'bar') {
      return (
        <BarChart data={data}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis 
            dataKey={xAxisKey}
            tick={{ fontSize: 12 }}
            tickFormatter={(value) => {
              if (xAxisKey === 'date') {
                return new Date(value).toLocaleDateString('en-US', {
                  month: 'short',
                  day: 'numeric'
                });
              }
              return value.toString();
            }}
          />
          <YAxis tick={{ fontSize: 12 }} />
          <Tooltip
            labelFormatter={(value) => {
              if (xAxisKey === 'date') {
                return new Date(value).toLocaleDateString();
              }
              return value.toString();
            }}
          />
          <Legend />
          {dataKeys.map((item) => (
            <Bar
              key={item.key}
              dataKey={item.key}
              name={item.name}
              fill={item.color}
              radius={[4, 4, 0, 0]}
            />
          ))}
        </BarChart>
      );
    }

    // Default to line chart
    return (
      <LineChart data={data}>
        <CartesianGrid strokeDasharray="3 3" />
        <XAxis 
          dataKey={xAxisKey}
          tick={{ fontSize: 12 }}
          tickFormatter={(value) => {
            if (xAxisKey === 'date') {
              return new Date(value).toLocaleDateString('en-US', {
                month: 'short',
                day: 'numeric'
              });
            }
            return value.toString();
          }}
        />
        <YAxis tick={{ fontSize: 12 }} />
        <Tooltip
          labelFormatter={(value) => {
            if (xAxisKey === 'date') {
              return new Date(value).toLocaleDateString();
            }
            return value.toString();
          }}
        />
        <Legend />
        {dataKeys.map((item) => (
          <Line
            key={item.key}
            type="monotone"
            dataKey={item.key}
            name={item.name}
            stroke={item.color}
            strokeWidth={2}
            dot={{ fill: item.color, strokeWidth: 2, r: 4 }}
            activeDot={{ r: 6 }}
          />
        ))}
      </LineChart>
    );
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle>{title}</CardTitle>
      </CardHeader>
      <CardContent>
        <div className="h-64">
          <ResponsiveContainer width="100%" height="100%">
            {renderChart()}
          </ResponsiveContainer>
        </div>
      </CardContent>
    </Card>
  );
}