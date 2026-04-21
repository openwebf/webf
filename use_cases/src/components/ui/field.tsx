import * as React from 'react';
import { cn } from '../../lib/utils';

export const Field = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement> & {
    orientation?: 'vertical' | 'horizontal';
  }
>(({ className, orientation = 'vertical', ...props }, ref) => (
  <div
    ref={ref}
    className={cn(
      orientation === 'horizontal' ? 'flex items-start gap-3' : 'grid gap-2',
      className,
    )}
    {...props}
  />
));

Field.displayName = 'Field';

export const FieldGroup = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div ref={ref} className={cn('grid gap-4', className)} {...props} />
));

FieldGroup.displayName = 'FieldGroup';

export const FieldContent = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div ref={ref} className={cn('grid gap-1.5', className)} {...props} />
));

FieldContent.displayName = 'FieldContent';

export const FieldLabel = React.forwardRef<
  HTMLLabelElement,
  React.LabelHTMLAttributes<HTMLLabelElement>
>(({ className, ...props }, ref) => (
  <label
    ref={ref}
    className={cn('text-sm font-medium leading-none text-zinc-900', className)}
    {...props}
  />
));

FieldLabel.displayName = 'FieldLabel';

export const FieldDescription = React.forwardRef<
  HTMLParagraphElement,
  React.HTMLAttributes<HTMLParagraphElement>
>(({ className, ...props }, ref) => (
  <p ref={ref} className={cn('text-sm text-zinc-500', className)} {...props} />
));

FieldDescription.displayName = 'FieldDescription';

export const FieldSet = React.forwardRef<
  HTMLFieldSetElement,
  React.FieldsetHTMLAttributes<HTMLFieldSetElement>
>(({ className, ...props }, ref) => (
  <fieldset ref={ref} className={cn('grid gap-3', className)} {...props} />
));

FieldSet.displayName = 'FieldSet';

export const FieldLegend = React.forwardRef<
  HTMLLegendElement,
  React.HTMLAttributes<HTMLLegendElement>
>(({ className, ...props }, ref) => (
  <legend
    ref={ref}
    className={cn('text-sm font-medium leading-none text-zinc-900', className)}
    {...props}
  />
));

FieldLegend.displayName = 'FieldLegend';
