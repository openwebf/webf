/** @jsxImportSource react */
import React from 'react';
import { cn } from '../../../specs/shadcn/_shared/cn';

type CardProps = React.HTMLAttributes<HTMLDivElement>;

export function Card({ children, className, ...props }: CardProps) {
  return (
    <section {...props} className={cn('shadcn-card', className)}>
      {children}
    </section>
  );
}

export function CardHeader({ children, className, ...props }: CardProps) {
  return (
    <div {...props} className={cn('shadcn-card-header', className)}>
      {children}
    </div>
  );
}

export function CardTitle({ children, className, ...props }: CardProps) {
  return (
    <h2 {...props} className={cn('shadcn-card-title', className)}>
      {children}
    </h2>
  );
}

export function CardDescription({ children, className, ...props }: CardProps) {
  return (
    <p {...props} className={cn('shadcn-card-description', className)}>
      {children}
    </p>
  );
}
