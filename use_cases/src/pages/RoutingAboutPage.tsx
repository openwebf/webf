import React from 'react';
import { RoutingDemoShell } from './RoutingDemoShell';
import { RouterDemoAbout } from './RouterDemoAbout';

export const RoutingAboutPage: React.FC = () => {
  return (
    <RoutingDemoShell title="Routing Demo: About">
      <RouterDemoAbout />
    </RoutingDemoShell>
  );
};

