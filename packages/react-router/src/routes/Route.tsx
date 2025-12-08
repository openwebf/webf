/**
 * Route Component
 *
 * This component is a core part of the application routing system, responsible for:
 * 1. Managing page rendering and lifecycle
 * 2. Providing route context (RouteContext)
 * 3. Handling page navigation bar (AppBar)
 * 4. Providing page lifecycle hooks
 */

import React, { useState } from 'react'
// import { Router, RouterEvents$ } from './router'
import { useMemoizedFn } from 'ahooks';
import { WebFRouterLink } from '../utils/RouterLink';

/**
 * Route component props interface
 */
export interface RouteProps {
  /**
   * Page title
   * Displayed in the center of the navigation bar
   */
  title?: string
  /**
   * Page path
   * Must be a member of the RoutePath enum
   */
  path: string
  /**
   * Whether to pre-render
   * If true, the page will be rendered when the app starts, rather than waiting for route navigation
   * Can be used to improve page switching performance or preload data
   *
   * @default false
   */
  prerender?: boolean
  /**
   * Page content
   * The actual page component to render
   */
  element: React.ReactNode
  /**
   * Theme for this route
   * Controls the visual style of the navigation bar and page
   *
   * @default "material"
   */
  theme?: 'material' | 'cupertino'
}

/**
 * Route Component
 *
 * Responsible for managing page rendering, lifecycle and navigation bar
 */
export function Route({path, prerender = false, element, title, theme}: RouteProps) {
  // Mark whether the page has been rendered
  const [hasRendered, updateRender] = useState(false)

  /**
   * Rendering control logic
   */
  const shouldPrerender = prerender;
  const shouldRenderChildren = shouldPrerender || hasRendered

  /**
   * Handle page display event
   */
  const handleOnScreen = useMemoizedFn(() => {
    updateRender(true);
  })

  /**
   * Handle page hide event
   */
  const handleOffScreen = useMemoizedFn(() => {
  })

  return (
    <WebFRouterLink path={path} title={title} theme={theme} onScreen={handleOnScreen} offScreen={handleOffScreen}>
      {shouldRenderChildren ? element : null}
    </WebFRouterLink>
  )
}
