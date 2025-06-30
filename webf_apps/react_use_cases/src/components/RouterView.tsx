import React, { useState, ReactNode } from 'react';
import { createComponent } from '../utils/CreateComponent';

interface RouterViewProps {
  path: string;
  title?: string;
  children?: ReactNode;
}

const WebFRouterLink = createComponent({
  tagName: 'webf-router-link',
  displayName: 'WebFRouterLink',
  events: {
    onOnScreen: 'onscreen'
  }
});

export const RouterView: React.FC<RouterViewProps> = ({ path, title, children }) => {
  const [isMounted, setIsMounted] = useState(false);

  const handleOnScreen = () => {
    setIsMounted(true);
  };

  return (
    <WebFRouterLink path={path} title={title} onOnScreen={handleOnScreen}>
      {isMounted ? children : null}
    </WebFRouterLink>
  );
};