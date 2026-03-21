import React, { useEffect } from 'react';
import {
  Routes as BaseRoutes,
  Route,
  WebFRouterLink,
  WebFRouter,
  useParams,
  useLocation,
  useRouteContext,
  useNavigate,
  useRoutes,
  isWebF,
  isBrowser,
  platform,
  __unstable_setEnsureRouteMountedCallback,
} from '@openwebf/react-router';

type BaseRoutesProps = React.ComponentProps<typeof BaseRoutes>;

export function Routes(props: BaseRoutesProps) {
  useEffect(() => {
    if (!isBrowser()) {
      return;
    }

    // Browser mode does not render <webf-router-link>, so the upstream
    // ensureRouteMounted guard never resolves and push/replace hang forever.
    const timer = window.setTimeout(() => {
      __unstable_setEnsureRouteMountedCallback(() => undefined);
    }, 0);

    return () => {
      window.clearTimeout(timer);
      __unstable_setEnsureRouteMountedCallback(null);
    };
  }, []);

  return <BaseRoutes {...props} />;
}

export {
  Route,
  WebFRouterLink,
  WebFRouter,
  useParams,
  useLocation,
  useRouteContext,
  useNavigate,
  useRoutes,
  isWebF,
  isBrowser,
  platform,
};

// Backward-compatible alias
export { isWebF as isWebFEnvironment };
