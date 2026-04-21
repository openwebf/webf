import * as React from 'react';
import { cn } from '../../lib/utils';

export const Progress = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement> & {
    value?: number;
  }
>(({ className, value = 0, ...props }, ref) => {
  const normalized = Math.max(0, Math.min(100, value));

  return (
    <div
      ref={ref}
      role="progressbar"
      aria-valuemin={0}
      aria-valuemax={100}
      aria-valuenow={normalized}
      className={cn('h-2 w-full overflow-hidden rounded-full bg-zinc-200', className)}
      {...props}
    >
      <div
        className="h-full rounded-full bg-zinc-900 transition-[width]"
        style={{ width: `${normalized}%` }}
      />
    </div>
  );
});

Progress.displayName = 'Progress';

export const ProgressLabel = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn('text-sm font-medium leading-none text-zinc-900', className)}
    {...props}
  />
));

ProgressLabel.displayName = 'ProgressLabel';

export const ProgressValue = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div ref={ref} className={cn('text-sm text-zinc-500', className)} {...props} />
));

ProgressValue.displayName = 'ProgressValue';
