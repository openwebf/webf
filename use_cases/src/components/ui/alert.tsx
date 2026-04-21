import * as React from 'react';
import { cn } from '../../lib/utils';

type AlertVariant = 'default' | 'destructive';

const variantClasses: Record<AlertVariant, string> = {
  default: 'border-zinc-200 bg-white text-zinc-950',
  destructive: 'border-red-200 bg-red-50 text-red-950',
};

export const Alert = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement> & {
    variant?: AlertVariant;
  }
>(({ className, variant = 'default', ...props }, ref) => (
  <div
    ref={ref}
    role="alert"
    className={cn(
      'grid gap-2 rounded-xl border p-4 shadow-sm',
      variantClasses[variant],
      className,
    )}
    {...props}
  />
));

Alert.displayName = 'Alert';

export const AlertTitle = React.forwardRef<
  HTMLHeadingElement,
  React.HTMLAttributes<HTMLHeadingElement>
>(({ className, ...props }, ref) => (
  <h5 ref={ref} className={cn('text-sm font-semibold', className)} {...props} />
));

AlertTitle.displayName = 'AlertTitle';

export const AlertDescription = React.forwardRef<
  HTMLParagraphElement,
  React.HTMLAttributes<HTMLParagraphElement>
>(({ className, ...props }, ref) => (
  <p ref={ref} className={cn('text-sm leading-6 text-zinc-600', className)} {...props} />
));

AlertDescription.displayName = 'AlertDescription';

export const AlertAction = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div ref={ref} className={cn('mt-1 flex justify-end', className)} {...props} />
));

AlertAction.displayName = 'AlertAction';
