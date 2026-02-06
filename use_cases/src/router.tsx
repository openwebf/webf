// Re-export everything from @openwebf/react-router which now has built-in browser support
export { Routes, Route, WebFRouterLink, WebFRouter, useParams, useLocation, useRouteContext, useNavigate, useRoutes, isWebF, isBrowser, platform } from '@openwebf/react-router';

// Backward-compatible alias
export { isWebF as isWebFEnvironment } from '@openwebf/react-router';