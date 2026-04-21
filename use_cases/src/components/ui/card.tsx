/** @jsxImportSource react */
import * as React from 'react';
import { cn } from '../../lib/utils';

export const Card = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn(
      'min-w-0 rounded-xl border border-zinc-200 bg-white text-zinc-950 shadow-sm',
      className,
    )}
    {...props}
  />
));

Card.displayName = 'Card';

export const CardHeader = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn(
      'min-w-0 grid grid-cols-[1fr_auto] items-start gap-x-4 gap-y-1.5 p-6 pb-0',
      className,
    )}
    {...props}
  />
));

CardHeader.displayName = 'CardHeader';

export const CardTitle = React.forwardRef<
  HTMLHeadingElement,
  React.HTMLAttributes<HTMLHeadingElement>
>(({ className, ...props }, ref) => (
  <h3
    ref={ref}
    className={cn(
      'col-start-1 min-w-0 text-base font-semibold leading-none tracking-tight',
      className,
    )}
    {...props}
  />
));

CardTitle.displayName = 'CardTitle';

export const CardDescription = React.forwardRef<
  HTMLParagraphElement,
  React.HTMLAttributes<HTMLParagraphElement>
>(({ className, ...props }, ref) => (
  <p
    ref={ref}
    className={cn(
      'col-start-1 min-w-0 whitespace-normal break-words text-sm leading-6 text-zinc-500',
      className,
    )}
    {...props}
  />
));

CardDescription.displayName = 'CardDescription';

export const CardAction = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn('col-start-2 row-span-2 min-w-fit justify-self-end self-start', className)}
    {...props}
  />
));

CardAction.displayName = 'CardAction';

export const CardContent = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div ref={ref} className={cn('min-w-0 p-6 pt-6', className)} {...props} />
));

CardContent.displayName = 'CardContent';

export const CardFooter = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn('flex items-center gap-2 p-6 pt-0', className)}
    {...props}
  />
));

CardFooter.displayName = 'CardFooter';
