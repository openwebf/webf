import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/webf-react-core-ui";

<%= dependencies %>

export interface <%= className %>Props {
  <% _.forEach(properties?.props, function(prop, index) { %>
    <% var propName = _.camelCase(prop.name); %>
    <% var attributeName = _.kebabCase(prop.name); %>
  /**
   * <%= propName %> property
    <% if (prop.optional) { %>
   * @default undefined
    <% } %>
   */
    <% if (prop.optional) { %>
  <%= propName %>?: <%= generateReturnType(prop.type) %>;
    <% } else { %>
  <%= propName %>: <%= generateReturnType(prop.type) %>;
    <% } %>
  
  <% }); %>
  <% _.forEach(events?.props, function(prop, index) { %>
    <% var propName = toReactEventName(prop.name); %>
  /**
   * <%= prop.name %> event handler
   */
  <%= propName %>?: (event: <%= getEventType(prop.type) %>) => void;
  
  <% }); %>
  /**
   * Additional CSS styles
   */
  style?: React.CSSProperties;
  
  /**
   * Children elements
   */
  children?: React.ReactNode;
  
  /**
   * Additional CSS class names
   */
  className?: string;
}

export interface <%= className %>Element extends WebFElementWithMethods<{
  <% _.forEach(properties?.methods, function(method, index) { %>
  <%= generateMethodDeclaration(method) %>
  <% }); %>
}> {}

/**
 * <%= className %> - WebF <%= className %> component
 * 
 * @example
 * ```tsx
 * <<%= className %>
 *   // Add example props here
 * >
 *   Content
 * </<%= className %>>
 * ```
 */
export const <%= className %> = createWebFComponent<<%= className %>Element, <%= className %>Props>({
  tagName: '<%= _.kebabCase(className) %>',
  displayName: '<%= className %>',
  
  // Map props to attributes
  attributeProps: [<% _.forEach(properties?.props, function(prop, index) { %>
    <% var propName = _.camelCase(prop.name); %>'<%= propName %>',<% }); %>
  ],
  
  // Convert prop names to attribute names if needed
  attributeMap: {
    <% _.forEach(properties?.props, function(prop, index) { %>
      <% var propName = _.camelCase(prop.name); %>
      <% var attributeName = _.kebabCase(prop.name); %>
      <% if (propName !== attributeName) { %>
    <%= propName %>: '<%= attributeName %>',
      <% } %>
    <% }); %>
  },
  
  <% if (events) { %>
  // Event handlers
  events: [
    <% _.forEach(events?.props, function(prop, index) { %>
      <% var propName = toReactEventName(prop.name); %>
    {
      propName: '<%= propName %>',
      eventName: '<%= prop.name %>',
      handler: (callback) => (event) => {
        callback((event as <%= getEventType(prop.type) %>));
      },
    },
    <% }); %>
  ],
  <% } %>
  
  // Default prop values
  defaultProps: {
    // Add default values here
  },
});
