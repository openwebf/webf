import React, { useState, ReactNode } from 'react';
import { WebFRouterLink } from '../router';

interface RouterViewProps {
  path: string;
  title?: string;
  children?: ReactNode;
}

export const RouterView: React.FC<RouterViewProps> = ({ path, title, children }) => {
  const [isMounted, setIsMounted] = useState(false);

  const handleOnScreen = () => {
    setIsMounted(true);
  };

  return (
    <WebFRouterLink path={path} title={title} onScreen={handleOnScreen}>
      {isMounted ? children : null}
    </WebFRouterLink>
  );
};
