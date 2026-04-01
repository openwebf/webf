import * as React from 'react';
import { cn } from '../../lib/utils';

type SelectContextValue = {
  open: boolean;
  setOpen: (open: boolean) => void;
  value?: string;
  setValue: (value: string) => void;
  selectedLabel?: React.ReactNode;
  registerItem: (value: string, label: React.ReactNode) => void;
  unregisterItem: (value: string) => void;
  contentRef: React.RefObject<HTMLDivElement>;
};

const SelectContext = React.createContext<SelectContextValue | null>(null);

function useSelectContext(component: string) {
  const context = React.useContext(SelectContext);
  if (!context) {
    throw new Error(`${component} must be used within <Select>.`);
  }
  return context;
}

export function Select({
  value,
  defaultValue,
  onValueChange,
  children,
}: {
  value?: string;
  defaultValue?: string;
  onValueChange?: (value: string) => void;
  children: React.ReactNode;
}) {
  const [open, setOpen] = React.useState(false);
  const [internalValue, setInternalValue] = React.useState(defaultValue);
  const [labels, setLabels] = React.useState<Record<string, React.ReactNode>>({});
  const contentRef = React.useRef<HTMLDivElement>(null);
  const currentValue = value ?? internalValue;

  React.useEffect(() => {
    if (!open) {
      return;
    }

    const handlePointerDown = (event: Event) => {
      if (contentRef.current?.contains(event.target as Node)) {
        return;
      }
      setOpen(false);
    };

    document.addEventListener('pointerdown', handlePointerDown);
    return () => document.removeEventListener('pointerdown', handlePointerDown);
  }, [open]);

  const setValue = React.useCallback(
    (nextValue: string) => {
      if (value === undefined) {
        setInternalValue(nextValue);
      }
      onValueChange?.(nextValue);
      setOpen(false);
    },
    [onValueChange, value],
  );

  const registerItem = React.useCallback((itemValue: string, label: React.ReactNode) => {
    setLabels((prev) => {
      if (prev[itemValue] === label) {
        return prev;
      }
      return { ...prev, [itemValue]: label };
    });
  }, []);

  const unregisterItem = React.useCallback((itemValue: string) => {
    setLabels((prev) => {
      if (!(itemValue in prev)) {
        return prev;
      }
      const next = { ...prev };
      delete next[itemValue];
      return next;
    });
  }, []);

  return (
    <SelectContext.Provider
      value={{
        open,
        setOpen,
        value: currentValue,
        setValue,
        selectedLabel: currentValue ? labels[currentValue] : undefined,
        registerItem,
        unregisterItem,
        contentRef,
      }}
    >
      <div className="relative inline-flex">{children}</div>
    </SelectContext.Provider>
  );
}

export const SelectTrigger = React.forwardRef<
  HTMLButtonElement,
  React.ButtonHTMLAttributes<HTMLButtonElement>
>(({ className, children, disabled, ...props }, ref) => {
  const { open, setOpen } = useSelectContext('SelectTrigger');

  return (
    <button
      ref={ref}
      type="button"
      disabled={disabled}
      data-state={open ? 'open' : 'closed'}
      className={cn(
        'flex h-9 w-full min-w-[180px] items-center justify-between gap-3 rounded-md border border-zinc-200 bg-white px-3 py-2 text-sm text-zinc-950 shadow-sm transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-zinc-300 disabled:cursor-not-allowed disabled:opacity-50',
        className,
      )}
      onClick={() => setOpen(!open)}
      {...props}
    >
      {children}
      <span className="text-zinc-400">⌄</span>
    </button>
  );
});

SelectTrigger.displayName = 'SelectTrigger';

export const SelectValue = React.forwardRef<
  HTMLSpanElement,
  React.HTMLAttributes<HTMLSpanElement> & {
    placeholder?: string;
  }
>(({ className, placeholder = 'Select an option', ...props }, ref) => {
  const { selectedLabel } = useSelectContext('SelectValue');

  return (
    <span
      ref={ref}
      className={cn('truncate text-left', !selectedLabel && 'text-zinc-400', className)}
      {...props}
    >
      {selectedLabel ?? placeholder}
    </span>
  );
});

SelectValue.displayName = 'SelectValue';

export const SelectContent = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => {
  const { open, contentRef } = useSelectContext('SelectContent');
  const mergedRef = (node: HTMLDivElement | null) => {
    contentRef.current = node;
    if (typeof ref === 'function') {
      ref(node);
    } else if (ref) {
      ref.current = node;
    }
  };

  if (!open) {
    return null;
  }

  return (
    <div
      ref={mergedRef}
      className={cn(
        'absolute left-0 top-full z-50 mt-2 min-w-full rounded-md border border-zinc-200 bg-white p-1 shadow-lg',
        className,
      )}
      {...props}
    />
  );
});

SelectContent.displayName = 'SelectContent';

export const SelectGroup = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div ref={ref} className={cn('grid gap-1', className)} {...props} />
));

SelectGroup.displayName = 'SelectGroup';

export const SelectLabel = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn('px-2 py-1.5 text-xs font-semibold text-zinc-500', className)}
    {...props}
  />
));

SelectLabel.displayName = 'SelectLabel';

export const SelectSeparator = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div ref={ref} className={cn('my-1 h-px bg-zinc-200', className)} {...props} />
));

SelectSeparator.displayName = 'SelectSeparator';

export const SelectItem = React.forwardRef<
  HTMLButtonElement,
  React.ButtonHTMLAttributes<HTMLButtonElement> & {
    value: string;
    textValue?: string;
  }
>(({ className, children, value, textValue, ...props }, ref) => {
  const context = useSelectContext('SelectItem');
  const label = textValue ?? children;
  const { registerItem, unregisterItem } = context;

  React.useEffect(() => {
    registerItem(value, label);
    return () => unregisterItem(value);
  }, [label, registerItem, unregisterItem, value]);

  const selected = context.value === value;

  return (
    <button
      ref={ref}
      type="button"
      className={cn(
        'flex w-full items-center justify-between rounded-sm px-2 py-1.5 text-sm text-zinc-700 transition-colors hover:bg-zinc-100 hover:text-zinc-950',
        selected && 'bg-zinc-100 text-zinc-950',
        className,
      )}
      data-state={selected ? 'checked' : 'unchecked'}
      onClick={() => context.setValue(value)}
      {...props}
    >
      <span>{label}</span>
      <span className={cn('text-zinc-400', !selected && 'opacity-0')}>✓</span>
    </button>
  );
});

SelectItem.displayName = 'SelectItem';
