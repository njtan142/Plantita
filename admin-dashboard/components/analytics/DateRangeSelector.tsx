import { useState } from 'react';
import { 
  Select, 
  SelectContent, 
  SelectItem, 
  SelectTrigger, 
  SelectValue 
} from '@/components/ui/select';
import { Calendar } from 'lucide-react';

interface DateRangeOption {
  value: string;
  label: string;
  days: number;
}

const DATE_RANGE_OPTIONS: DateRangeOption[] = [
  { value: '7', label: 'Last 7 days', days: 7 },
  { value: '30', label: 'Last 30 days', days: 30 },
  { value: '90', label: 'Last 90 days', days: 90 },
  { value: '365', label: 'Last year', days: 365 },
  { value: 'custom', label: 'Custom range', days: 0 },
];

interface DateRangeSelectorProps {
  value?: string;
  onChange?: (value: string) => void;
  placeholder?: string;
}

export function DateRangeSelector({
  value,
  onChange,
  placeholder = 'Select date range'
}: DateRangeSelectorProps) {
  const [selectedValue, setSelectedValue] = useState<string>(value || '30');

  const handleChange = (newValue: string) => {
    setSelectedValue(newValue);
    onChange?.(newValue);
  };

  return (
    <div className="flex items-center gap-2">
      <Calendar className="h-4 w-4 text-muted-foreground" />
      <Select value={selectedValue} onValueChange={handleChange}>
        <SelectTrigger className="w-[180px]">
          <SelectValue placeholder={placeholder} />
        </SelectTrigger>
        <SelectContent>
          {DATE_RANGE_OPTIONS.map((option) => (
            <SelectItem key={option.value} value={option.value}>
              {option.label}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>
    </div>
  );
}