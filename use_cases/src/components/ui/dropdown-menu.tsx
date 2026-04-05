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
  const items = React.Children.toArray(children);

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
      <div className="min-w-0 relative inline-flex">
        <div className="min-w-0">{items}</div>
      </div>
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
        'absolute right-0 top-full z-50 mt-2 w-64 rounded-md border border-zinc-200 bg-white p-1 shadow-lg',
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
  <div ref={ref} className={cn('flex flex-col gap-1', className)} {...props} />
));

DropdownMenuGroup.displayName = 'DropdownMenuGroup';

export const DropdownMenuLabel = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, children, ...props }, ref) => (
  <div
    ref={ref}
    className={cn(
      'mb-1 grid gap-2 px-2 pt-1.5 text-xs font-semibold text-zinc-500',
      className,
    )}
    {...props}
  >
    <span>{children}</span>
    <span
      aria-hidden="true"
      className="block h-px w-full overflow-hidden bg-zinc-300 text-transparent"
    >
      .
    </span>
  </div>
));

DropdownMenuLabel.displayName = 'DropdownMenuLabel';

export const DropdownMenuSeparator = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn('-mx-1 my-1 px-1', className)}
    {...props}
  >
    <span
      aria-hidden="true"
      className="block h-px w-full overflow-hidden bg-zinc-300 text-transparent"
    >
      .
    </span>
  </div>
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
        'flex w-full appearance-none items-center justify-between rounded-sm border-0 bg-transparent px-2 py-1.5 text-left text-sm text-zinc-700 shadow-none outline-none transition-colors hover:bg-zinc-100 hover:text-zinc-950',
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
