import React, {
  Children,
  cloneElement,
  createContext,
  forwardRef,
  isValidElement,
  useContext,
  useEffect,
  useId,
  useImperativeHandle,
  useMemo,
  useRef,
  useState,
} from 'react';
import * as WebFShadcn from '@openwebf/react-shadcn-ui';
import './shadcnCompat.css';

const isWebFRuntime = () => Boolean((globalThis as any).webf?.hybridHistory);

const cn = (...values: Array<string | false | null | undefined>) => values.filter(Boolean).join(' ');

const mergeStyles = (
  ...styles: Array<React.CSSProperties | undefined>
): React.CSSProperties | undefined => {
  const merged = Object.assign({}, ...styles.filter(Boolean));
  return Object.keys(merged).length ? merged : undefined;
};

const normalizeButtonVariant = (variant?: string) => (variant === 'primary' ? 'default' : variant || 'default');

const asArray = (value?: string | null) =>
  (value || '')
    .split(',')
    .map((item) => item.trim())
    .filter(Boolean);

const textFromChildren = (children: React.ReactNode): string =>
  Children.toArray(children)
    .map((child) => {
      if (typeof child === 'string' || typeof child === 'number') {
        return String(child);
      }
      if (isValidElement(child)) {
        return textFromChildren(child.props.children);
      }
      return '';
    })
    .join('')
    .trim();

const emitDetail = (handler: ((event: any) => void) | undefined, value: any) => {
  if (!handler) return;
  handler({
    detail: { value },
    target: { value },
    currentTarget: { value },
  });
};

const componentName = (type: any) => type?.displayName || type?.name || '';
const isNamedComponent = (element: React.ReactNode, names: string[]) =>
  isValidElement(element) && names.includes(componentName(element.type));

const composeHandlers =
  <E,>(first?: (event: E) => void, second?: (event: E) => void) =>
  (event: E) => {
    first?.(event);
    second?.(event);
  };

const useControllableState = <T,>({
  value,
  defaultValue,
  onChange,
}: {
  value?: T;
  defaultValue: T;
  onChange?: (next: T) => void;
}) => {
  const [internalValue, setInternalValue] = useState(defaultValue);
  const controlled = value !== undefined;
  const currentValue = controlled ? value : internalValue;

  const setValue = (next: T | ((prev: T) => T)) => {
    const resolved =
      typeof next === 'function' ? (next as (prev: T) => T)(currentValue as T) : next;
    if (!controlled) {
      setInternalValue(resolved);
    }
    onChange?.(resolved);
  };

  return [currentValue as T, setValue] as const;
};

const useOutsideClose = (
  refs: Array<React.RefObject<HTMLElement>>,
  active: boolean,
  onClose: () => void
) => {
  useEffect(() => {
    if (!active) return;
    const handlePointerDown = (event: MouseEvent) => {
      const target = event.target as Node | null;
      const isInside = refs.some((ref) => ref.current?.contains(target ?? null));
      if (!isInside) onClose();
    };
    document.addEventListener('mousedown', handlePointerDown);
    return () => document.removeEventListener('mousedown', handlePointerDown);
  }, [active, onClose, refs]);
};

const BrowserNamedIcon = ({ name, size = 16 }: { name?: string; size?: number }) => {
  const iconName = String(name || '').toLowerCase();
  const strokeWidth = 2;
  const common = {
    width: size,
    height: size,
    viewBox: '0 0 24 24',
    fill: 'none',
    stroke: 'currentColor',
    strokeWidth,
    strokeLinecap: 'round' as const,
    strokeLinejoin: 'round' as const,
    'aria-hidden': true,
    className: 'browser-shadcn-icon-glyph',
  };

  switch (iconName) {
    case 'plus':
      return <svg {...common}><path d="M12 5v14" /><path d="M5 12h14" /></svg>;
    case 'minus':
      return <svg {...common}><path d="M5 12h14" /></svg>;
    case 'search':
      return <svg {...common}><circle cx="11" cy="11" r="7" /><path d="m20 20-3.5-3.5" /></svg>;
    case 'settings':
      return <svg {...common}><circle cx="12" cy="12" r="3" /><path d="M19.4 15a1.7 1.7 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.7 1.7 0 0 0-1.82-.33 1.7 1.7 0 0 0-1 1.54V21a2 2 0 1 1-4 0v-.09a1.7 1.7 0 0 0-1-1.54 1.7 1.7 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06A1.7 1.7 0 0 0 4.6 15a1.7 1.7 0 0 0-1.54-1H3a2 2 0 1 1 0-4h.09a1.7 1.7 0 0 0 1.54-1 1.7 1.7 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.7 1.7 0 0 0 1.82.33h.01A1.7 1.7 0 0 0 10 3.09V3a2 2 0 1 1 4 0v.09a1.7 1.7 0 0 0 1 1.54h.01a1.7 1.7 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.7 1.7 0 0 0-.33 1.82V9c0 .67.39 1.28 1 1.54.18.08.37.12.56.12H21a2 2 0 1 1 0 4h-.09c-.19 0-.38.04-.56.12-.61.26-1 .87-1 1.54V15Z" /></svg>;
    case 'edit':
      return <svg {...common}><path d="M12 20h9" /><path d="M16.5 3.5a2.1 2.1 0 1 1 3 3L7 19l-4 1 1-4 12.5-12.5Z" /></svg>;
    case 'trash':
      return <svg {...common}><path d="M3 6h18" /><path d="M8 6V4h8v2" /><path d="M19 6l-1 14H6L5 6" /><path d="M10 11v6" /><path d="M14 11v6" /></svg>;
    case 'copy':
      return <svg {...common}><rect x="9" y="9" width="10" height="10" rx="2" /><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1" /></svg>;
    case 'share':
    case 'external-link':
      return <svg {...common}><path d="M15 3h6v6" /><path d="M10 14 21 3" /><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6" /></svg>;
    case 'chevron-left':
      return <svg {...common}><path d="m15 18-6-6 6-6" /></svg>;
    case 'chevron-right':
      return <svg {...common}><path d="m9 18 6-6-6-6" /></svg>;
    case 'chevron-up':
      return <svg {...common}><path d="m18 15-6-6-6 6" /></svg>;
    case 'chevron-down':
      return <svg {...common}><path d="m6 9 6 6 6-6" /></svg>;
    case 'arrow-left':
      return <svg {...common}><path d="M19 12H5" /><path d="m12 19-7-7 7-7" /></svg>;
    case 'arrow-right':
      return <svg {...common}><path d="M5 12h14" /><path d="m12 5 7 7-7 7" /></svg>;
    case 'check':
      return <svg {...common}><path d="m20 6-11 11-5-5" /></svg>;
    case 'x':
      return <svg {...common}><path d="M18 6 6 18" /><path d="m6 6 12 12" /></svg>;
    case 'warning':
      return <svg {...common}><path d="M12 9v4" /><path d="M12 17h.01" /><path d="M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0Z" /></svg>;
    case 'help':
      return <svg {...common}><circle cx="12" cy="12" r="10" /><path d="M9.1 9a3 3 0 1 1 5.8 1c0 2-3 2-3 4" /><path d="M12 17h.01" /></svg>;
    case 'info':
      return <svg {...common}><circle cx="12" cy="12" r="10" /><path d="M12 16v-4" /><path d="M12 8h.01" /></svg>;
    case 'play':
      return <svg {...common}><polygon points="8 5 19 12 8 19 8 5" /></svg>;
    case 'pause':
      return <svg {...common}><path d="M10 4h-2v16h2z" /><path d="M16 4h-2v16h2z" /></svg>;
    case 'stop':
      return <svg {...common}><rect x="6" y="6" width="12" height="12" rx="1" /></svg>;
    case 'refresh':
      return <svg {...common}><path d="M21 12a9 9 0 1 1-2.64-6.36" /><path d="M21 3v6h-6" /></svg>;
    case 'download':
      return <svg {...common}><path d="M12 3v12" /><path d="m7 10 5 5 5-5" /><path d="M5 21h14" /></svg>;
    case 'upload':
      return <svg {...common}><path d="M12 21V9" /><path d="m17 14-5-5-5 5" /><path d="M5 3h14" /></svg>;
    case 'star':
      return <svg {...common}><path d="m12 3 2.8 5.7 6.2.9-4.5 4.4 1 6.2L12 17.2 6.5 20.2l1-6.2L3 9.6l6.2-.9L12 3Z" /></svg>;
    case 'heart':
      return <svg {...common}><path d="m12 20-1.4-1.3C5.4 14 2 10.9 2 7.1 2 4 4.4 2 7.2 2c1.7 0 3.4.8 4.8 2.2C13.4 2.8 15.1 2 16.8 2 19.6 2 22 4 22 7.1c0 3.8-3.4 6.9-8.6 11.6L12 20Z" /></svg>;
    case 'zap':
      return <svg {...common}><path d="M13 2 4 14h6l-1 8 9-12h-6l1-8Z" /></svg>;
    case 'rocket':
      return (
        <svg {...common}>
          <path d="M12 15v5s3.03-.55 4-2c1.08-1.62 0-5 0-5" />
          <path d="M4.5 16.5c-1.5 1.26-2 5-2 5s3.74-.5 5-2c.71-.84.7-2.13-.09-2.91a2.18 2.18 0 0 0-2.91-.09" />
          <path d="M9 12a22 22 0 0 1 2-3.95A12.88 12.88 0 0 1 22 2c0 2.72-.78 7.5-6 11a22.4 22.4 0 0 1-4 2z" />
          <path d="M9 12H4s.55-3.03 2-4c1.62-1.08 5 .05 5 .05" />
        </svg>
      );
    case 'bold':
      return <span className="browser-shadcn-icon-text" style={{ fontSize: size }}>B</span>;
    case 'italic':
      return <span className="browser-shadcn-icon-text browser-shadcn-icon-text-italic" style={{ fontSize: size }}>I</span>;
    case 'underline':
      return <span className="browser-shadcn-icon-text browser-shadcn-icon-text-underline" style={{ fontSize: size }}>U</span>;
    case 'align-left':
      return <svg {...common}><path d="M4 6h16" /><path d="M4 12h10" /><path d="M4 18h16" /></svg>;
    case 'align-center':
      return <svg {...common}><path d="M4 6h16" /><path d="M7 12h10" /><path d="M4 18h16" /></svg>;
    case 'align-right':
      return <svg {...common}><path d="M4 6h16" /><path d="M10 12h10" /><path d="M4 18h16" /></svg>;
    case 'more-horizontal':
      return <svg {...common}><circle cx="6" cy="12" r="1.5" fill="currentColor" /><circle cx="12" cy="12" r="1.5" fill="currentColor" /><circle cx="18" cy="12" r="1.5" fill="currentColor" /></svg>;
    case 'github':
      return <span className="browser-shadcn-icon-text" style={{ fontSize: Math.max(10, size - 2) }}>GH</span>;
    case 'twitter':
      return <span className="browser-shadcn-icon-text" style={{ fontSize: size }}>X</span>;
    case 'facebook':
      return <span className="browser-shadcn-icon-text" style={{ fontSize: size }}>f</span>;
    case 'instagram':
      return <svg {...common}><rect x="4" y="4" width="16" height="16" rx="4" /><circle cx="12" cy="12" r="3.5" /><circle cx="17.5" cy="6.5" r="1" fill="currentColor" /></svg>;
    case 'linkedin':
      return <span className="browser-shadcn-icon-text" style={{ fontSize: Math.max(9, size - 3) }}>in</span>;
    case 'youtube':
      return <svg {...common}><path d="M21 8s-.2-1.4-.8-2c-.8-.8-1.7-.8-2.1-.9C15.1 5 12 5 12 5h-.1S8.9 5 5.9 5.1c-.4 0-1.3 0-2.1.9-.6.6-.8 2-.8 2S3 9.6 3 11.1v1.8C3 14.4 3 16 3 16s.2 1.4.8 2c.8.8 1.9.8 2.4.9 1.7.2 5.8.2 5.8.2s3.1 0 6.1-.1c.4 0 1.3 0 2.1-.9.6-.6.8-2 .8-2s0-1.6 0-3.1v-1.8C21 9.6 21 8 21 8Z" /><path d="m10 9 5 3-5 3V9Z" fill="currentColor" stroke="none" /></svg>;
    default:
      return <span className="browser-shadcn-icon-text" style={{ fontSize: size }}>?</span>;
  }
};

function hybridComponent<TOriginalProps extends object, TFallbackProps extends object = TOriginalProps>(
  name: keyof typeof WebFShadcn,
  Fallback: React.ComponentType<TFallbackProps>
) {
  const Original = WebFShadcn[name] as React.ComponentType<TOriginalProps>;

  const Component = forwardRef<any, TOriginalProps & TFallbackProps>((props, ref) => {
    if (isWebFRuntime()) {
      return <Original ref={ref} {...(props as TOriginalProps)} />;
    }
    return <Fallback ref={ref} {...(props as TFallbackProps)} />;
  });

  Component.displayName = String(name);
  return Component;
}

type FormValue = string | boolean;

interface FormContextValue {
  disabled?: boolean;
  values: Record<string, FormValue>;
  setFieldValue: (fieldId: string, value: FormValue, required?: boolean) => void;
  registerField: (fieldId: string, required?: boolean, initialValue?: FormValue) => void;
  unregisterField: (fieldId: string) => void;
}

const FormContext = createContext<FormContextValue | null>(null);
const FieldContext = createContext<{ fieldId?: string; required?: boolean } | null>(null);

export interface FlutterShadcnFormElement {
  submit: () => boolean;
  reset: () => void;
  value?: string;
}

const BrowserTheme = forwardRef<HTMLDivElement, any>(function BrowserTheme(
  { children, colorScheme = 'zinc', brightness = 'light', className, style, ...rest },
  ref
) {
  return (
    <div
      ref={ref}
      data-color-scheme={colorScheme}
      data-brightness={brightness}
      className={cn('browser-shadcn-theme', className)}
      style={style}
      {...rest}
    >
      {children}
    </div>
  );
});

const BrowserButton = forwardRef<HTMLButtonElement, any>(function BrowserButton(
  {
    children,
    variant = 'default',
    size = 'default',
    loading,
    className,
    disabled,
    type = 'button',
    style,
    ...rest
  },
  ref
) {
  const isUnavailable = Boolean(disabled || loading);
  const normalizedVariant = normalizeButtonVariant(variant);
  const mergedStyle = mergeStyles(
    isUnavailable
      ? {
          cursor: 'not-allowed',
          opacity: 0.55,
        }
      : undefined,
    style
  );

  return (
    <button
      ref={ref}
      type={type}
      data-variant={normalizedVariant}
      data-size={size}
      className={cn('browser-shadcn-button', className)}
      disabled={isUnavailable}
      aria-disabled={isUnavailable}
      style={mergedStyle}
      {...rest}
    >
      {loading ? <span className="browser-shadcn-spinner" aria-hidden="true" /> : null}
      {children}
    </button>
  );
});

const BrowserIconButton = forwardRef<HTMLButtonElement, any>(function BrowserIconButton(
  { children, icon, iconSize = 16, variant = 'ghost', className, size = 'icon', ...rest },
  ref
) {
    return (
      <BrowserButton
        ref={ref}
        variant={variant}
        size={size}
        className={cn('browser-shadcn-icon-button', className)}
        aria-label={rest['aria-label'] ?? icon}
        {...rest}
      >
        {children ?? <BrowserNamedIcon name={icon} size={iconSize} />}
      </BrowserButton>
    );
  }
);

const useFieldRegistration = (value: FormValue | undefined) => {
  const form = useContext(FormContext);
  const field = useContext(FieldContext);

  useEffect(() => {
    if (!form || !field?.fieldId) return;
    form.registerField(field.fieldId, field.required, value);
    return () => form.unregisterField(field.fieldId!);
  }, [field?.fieldId, field?.required, form, value]);

  return { form, field };
};

const BrowserInput = forwardRef<HTMLInputElement, any>(function BrowserInput(
  { className, value, onInput, onChange, disabled, readonly, maxlength, type = 'text', ...rest },
  ref
) {
  const { form, field } = useFieldRegistration(value);
  const currentValue =
    form && field?.fieldId && value === undefined ? form.values[field.fieldId] ?? '' : value ?? '';

  return (
    <input
      ref={ref}
      type={type}
      className={cn('browser-shadcn-input', className)}
      value={typeof currentValue === 'boolean' ? String(currentValue) : currentValue}
      disabled={disabled || form?.disabled}
      readOnly={readonly}
      maxLength={maxlength ? Number(maxlength) : undefined}
      onInput={(event) => {
        const nextValue = (event.currentTarget as HTMLInputElement).value;
        if (form && field?.fieldId) {
          form.setFieldValue(field.fieldId, nextValue, field.required);
        }
        onInput?.(event);
      }}
      onChange={(event) => {
        const nextValue = event.currentTarget.value;
        if (form && field?.fieldId) {
          form.setFieldValue(field.fieldId, nextValue, field.required);
        }
        onChange?.(event);
      }}
      {...rest}
    />
  );
});

const BrowserTextarea = forwardRef<HTMLTextAreaElement, any>(function BrowserTextarea(
  { className, value, onInput, onChange, disabled, readonly, rows, maxlength, ...rest },
  ref
) {
  const { form, field } = useFieldRegistration(value);
  const currentValue =
    form && field?.fieldId && value === undefined ? form.values[field.fieldId] ?? '' : value ?? '';

  return (
    <textarea
      ref={ref}
      rows={rows ? Number(rows) : 4}
      className={cn('browser-shadcn-textarea', className)}
      value={typeof currentValue === 'boolean' ? String(currentValue) : currentValue}
      disabled={disabled || form?.disabled}
      readOnly={readonly}
      maxLength={maxlength ? Number(maxlength) : undefined}
      onInput={(event) => {
        const nextValue = event.currentTarget.value;
        if (form && field?.fieldId) {
          form.setFieldValue(field.fieldId, nextValue, field.required);
        }
        onInput?.(event);
      }}
      onChange={(event) => {
        const nextValue = event.currentTarget.value;
        if (form && field?.fieldId) {
          form.setFieldValue(field.fieldId, nextValue, field.required);
        }
        onChange?.(event);
      }}
      {...rest}
    />
  );
});

const BrowserBadge = forwardRef<HTMLSpanElement, any>(function BrowserBadge(
  { children, variant = 'default', className, ...rest },
  ref
) {
  return (
    <span ref={ref} data-variant={variant} className={cn('browser-shadcn-badge', className)} {...rest}>
      {children}
    </span>
  );
});

const BrowserAlert = forwardRef<HTMLDivElement, any>(function BrowserAlert(
  { children, variant = 'default', className, ...rest },
  ref
) {
  return (
    <div ref={ref} data-variant={variant} className={cn('browser-shadcn-alert', className)} {...rest}>
      {children}
    </div>
  );
});

const makeSimpleWrapper = (
  className: string,
  tagName: keyof JSX.IntrinsicElements = 'div',
  defaultProps?: Record<string, unknown>
) =>
  forwardRef<any, any>(function SimpleWrapper({ children, className: extraClassName, ...rest }, ref) {
    return React.createElement(
      tagName,
      { ref, className: cn(className, extraClassName), ...defaultProps, ...rest },
      children
    );
  });

const BrowserCard = makeSimpleWrapper('browser-shadcn-card');
const BrowserCardHeader = makeSimpleWrapper('browser-shadcn-card-header');
const BrowserCardTitle = makeSimpleWrapper('browser-shadcn-card-title', 'div');
const BrowserCardDescription = makeSimpleWrapper('browser-shadcn-card-description', 'div');
const BrowserCardContent = makeSimpleWrapper('browser-shadcn-card-content');
const BrowserCardFooter = makeSimpleWrapper('browser-shadcn-card-footer');
const BrowserAlertTitle = makeSimpleWrapper('browser-shadcn-alert-title', 'div');
const BrowserAlertDescription = makeSimpleWrapper('browser-shadcn-alert-description', 'div');

const BrowserAvatar = forwardRef<HTMLSpanElement, any>(function BrowserAvatar(
  { src, fallback, size = 'medium', className, ...rest },
  ref
) {
  const [failed, setFailed] = useState(false);
  return (
    <span ref={ref} data-size={size} className={cn('browser-shadcn-avatar', className)} {...rest}>
      {src && !failed ? <img src={src} alt={fallback || 'avatar'} onError={() => setFailed(true)} /> : fallback || '?'}
    </span>
  );
});

const BrowserProgress = forwardRef<HTMLDivElement, any>(function BrowserProgress(
  { value = '0', className, ...rest },
  ref
) {
  const numericValue = Math.max(0, Math.min(100, Number(value) || 0));
  return (
    <div ref={ref} className={cn('browser-shadcn-progress-track', className)} {...rest}>
      <div className="browser-shadcn-progress-fill" style={{ width: `${numericValue}%` }} />
    </div>
  );
});

const BrowserSkeleton = forwardRef<HTMLDivElement, any>(function BrowserSkeleton(
  { className, style, ...rest },
  ref
) {
  return <div ref={ref} className={cn('browser-shadcn-skeleton', className)} style={style} {...rest} />;
});

type BreadcrumbContextValue = {
  separator: string;
};

const BreadcrumbContext = createContext<BreadcrumbContextValue>({ separator: '/' });

const separatorMap: Record<string, string> = {
  slash: '/',
  arrow: '>',
  dot: '•',
  dash: '-',
};

const BrowserBreadcrumb = forwardRef<HTMLElement, any>(function BrowserBreadcrumb(
  { children, separator = 'slash', className, ...rest },
  ref
) {
  const value = separatorMap[separator] ?? separator;
  return (
    <BreadcrumbContext.Provider value={{ separator: value }}>
      <nav ref={ref} className={cn('browser-shadcn-breadcrumb', className)} {...rest}>
        <ol className="browser-shadcn-breadcrumb-list">{children}</ol>
      </nav>
    </BreadcrumbContext.Provider>
  );
});

const BrowserBreadcrumbList = makeSimpleWrapper('browser-shadcn-breadcrumb-list', 'ol');

const BrowserBreadcrumbItem = forwardRef<HTMLLIElement, any>(function BrowserBreadcrumbItem(
  { children, className, ...rest },
  ref
) {
  const { separator } = useContext(BreadcrumbContext);
  const content = Children.toArray(children);
  return (
    <li ref={ref} className={cn('browser-shadcn-breadcrumb-item', className)} {...rest}>
      {content}
      {!content.some((child) => isNamedComponent(child, ['BrowserBreadcrumbPage', 'FlutterShadcnBreadcrumbPage'])) ? (
        <span className="browser-shadcn-breadcrumb-separator">{separator}</span>
      ) : null}
    </li>
  );
});

const BrowserBreadcrumbLink = forwardRef<HTMLButtonElement, any>(function BrowserBreadcrumbLink(
  { children, className, onClick, ...rest },
  ref
) {
  return (
    <button ref={ref} type="button" className={cn('browser-shadcn-breadcrumb-link', className)} onClick={onClick} {...rest}>
      {children}
    </button>
  );
});

const BrowserBreadcrumbPage = makeSimpleWrapper('browser-shadcn-breadcrumb-page', 'span');
const BrowserBreadcrumbSeparator = makeSimpleWrapper('browser-shadcn-breadcrumb-separator', 'span');
const BrowserBreadcrumbEllipsis = forwardRef<HTMLButtonElement, any>(function BrowserBreadcrumbEllipsis(
  { className, ...rest },
  ref
) {
  return (
    <button ref={ref} type="button" className={cn('browser-shadcn-breadcrumb-ellipsis', className)} {...rest}>
      ...
    </button>
  );
});

const BrowserDropdownMenuContext = createContext<{
  open: boolean;
  setOpen: (next: boolean) => void;
  triggerRef: React.RefObject<HTMLElement>;
} | null>(null);

const BrowserDropdownMenu = forwardRef<HTMLDivElement, any>(function BrowserDropdownMenu(
  { children, className, ...rest },
  ref
) {
  const [open, setOpen] = useState(false);
  const triggerRef = useRef<HTMLElement>(null);
  const contentRef = useRef<HTMLDivElement>(null);
  useOutsideClose([triggerRef, contentRef], open, () => setOpen(false));

  return (
    <BrowserDropdownMenuContext.Provider value={{ open, setOpen, triggerRef }}>
      <div ref={ref} className={cn('browser-shadcn-menu-root', className)} {...rest}>
        {Children.map(children, (child) => {
          if (isNamedComponent(child, ['BrowserDropdownMenuContent', 'FlutterShadcnDropdownMenuContent'])) {
            return cloneElement(child, { ref: contentRef } as any);
          }
          return child;
        })}
      </div>
    </BrowserDropdownMenuContext.Provider>
  );
});

const wrapTrigger = (
  child: React.ReactNode,
  ref: React.RefObject<HTMLElement>,
  handler: (event: any) => void
) => {
  if (isValidElement(child)) {
    return cloneElement(child as React.ReactElement<any>, {
      ref,
      onClick: composeHandlers((child as React.ReactElement<any>).props.onClick, handler),
    });
  }
  return (
    <button ref={ref as React.RefObject<HTMLButtonElement>} type="button" onClick={handler}>
      {child}
    </button>
  );
};

const BrowserDropdownMenuTrigger = forwardRef<HTMLElement, any>(function BrowserDropdownMenuTrigger(
  { children },
  externalRef
) {
  const context = useContext(BrowserDropdownMenuContext);
  if (!context) return <>{children}</>;
  const setRef = (node: HTMLElement | null) => {
    (context.triggerRef as React.MutableRefObject<HTMLElement | null>).current = node;
    if (typeof externalRef === 'function') externalRef(node);
    else if (externalRef) (externalRef as React.MutableRefObject<HTMLElement | null>).current = node;
  };
  return wrapTrigger(children, { current: context.triggerRef.current } as React.RefObject<HTMLElement>, (event) => {
    setRef(event.currentTarget as HTMLElement);
    context.setOpen(!context.open);
  });
});

const BrowserDropdownMenuContent = forwardRef<HTMLDivElement, any>(function BrowserDropdownMenuContent(
  { children, className, ...rest },
  ref
) {
  const context = useContext(BrowserDropdownMenuContext);
  if (!context?.open) return null;
  return (
    <div ref={ref} className={cn('browser-shadcn-menu-content', className)} {...rest}>
      {children}
    </div>
  );
});

const BrowserDropdownMenuItem = forwardRef<HTMLButtonElement, any>(function BrowserDropdownMenuItem(
  { children, shortcut, inset, disabled, className, onClick, ...rest },
  ref
) {
  const context = useContext(BrowserDropdownMenuContext);
  return (
    <button
      ref={ref}
      type="button"
      data-inset={Boolean(inset)}
      data-disabled={Boolean(disabled)}
      className={cn('browser-shadcn-menu-item', className)}
      disabled={disabled}
      onClick={(event) => {
        onClick?.(event);
        context?.setOpen(false);
      }}
      {...rest}
    >
      <span>{children}</span>
      {shortcut ? <span className="browser-shadcn-menu-shortcut">{shortcut}</span> : null}
    </button>
  );
});

const BrowserDropdownMenuSeparator = makeSimpleWrapper('browser-shadcn-menu-separator');
const BrowserDropdownMenuLabel = makeSimpleWrapper('browser-shadcn-menu-label');

const BrowserPopoverContext = createContext<{
  open: boolean;
  setOpen: (next: boolean) => void;
  triggerRef: React.RefObject<HTMLElement>;
} | null>(null);

const BrowserPopover = forwardRef<HTMLDivElement, any>(function BrowserPopover({ children, className, ...rest }, ref) {
  const [open, setOpen] = useState(false);
  const triggerRef = useRef<HTMLElement>(null);
  const contentRef = useRef<HTMLDivElement>(null);
  useOutsideClose([triggerRef, contentRef], open, () => setOpen(false));
  return (
    <BrowserPopoverContext.Provider value={{ open, setOpen, triggerRef }}>
      <div ref={ref} className={cn('browser-shadcn-popover-root', className)} {...rest}>
        {Children.map(children, (child) => {
          if (isNamedComponent(child, ['BrowserPopoverContent', 'FlutterShadcnPopoverContent'])) {
            return cloneElement(child, { ref: contentRef } as any);
          }
          return child;
        })}
      </div>
    </BrowserPopoverContext.Provider>
  );
});

const BrowserPopoverTrigger = forwardRef<HTMLElement, any>(function BrowserPopoverTrigger({ children }, ref) {
  const context = useContext(BrowserPopoverContext);
  if (!context) return <>{children}</>;
  return wrapTrigger(children, context.triggerRef, (event) => {
    (context.triggerRef as React.MutableRefObject<HTMLElement | null>).current = event.currentTarget as HTMLElement;
    if (typeof ref === 'function') ref(event.currentTarget as HTMLElement);
    else if (ref) (ref as React.MutableRefObject<HTMLElement | null>).current = event.currentTarget as HTMLElement;
    context.setOpen(!context.open);
  });
});

const BrowserPopoverContent = forwardRef<HTMLDivElement, any>(function BrowserPopoverContent(
  { children, className, ...rest },
  ref
) {
  const context = useContext(BrowserPopoverContext);
  if (!context?.open) return null;
  return (
    <div ref={ref} className={cn('browser-shadcn-popover-content', className)} {...rest}>
      {children}
    </div>
  );
});

const BrowserTooltip = forwardRef<HTMLSpanElement, any>(function BrowserTooltip(
  { children, content, side = 'top', className, ...rest },
  ref
) {
  const [open, setOpen] = useState(false);
  return (
    <span
      ref={ref}
      className={cn('browser-shadcn-tooltip-root', className)}
      onMouseEnter={() => setOpen(true)}
      onMouseLeave={() => setOpen(false)}
      {...rest}
    >
      {children}
      {open ? (
        <span className="browser-shadcn-tooltip" data-side={side}>
          {content}
        </span>
      ) : null}
    </span>
  );
});

const DialogContext = createContext<{ open: boolean; onClose?: () => void; side?: string } | null>(null);

const BrowserDialog = forwardRef<HTMLDivElement, any>(function BrowserDialog(
  { children, open = false, onClose, className, ...rest },
  ref
) {
  return (
    <DialogContext.Provider value={{ open, onClose }}>
      <div ref={ref} className={className} {...rest}>
        {children}
      </div>
    </DialogContext.Provider>
  );
});

const BrowserDialogContent = forwardRef<HTMLDivElement, any>(function BrowserDialogContent(
  { children, className, ...rest },
  ref
) {
  const context = useContext(DialogContext);
  if (!context?.open) return null;
  return (
    <div className="browser-shadcn-dialog-overlay" onClick={() => context.onClose?.()}>
      <div
        ref={ref}
        className={cn('browser-shadcn-dialog-panel', className)}
        onClick={(event) => event.stopPropagation()}
        {...rest}
      >
        {children}
      </div>
    </div>
  );
});

const BrowserDialogHeader = makeSimpleWrapper('browser-shadcn-dialog-header');
const BrowserDialogTitle = makeSimpleWrapper('browser-shadcn-dialog-title');
const BrowserDialogDescription = makeSimpleWrapper('browser-shadcn-dialog-description');
const BrowserDialogFooter = makeSimpleWrapper('browser-shadcn-dialog-footer');

const BrowserSheet = forwardRef<HTMLDivElement, any>(function BrowserSheet(
  { children, open = false, onClose, side = 'bottom', className, ...rest },
  ref
) {
  return (
    <DialogContext.Provider value={{ open, onClose, side }}>
      <div ref={ref} className={className} {...rest}>
        {children}
      </div>
    </DialogContext.Provider>
  );
});

const BrowserSheetContent = forwardRef<HTMLDivElement, any>(function BrowserSheetContent(
  { children, className, ...rest },
  ref
) {
  const context = useContext(DialogContext);
  if (!context?.open) return null;
  return (
    <div className="browser-shadcn-sheet-overlay" onClick={() => context.onClose?.()}>
      <div
        ref={ref}
        data-side={context.side || 'bottom'}
        className={cn('browser-shadcn-sheet-panel', className)}
        onClick={(event) => event.stopPropagation()}
        {...rest}
      >
        {children}
      </div>
    </div>
  );
});

const BrowserSheetHeader = makeSimpleWrapper('browser-shadcn-sheet-header');
const BrowserSheetTitle = makeSimpleWrapper('browser-shadcn-sheet-title');
const BrowserSheetDescription = makeSimpleWrapper('browser-shadcn-sheet-description');

type TabsContextValue = {
  value: string;
  setValue: (value: string) => void;
};

const TabsContext = createContext<TabsContextValue | null>(null);

const BrowserTabs = forwardRef<HTMLDivElement, any>(function BrowserTabs(
  { children, value, defaultValue, onChange, className, ...rest },
  ref
) {
  const [currentValue, setCurrentValue] = useControllableState<string>({
    value,
    defaultValue: defaultValue || '',
    onChange: (next) => emitDetail(onChange, next),
  });

  return (
    <TabsContext.Provider value={{ value: currentValue, setValue: setCurrentValue }}>
      <div ref={ref} className={cn('browser-shadcn-tabs', className)} {...rest}>
        {children}
      </div>
    </TabsContext.Provider>
  );
});

const BrowserTabsList = makeSimpleWrapper('browser-shadcn-tabs-list');

const BrowserTabsTrigger = forwardRef<HTMLButtonElement, any>(function BrowserTabsTrigger(
  { children, value, className, ...rest },
  ref
) {
  const context = useContext(TabsContext);
  const active = context?.value === value;
  return (
    <button
      ref={ref}
      type="button"
      data-active={active}
      className={cn('browser-shadcn-tabs-trigger', className)}
      onClick={() => context?.setValue(value)}
      {...rest}
    >
      {children}
    </button>
  );
});

const BrowserTabsContent = forwardRef<HTMLDivElement, any>(function BrowserTabsContent(
  { children, value, className, ...rest },
  ref
) {
  const context = useContext(TabsContext);
  if (context?.value !== value) return null;
  return (
    <div ref={ref} className={cn('browser-shadcn-tabs-content', className)} {...rest}>
      {children}
    </div>
  );
});

type AccordionContextValue = {
  type: 'single' | 'multiple';
  value: string[];
  toggle: (item: string) => void;
};

const AccordionContext = createContext<AccordionContextValue | null>(null);
const AccordionItemContext = createContext<{ value: string } | null>(null);

const BrowserAccordion = forwardRef<HTMLDivElement, any>(function BrowserAccordion(
  { children, type = 'single', collapsible, value, defaultValue, onChange, className, ...rest },
  ref
) {
  const initialValue = type === 'multiple' ? asArray(value ?? defaultValue) : asArray(value ?? defaultValue).slice(0, 1);
  const [currentValue, setCurrentValue] = useControllableState<string[]>({
    value: value === undefined ? undefined : asArray(value),
    defaultValue: initialValue,
    onChange: (next) => emitDetail(onChange, type === 'multiple' ? next.join(',') : next[0] || (collapsible ? null : '')),
  });

  const toggle = (item: string) => {
    setCurrentValue((prev) => {
      if (type === 'multiple') {
        return prev.includes(item) ? prev.filter((entry) => entry !== item) : [...prev, item];
      }
      if (prev[0] === item) {
        return collapsible ? [] : prev;
      }
      return [item];
    });
  };

  return (
    <AccordionContext.Provider value={{ type, value: currentValue, toggle }}>
      <div ref={ref} className={cn('browser-shadcn-accordion', className)} {...rest}>
        {children}
      </div>
    </AccordionContext.Provider>
  );
});

const BrowserAccordionItem = forwardRef<HTMLDivElement, any>(function BrowserAccordionItem(
  { children, value, className, ...rest },
  ref
) {
  return (
    <AccordionItemContext.Provider value={{ value }}>
      <div ref={ref} className={cn('browser-shadcn-accordion-item', className)} {...rest}>
        {children}
      </div>
    </AccordionItemContext.Provider>
  );
});

const BrowserAccordionTrigger = forwardRef<HTMLButtonElement, any>(function BrowserAccordionTrigger(
  { children, className, ...rest },
  ref
) {
  const accordion = useContext(AccordionContext);
  const item = useContext(AccordionItemContext);
  const open = item ? accordion?.value.includes(item.value) : false;

  return (
    <button
      ref={ref}
      type="button"
      data-open={open}
      className={cn('browser-shadcn-accordion-trigger', className)}
      onClick={() => item && accordion?.toggle(item.value)}
      {...rest}
    >
      {children}
    </button>
  );
});

const BrowserAccordionContent = forwardRef<HTMLDivElement, any>(function BrowserAccordionContent(
  { children, className, ...rest },
  ref
) {
  const accordion = useContext(AccordionContext);
  const item = useContext(AccordionItemContext);
  const open = item ? accordion?.value.includes(item.value) : false;
  if (!open) return null;
  return (
    <div ref={ref} className={cn('browser-shadcn-accordion-content', className)} {...rest}>
      {children}
    </div>
  );
});

type RadioContextValue = {
  value: string;
  setValue: (value: string) => void;
  disabled?: boolean;
  name: string;
};

const RadioContext = createContext<RadioContextValue | null>(null);

const BrowserRadio = forwardRef<HTMLDivElement, any>(function BrowserRadio(
  { children, value, defaultValue, onChange, disabled, className, ...rest },
  ref
) {
  const name = useId();
  const [currentValue, setCurrentValue] = useControllableState<string>({
    value,
    defaultValue: defaultValue || value || '',
    onChange: (next) => emitDetail(onChange, next),
  });

  return (
    <RadioContext.Provider value={{ value: currentValue, setValue: setCurrentValue, disabled, name }}>
      <div ref={ref} className={className} {...rest}>
        {children}
      </div>
    </RadioContext.Provider>
  );
});

const BrowserRadioItem = forwardRef<HTMLInputElement, any>(function BrowserRadioItem(
  { value, disabled, className, ...rest },
  ref
) {
  const context = useContext(RadioContext);
  return (
    <input
      ref={ref}
      type="radio"
      name={context?.name}
      className={cn('browser-shadcn-radio-input', className)}
      checked={context?.value === value}
      disabled={disabled || context?.disabled}
      onChange={() => context?.setValue(value)}
      {...rest}
    />
  );
});

const BrowserCheckbox = forwardRef<HTMLInputElement, any>(function BrowserCheckbox(
  { checked, onChange, disabled, label, children, className, ...rest },
  ref
) {
  const { form, field } = useFieldRegistration(Boolean(checked));
  const resolvedChecked =
    checked !== undefined
      ? Boolean(checked)
      : form && field?.fieldId
        ? Boolean(form.values[field.fieldId])
        : false;
  const content = label ?? children;
  return (
    <label className={cn('browser-shadcn-checkbox', className)}>
      <input
        ref={ref}
        type="checkbox"
        className="browser-shadcn-checkbox-input"
        checked={resolvedChecked}
        disabled={disabled || form?.disabled}
        onChange={(event) => {
          const nextValue = event.currentTarget.checked;
          if (form && field?.fieldId) {
            form.setFieldValue(field.fieldId, nextValue, field.required);
          }
          if (onChange) {
            emitDetail(onChange, nextValue);
          }
        }}
        {...rest}
      />
      {content ? <span style={{ marginLeft: 8 }}>{content}</span> : null}
    </label>
  );
});

const BrowserSwitch = forwardRef<HTMLInputElement, any>(function BrowserSwitch(
  { checked, onChange, disabled, children: _children, className, ...rest },
  ref
) {
  const { form, field } = useFieldRegistration(Boolean(checked));
  const resolvedChecked =
    checked !== undefined
      ? Boolean(checked)
      : form && field?.fieldId
        ? Boolean(form.values[field.fieldId])
        : false;
  return (
    <label className={cn('browser-shadcn-switch', className)}>
      <input
        ref={ref}
        type="checkbox"
        className="browser-shadcn-switch-input"
        checked={resolvedChecked}
        disabled={disabled || form?.disabled}
        onChange={(event) => {
          const nextValue = event.currentTarget.checked;
          if (form && field?.fieldId) {
            form.setFieldValue(field.fieldId, nextValue, field.required);
          }
          if (onChange) {
            emitDetail(onChange, nextValue);
          }
        }}
        {...rest}
      />
    </label>
  );
});

type OptionNode =
  | { type: 'item'; value: string; label: string; disabled?: boolean }
  | { type: 'group'; label: string; children: OptionNode[] };

const SelectItemMarker = ({ children }: { children?: React.ReactNode }) => <>{children}</>;
SelectItemMarker.displayName = 'BrowserSelectItem';
const SelectGroupMarker = ({ children }: { children?: React.ReactNode }) => <>{children}</>;
SelectGroupMarker.displayName = 'BrowserSelectGroup';
const SelectSeparatorMarker = ({ children }: { children?: React.ReactNode }) => <>{children}</>;
SelectSeparatorMarker.displayName = 'BrowserSelectSeparator';
const SelectTriggerMarker = ({ children }: { children?: React.ReactNode }) => <>{children}</>;
SelectTriggerMarker.displayName = 'BrowserSelectTrigger';
const SelectContentMarker = ({ children }: { children?: React.ReactNode }) => <>{children}</>;
SelectContentMarker.displayName = 'BrowserSelectContent';

const flattenOptions = (children: React.ReactNode): OptionNode[] =>
  Children.toArray(children).flatMap((child) => {
    if (!isValidElement(child)) return [];
    const displayName = componentName(child.type);
    if (displayName === 'BrowserSelectItem' || displayName === 'FlutterShadcnSelectItem' || displayName === 'FlutterShadcnComboboxItem') {
      return [
        {
          type: 'item',
          value: child.props.value,
          label: textFromChildren(child.props.children),
          disabled: child.props.disabled,
        } as OptionNode,
      ];
    }
    if (displayName === 'BrowserSelectGroup' || displayName === 'FlutterShadcnSelectGroup') {
      return [
        {
          type: 'group',
          label: child.props.label || '',
          children: flattenOptions(child.props.children),
        } as OptionNode,
      ];
    }
    return flattenOptions(child.props.children);
  });

const renderOptions = (options: OptionNode[]): React.ReactNode[] =>
  options.map((option, index) => {
    if (option.type === 'group') {
      return (
        <optgroup key={`${option.label}-${index}`} label={option.label}>
          {renderOptions(option.children)}
        </optgroup>
      );
    }
    return (
      <option key={`${option.value}-${index}`} value={option.value} disabled={option.disabled}>
        {option.label}
      </option>
    );
  });

const BrowserSelect = forwardRef<HTMLSelectElement, any>(function BrowserSelect(
  { children, placeholder, value, onChange, disabled, className, ...rest },
  ref
) {
  const { form, field } = useFieldRegistration(value);
  const options = useMemo(() => flattenOptions(children), [children]);
  const currentValue =
    form && field?.fieldId && value === undefined ? String(form.values[field.fieldId] ?? '') : String(value ?? '');
  return (
    <select
      ref={ref}
      className={cn('browser-shadcn-select-native', className)}
      value={currentValue}
      disabled={disabled || form?.disabled}
      onChange={(event) => {
        const nextValue = event.currentTarget.value;
        if (form && field?.fieldId) {
          form.setFieldValue(field.fieldId, nextValue, field.required);
        }
        emitDetail(onChange, nextValue);
      }}
      {...rest}
    >
      {placeholder ? (
        <option value="" disabled>
          {placeholder}
        </option>
      ) : null}
      {renderOptions(options)}
    </select>
  );
});

const BrowserCombobox = forwardRef<HTMLInputElement, any>(function BrowserCombobox(
  { children, placeholder, disabled, className, onChange, ...rest },
  ref
) {
  const listId = useId();
  const options = useMemo(() => flattenOptions(children), [children]);
  return (
    <>
      <input
        ref={ref}
        type="text"
        list={listId}
        className={cn('browser-shadcn-combobox-input', className)}
        placeholder={placeholder}
        disabled={disabled}
        onChange={(event) => emitDetail(onChange, event.currentTarget.value)}
        {...rest}
      />
      <datalist id={listId}>{renderOptions(options)}</datalist>
    </>
  );
});

const BrowserSlider = forwardRef<HTMLInputElement, any>(function BrowserSlider(
  { value = '0', onInput, disabled, className, ...rest },
  ref
) {
  return (
    <input
      ref={ref}
      type="range"
      className={className}
      value={value}
      disabled={disabled}
      onInput={(event) => emitDetail(onInput, (event.currentTarget as HTMLInputElement).value)}
      {...rest}
    />
  );
});

const BrowserTable = forwardRef<HTMLDivElement, any>(function BrowserTable(
  { children, className, ...rest },
  ref
) {
  return (
    <div ref={ref} className={cn('browser-shadcn-table-wrap', className)} {...rest}>
      <table className="browser-shadcn-table">{children}</table>
    </div>
  );
});

const BrowserTableHeader = makeSimpleWrapper('', 'thead');
const BrowserTableBody = makeSimpleWrapper('', 'tbody');
const BrowserTableRow = makeSimpleWrapper('', 'tr');
const BrowserTableHead = makeSimpleWrapper('', 'th');
const BrowserTableCell = makeSimpleWrapper('', 'td');

const BrowserContextMenuContext = createContext<{
  open: boolean;
  setOpen: (value: boolean) => void;
  point: { x: number; y: number };
  setPoint: (point: { x: number; y: number }) => void;
} | null>(null);

const BrowserContextMenu = forwardRef<HTMLDivElement, any>(function BrowserContextMenu(
  { children, className, ...rest },
  ref
) {
  const [open, setOpen] = useState(false);
  const [point, setPoint] = useState({ x: 0, y: 0 });
  useEffect(() => {
    if (!open) return;
    const close = () => setOpen(false);
    document.addEventListener('click', close);
    return () => document.removeEventListener('click', close);
  }, [open]);

  return (
    <BrowserContextMenuContext.Provider value={{ open, setOpen, point, setPoint }}>
      <div ref={ref} className={className} {...rest}>
        {children}
      </div>
    </BrowserContextMenuContext.Provider>
  );
});

const BrowserContextMenuTrigger = forwardRef<HTMLDivElement, any>(function BrowserContextMenuTrigger(
  { children, className, ...rest },
  ref
) {
  const context = useContext(BrowserContextMenuContext);
  return (
    <div
      ref={ref}
      className={cn('browser-shadcn-contextmenu-trigger', className)}
      onContextMenu={(event) => {
        event.preventDefault();
        context?.setPoint({ x: event.clientX, y: event.clientY });
        context?.setOpen(true);
      }}
      onClick={() => context?.setOpen(true)}
      {...rest}
    >
      {children}
    </div>
  );
});

const BrowserContextMenuContent = forwardRef<HTMLDivElement, any>(function BrowserContextMenuContent(
  { children, className, ...rest },
  ref
) {
  const context = useContext(BrowserContextMenuContext);
  if (!context?.open) return null;
  return (
    <div
      ref={ref}
      className={cn('browser-shadcn-menu-content', 'browser-shadcn-contextmenu-content', className)}
      style={{ left: context.point.x, top: context.point.y }}
      {...rest}
    >
      {children}
    </div>
  );
});

const MenuRadioContext = createContext<{
  value: string;
  setValue: (value: string) => void;
} | null>(null);

const BrowserContextMenuRadioGroup = forwardRef<HTMLDivElement, any>(function BrowserContextMenuRadioGroup(
  { children, value = '', onChange, className, ...rest },
  ref
) {
  const [currentValue, setCurrentValue] = useControllableState<string>({
    value,
    defaultValue: value,
    onChange: (next) => emitDetail(onChange, next),
  });
  return (
    <MenuRadioContext.Provider value={{ value: currentValue, setValue: setCurrentValue }}>
      <div ref={ref} className={className} {...rest}>
        {children}
      </div>
    </MenuRadioContext.Provider>
  );
});

const BrowserContextMenuRadioItem = forwardRef<HTMLButtonElement, any>(function BrowserContextMenuRadioItem(
  { children, value, ...rest },
  ref
) {
  const radio = useContext(MenuRadioContext);
  return (
    <BrowserDropdownMenuItem
      ref={ref}
      onClick={() => radio?.setValue(value)}
      {...rest}
    >
      <span>{radio?.value === value ? '● ' : '○ '}{children}</span>
    </BrowserDropdownMenuItem>
  );
});

const BrowserContextMenuCheckboxItem = forwardRef<HTMLButtonElement, any>(function BrowserContextMenuCheckboxItem(
  { children, checked, onChange, ...rest },
  ref
) {
  return (
    <BrowserDropdownMenuItem
      ref={ref}
      onClick={() => emitDetail(onChange, !checked)}
      {...rest}
    >
      <span>{checked ? '✓ ' : ''}{children}</span>
    </BrowserDropdownMenuItem>
  );
});

const BrowserContextMenuSub = forwardRef<HTMLDivElement, any>(function BrowserContextMenuSub(
  { children, className, ...rest },
  ref
) {
  const [open, setOpen] = useState(false);
  return (
    <div
      ref={ref}
      className={cn('browser-shadcn-menu-sub', className)}
      onMouseLeave={() => setOpen(false)}
      {...rest}
    >
      {Children.map(children, (child) => {
        if (!isValidElement(child)) return child;
        if (isNamedComponent(child, ['BrowserContextMenuSubTrigger', 'FlutterShadcnContextMenuSubTrigger'])) {
          return cloneElement(child, { onOpen: () => setOpen(true) } as any);
        }
        if (isNamedComponent(child, ['BrowserContextMenuSubContent', 'FlutterShadcnContextMenuSubContent'])) {
          return open ? child : null;
        }
        return child;
      })}
    </div>
  );
});

const BrowserContextMenuSubTrigger = forwardRef<HTMLButtonElement, any>(function BrowserContextMenuSubTrigger(
  { children, onOpen, ...rest },
  ref
) {
  return (
    <BrowserDropdownMenuItem ref={ref} onClick={() => undefined} onMouseEnter={onOpen} {...rest}>
      <span>{children}</span>
      <span className="browser-shadcn-menu-shortcut">›</span>
    </BrowserDropdownMenuItem>
  );
});

const BrowserContextMenuSubContent = forwardRef<HTMLDivElement, any>(function BrowserContextMenuSubContent(
  { children, className, ...rest },
  ref
) {
  return (
    <div ref={ref} className={cn('browser-shadcn-menu-content', 'browser-shadcn-menu-sub-content', className)} {...rest}>
      {children}
    </div>
  );
});

const BrowserCalendar = forwardRef<HTMLDivElement, any>(function BrowserCalendar(
  { mode = 'single', value, onChange, numberOfMonths = 1, className, ...rest },
  ref
) {
  const [singleValue, setSingleValue] = useState<string>(typeof value === 'string' ? value : '');
  const [rangeValue, setRangeValue] = useState<{ start: string; end: string }>(() => {
    const [start = '', end = ''] = String(value || '').split(/[>|,]/).map((entry) => entry.trim());
    return { start, end };
  });
  const [multipleValue, setMultipleValue] = useState<string[]>(asArray(value));
  const [draftDate, setDraftDate] = useState('');

  const updateMultiple = (next: string[]) => {
    setMultipleValue(next);
    emitDetail(onChange, next.join(','));
  };

  return (
    <div ref={ref} className={cn('browser-shadcn-calendar', className)} {...rest}>
      <div className="browser-shadcn-calendar-grid" style={{ width: numberOfMonths > 1 ? '100%' : undefined }}>
        {mode === 'range' ? (
          <>
            <input
              type="date"
              className="browser-shadcn-calendar-input"
              value={rangeValue.start}
              onChange={(event) => {
                const next = { ...rangeValue, start: event.currentTarget.value };
                setRangeValue(next);
                emitDetail(onChange, [next.start, next.end].filter(Boolean).join(' -> '));
              }}
            />
            <input
              type="date"
              className="browser-shadcn-calendar-input"
              value={rangeValue.end}
              onChange={(event) => {
                const next = { ...rangeValue, end: event.currentTarget.value };
                setRangeValue(next);
                emitDetail(onChange, [next.start, next.end].filter(Boolean).join(' -> '));
              }}
            />
          </>
        ) : mode === 'multiple' ? (
          <>
            <input
              type="date"
              className="browser-shadcn-calendar-input"
              value={draftDate}
              onChange={(event) => setDraftDate(event.currentTarget.value)}
            />
            <BrowserButton
              size="sm"
              variant="outline"
              onClick={() => {
                if (!draftDate) return;
                if (!multipleValue.includes(draftDate)) {
                  updateMultiple([...multipleValue, draftDate]);
                }
                setDraftDate('');
              }}
            >
              Add Date
            </BrowserButton>
          </>
        ) : (
          <input
            type="date"
            className="browser-shadcn-calendar-input"
            value={singleValue}
            onChange={(event) => {
              const nextValue = event.currentTarget.value;
              setSingleValue(nextValue);
              emitDetail(onChange, nextValue || null);
            }}
          />
        )}
      </div>
      {mode === 'multiple' && multipleValue.length > 0 ? (
        <div className="browser-shadcn-calendar-chip-list">
          {multipleValue.map((entry) => (
            <span key={entry} className="browser-shadcn-calendar-chip">
              {entry}
              <button type="button" onClick={() => updateMultiple(multipleValue.filter((item) => item !== entry))}>
                ×
              </button>
            </span>
          ))}
        </div>
      ) : null}
    </div>
  );
});

const BrowserDatePicker = forwardRef<HTMLInputElement, any>(function BrowserDatePicker(
  { placeholder, onChange, className, ...rest },
  ref
) {
  return (
    <input
      ref={ref}
      type="date"
      className={cn('browser-shadcn-calendar-input', className)}
      aria-label={placeholder || 'Pick a date'}
      onChange={(event) => emitDetail(onChange, event.currentTarget.value)}
      {...rest}
    />
  );
});

const BrowserForm = forwardRef<FlutterShadcnFormElement, any>(function BrowserForm(
  { children, disabled, onChange, onSubmit, onReset, className, ...rest },
  ref
) {
  const [values, setValues] = useState<Record<string, FormValue>>({});
  const requiredMapRef = useRef<Record<string, boolean>>({});
  const valuesRef = useRef<Record<string, FormValue>>({});
  valuesRef.current = values;

  const registerField = (fieldId: string, required?: boolean, initialValue?: FormValue) => {
    requiredMapRef.current[fieldId] = Boolean(required);
    setValues((prev) => {
      if (prev[fieldId] !== undefined) return prev;
      return { ...prev, [fieldId]: initialValue ?? '' };
    });
  };

  const setFieldValue = (fieldId: string, nextValue: FormValue, required?: boolean) => {
    if (required !== undefined) requiredMapRef.current[fieldId] = required;
    setValues((prev) => {
      const next = { ...prev, [fieldId]: nextValue };
      valuesRef.current = next;
      onChange?.({ detail: next });
      return next;
    });
  };

  const unregisterField = (fieldId: string) => {
    delete requiredMapRef.current[fieldId];
  };

  useImperativeHandle(
    ref,
    () => ({
      submit() {
        const isValid = Object.entries(requiredMapRef.current).every(([fieldId, required]) => {
          if (!required) return true;
          const fieldValue = valuesRef.current[fieldId];
          return Boolean(fieldValue);
        });
        if (isValid) {
          onSubmit?.({ detail: valuesRef.current });
        }
        return isValid;
      },
      reset() {
        const nextValues = Object.keys(valuesRef.current).reduce<Record<string, FormValue>>((acc, key) => {
          acc[key] = '';
          return acc;
        }, {});
        valuesRef.current = nextValues;
        setValues(nextValues);
        onReset?.({ detail: nextValues });
      },
      get value() {
        return JSON.stringify(valuesRef.current);
      },
    }),
    [onReset, onSubmit]
  );

  const contextValue = useMemo<FormContextValue>(
    () => ({
      disabled,
      values,
      setFieldValue,
      registerField,
      unregisterField,
    }),
    [disabled, values]
  );

  return (
    <FormContext.Provider value={contextValue}>
      <div className={cn('browser-shadcn-form', className)} {...rest}>
        {children}
      </div>
    </FormContext.Provider>
  );
});

const BrowserFormField = forwardRef<HTMLDivElement, any>(function BrowserFormField(
  { fieldId, label, description, required, placeholder, children, className, ...rest },
  ref
) {
  const defaultField =
    children ??
    (fieldId === 'bio' || fieldId === 'message' ? (
      <BrowserTextarea placeholder={placeholder} />
    ) : (
      <BrowserInput placeholder={placeholder} />
    ));

  return (
    <FieldContext.Provider value={{ fieldId, required }}>
      <div ref={ref} className={cn('browser-shadcn-form-field', className)} {...rest}>
        {label ? <div className="browser-shadcn-form-label">{label}</div> : null}
        {defaultField}
        {description ? <div className="browser-shadcn-form-description">{description}</div> : null}
      </div>
    </FieldContext.Provider>
  );
});

const BrowserFormLabel = makeSimpleWrapper('browser-shadcn-form-label', 'label');
const BrowserFormDescription = makeSimpleWrapper('browser-shadcn-form-description', 'div');
const BrowserFormMessage = forwardRef<HTMLDivElement, any>(function BrowserFormMessage(
  { type = 'info', className, ...rest },
  ref
) {
  return <div ref={ref} data-type={type} className={cn('browser-shadcn-form-message', className)} {...rest} />;
});

const BrowserBreadcrumbDropdown = forwardRef<HTMLDivElement, any>(function BrowserBreadcrumbDropdown(
  { children, className, ...rest },
  ref
) {
  const [open, setOpen] = useState(false);
  const items = Children.toArray(children);
  const trigger = items[0];
  const dropdownItems = items.slice(1);
  return (
    <div ref={ref} className={cn('browser-shadcn-breadcrumb-dropdown', className)} {...rest}>
      <span onClick={() => setOpen((value) => !value)}>{trigger}</span>
      {open ? <div className="browser-shadcn-breadcrumb-dropdown-menu">{dropdownItems}</div> : null}
    </div>
  );
});

const BrowserBreadcrumbDropdownItem = forwardRef<HTMLButtonElement, any>(function BrowserBreadcrumbDropdownItem(
  { children, onClick, ...rest },
  ref
) {
  return (
    <button ref={ref} type="button" className="browser-shadcn-breadcrumb-dropdown-item" onClick={onClick} {...rest}>
      {children}
    </button>
  );
});

const BrowserSelectItem = SelectItemMarker as any;
const BrowserSelectGroup = SelectGroupMarker as any;
const BrowserSelectSeparator = SelectSeparatorMarker as any;
const BrowserSelectTrigger = SelectTriggerMarker as any;
const BrowserSelectContent = SelectContentMarker as any;
const BrowserComboboxItem = SelectItemMarker as any;

const HybridButton = forwardRef<any, any>(function HybridButton(
  { loading, disabled, style, ...rest },
  ref
) {
  const isUnavailable = Boolean(disabled || loading);
  const mergedStyle = mergeStyles(
    isUnavailable
      ? {
          cursor: 'not-allowed',
          opacity: 0.55,
        }
      : undefined,
    style
  );

  if (isWebFRuntime()) {
    const Original = WebFShadcn.FlutterShadcnButton as React.ComponentType<any>;
    return (
      <Original
        ref={ref}
        loading={loading}
        disabled={isUnavailable}
        aria-disabled={isUnavailable}
        style={mergedStyle}
        {...rest}
      />
    );
  }

  return <BrowserButton ref={ref} loading={loading} disabled={isUnavailable} style={mergedStyle} {...rest} />;
});

const HybridIconButton = forwardRef<any, any>(function HybridIconButton(
  { loading, disabled, style, ...rest },
  ref
) {
  const isUnavailable = Boolean(disabled || loading);
  const mergedStyle = mergeStyles(
    isUnavailable
      ? {
          cursor: 'not-allowed',
          opacity: 0.55,
        }
      : undefined,
    style
  );

  if (isWebFRuntime()) {
    const Original = WebFShadcn.FlutterShadcnIconButton as React.ComponentType<any>;
    return (
      <Original
        ref={ref}
        loading={loading}
        disabled={isUnavailable}
        aria-disabled={isUnavailable}
        style={mergedStyle}
        {...rest}
      />
    );
  }

  return <BrowserIconButton ref={ref} loading={loading} disabled={isUnavailable} style={mergedStyle} {...rest} />;
});

export const FlutterShadcnTheme = hybridComponent('FlutterShadcnTheme', BrowserTheme);
export const FlutterShadcnButton = HybridButton;
export const FlutterShadcnIconButton = HybridIconButton;
export const FlutterShadcnInput = hybridComponent('FlutterShadcnInput', BrowserInput);
export const FlutterShadcnTextarea = hybridComponent('FlutterShadcnTextarea', BrowserTextarea);
export const FlutterShadcnBadge = hybridComponent('FlutterShadcnBadge', BrowserBadge);
export const FlutterShadcnAlert = hybridComponent('FlutterShadcnAlert', BrowserAlert);
export const FlutterShadcnAlertTitle = hybridComponent('FlutterShadcnAlertTitle', BrowserAlertTitle);
export const FlutterShadcnAlertDescription = hybridComponent('FlutterShadcnAlertDescription', BrowserAlertDescription);
export const FlutterShadcnAvatar = hybridComponent('FlutterShadcnAvatar', BrowserAvatar);
export const FlutterShadcnCard = hybridComponent('FlutterShadcnCard', BrowserCard);
export const FlutterShadcnCardHeader = hybridComponent('FlutterShadcnCardHeader', BrowserCardHeader);
export const FlutterShadcnCardTitle = hybridComponent('FlutterShadcnCardTitle', BrowserCardTitle);
export const FlutterShadcnCardDescription = hybridComponent('FlutterShadcnCardDescription', BrowserCardDescription);
export const FlutterShadcnCardContent = hybridComponent('FlutterShadcnCardContent', BrowserCardContent);
export const FlutterShadcnCardFooter = hybridComponent('FlutterShadcnCardFooter', BrowserCardFooter);
export const FlutterShadcnProgress = hybridComponent('FlutterShadcnProgress', BrowserProgress);
export const FlutterShadcnSkeleton = hybridComponent('FlutterShadcnSkeleton', BrowserSkeleton);
export const FlutterShadcnBreadcrumb = hybridComponent('FlutterShadcnBreadcrumb', BrowserBreadcrumb);
export const FlutterShadcnBreadcrumbList = hybridComponent('FlutterShadcnBreadcrumbList', BrowserBreadcrumbList);
export const FlutterShadcnBreadcrumbItem = hybridComponent('FlutterShadcnBreadcrumbItem', BrowserBreadcrumbItem);
export const FlutterShadcnBreadcrumbLink = hybridComponent('FlutterShadcnBreadcrumbLink', BrowserBreadcrumbLink);
export const FlutterShadcnBreadcrumbPage = hybridComponent('FlutterShadcnBreadcrumbPage', BrowserBreadcrumbPage);
export const FlutterShadcnBreadcrumbSeparator = hybridComponent('FlutterShadcnBreadcrumbSeparator', BrowserBreadcrumbSeparator);
export const FlutterShadcnBreadcrumbEllipsis = hybridComponent('FlutterShadcnBreadcrumbEllipsis', BrowserBreadcrumbEllipsis);
export const FlutterShadcnBreadcrumbDropdown = hybridComponent('FlutterShadcnBreadcrumbDropdown', BrowserBreadcrumbDropdown);
export const FlutterShadcnBreadcrumbDropdownItem = hybridComponent(
  'FlutterShadcnBreadcrumbDropdownItem',
  BrowserBreadcrumbDropdownItem
);
export const FlutterShadcnTabs = hybridComponent('FlutterShadcnTabs', BrowserTabs);
export const FlutterShadcnTabsList = hybridComponent('FlutterShadcnTabsList', BrowserTabsList);
export const FlutterShadcnTabsTrigger = hybridComponent('FlutterShadcnTabsTrigger', BrowserTabsTrigger);
export const FlutterShadcnTabsContent = hybridComponent('FlutterShadcnTabsContent', BrowserTabsContent);
export const FlutterShadcnAccordion = hybridComponent('FlutterShadcnAccordion', BrowserAccordion);
export const FlutterShadcnAccordionItem = hybridComponent('FlutterShadcnAccordionItem', BrowserAccordionItem);
export const FlutterShadcnAccordionTrigger = hybridComponent('FlutterShadcnAccordionTrigger', BrowserAccordionTrigger);
export const FlutterShadcnAccordionContent = hybridComponent('FlutterShadcnAccordionContent', BrowserAccordionContent);
export const FlutterShadcnRadio = hybridComponent('FlutterShadcnRadio', BrowserRadio);
export const FlutterShadcnRadioItem = hybridComponent('FlutterShadcnRadioItem', BrowserRadioItem);
export const FlutterShadcnCheckbox = hybridComponent('FlutterShadcnCheckbox', BrowserCheckbox);
export const FlutterShadcnSwitch = hybridComponent('FlutterShadcnSwitch', BrowserSwitch);
export const FlutterShadcnSelect = hybridComponent('FlutterShadcnSelect', BrowserSelect);
export const FlutterShadcnSelectItem = hybridComponent('FlutterShadcnSelectItem', BrowserSelectItem);
export const FlutterShadcnSelectGroup = hybridComponent('FlutterShadcnSelectGroup', BrowserSelectGroup);
export const FlutterShadcnSelectSeparator = hybridComponent('FlutterShadcnSelectSeparator', BrowserSelectSeparator);
export const FlutterShadcnSelectTrigger = hybridComponent('FlutterShadcnSelectTrigger', BrowserSelectTrigger);
export const FlutterShadcnSelectContent = hybridComponent('FlutterShadcnSelectContent', BrowserSelectContent);
export const FlutterShadcnCombobox = hybridComponent('FlutterShadcnCombobox', BrowserCombobox);
export const FlutterShadcnComboboxItem = hybridComponent('FlutterShadcnComboboxItem', BrowserComboboxItem);
export const FlutterShadcnSlider = hybridComponent('FlutterShadcnSlider', BrowserSlider);
export const FlutterShadcnTable = hybridComponent('FlutterShadcnTable', BrowserTable);
export const FlutterShadcnTableHeader = hybridComponent('FlutterShadcnTableHeader', BrowserTableHeader);
export const FlutterShadcnTableBody = hybridComponent('FlutterShadcnTableBody', BrowserTableBody);
export const FlutterShadcnTableRow = hybridComponent('FlutterShadcnTableRow', BrowserTableRow);
export const FlutterShadcnTableHead = hybridComponent('FlutterShadcnTableHead', BrowserTableHead);
export const FlutterShadcnTableCell = hybridComponent('FlutterShadcnTableCell', BrowserTableCell);
export const FlutterShadcnDropdownMenu = hybridComponent('FlutterShadcnDropdownMenu', BrowserDropdownMenu);
export const FlutterShadcnDropdownMenuTrigger = hybridComponent('FlutterShadcnDropdownMenuTrigger', BrowserDropdownMenuTrigger);
export const FlutterShadcnDropdownMenuContent = hybridComponent('FlutterShadcnDropdownMenuContent', BrowserDropdownMenuContent);
export const FlutterShadcnDropdownMenuItem = hybridComponent('FlutterShadcnDropdownMenuItem', BrowserDropdownMenuItem);
export const FlutterShadcnDropdownMenuSeparator = hybridComponent(
  'FlutterShadcnDropdownMenuSeparator',
  BrowserDropdownMenuSeparator
);
export const FlutterShadcnDropdownMenuLabel = hybridComponent('FlutterShadcnDropdownMenuLabel', BrowserDropdownMenuLabel);
export const FlutterShadcnPopover = hybridComponent('FlutterShadcnPopover', BrowserPopover);
export const FlutterShadcnPopoverTrigger = hybridComponent('FlutterShadcnPopoverTrigger', BrowserPopoverTrigger);
export const FlutterShadcnPopoverContent = hybridComponent('FlutterShadcnPopoverContent', BrowserPopoverContent);
export const FlutterShadcnTooltip = hybridComponent('FlutterShadcnTooltip', BrowserTooltip);
export const FlutterShadcnDialog = hybridComponent('FlutterShadcnDialog', BrowserDialog);
export const FlutterShadcnDialogContent = hybridComponent('FlutterShadcnDialogContent', BrowserDialogContent);
export const FlutterShadcnDialogHeader = hybridComponent('FlutterShadcnDialogHeader', BrowserDialogHeader);
export const FlutterShadcnDialogTitle = hybridComponent('FlutterShadcnDialogTitle', BrowserDialogTitle);
export const FlutterShadcnDialogDescription = hybridComponent(
  'FlutterShadcnDialogDescription',
  BrowserDialogDescription
);
export const FlutterShadcnDialogFooter = hybridComponent('FlutterShadcnDialogFooter', BrowserDialogFooter);
export const FlutterShadcnSheet = hybridComponent('FlutterShadcnSheet', BrowserSheet);
export const FlutterShadcnSheetContent = hybridComponent('FlutterShadcnSheetContent', BrowserSheetContent);
export const FlutterShadcnSheetHeader = hybridComponent('FlutterShadcnSheetHeader', BrowserSheetHeader);
export const FlutterShadcnSheetTitle = hybridComponent('FlutterShadcnSheetTitle', BrowserSheetTitle);
export const FlutterShadcnSheetDescription = hybridComponent(
  'FlutterShadcnSheetDescription',
  BrowserSheetDescription
);
export const FlutterShadcnContextMenu = hybridComponent('FlutterShadcnContextMenu', BrowserContextMenu);
export const FlutterShadcnContextMenuTrigger = hybridComponent(
  'FlutterShadcnContextMenuTrigger',
  BrowserContextMenuTrigger
);
export const FlutterShadcnContextMenuContent = hybridComponent(
  'FlutterShadcnContextMenuContent',
  BrowserContextMenuContent
);
export const FlutterShadcnContextMenuItem = hybridComponent('FlutterShadcnContextMenuItem', BrowserDropdownMenuItem);
export const FlutterShadcnContextMenuSeparator = hybridComponent(
  'FlutterShadcnContextMenuSeparator',
  BrowserDropdownMenuSeparator
);
export const FlutterShadcnContextMenuLabel = hybridComponent('FlutterShadcnContextMenuLabel', BrowserDropdownMenuLabel);
export const FlutterShadcnContextMenuSub = hybridComponent('FlutterShadcnContextMenuSub', BrowserContextMenuSub);
export const FlutterShadcnContextMenuSubTrigger = hybridComponent(
  'FlutterShadcnContextMenuSubTrigger',
  BrowserContextMenuSubTrigger
);
export const FlutterShadcnContextMenuSubContent = hybridComponent(
  'FlutterShadcnContextMenuSubContent',
  BrowserContextMenuSubContent
);
export const FlutterShadcnContextMenuCheckboxItem = hybridComponent(
  'FlutterShadcnContextMenuCheckboxItem',
  BrowserContextMenuCheckboxItem
);
export const FlutterShadcnContextMenuRadioGroup = hybridComponent(
  'FlutterShadcnContextMenuRadioGroup',
  BrowserContextMenuRadioGroup
);
export const FlutterShadcnContextMenuRadioItem = hybridComponent(
  'FlutterShadcnContextMenuRadioItem',
  BrowserContextMenuRadioItem
);
export const FlutterShadcnCalendar = hybridComponent('FlutterShadcnCalendar', BrowserCalendar);
export const FlutterShadcnDatePicker = hybridComponent('FlutterShadcnDatePicker', BrowserDatePicker);
export const FlutterShadcnForm = hybridComponent('FlutterShadcnForm', BrowserForm);
export const FlutterShadcnFormField = hybridComponent('FlutterShadcnFormField', BrowserFormField);
export const FlutterShadcnFormLabel = hybridComponent('FlutterShadcnFormLabel', BrowserFormLabel);
export const FlutterShadcnFormDescription = hybridComponent(
  'FlutterShadcnFormDescription',
  BrowserFormDescription
);
export const FlutterShadcnFormMessage = hybridComponent('FlutterShadcnFormMessage', BrowserFormMessage);
