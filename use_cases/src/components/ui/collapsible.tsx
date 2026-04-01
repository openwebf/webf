import * as React from 'react';
import { cn } from '../../lib/utils';

type CollapsibleContextValue = {
  open: boolean;
  onOpenChange: (open: boolean) => void;
};

const CollapsibleContext = React.createContext<CollapsibleContextValue | null>(null);

function useCollapsibleContext(component: string) {
  const context = React.useContext(CollapsibleContext);
  if (!context) {
    throw new Error(`${component} must be used within <Collapsible>.`);
  }
  return context;
}

export function Collapsible({
  open,
  defaultOpen = false,
  onOpenChange,
  className,
  children,
}: React.HTMLAttributes<HTMLDivElement> & {
  open?: boolean;
  defaultOpen?: boolean;
  onOpenChange?: (open: boolean) => void;
}) {
  const [internalOpen, setInternalOpen] = React.useState(defaultOpen);
  const currentOpen = open ?? internalOpen;

  const setOpen = React.useCallback(
    (nextOpen: boolean) => {
      if (open === undefined) {
        setInternalOpen(nextOpen);
      }
      onOpenChange?.(nextOpen);
    },
    [onOpenChange, open],
  );

  return (
    <CollapsibleContext.Provider value={{ open: currentOpen, onOpenChange: setOpen }}>
      <div className={cn('grid gap-2', className)}>{children}</div>
    </CollapsibleContext.Provider>
  );
}

export function CollapsibleTrigger({
  children,
}: {
  children: React.ReactElement;
}) {
  const { open, onOpenChange } = useCollapsibleContext('CollapsibleTrigger');

  return React.cloneElement(children, {
    onClick: (event: React.MouseEvent) => {
      children.props.onClick?.(event);
      onOpenChange(!open);
    },
  });
}

export const CollapsibleContent = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => {
  const { open } = useCollapsibleContext('CollapsibleContent');
  if (!open) {
    return null;
  }

  return <div ref={ref} className={cn('grid gap-2', className)} {...props} />;
});

CollapsibleContent.displayName = 'CollapsibleContent';
