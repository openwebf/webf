import React, { forwardRef } from 'react';

export interface CreateComponentOptions {
  tagName: string;
  displayName: string;
  events?: Record<string, string>;
}

export function createComponent<T = HTMLElement>(options: CreateComponentOptions) {
  const { tagName, displayName, events = {} } = options;

  const Component = forwardRef<T, any>((props, ref) => {
    const { children, ...restProps } = props;

    // Convert event handlers
    const eventHandlers: Record<string, any> = {};
    Object.entries(events).forEach(([reactEvent, domEvent]) => {
      if (props[reactEvent]) {
        eventHandlers[`on${domEvent}`] = props[reactEvent];
      }
    });

    // Handle attribute casing for WebF custom elements
    const processedProps: Record<string, any> = {};
    Object.entries(restProps).forEach(([key, value]) => {
      // Handle event handlers
      if (key.startsWith('on')) {
        // If this event is mapped in our events config, skip it (handled by eventHandlers)
        if (events[key]) {
          return;
        }
        // Otherwise, pass the event handler through directly
        // This allows onClick to work on WebF custom elements
        processedProps[key.toLowerCase()] = value;
        return;
      }
      
      // Convert camelCase to kebab-case for HTML attributes, but preserve some special cases
      if (key !== 'className' && key !== 'ref' && key !== 'key') {
        // For WebF custom elements, preserve camelCase for certain attributes
        const webfCamelCaseAttrs = ['maskClosable', 'backgroundOpacity', 'surfacePainted', 'enableHapticFeedback', 'isDestructiveAction', 'confirmDestructive', 'cancelDefault'];
        
        if (webfCamelCaseAttrs.includes(key)) {
          // Keep camelCase for WebF specific attributes
          processedProps[key] = value;
        } else {
          // Convert to kebab-case as standard for other attributes
          const kebabKey = key.replace(/([A-Z])/g, '-$1').toLowerCase();
          processedProps[kebabKey] = value;
        }
      } else {
        processedProps[key] = value;
      }
    });

    return React.createElement(
      tagName,
      {
        ...processedProps,
        ...eventHandlers,
        ref,
      },
      children
    );
  });

  Component.displayName = displayName;
  return Component;
}