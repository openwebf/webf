import React from "react";
import { createWebFComponent, WebFElementWithMethods } from "@openwebf/react-core-ui";

<%= dependencies %>

export interface <%= className %>Props {
  <% _.forEach(properties?.props, function(prop, index) { %>
    <% var propName = _.camelCase(prop.name); %>
    <% var attributeName = _.kebabCase(prop.name); %>
    <% if (prop.documentation) { %>
  /**
   * <%= prop.documentation.split('\n').join('\n   * ') %>
   */
    <% } else { %>
  /**
   * <%= propName %> property
    <% if (prop.optional) { %>
   * @default undefined
    <% } %>
   */
    <% } %>
    <% if (prop.optional) { %>
  <%= propName %>?: <%= generateReturnType(prop.type) %>;
    <% } else { %>
  <%= propName %>: <%= generateReturnType(prop.type) %>;
    <% } %>
  
  <% }); %>
  <% _.forEach(events?.props, function(prop, index) { %>
    <% var propName = toReactEventName(prop.name); %>
    <% if (prop.documentation) { %>
  /**
   * <%= prop.documentation.split('\n').join('\n   * ') %>
   */
    <% } else { %>
  /**
   * <%= prop.name %> event handler
   */
    <% } %>
  <%= propName %>?: (event: <%= getEventType(prop.type) %>) => void;
  
  <% }); %>
  /**
   * HTML id attribute
   */
  id?: string;
  
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

<% if (methods && methods.methods.length > 0) { %>
/**
 * Element interface with methods/properties accessible via ref
 * @example
 * ```tsx
 * const ref = useRef<<%= className %>Element>(null);
 * // Call methods on the element
 * ref.current?.finishRefresh('success');
<% if (properties && properties.props && properties.props.length > 0) { %>
 * // Access properties
 * console.log(ref.current?.<%= _.camelCase(properties.props[0].name || 'someProp') %>);
<% } %>
 * ```
 */
<% } %>
export interface <%= className %>Element extends WebFElementWithMethods<{
  <% _.forEach(methods?.methods, function(method, index) { %>
<%= generateMethodDeclarationWithDocs(method, '  ') %>
  <% }); %>
}> {
  <% _.forEach(properties?.props, function(prop, index) { %>
  <% var propName = _.camelCase(prop.name); %>
  <% if (prop.documentation) { %>
  /** <%= prop.documentation.split('\n')[0] %> */
  <% } %>
  <% if (prop.readonly) { %>
  readonly <%= propName %><% if (prop.optional) { %>?<% } %>: <%= generateReturnType(prop.type) %>;
  <% } else { %>
  <%= propName %><% if (prop.optional) { %>?<% } %>: <%= generateReturnType(prop.type) %>;
  <% } %>
  <% }); %>
}

<% if (properties?.documentation || methods?.documentation || events?.documentation) { %>
  <% const docs = properties?.documentation || methods?.documentation || events?.documentation; %>
/**
 * <%= docs %>
 * 
 * @example
 * ```tsx<% if (methods && methods.methods.length > 0) { %>
 * const ref = useRef<<%= className %>Element>(null);<% } %>
 * 
 * <<%= className %><% if (methods && methods.methods.length > 0) { %>
 *   ref={ref}<% } %>
 *   // Add props here
 * >
 *   Content
 * </<%= className %>><% if (methods && methods.methods.length > 0) { %>
 * 
 * // Call methods on the element
 * ref.current?.finishRefresh('success');<% } %>
 * ```
 */
<% } else { %>
/**
 * <%= className %> - WebF <%= className %> component
 * 
 * @example
 * ```tsx<% if (methods && methods.methods.length > 0) { %>
 * const ref = useRef<<%= className %>Element>(null);<% } %>
 * 
 * <<%= className %><% if (methods && methods.methods.length > 0) { %>
 *   ref={ref}<% } %>
 *   // Add props here
 * >
 *   Content
 * </<%= className %>><% if (methods && methods.methods.length > 0) { %>
 * 
 * // Call methods on the element
 * ref.current?.finishRefresh('success');<% } %>
 * ```
 */
<% } %>
export const <%= className %> = createWebFComponent<<%= className %>Element, <%= className %>Props>({
  tagName: '<%= toWebFTagName(className) %>',
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
      handler: (callback: (event: <%= getEventType(prop.type) %>) => void) => (event: Event) => {
        callback(event as <%= getEventType(prop.type) %>);
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
