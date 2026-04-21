import * as React from 'react';
import { cn } from '../../lib/utils';

export const Skeleton = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn('rounded-md bg-zinc-200/80', className)}
    {...props}
  />
));

Skeleton.displayName = 'Skeleton';
