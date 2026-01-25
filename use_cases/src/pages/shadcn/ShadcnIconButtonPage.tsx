import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterShadcnTheme,
  FlutterShadcnIconButton,
} from '@openwebf/react-shadcn-ui';

export const ShadcnIconButtonPage: React.FC = () => {
  const handleClick = (variant: string) => {
    console.log(`${variant} icon button clicked`);
  };

  return (
    <FlutterShadcnTheme colorScheme="zinc" brightness="light">
      <div className="min-h-screen w-full bg-white">
        <WebFListView className="w-full px-4 py-6 max-w-2xl mx-auto">
          <h1 className="text-2xl font-bold mb-6">Icon Button</h1>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Variants</h2>
            <p className="text-sm text-gray-600 mb-4">
              Icon buttons come in five variants: primary, secondary, destructive, outline, and ghost.
            </p>
            <div className="flex flex-wrap gap-4">
              <FlutterShadcnIconButton
                icon="rocket"
                variant="primary"
                onClick={() => handleClick('Primary')}
              />
              <FlutterShadcnIconButton
                icon="rocket"
                variant="secondary"
                onClick={() => handleClick('Secondary')}
              />
              <FlutterShadcnIconButton
                icon="rocket"
                variant="destructive"
                onClick={() => handleClick('Destructive')}
              />
              <FlutterShadcnIconButton
                icon="rocket"
                variant="outline"
                onClick={() => handleClick('Outline')}
              />
              <FlutterShadcnIconButton
                icon="rocket"
                variant="ghost"
                onClick={() => handleClick('Ghost')}
              />
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Common Icons</h2>
            <p className="text-sm text-gray-600 mb-4">
              Various Lucide icons can be used by specifying the icon name.
            </p>
            <div className="flex flex-wrap gap-4">
              <FlutterShadcnIconButton icon="plus" variant="outline" />
              <FlutterShadcnIconButton icon="minus" variant="outline" />
              <FlutterShadcnIconButton icon="search" variant="outline" />
              <FlutterShadcnIconButton icon="settings" variant="outline" />
              <FlutterShadcnIconButton icon="edit" variant="outline" />
              <FlutterShadcnIconButton icon="trash" variant="outline" />
              <FlutterShadcnIconButton icon="copy" variant="outline" />
              <FlutterShadcnIconButton icon="share" variant="outline" />
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Navigation Icons</h2>
            <p className="text-sm text-gray-600 mb-4">
              Commonly used for navigation and directional actions.
            </p>
            <div className="flex flex-wrap gap-4">
              <FlutterShadcnIconButton icon="chevron-left" variant="outline" />
              <FlutterShadcnIconButton icon="chevron-right" variant="outline" />
              <FlutterShadcnIconButton icon="chevron-up" variant="outline" />
              <FlutterShadcnIconButton icon="chevron-down" variant="outline" />
              <FlutterShadcnIconButton icon="arrow-left" variant="ghost" />
              <FlutterShadcnIconButton icon="arrow-right" variant="ghost" />
              <FlutterShadcnIconButton icon="external-link" variant="ghost" />
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Status Icons</h2>
            <p className="text-sm text-gray-600 mb-4">
              Icons for indicating status or providing feedback.
            </p>
            <div className="flex flex-wrap gap-4">
              <FlutterShadcnIconButton icon="check" variant="primary" />
              <FlutterShadcnIconButton icon="x" variant="destructive" />
              <FlutterShadcnIconButton icon="info" variant="secondary" />
              <FlutterShadcnIconButton icon="warning" variant="outline" />
              <FlutterShadcnIconButton icon="help" variant="ghost" />
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Media Controls</h2>
            <p className="text-sm text-gray-600 mb-4">
              Icons for media playback and controls.
            </p>
            <div className="flex flex-wrap gap-4">
              <FlutterShadcnIconButton icon="play" variant="primary" />
              <FlutterShadcnIconButton icon="pause" variant="secondary" />
              <FlutterShadcnIconButton icon="stop" variant="outline" />
              <FlutterShadcnIconButton icon="refresh" variant="ghost" />
              <FlutterShadcnIconButton icon="download" variant="outline" />
              <FlutterShadcnIconButton icon="upload" variant="outline" />
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Custom Icon Size</h2>
            <p className="text-sm text-gray-600 mb-4">
              Icon size can be customized using the iconSize property.
            </p>
            <div className="flex flex-wrap items-center gap-4">
              <FlutterShadcnIconButton icon="star" iconSize={12} variant="outline" />
              <FlutterShadcnIconButton icon="star" iconSize={16} variant="outline" />
              <FlutterShadcnIconButton icon="star" iconSize={20} variant="outline" />
              <FlutterShadcnIconButton icon="star" iconSize={24} variant="outline" />
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Disabled State</h2>
            <p className="text-sm text-gray-600 mb-4">
              Icon buttons can be disabled to prevent interaction.
            </p>
            <div className="flex flex-wrap gap-4">
              <FlutterShadcnIconButton icon="rocket" variant="primary" disabled />
              <FlutterShadcnIconButton icon="rocket" variant="secondary" disabled />
              <FlutterShadcnIconButton icon="rocket" variant="destructive" disabled />
              <FlutterShadcnIconButton icon="rocket" variant="outline" disabled />
              <FlutterShadcnIconButton icon="rocket" variant="ghost" disabled />
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Loading State</h2>
            <p className="text-sm text-gray-600 mb-4">
              Show a loading spinner to indicate an action is in progress.
            </p>
            <div className="flex flex-wrap gap-4">
              <FlutterShadcnIconButton icon="rocket" variant="primary" loading />
              <FlutterShadcnIconButton icon="rocket" variant="secondary" loading />
              <FlutterShadcnIconButton icon="rocket" variant="destructive" loading />
              <FlutterShadcnIconButton icon="rocket" variant="outline" loading />
              <FlutterShadcnIconButton icon="rocket" variant="ghost" loading />
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">With Gradient and Shadow</h2>
            <p className="text-sm text-gray-600 mb-4">
              Icon buttons support CSS gradients and shadows for custom styling.
            </p>
            <div className="flex flex-wrap gap-4">
              <FlutterShadcnIconButton
                icon="star"
                style={{
                  backgroundImage: 'linear-gradient(to right, #06b6d4, #6366f1)',
                  boxShadow: '0 4px 10px rgba(99, 102, 241, 0.4)',
                }}
              />
              <FlutterShadcnIconButton
                icon="heart"
                style={{
                  backgroundImage: 'linear-gradient(to right, #f43f5e, #ec4899)',
                  boxShadow: '0 4px 10px rgba(244, 63, 94, 0.4)',
                }}
              />
              <FlutterShadcnIconButton
                icon="zap"
                style={{
                  backgroundImage: 'linear-gradient(to right, #f59e0b, #ef4444)',
                  boxShadow: '0 4px 10px rgba(245, 158, 11, 0.4)',
                }}
              />
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Social Icons</h2>
            <p className="text-sm text-gray-600 mb-4">
              Common social media and brand icons.
            </p>
            <div className="flex flex-wrap gap-4">
              <FlutterShadcnIconButton icon="github" variant="outline" />
              <FlutterShadcnIconButton icon="twitter" variant="outline" />
              <FlutterShadcnIconButton icon="facebook" variant="outline" />
              <FlutterShadcnIconButton icon="instagram" variant="outline" />
              <FlutterShadcnIconButton icon="linkedin" variant="outline" />
              <FlutterShadcnIconButton icon="youtube" variant="outline" />
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Use Cases</h2>
            <p className="text-sm text-gray-600 mb-4">
              Common UI patterns using icon buttons.
            </p>

            <div className="space-y-4">
              <div className="flex items-center gap-2 p-3 border rounded-lg">
                <span className="flex-1 text-sm">Toolbar buttons</span>
                <FlutterShadcnIconButton icon="bold" variant="ghost" iconSize={14} />
                <FlutterShadcnIconButton icon="italic" variant="ghost" iconSize={14} />
                <FlutterShadcnIconButton icon="underline" variant="ghost" iconSize={14} />
                <span className="mx-2 text-gray-300">|</span>
                <FlutterShadcnIconButton icon="align-left" variant="ghost" iconSize={14} />
                <FlutterShadcnIconButton icon="align-center" variant="ghost" iconSize={14} />
                <FlutterShadcnIconButton icon="align-right" variant="ghost" iconSize={14} />
              </div>

              <div className="flex items-center gap-2 p-3 border rounded-lg">
                <span className="flex-1 text-sm">Action buttons</span>
                <FlutterShadcnIconButton icon="edit" variant="ghost" iconSize={14} />
                <FlutterShadcnIconButton icon="copy" variant="ghost" iconSize={14} />
                <FlutterShadcnIconButton icon="trash" variant="ghost" iconSize={14} />
                <FlutterShadcnIconButton icon="more-horizontal" variant="ghost" iconSize={14} />
              </div>

              <div className="flex items-center gap-2 p-3 border rounded-lg">
                <FlutterShadcnIconButton icon="chevron-left" variant="outline" />
                <span className="flex-1 text-center text-sm">Navigation</span>
                <FlutterShadcnIconButton icon="chevron-right" variant="outline" />
              </div>
            </div>
          </div>
        </WebFListView>
      </div>
    </FlutterShadcnTheme>
  );
};
