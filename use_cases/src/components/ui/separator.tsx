import * as React from 'react';
import { cn } from '../../lib/utils';

export interface SeparatorProps extends React.HTMLAttributes<HTMLDivElement> {
  orientation?: 'horizontal' | 'vertical';
}

export const Separator = React.forwardRef<HTMLDivElement, SeparatorProps>(
  ({ className, orientation = 'horizontal', ...props }, ref) => (
    <div
      ref={ref}
      role="separator"
      aria-orientation={orientation}
      className={cn(
        orientation === 'horizontal' ? 'h-px w-full bg-zinc-200' : 'h-full w-px shrink-0 bg-zinc-200',
        className,
      )}
      {...props}
    />
  ),
);

Separator.displayName = 'Separator';
