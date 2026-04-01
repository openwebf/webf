import * as React from 'react';
import { cn } from '../../lib/utils';

type PopoverContextValue = {
  open: boolean;
  setOpen: (open: boolean) => void;
  contentRef: React.RefObject<HTMLDivElement>;
};

const PopoverContext = React.createContext<PopoverContextValue | null>(null);

function usePopoverContext(component: string) {
  const context = React.useContext(PopoverContext);
  if (!context) {
    throw new Error(`${component} must be used within <Popover>.`);
  }
  return context;
}

export function Popover({ children }: { children: React.ReactNode }) {
  const [open, setOpen] = React.useState(false);
  const contentRef = React.useRef<HTMLDivElement>(null);

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

  return (
    <PopoverContext.Provider value={{ open, setOpen, contentRef }}>
      <div className="relative inline-flex">{children}</div>
    </PopoverContext.Provider>
  );
}

export function PopoverTrigger({
  children,
}: {
  children: React.ReactElement;
}) {
  const { open, setOpen } = usePopoverContext('PopoverTrigger');

  return React.cloneElement(children, {
    onClick: (event: React.MouseEvent) => {
      children.props.onClick?.(event);
      setOpen(!open);
    },
  });
}

export const PopoverContent = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement> & {
    align?: 'start' | 'center' | 'end';
  }
>(({ className, align = 'center', ...props }, ref) => {
  const { open, contentRef } = usePopoverContext('PopoverContent');
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

  const alignmentClass =
    align === 'start'
      ? 'left-0'
      : align === 'end'
        ? 'right-0'
        : 'left-1/2 -translate-x-1/2';

  return (
    <div
      ref={mergedRef}
      className={cn(
        'absolute top-full z-50 mt-2 w-72 rounded-xl border border-zinc-200 bg-white p-4 shadow-lg',
        alignmentClass,
        className,
      )}
      {...props}
    />
  );
});

PopoverContent.displayName = 'PopoverContent';

export const PopoverHeader = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div ref={ref} className={cn('grid gap-1.5', className)} {...props} />
));

PopoverHeader.displayName = 'PopoverHeader';

export const PopoverTitle = React.forwardRef<
  HTMLHeadingElement,
  React.HTMLAttributes<HTMLHeadingElement>
>(({ className, ...props }, ref) => (
  <h4 ref={ref} className={cn('text-sm font-semibold text-zinc-950', className)} {...props} />
));

PopoverTitle.displayName = 'PopoverTitle';

export const PopoverDescription = React.forwardRef<
  HTMLParagraphElement,
  React.HTMLAttributes<HTMLParagraphElement>
>(({ className, ...props }, ref) => (
  <p ref={ref} className={cn('text-sm text-zinc-500', className)} {...props} />
));

PopoverDescription.displayName = 'PopoverDescription';
