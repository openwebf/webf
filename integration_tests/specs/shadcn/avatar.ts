import React from 'react';
import { AvatarFixture, AvatarImageFixture } from './shared/shadcn-component';
import { runShadcnCase } from './shared/shadcn-test-utils';

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
  
  it('shadcn_avatar_image', async () => {
      await runShadcnCase(
        React.createElement(AvatarImageFixture),
        ['shadcn_avatar_image', 'OpenWebF', 'Image avatar fixture'],
        async (container) => {
          const image = container.querySelector('img[alt="OpenWebF avatar"]') as HTMLImageElement | null;
          expect(image).not.toBeNull();
          expect(image!.getAttribute('src')?.startsWith('data:image/svg+xml;utf8,')).toBe(true);
          expect(container.textContent).not.toContain('OW');
          await snapshot();
        },
      );
    });
});
