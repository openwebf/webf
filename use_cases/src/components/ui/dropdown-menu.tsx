import * as React from 'react';
import { cn } from '../../lib/utils';

type DropdownMenuContextValue = {
  open: boolean;
  setOpen: (open: boolean) => void;
  contentRef: React.RefObject<HTMLDivElement>;
};

const DropdownMenuContext = React.createContext<DropdownMenuContextValue | null>(
  null,
);

function useDropdownMenuContext(component: string) {
  const context = React.useContext(DropdownMenuContext);
  if (!context) {
    throw new Error(`${component} must be used within <DropdownMenu>.`);
  }
  return context;
}

export function DropdownMenu({ children }: { children: React.ReactNode }) {
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
    <DropdownMenuContext.Provider value={{ open, setOpen, contentRef }}>
      <div className="relative inline-flex">{children}</div>
    </DropdownMenuContext.Provider>
  );
}

export function DropdownMenuTrigger({
  children,
}: {
  children: React.ReactElement;
}) {
  const { open, setOpen } = useDropdownMenuContext('DropdownMenuTrigger');

  return React.cloneElement(children, {
    onClick: (event: React.MouseEvent) => {
      children.props.onClick?.(event);
      setOpen(!open);
    },
  });
}

export const DropdownMenuContent = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => {
  const { open, contentRef } = useDropdownMenuContext('DropdownMenuContent');
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
        'absolute right-0 top-full z-50 mt-2 min-w-56 rounded-md border border-zinc-200 bg-white p-1 shadow-lg',
        className,
      )}
      {...props}
    />
  );
});

DropdownMenuContent.displayName = 'DropdownMenuContent';

export const DropdownMenuGroup = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div ref={ref} className={cn('grid gap-1', className)} {...props} />
));

DropdownMenuGroup.displayName = 'DropdownMenuGroup';

export const DropdownMenuLabel = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn('px-2 py-1.5 text-xs font-semibold text-zinc-500', className)}
    {...props}
  />
));

DropdownMenuLabel.displayName = 'DropdownMenuLabel';

export const DropdownMenuSeparator = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div ref={ref} className={cn('my-1 h-px bg-zinc-200', className)} {...props} />
));

DropdownMenuSeparator.displayName = 'DropdownMenuSeparator';

export const DropdownMenuItem = React.forwardRef<
  HTMLButtonElement,
  React.ButtonHTMLAttributes<HTMLButtonElement>
>(({ className, onClick, ...props }, ref) => {
  const { setOpen } = useDropdownMenuContext('DropdownMenuItem');

  return (
    <button
      ref={ref}
      type="button"
      className={cn(
        'flex w-full items-center justify-between rounded-sm px-2 py-1.5 text-sm text-zinc-700 transition-colors hover:bg-zinc-100 hover:text-zinc-950',
        className,
      )}
      onClick={(event) => {
        onClick?.(event);
        setOpen(false);
      }}
      {...props}
    />
  );
});

DropdownMenuItem.displayName = 'DropdownMenuItem';

export const DropdownMenuShortcut = React.forwardRef<
  HTMLSpanElement,
  React.HTMLAttributes<HTMLSpanElement>
>(({ className, ...props }, ref) => (
  <span
    ref={ref}
    className={cn('ml-4 text-xs tracking-widest text-zinc-400', className)}
    {...props}
  />
));

DropdownMenuShortcut.displayName = 'DropdownMenuShortcut';
