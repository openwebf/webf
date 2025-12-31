import React from 'react';
import { RoutingDemoShell } from './RoutingDemoShell';
import { RouterDemoUser } from './RouterDemoUser';

export const RoutingUserPage: React.FC = () => {
  return (
    <RoutingDemoShell title="Routing Demo: User">
      <RouterDemoUser />
    </RoutingDemoShell>
  );
};

