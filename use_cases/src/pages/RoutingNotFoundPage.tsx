import React from 'react';
import { RoutingDemoShell } from './RoutingDemoShell';
import { RouterDemoNotFound } from './RouterDemoNotFound';

export const RoutingNotFoundPage: React.FC = () => {
  return (
    <RoutingDemoShell title="Routing Demo: Not Found">
      <RouterDemoNotFound />
    </RoutingDemoShell>
  );
};

