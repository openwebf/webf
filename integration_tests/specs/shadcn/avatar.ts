import React from 'react';
import { AvatarFixture } from './shadcn-component';
import { runShadcnCase } from './shadcn-test-utils';

describe('Shadcn avatar integration', () => {
  it('shadcn_avatar', async () => {
    await runShadcnCase(
      React.createElement(AvatarFixture),
      ['shadcn_avatar', 'Jane Doe', 'JD'],
      async () => {
        await snapshot();
      },
    );
  });
});
