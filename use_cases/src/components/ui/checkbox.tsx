import * as React from 'react';
import { cn } from '../../lib/utils';

export interface CheckboxProps
  extends Omit<React.ButtonHTMLAttributes<HTMLButtonElement>, 'onChange'> {
  checked?: boolean;
  defaultChecked?: boolean;
  onCheckedChange?: (checked: boolean) => void;
}

export const Checkbox = React.forwardRef<HTMLButtonElement, CheckboxProps>(
  ({ className, checked, defaultChecked = false, onCheckedChange, disabled, ...props }, ref) => {
    const [internalChecked, setInternalChecked] = React.useState(defaultChecked);
    const isChecked = checked ?? internalChecked;

    return (
      <button
        ref={ref}
        type="button"
        role="checkbox"
        aria-checked={isChecked}
        disabled={disabled}
        data-state={isChecked ? 'checked' : 'unchecked'}
        className={cn(
          'inline-flex h-4 w-4 shrink-0 items-center justify-center rounded-[4px] border border-zinc-300 bg-white text-white shadow-sm transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-zinc-300 disabled:cursor-not-allowed disabled:opacity-50',
          isChecked && 'border-zinc-900 bg-zinc-900',
          className,
        )}
        onClick={() => {
          const next = !isChecked;
          if (checked === undefined) {
            setInternalChecked(next);
          }
          onCheckedChange?.(next);
        }}
        {...props}
      >
        <span className={cn('text-[10px] leading-none', !isChecked && 'opacity-0')}>
          ✓
        </span>
      </button>
    );
  },
);

Checkbox.displayName = 'Checkbox';
