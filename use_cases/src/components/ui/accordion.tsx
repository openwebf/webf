import * as React from 'react';
import { cn } from '../../lib/utils';

type AccordionRootContextValue = {
  type: 'single' | 'multiple';
  collapsible: boolean;
  openValues: string[];
  toggleValue: (value: string) => void;
};

type AccordionItemContextValue = {
  value: string;
  open: boolean;
};

const AccordionRootContext = React.createContext<AccordionRootContextValue | null>(
  null,
);
const AccordionItemContext = React.createContext<AccordionItemContextValue | null>(
  null,
);

function useAccordionRootContext(component: string) {
  const context = React.useContext(AccordionRootContext);
  if (!context) {
    throw new Error(`${component} must be used within <Accordion>.`);
  }
  return context;
}

function useAccordionItemContext(component: string) {
  const context = React.useContext(AccordionItemContext);
  if (!context) {
    throw new Error(`${component} must be used within <AccordionItem>.`);
  }
  return context;
}

export function Accordion({
  type,
  collapsible = false,
  defaultValue,
  value,
  onValueChange,
  className,
  children,
}: React.HTMLAttributes<HTMLDivElement> & {
  type: 'single' | 'multiple';
  collapsible?: boolean;
  defaultValue?: string | string[];
  value?: string | string[];
  onValueChange?: (value: string | string[]) => void;
}) {
  const [internalValue, setInternalValue] = React.useState<string[]>(
    type === 'multiple'
      ? Array.isArray(defaultValue)
        ? defaultValue
        : []
      : typeof defaultValue === 'string' && defaultValue
        ? [defaultValue]
        : [],
  );

  const openValues = React.useMemo(() => {
    if (value === undefined) {
      return internalValue;
    }
    return Array.isArray(value) ? value : value ? [value] : [];
  }, [internalValue, value]);

  const toggleValue = React.useCallback(
    (itemValue: string) => {
      const nextValues =
        type === 'multiple'
          ? openValues.includes(itemValue)
            ? openValues.filter((valueItem) => valueItem !== itemValue)
            : [...openValues, itemValue]
          : openValues.includes(itemValue)
            ? collapsible
              ? []
              : [itemValue]
            : [itemValue];

      if (value === undefined) {
        setInternalValue(nextValues);
      }

      if (type === 'multiple') {
        onValueChange?.(nextValues);
      } else {
        onValueChange?.(nextValues[0] ?? '');
      }
    },
    [collapsible, onValueChange, openValues, type, value],
  );

  return (
    <AccordionRootContext.Provider
      value={{ type, collapsible, openValues, toggleValue }}
    >
      <div className={cn('grid gap-2', className)}>{children}</div>
    </AccordionRootContext.Provider>
  );
}

export const AccordionItem = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement> & {
    value: string;
  }
>(({ className, value, children, ...props }, ref) => {
  const rootContext = useAccordionRootContext('AccordionItem');
  const open = rootContext.openValues.includes(value);

  return (
    <AccordionItemContext.Provider value={{ value, open }}>
      <div
        ref={ref}
        data-state={open ? 'open' : 'closed'}
        className={cn('rounded-lg border border-zinc-200 bg-white', className)}
        {...props}
      >
        {children}
      </div>
    </AccordionItemContext.Provider>
  );
});

AccordionItem.displayName = 'AccordionItem';

export const AccordionTrigger = React.forwardRef<
  HTMLButtonElement,
  React.ButtonHTMLAttributes<HTMLButtonElement>
>(({ className, children, ...props }, ref) => {
  const rootContext = useAccordionRootContext('AccordionTrigger');
  const itemContext = useAccordionItemContext('AccordionTrigger');

  return (
    <button
      ref={ref}
      type="button"
      className={cn(
        'flex w-full items-center justify-between gap-3 px-4 py-3 text-left text-sm font-medium text-zinc-950 transition-colors hover:text-zinc-700',
        className,
      )}
      onClick={() => rootContext.toggleValue(itemContext.value)}
      {...props}
    >
      <span>{children}</span>
      <span className="text-zinc-400">{itemContext.open ? '−' : '+'}</span>
    </button>
  );
});

AccordionTrigger.displayName = 'AccordionTrigger';

export const AccordionContent = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => {
  const itemContext = useAccordionItemContext('AccordionContent');
  if (!itemContext.open) {
    return null;
  }

  return (
    <div
      ref={ref}
      className={cn('border-t border-zinc-200 px-4 py-3 text-sm leading-6 text-zinc-600', className)}
      {...props}
    />
  );
});

AccordionContent.displayName = 'AccordionContent';
