import React, { PropsWithChildren, useEffect } from 'react';

// Always import types/values; choose at runtime which to expose
import * as WebFLib from '@openwebf/react-router';
import {
  BrowserRouter,
  Link as RRDLink,
  Route as RRDRoute,
  Routes as RRDRoutes,
  useLocation as RRDUseLocation,
  useNavigate,
  useParams as RRDUseParams,
} from 'react-router-dom';

const isWebF = typeof window !== 'undefined' && !!(window as any).webf;

// Navigator bridge for browser environment
type NavigateFn = (to: string, options?: { replace?: boolean; state?: any }) => void;
let navigateImpl: NavigateFn = (to, options) => {
  // Fallback if navigate not yet registered
  if (options?.replace) {
    window.location.replace(to);
  } else {
    window.location.assign(to);
  }
};

const NavigatorRegistrar: React.FC = () => {
  const navigate = useNavigate();
  useEffect(() => {
    navigateImpl = (to, options) => navigate(to, options);
  }, [navigate]);
  return null;
};

export const RouterProvider: React.FC<PropsWithChildren<{}>> = ({ children }) => {
  if (isWebF) {
    return <>{children}</>;
  }
  return (
    <BrowserRouter>
      <NavigatorRegistrar />
      {children}
    </BrowserRouter>
  );
};

// Hooks
export const useParams: typeof RRDUseParams = isWebF ? (WebFLib as any).useParams : RRDUseParams;
export const useLocation: typeof RRDUseLocation = isWebF ? (WebFLib as any).useLocation : RRDUseLocation;

// Components (use any typing to allow extra props like `title`)
export const Routes: any = isWebF ? (WebFLib as any).Routes : (RRDRoutes as any);
export const Route: any = isWebF ? (WebFLib as any).Route : (RRDRoute as any);

// WebFRouterLink shim for browser
type WebFRouterLinkProps = PropsWithChildren<{
  path: string;
  title?: string;
  onScreen?: () => void;
}>;

export const WebFRouterLink: React.FC<WebFRouterLinkProps> = isWebF
  ? (WebFLib as any).WebFRouterLink
  : ({ path, children, onScreen }: WebFRouterLinkProps) => {
      useEffect(() => {
        onScreen?.();
      }, [onScreen]);
      return <RRDLink to={path}>{children}</RRDLink>;
    };

export const WebFRouter = isWebF
  ? ((WebFLib as any).WebFRouter)
  : {
      pushState: (state: any, path: string) => navigateImpl(path, { state }),
      replaceState: (state: any, path: string) => navigateImpl(path, { replace: true, state }),
      back: () => window.history.back(),
      push: async (path: string, state?: any) => {
        navigateImpl(path, { state });
        return true;
      },
      replace: async (path: string, state?: any) => {
        navigateImpl(path, { replace: true, state });
        return true;
      },
      popAndPushNamed: async (path: string, state?: any) => {
        // Approximate by replacing current entry
        navigateImpl(path, { replace: true, state });
        return true;
      },
      canPop: () => window.history.length > 1,
      maybePop: (opts?: { cancelled?: boolean }) => {
        if (window.history.length > 1) {
          window.history.back();
          return true;
        }
        return false;
      },
      restorablePopAndPushNamed: async (path: string, state?: any) => {
        const restorationId = Date.now();
        navigateImpl(path, { state: { ...(state || {}), restorationId } });
        return restorationId;
      },
    };

export const isWebFEnvironment = isWebF;

