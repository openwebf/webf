import * as React from 'react';
import { cn } from '../../lib/utils';
import { Button } from './button';

type PopoverContextValue = {
  open: boolean;
  setOpen: React.Dispatch<React.SetStateAction<boolean>>;
  rootRef: React.RefObject<HTMLDivElement>;
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
  const rootRef = React.useRef<HTMLDivElement>(null);
  const contentRef = React.useRef<HTMLDivElement>(null);
  const items = React.Children.toArray(children);

  React.useEffect(() => {
    if (!open) {
      return;
    }

    const handleDocumentClick = (event: Event) => {
      if (rootRef.current?.contains(event.target as Node)) {
        return;
      }
      setOpen(false);
    };

    document.addEventListener('click', handleDocumentClick);
    return () => document.removeEventListener('click', handleDocumentClick);
  }, [open]);

  return (
    <PopoverContext.Provider value={{ open, setOpen, rootRef, contentRef }}>
      <div ref={rootRef} className="relative inline-flex">
        <div className="min-w-0">{items}</div>
      </div>
    </PopoverContext.Provider>
  );
}

export function PopoverTrigger({
  children,
}: {
  children: React.ReactElement;
}) {
  const { setOpen } = usePopoverContext('PopoverTrigger');

  return React.cloneElement(children, {
    onClick: (event: React.MouseEvent) => {
      children.props.onClick?.(event);
      setOpen((value) => !value);
    },
  });
}

export const PopoverContent = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement> & {
    align?: 'start' | 'center' | 'end';
  }
>(({ className, align = 'center', style, ...props }, ref) => {
  const { open, rootRef, contentRef } = usePopoverContext('PopoverContent');
  const [position, setPosition] = React.useState({
    top: 0,
    left: 0,
    ready: false,
  });
  const mergedRef = (node: HTMLDivElement | null) => {
    contentRef.current = node;
    if (typeof ref === 'function') {
      ref(node);
    } else if (ref) {
      ref.current = node;
    }
  };

  React.useEffect(() => {
    const anchor = rootRef.current;
    const content = contentRef.current;
    if (!open || !anchor || !content) {
      setPosition((current) => (current.ready ? { ...current, ready: false } : current));
      return;
    }

    let frameId = 0;

    const updatePosition = () => {
      const anchorRect = anchor.getBoundingClientRect();
      const contentRect = content.getBoundingClientRect();
      let nextLeft = anchorRect.left;

      if (align === 'center') {
        nextLeft += (anchorRect.width - contentRect.width) / 2;
      } else if (align === 'end') {
        nextLeft += anchorRect.width - contentRect.width;
      }

      setPosition({
        top: anchorRect.bottom + 8,
        left: nextLeft,
        ready: true,
      });
    };

    const scheduleUpdate = () => {
      cancelAnimationFrame(frameId);
      frameId = requestAnimationFrame(updatePosition);
    };

    scheduleUpdate();
    anchor.addEventListener('onscreen', scheduleUpdate);
    content.addEventListener('onscreen', scheduleUpdate);
    window.addEventListener('resize', scheduleUpdate);
    window.addEventListener('scroll', scheduleUpdate);

    return () => {
      cancelAnimationFrame(frameId);
      anchor.removeEventListener('onscreen', scheduleUpdate);
      content.removeEventListener('onscreen', scheduleUpdate);
      window.removeEventListener('resize', scheduleUpdate);
      window.removeEventListener('scroll', scheduleUpdate);
    };
  }, [align, contentRef, open, rootRef]);

  if (!open) {
    return null;
  }

  return (
    <div
      ref={mergedRef}
      data-slot="popover-content"
      className={cn(
        'fixed left-0 top-0 z-[9999] w-72 rounded-xl border border-zinc-200 bg-white p-4 shadow-lg',
        className,
      )}
      style={{
        ...style,
        top: position.top,
        left: position.left,
        visibility: position.ready ? 'visible' : 'hidden',
      }}
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

export function PopoverSwitchFixture() {
  return (
    <div className="min-h-screen bg-zinc-50 p-6">
      <div className="mx-auto grid max-w-3xl gap-4 rounded-2xl border border-zinc-200 bg-white p-6 shadow-sm">
        <h1 className="text-xl font-semibold text-zinc-950">
          shadcn_popover_switch
        </h1>
        <div className="flex gap-3">
          <Popover>
            <PopoverTrigger>
              <Button variant="outline">Left</Button>
            </PopoverTrigger>
            <PopoverContent align="start">
              <PopoverHeader>
                <PopoverTitle>Left title</PopoverTitle>
                <PopoverDescription>Left body</PopoverDescription>
              </PopoverHeader>
            </PopoverContent>
          </Popover>

          <Popover>
            <PopoverTrigger>
              <Button variant="ghost">Center</Button>
            </PopoverTrigger>
            <PopoverContent align="center">
              <PopoverHeader>
                <PopoverTitle>Center title</PopoverTitle>
                <PopoverDescription>Center body</PopoverDescription>
              </PopoverHeader>
            </PopoverContent>
          </Popover>
        </div>
      </div>
    </div>
  );
}
