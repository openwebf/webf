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

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">With Shadow</h2>
            <div className="flex flex-wrap gap-3">
              <FlutterShadcnButton
                style={{ boxShadow: '0 4px 6px 0 rgba(0, 0, 0, 0.1)' }}
              >
                Shadow SM
              </FlutterShadcnButton>
              <FlutterShadcnButton
                style={{ boxShadow: '0 10px 15px 0 rgba(0, 0, 0, 0.15)' }}
              >
                Shadow MD
              </FlutterShadcnButton>
              <FlutterShadcnButton
                style={{ boxShadow: '0 20px 25px 4px rgba(0, 0, 0, 0.2)' }}
              >
                Shadow LG
              </FlutterShadcnButton>
              <FlutterShadcnButton
                variant="destructive"
                style={{ boxShadow: '0 10px 20px 0 rgba(239, 68, 68, 0.4)' }}
              >
                Colored Shadow
              </FlutterShadcnButton>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">With Gradient</h2>
            <div className="flex flex-wrap gap-3">
              <FlutterShadcnButton
                style={{ backgroundImage: 'linear-gradient(to right, #667eea, #764ba2)' }}
              >
                Purple Gradient
              </FlutterShadcnButton>
              <FlutterShadcnButton
                style={{ backgroundImage: 'linear-gradient(to right, #f093fb, #f5576c)' }}
              >
                Pink Gradient
              </FlutterShadcnButton>
              <FlutterShadcnButton
                style={{ backgroundImage: 'linear-gradient(to right, #4facfe, #00f2fe)' }}
              >
                Blue Gradient
              </FlutterShadcnButton>
              <FlutterShadcnButton
                style={{ backgroundImage: 'linear-gradient(to right, #43e97b, #38f9d7)' }}
              >
                Green Gradient
              </FlutterShadcnButton>
              <FlutterShadcnButton
                style={{
                  backgroundImage: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
                  boxShadow: '0 10px 20px 0 rgba(102, 126, 234, 0.4)'
                }}
              >
                Gradient + Shadow
              </FlutterShadcnButton>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Custom Styled Text</h2>
            <div className="flex flex-wrap gap-3">
              <FlutterShadcnButton>
                <span style={{ fontSize: '18px', fontWeight: 'bold' }}>Large Bold</span>
              </FlutterShadcnButton>
              <FlutterShadcnButton variant="secondary">
                <span style={{ fontStyle: 'italic' }}>Italic Text</span>
              </FlutterShadcnButton>
              <FlutterShadcnButton variant="outline">
                <span style={{ letterSpacing: '2px' }}>S P A C E D</span>
              </FlutterShadcnButton>
              <FlutterShadcnButton variant="ghost">
                <span style={{ textDecoration: 'underline' }}>Underlined</span>
              </FlutterShadcnButton>
            </div>
          </div>
        </WebFListView>
      </div>
    </FlutterShadcnTheme>
  );
};
