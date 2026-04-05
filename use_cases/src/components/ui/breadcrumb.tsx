import * as React from 'react';
import { cn } from '../../lib/utils';

export const Breadcrumb = React.forwardRef<
  HTMLElement,
  React.HTMLAttributes<HTMLElement>
>(({ className, ...props }, ref) => (
  <nav ref={ref} aria-label="breadcrumb" className={cn('w-full', className)} {...props} />
));

Breadcrumb.displayName = 'Breadcrumb';

export const BreadcrumbList = React.forwardRef<
  HTMLOListElement,
  React.OlHTMLAttributes<HTMLOListElement>
>(({ className, ...props }, ref) => (
  <ol
    ref={ref}
    style={{ listStyleType: 'none', margin: 0, padding: 0 }}
    className={cn('m-0 flex list-none flex-wrap items-center gap-1.5 p-0 text-sm text-zinc-500', className)}
    {...props}
  />
));

BreadcrumbList.displayName = 'BreadcrumbList';

export const BreadcrumbItem = React.forwardRef<
  HTMLLIElement,
  React.LiHTMLAttributes<HTMLLIElement>
>(({ className, ...props }, ref) => (
  <li
    ref={ref}
    style={{ listStyleType: 'none' }}
    className={cn('list-none inline-flex items-center gap-1.5', className)}
    {...props}
  />
));

BreadcrumbItem.displayName = 'BreadcrumbItem';

export const BreadcrumbLink = React.forwardRef<
  HTMLAnchorElement,
  React.AnchorHTMLAttributes<HTMLAnchorElement>
>(({ className, ...props }, ref) => (
  <a
    ref={ref}
    className={cn('transition-colors hover:text-zinc-950', className)}
    {...props}
  />
));

BreadcrumbLink.displayName = 'BreadcrumbLink';

export const BreadcrumbPage = React.forwardRef<
  HTMLSpanElement,
  React.HTMLAttributes<HTMLSpanElement>
>(({ className, ...props }, ref) => (
  <span
    ref={ref}
    role="link"
    aria-disabled="true"
    aria-current="page"
    className={cn('font-medium text-zinc-950', className)}
    {...props}
  />
));

BreadcrumbPage.displayName = 'BreadcrumbPage';

export const BreadcrumbSeparator = React.forwardRef<
  HTMLLIElement,
  React.LiHTMLAttributes<HTMLLIElement>
>(({ className, children = '/', ...props }, ref) => (
  <li
    ref={ref}
    aria-hidden="true"
    style={{ listStyleType: 'none' }}
    className={cn('list-none text-zinc-400', className)}
    {...props}
  >
    {children}
  </li>
));

BreadcrumbSeparator.displayName = 'BreadcrumbSeparator';

export const BreadcrumbEllipsis = React.forwardRef<
  HTMLSpanElement,
  React.HTMLAttributes<HTMLSpanElement>
>(({ className, ...props }, ref) => (
  <span ref={ref} className={cn('inline-flex h-8 w-8 items-center justify-center', className)} {...props}>
    ...
  </span>
));

BreadcrumbEllipsis.displayName = 'BreadcrumbEllipsis';
