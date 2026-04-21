import * as React from 'react';
import { cn } from '../../lib/utils';

type RadioGroupContextValue = {
  value?: string;
  setValue: (value: string) => void;
  name?: string;
};

const RadioGroupContext = React.createContext<RadioGroupContextValue | null>(null);

function useRadioGroupContext(component: string) {
  const context = React.useContext(RadioGroupContext);
  if (!context) {
    throw new Error(`${component} must be used within <RadioGroup>.`);
  }
  return context;
}

export function RadioGroup({
  value,
  defaultValue,
  onValueChange,
  name,
  className,
  children,
}: React.HTMLAttributes<HTMLDivElement> & {
  value?: string;
  defaultValue?: string;
  onValueChange?: (value: string) => void;
  name?: string;
}) {
  const [internalValue, setInternalValue] = React.useState(defaultValue);
  const currentValue = value ?? internalValue;

  const setValue = React.useCallback(
    (nextValue: string) => {
      if (value === undefined) {
        setInternalValue(nextValue);
      }
      onValueChange?.(nextValue);
    },
    [onValueChange, value],
  );

  return (
    <RadioGroupContext.Provider value={{ value: currentValue, setValue, name }}>
      <div role="radiogroup" className={cn('grid gap-3', className)}>
        {children}
      </div>
    </RadioGroupContext.Provider>
  );
}

export const RadioGroupItem = React.forwardRef<
  HTMLButtonElement,
  React.ButtonHTMLAttributes<HTMLButtonElement> & {
    value: string;
  }
>(({ className, value, disabled, ...props }, ref) => {
  const context = useRadioGroupContext('RadioGroupItem');
  const selected = context.value === value;

  return (
    <button
      ref={ref}
      type="button"
      role="radio"
      aria-checked={selected}
      data-state={selected ? 'checked' : 'unchecked'}
      disabled={disabled}
      className={cn(
        'inline-flex h-4 w-4 shrink-0 items-center justify-center rounded-full border border-zinc-300 bg-white shadow-sm transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-zinc-300 disabled:cursor-not-allowed disabled:opacity-50',
        selected && 'border-zinc-900',
        className,
      )}
      onClick={() => context.setValue(value)}
      {...props}
    >
      <span
        className={cn(
          'h-2 w-2 rounded-full bg-zinc-900',
          !selected && 'opacity-0',
        )}
      />
    </button>
  );
});

RadioGroupItem.displayName = 'RadioGroupItem';
