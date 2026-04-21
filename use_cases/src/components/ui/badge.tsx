/** @jsxImportSource react */
import * as React from 'react';
import { cn } from '../../lib/utils';

type BadgeVariant = 'default' | 'secondary' | 'destructive' | 'outline';

const variantClasses: Record<BadgeVariant, string> = {
  default: 'border-transparent bg-zinc-900 text-white',
  secondary: 'border-transparent bg-zinc-100 text-zinc-900',
  destructive: 'border-transparent bg-red-600 text-white',
  outline: 'border-zinc-500 bg-white text-zinc-800',
};

export interface BadgeProps extends React.HTMLAttributes<HTMLDivElement> {
  variant?: BadgeVariant;
}

export const Badge = React.forwardRef<HTMLDivElement, BadgeProps>(
  ({ className, variant = 'default', ...props }, ref) => (
    <div
      ref={ref}
      className={cn(
        'inline-flex shrink-0 whitespace-nowrap items-center rounded-full border px-2.5 py-0.5 text-xs font-semibold transition-colors',
        variantClasses[variant],
        className,
      )}
      {...props}
    />
  ),
);

Badge.displayName = 'Badge';
