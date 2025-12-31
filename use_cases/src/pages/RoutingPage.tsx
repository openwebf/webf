import React from 'react';
import { RoutingDemoShell } from './RoutingDemoShell';
import { RouterDemoHome } from './RouterDemoHome';

export const RoutingPage: React.FC = () => {
  return (
    <RoutingDemoShell
      title="Routing & Navigation"
      description="Router demos rendered inside a scrollable WebFListView. Navigate within /routing/*."
    >
      <RouterDemoHome />
    </RoutingDemoShell>
  );
};

