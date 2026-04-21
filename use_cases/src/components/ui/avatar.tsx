import * as React from 'react';
import { cn } from '../../lib/utils';

const AvatarContext = React.createContext<{ hasImage: boolean }>({ hasImage: false });

export const Avatar = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, children, ...props }, ref) => {
  const imageChild = React.Children.toArray(children).find(
    (child) => React.isValidElement(child) && child.type === AvatarImage && Boolean(child.props.src),
  );

  return (
    <AvatarContext.Provider value={{ hasImage: Boolean(imageChild) }}>
      <div
        ref={ref}
        className={cn(
          'relative inline-flex h-10 w-10 shrink-0 items-center justify-center overflow-hidden rounded-full bg-zinc-100 text-sm font-medium text-zinc-700',
          className,
        )}
        {...props}
      >
        {children}
      </div>
    </AvatarContext.Provider>
  );
});

Avatar.displayName = 'Avatar';

export const AvatarImage = React.forwardRef<
  HTMLImageElement,
  React.ImgHTMLAttributes<HTMLImageElement>
>(({ className, alt = '', ...props }, ref) => (
  <img
    ref={ref}
    alt={alt}
    className={cn('h-full w-full object-cover', className)}
    {...props}
  />
));

AvatarImage.displayName = 'AvatarImage';

export const AvatarFallback = React.forwardRef<
  HTMLSpanElement,
  React.HTMLAttributes<HTMLSpanElement>
>(({ className, ...props }, ref) => {
  const { hasImage } = React.useContext(AvatarContext);
  if (hasImage) {
    return null;
  }

  return (
    <span
      ref={ref}
      className={cn('inline-flex h-full w-full items-center justify-center', className)}
      {...props}
    />
  );
});

AvatarFallback.displayName = 'AvatarFallback';

export const AvatarBadge = React.forwardRef<
  HTMLSpanElement,
  React.HTMLAttributes<HTMLSpanElement>
>(({ className, ...props }, ref) => (
  <span
    ref={ref}
    className={cn(
      'absolute bottom-0 right-0 h-3.5 w-3.5 rounded-full border-2 border-white bg-emerald-500',
      className,
    )}
    {...props}
  />
));

AvatarBadge.displayName = 'AvatarBadge';
