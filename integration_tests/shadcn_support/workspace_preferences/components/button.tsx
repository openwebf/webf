/** @jsxImportSource react */
import React from 'react';
import { cn } from '../../../specs/shadcn/_shared/cn';

type ButtonProps = React.ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: 'default' | 'outline';
};

export function Button({ className, type = 'button', variant = 'default', ...props }: ButtonProps) {
  return (
    <button
      {...props}
      className={cn(variant === 'default' ? 'shadcn-probe-button' : 'shadcn-probe-button-alt', className)}
      type={type}
    />
  );
}
