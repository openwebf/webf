import * as React from 'react';
import { cn } from '../../lib/utils';

type DialogContextValue = {
  open: boolean;
  onOpenChange: (open: boolean) => void;
};

const DialogContext = React.createContext<DialogContextValue | null>(null);

function useDialogContext(component: string) {
  const context = React.useContext(DialogContext);
  if (!context) {
    throw new Error(`${component} must be used within <Dialog>.`);
  }
  return context;
}

export function Dialog({
  open,
  onOpenChange,
  children,
}: {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  children: React.ReactNode;
}) {
  return (
    <DialogContext.Provider value={{ open, onOpenChange }}>
      {children}
    </DialogContext.Provider>
  );
}

export function DialogTrigger({
  children,
}: {
  children: React.ReactElement;
}) {
  const { onOpenChange } = useDialogContext('DialogTrigger');

  return React.cloneElement(children, {
    onClick: (event: React.MouseEvent) => {
      children.props.onClick?.(event);
      onOpenChange(true);
    },
  });
}

export function DialogContent({
  children,
  className,
  showCloseButton = true,
  onInteractOutside,
}: React.HTMLAttributes<HTMLDivElement> & {
  showCloseButton?: boolean;
  onInteractOutside?: () => void;
}) {
  const { open, onOpenChange } = useDialogContext('DialogContent');

  if (!open) {
    return null;
  }

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 px-4 py-6"
      onClick={() => {
        onInteractOutside?.();
        onOpenChange(false);
      }}
    >
      <div
        className={cn(
          'relative flex max-h-[85vh] w-full max-w-lg flex-col overflow-hidden rounded-xl border border-zinc-200 bg-white shadow-2xl',
          className,
        )}
        onClick={(event) => event.stopPropagation()}
      >
        {showCloseButton ? (
          <button
            type="button"
            className="absolute right-4 top-4 inline-flex h-8 w-8 items-center justify-center rounded-md text-zinc-500 transition-colors hover:bg-zinc-100 hover:text-zinc-900"
            onClick={() => onOpenChange(false)}
          >
            ×
          </button>
        ) : null}
        {children}
      </div>
    </div>
  );
}

export const DialogHeader = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div ref={ref} className={cn('grid gap-2 p-6 pb-4', className)} {...props} />
));

DialogHeader.displayName = 'DialogHeader';

export const DialogTitle = React.forwardRef<
  HTMLHeadingElement,
  React.HTMLAttributes<HTMLHeadingElement>
>(({ className, ...props }, ref) => (
  <h2
    ref={ref}
    className={cn('text-lg font-semibold leading-none tracking-tight', className)}
    {...props}
  />
));

DialogTitle.displayName = 'DialogTitle';

export const DialogDescription = React.forwardRef<
  HTMLParagraphElement,
  React.HTMLAttributes<HTMLParagraphElement>
>(({ className, ...props }, ref) => (
  <p ref={ref} className={cn('text-sm text-zinc-500', className)} {...props} />
));

DialogDescription.displayName = 'DialogDescription';

export const DialogBody = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div ref={ref} className={cn('overflow-y-auto px-6 pb-6', className)} {...props} />
));

DialogBody.displayName = 'DialogBody';

export const DialogFooter = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn(
      'flex flex-col-reverse gap-2 border-t border-zinc-100 bg-white px-6 py-4 sm:flex-row sm:justify-end',
      className,
    )}
    {...props}
  />
));

DialogFooter.displayName = 'DialogFooter';
