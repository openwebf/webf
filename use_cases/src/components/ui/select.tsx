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

  return (
    <SelectContext.Provider
      value={{
        open,
        setOpen,
        value: currentValue,
        setValue,
        selectedLabel: currentValue ? labels[currentValue] : undefined,
        registerItem,
        unregisterItem: () => {},
        contentRef,
      }}
    >
      <div className="relative block min-w-0">{children}</div>
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
      data-slot="select-trigger"
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
      data-slot="select-value"
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
      data-slot="select-content"
      className={cn(
        'absolute inset-x-0 top-full z-50 mt-2 flex min-w-full flex-col rounded-md border border-zinc-200 bg-white p-2 shadow-lg',
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
  <div
    ref={ref}
    data-slot="select-group"
    className={cn('flex w-full min-w-0 flex-col gap-1', className)}
    {...props}
  />
));

SelectGroup.displayName = 'SelectGroup';

export const SelectLabel = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    data-slot="select-label"
    className={cn('px-3 py-1.5 text-xs font-semibold text-zinc-500', className)}
    {...props}
  />
));

SelectLabel.displayName = 'SelectLabel';

export const SelectSeparator = React.forwardRef<HTMLDivElement, React.HTMLAttributes<HTMLDivElement>>(
  ({ className, ...props }, ref) => (
    <div
      ref={ref}
      data-slot="select-separator"
      role="separator"
      className={cn('my-1 w-full px-1', className)}
      {...props}
    >
      <div className="h-px w-full bg-zinc-200" />
    </div>
  ),
);

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
      data-slot="select-item"
      className={cn(
        'flex w-full min-w-0 items-center justify-between rounded-sm border-0 bg-transparent px-3 py-2 text-sm text-zinc-700 shadow-none transition-colors hover:bg-zinc-100 hover:text-zinc-950',
        selected && 'bg-zinc-100 text-zinc-950',
        className,
      )}
      data-state={selected ? 'checked' : 'unchecked'}
      onClick={() => context.setValue(value)}
      {...props}
    >
      <span className="truncate">{label}</span>
      <span className={cn('ml-3 shrink-0 text-zinc-400', !selected && 'opacity-0')}>✓</span>
    </button>
  );
});

SelectItem.displayName = 'SelectItem';
