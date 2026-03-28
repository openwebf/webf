import * as React from 'react';
import { cn } from '../../lib/utils';

type ButtonVariant =
  | 'default'
  | 'outline'
  | 'ghost'
  | 'destructive'
  | 'secondary'
  | 'link';

type ButtonSize =
  | 'default'
  | 'xs'
  | 'sm'
  | 'lg'
  | 'icon'
  | 'icon-xs'
  | 'icon-sm'
  | 'icon-lg';

const variantClasses: Record<ButtonVariant, string> = {
  default: 'bg-zinc-900 text-white hover:bg-zinc-800',
  outline: 'border border-zinc-200 bg-white text-zinc-950 hover:bg-zinc-50',
  ghost: 'bg-transparent text-zinc-700 hover:bg-zinc-100 hover:text-zinc-950',
  destructive: 'bg-red-600 text-white hover:bg-red-500',
  secondary: 'bg-zinc-100 text-zinc-900 hover:bg-zinc-200',
  link: 'bg-transparent px-0 text-zinc-900 underline-offset-4 hover:underline',
};

const sizeClasses: Record<ButtonSize, string> = {
  default: 'h-9 px-4 py-2 text-sm',
  xs: 'h-7 rounded-md px-2.5 text-xs',
  sm: 'h-8 rounded-md px-3 text-sm',
  lg: 'h-10 rounded-md px-6 text-sm',
  icon: 'h-9 w-9',
  'icon-xs': 'h-7 w-7 rounded-md',
  'icon-sm': 'h-8 w-8 rounded-md',
  'icon-lg': 'h-10 w-10 rounded-md',
};

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  size?: ButtonSize;
}

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  (
    {
      className,
      variant = 'default',
      size = 'default',
      type = 'button',
      ...props
    },
    ref,
  ) => (
    <button
      ref={ref}
      type={type}
      className={cn(
        'inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-zinc-300 disabled:pointer-events-none disabled:opacity-50',
        variantClasses[variant],
        sizeClasses[size],
        className,
      )}
      {...props}
    />
  ),
);

Button.displayName = 'Button';
