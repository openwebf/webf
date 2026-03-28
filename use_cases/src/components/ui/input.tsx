import * as React from 'react';
import { cn } from '../../lib/utils';

export const Input = React.forwardRef<
  HTMLInputElement,
  React.InputHTMLAttributes<HTMLInputElement>
>(({ className, type = 'text', ...props }, ref) => (
  <input
    ref={ref}
    type={type}
    className={cn(
      'flex h-9 w-full min-w-0 rounded-md border border-zinc-200 bg-white px-3 py-1 text-sm text-zinc-950 shadow-sm transition-colors placeholder:text-zinc-400 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-zinc-300 disabled:cursor-not-allowed disabled:opacity-50',
      className,
    )}
    {...props}
  />
));

Input.displayName = 'Input';
