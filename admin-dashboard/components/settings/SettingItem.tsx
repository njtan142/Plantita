import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Switch } from '@/components/ui/switch';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Textarea } from '@/components/ui/textarea';

interface SettingItemProps {
  id: string;
  label: string;
  description?: string;
  type: 'text' | 'number' | 'email' | 'password' | 'textarea' | 'checkbox' | 'select';
  value: string | number | boolean;
  options?: Array<{ value: string; label: string }>;
  placeholder?: string;
  onChange: (value: string | number | boolean) => void;
  disabled?: boolean;
}

export function SettingItem({
  id,
  label,
  description,
  type,
  value,
  options,
  placeholder,
  onChange,
  disabled = false
}: SettingItemProps) {
  const renderControl = () => {
    switch (type) {
      case 'checkbox':
        return (
          <Switch
            id={id}
            checked={value as boolean}
            onCheckedChange={onChange}
            disabled={disabled}
          />
        );
      
      case 'select':
        return (
          <Select
            value={value as string}
            onValueChange={onChange}
            disabled={disabled}
          >
            <SelectTrigger id={id}>
              <SelectValue placeholder={placeholder} />
            </SelectTrigger>
            <SelectContent>
              {options?.map((option) => (
                <SelectItem key={option.value} value={option.value}>
                  {option.label}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        );
      
      case 'textarea':
        return (
          <Textarea
            id={id}
            value={value as string}
            onChange={(e) => onChange(e.target.value)}
            placeholder={placeholder}
            disabled={disabled}
            rows={4}
          />
        );
      
      case 'number':
        return (
          <Input
            id={id}
            type="number"
            value={value as number}
            onChange={(e) => onChange(Number(e.target.value))}
            placeholder={placeholder}
            disabled={disabled}
          />
        );
      
      default:
        return (
          <Input
            id={id}
            type={type}
            value={value as string}
            onChange={(e) => onChange(e.target.value)}
            placeholder={placeholder}
            disabled={disabled}
          />
        );
    }
  };

  return (
    <div className="space-y-2">
      <div className="flex items-center justify-between">
        <div>
          <Label htmlFor={id} className="text-sm font-medium">
            {label}
          </Label>
          {description && (
            <p className="text-sm text-muted-foreground">
              {description}
            </p>
          )}
        </div>
        {type === 'checkbox' && (
          <div className="ml-4">
            {renderControl()}
          </div>
        )}
      </div>
      {type !== 'checkbox' && (
        <div>
          {renderControl()}
        </div>
      )}
    </div>
  );
}