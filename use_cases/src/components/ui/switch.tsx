import * as React from 'react';
import { cn } from '../../lib/utils';

export interface SwitchProps
  extends Omit<React.ButtonHTMLAttributes<HTMLButtonElement>, 'onChange'> {
  checked?: boolean;
  defaultChecked?: boolean;
  onCheckedChange?: (checked: boolean) => void;
}

export const Switch = React.forwardRef<HTMLButtonElement, SwitchProps>(
  ({ className, checked, defaultChecked = false, onCheckedChange, disabled, ...props }, ref) => {
    const [internalChecked, setInternalChecked] = React.useState(defaultChecked);
    const isChecked = checked ?? internalChecked;

    return (
      <button
        ref={ref}
        type="button"
        role="switch"
        aria-checked={isChecked}
        disabled={disabled}
        data-state={isChecked ? 'checked' : 'unchecked'}
        className={cn(
          'inline-flex h-6 w-11 shrink-0 items-center rounded-full border border-transparent bg-zinc-200 px-0.5 transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-zinc-300 disabled:cursor-not-allowed disabled:opacity-50',
          isChecked && 'bg-zinc-900',
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
        <span
          className={cn(
            'h-5 w-5 rounded-full bg-white shadow-sm transition-transform',
            isChecked && 'translate-x-5',
          )}
        />
      </button>
    );
  },
);

Switch.displayName = 'Switch';
