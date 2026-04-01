import * as React from 'react';
import { cn } from '../../lib/utils';

type TabsContextValue = {
  value: string;
  setValue: (value: string) => void;
  orientation: 'horizontal' | 'vertical';
};

const TabsContext = React.createContext<TabsContextValue | null>(null);

function useTabsContext(component: string) {
  const context = React.useContext(TabsContext);
  if (!context) {
    throw new Error(`${component} must be used within <Tabs>.`);
  }
  return context;
}

export function Tabs({
  value,
  defaultValue,
  onValueChange,
  orientation = 'horizontal',
  className,
  children,
}: React.HTMLAttributes<HTMLDivElement> & {
  value?: string;
  defaultValue: string;
  onValueChange?: (value: string) => void;
  orientation?: 'horizontal' | 'vertical';
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
    <TabsContext.Provider value={{ value: currentValue, setValue, orientation }}>
      <div
        className={cn(
          'grid gap-4',
          orientation === 'vertical' && 'grid-cols-[200px_1fr] items-start gap-6',
          className,
        )}
      >
        {children}
      </div>
    </TabsContext.Provider>
  );
}

export const TabsList = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement> & {
    variant?: 'default' | 'line';
  }
>(({ className, variant = 'default', ...props }, ref) => {
  const { orientation } = useTabsContext('TabsList');

  return (
    <div
      ref={ref}
      role="tablist"
      aria-orientation={orientation}
      className={cn(
        orientation === 'horizontal'
          ? 'inline-flex h-9 items-center rounded-lg bg-zinc-100 p-1 text-zinc-500'
          : 'inline-grid gap-1 rounded-lg bg-zinc-100 p-1 text-zinc-500',
        variant === 'line' &&
          (orientation === 'horizontal'
            ? 'h-auto gap-2 rounded-none border-b border-zinc-200 bg-transparent p-0'
            : 'rounded-none border-r border-zinc-200 bg-transparent p-0 pr-3'),
        className,
      )}
      {...props}
    />
  );
});

TabsList.displayName = 'TabsList';

export const TabsTrigger = React.forwardRef<
  HTMLButtonElement,
  React.ButtonHTMLAttributes<HTMLButtonElement> & {
    value: string;
  }
>(({ className, value, disabled, ...props }, ref) => {
  const context = useTabsContext('TabsTrigger');
  const active = context.value === value;

  return (
    <button
      ref={ref}
      type="button"
      role="tab"
      aria-selected={active}
      disabled={disabled}
      className={cn(
        'inline-flex items-center justify-center whitespace-nowrap rounded-md px-3 py-1.5 text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-zinc-300 disabled:pointer-events-none disabled:opacity-50',
        active
          ? 'bg-white text-zinc-950 shadow-sm'
          : 'text-zinc-600 hover:text-zinc-950',
        className,
      )}
      data-state={active ? 'active' : 'inactive'}
      onClick={() => context.setValue(value)}
      {...props}
    />
  );
});

TabsTrigger.displayName = 'TabsTrigger';

export const TabsContent = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement> & {
    value: string;
  }
>(({ className, value, ...props }, ref) => {
  const context = useTabsContext('TabsContent');
  if (context.value !== value) {
    return null;
  }

  return (
    <div
      ref={ref}
      role="tabpanel"
      className={cn('outline-none', className)}
      {...props}
    />
  );
});

TabsContent.displayName = 'TabsContent';
