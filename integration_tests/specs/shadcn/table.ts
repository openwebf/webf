import React from 'react';
import { TableFixture } from './shadcn-component';
import { runShadcnCase } from './shadcn-test-utils';

// TODO not implement Table Element
xdescribe('Shadcn table integration', () => {
  it('shadcn_table', async () => {
    await runShadcnCase(
      React.createElement(TableFixture),
      ['shadcn_table', 'Official table sample', 'INV001', '$150.00'],
      async (container) => {
        expect(container.querySelector('table')).not.toBeNull();
        await snapshot();
      },
    );
  });
});
