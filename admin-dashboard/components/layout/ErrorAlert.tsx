import { AlertCircle, CheckCircle, Info, XCircle } from 'lucide-react';
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';

const alertVariants = cva(
  'relative w-full rounded-lg border p-4 [&>svg~*]:pl-7 [&>svg+div]:translate-y-[-3px] [&>svg]:absolute [&>svg]:left-4 [&>svg]:top-4 [&>svg]:text-foreground',
  {
    variants: {
      variant: {
        default: 'bg-background text-foreground',
        destructive:
          'border-destructive/50 text-destructive dark:border-destructive [&>svg]:text-destructive',
        success:
          'border-green-500/50 text-green-700 dark:border-green-500 [&>svg]:text-green-500',
        warning:
          'border-yellow-500/50 text-yellow-700 dark:border-yellow-500 [&>svg]:text-yellow-500',
        info: 'border-blue-500/50 text-blue-700 dark:border-blue-500 [&>svg]:text-blue-500',
      },
    },
    defaultVariants: {
      variant: 'default',
    },
  }
);

const AlertTitle = cva('mb-1 font-medium leading-none tracking-tight', {
  variants: {
    variant: {
      default: 'text-foreground',
      destructive: 'text-destructive',
      success: 'text-green-700',
      warning: 'text-yellow-700',
      info: 'text-blue-700',
    },
  },
  defaultVariants: {
    variant: 'default',
  },
});

const AlertDescription = cva('text-sm [&_p]:leading-relaxed', {
  variants: {
    variant: {
      default: 'text-foreground',
      destructive: 'text-destructive/80',
      success: 'text-green-700/80',
      warning: 'text-yellow-700/80',
      info: 'text-blue-700/80',
    },
  },
  defaultVariants: {
    variant: 'default',
  },
});

interface AlertProps
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof alertVariants> {}

const ErrorAlert = React.forwardRef<
  HTMLDivElement,
  AlertProps & {
    title?: string;
    message?: string;
  }
>(({ className, variant, title, message, ...props }, ref) => (
  <div
    ref={ref}
    role="alert"
    className={cn(alertVariants({ variant }), className)}
    {...props}
  >
    {variant === 'destructive' && <XCircle className="h-4 w-4" />}
    {variant === 'success' && <CheckCircle className="h-4 w-4" />}
    {variant === 'warning' && <AlertCircle className="h-4 w-4" />}
    {variant === 'info' && <Info className="h-4 w-4" />}
    {title && (
      <h5 className={cn(AlertTitle({ variant }), 'text-base')}>
        {title}
      </h5>
    )}
    {message && (
      <div className={cn(AlertDescription({ variant }))}>
        {message}
      </div>
    )}
    {props.children}
  </div>
));
ErrorAlert.displayName = 'ErrorAlert';

export { ErrorAlert };