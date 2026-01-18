import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterShadcnTheme,
  FlutterShadcnButton,
} from '@openwebf/react-shadcn-ui';

export const ShadcnButtonsPage: React.FC = () => {
  const handleClick = (variant: string) => {
    console.log(`Button clicked: ${variant}`);
  };

  return (
    <FlutterShadcnTheme colorScheme="zinc" brightness="light">
      <div className="min-h-screen w-full bg-white">
        <WebFListView className="w-full px-4 py-6 max-w-2xl mx-auto">
          <h1 className="text-2xl font-bold mb-6">Shadcn Buttons</h1>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Button Variants</h2>
            <div className="flex flex-wrap gap-3">
              <FlutterShadcnButton variant="default" onClick={() => handleClick('default')}>
                Default
              </FlutterShadcnButton>
              <FlutterShadcnButton variant="secondary" onClick={() => handleClick('secondary')}>
                Secondary
              </FlutterShadcnButton>
              <FlutterShadcnButton variant="destructive" onClick={() => handleClick('destructive')}>
                Destructive
              </FlutterShadcnButton>
              <FlutterShadcnButton variant="outline" onClick={() => handleClick('outline')}>
                Outline
              </FlutterShadcnButton>
              <FlutterShadcnButton variant="ghost" onClick={() => handleClick('ghost')}>
                Ghost
              </FlutterShadcnButton>
              <FlutterShadcnButton variant="link" onClick={() => handleClick('link')}>
                Link
              </FlutterShadcnButton>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Button Sizes</h2>
            <div className="flex flex-wrap gap-3 items-center">
              <FlutterShadcnButton size="sm">Small</FlutterShadcnButton>
              <FlutterShadcnButton size="default">Default</FlutterShadcnButton>
              <FlutterShadcnButton size="lg">Large</FlutterShadcnButton>
              <FlutterShadcnButton size="icon">+</FlutterShadcnButton>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Disabled State</h2>
            <div className="flex flex-wrap gap-3">
              <FlutterShadcnButton disabled>Disabled Default</FlutterShadcnButton>
              <FlutterShadcnButton variant="secondary" disabled>Disabled Secondary</FlutterShadcnButton>
              <FlutterShadcnButton variant="destructive" disabled>Disabled Destructive</FlutterShadcnButton>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Loading State</h2>
            <div className="flex flex-wrap gap-3">
              <FlutterShadcnButton loading>Loading...</FlutterShadcnButton>
              <FlutterShadcnButton variant="outline" loading>Processing</FlutterShadcnButton>
            </div>
          </div>
        </WebFListView>
      </div>
    </FlutterShadcnTheme>
  );
};
