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
import { WebFRouter } from './utils';

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
}

/**
 * Route Component
 *
 * Responsible for managing page rendering, lifecycle and navigation bar
 */
export function Route({path, prerender = false, element }: RouteProps) {
  // Mark whether the page has been rendered
  const [hasRendered, updateRender] = useState(WebFRouter.path === path)

  /**
   * Rendering control logic
   */
  const shouldPrerender = prerender || WebFRouter.path === path
  const shouldRenderChildren = shouldPrerender || hasRendered

  // /**
  //  * Listen to route state changes, update context and rendering state
  //  */
  // const handleRouteStateChange = useMemoizedFn(event => {
  //   // Create new context object
  //   const newContext: RouteContext = {
  //     ...context,
  //     path,
  //     params: event.state
  //   }

  //   // Check if context has changed
  //   const isSameContext = isEqual(context, newContext)

  //   // Update state when context changes
  //   if (!isSameContext) {
  //     setContext(newContext)
  //   }

  //   if (event.kind === 'didPush') {
  //     setHasRendered(true)
  //   }
  // })

  /**
   * Handle page display event
   */
  const handleOnScreen = useMemoizedFn(() => {
    console.log('on screen');
    updateRender(true);
    // logger.trace('onScreen', { path })
    // RouterEvents$.emit('onScreen', { path })
  })

  /**
   * Handle page hide event
   */
  const handleOffScreen = useMemoizedFn(() => {
    console.log('off screen');
    // RouterEvents$.emit('offScreen', { path })
  })

  return (
    <WebFRouterLink path={path} onScreen={handleOnScreen} offScreen={handleOffScreen}>
      {shouldRenderChildren ? element : null}
    </WebFRouterLink>
  )
}
