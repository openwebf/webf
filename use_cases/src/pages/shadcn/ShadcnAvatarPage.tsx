import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterShadcnTheme,
  FlutterShadcnAvatar,
} from '@openwebf/react-shadcn-ui';

export const ShadcnAvatarPage: React.FC = () => {
  return (
    <FlutterShadcnTheme colorScheme="zinc" brightness="light">
      <div className="min-h-screen w-full bg-white">
        <WebFListView className="w-full px-4 py-6 max-w-2xl mx-auto">
          <h1 className="text-2xl font-bold mb-6">Avatar</h1>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Basic Avatars</h2>
            <div className="flex gap-4 items-center">
              <FlutterShadcnAvatar
                src="https://github.com/shadcn.png"
                fallback="CN"
              />
              <FlutterShadcnAvatar
                src="https://github.com/vercel.png"
                fallback="VC"
              />
              <FlutterShadcnAvatar
                src="https://github.com/openwebf.png"
                fallback="WF"
              />
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Fallback Avatars</h2>
            <p className="text-sm text-gray-600 mb-4">When image fails to load, fallback text is shown.</p>
            <div className="flex gap-4 items-center">
              <FlutterShadcnAvatar fallback="JD" />
              <FlutterShadcnAvatar fallback="AB" />
              <FlutterShadcnAvatar fallback="XY" />
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Avatar Sizes</h2>
            <div className="flex gap-4 items-end">
              <div className="text-center">
                <FlutterShadcnAvatar fallback="SM" size="small" />
                <p className="text-xs text-gray-500 mt-1">Small</p>
              </div>
              <div className="text-center">
                <FlutterShadcnAvatar fallback="MD" size="medium" />
                <p className="text-xs text-gray-500 mt-1">Medium</p>
              </div>
              <div className="text-center">
                <FlutterShadcnAvatar fallback="LG" size="large" />
                <p className="text-xs text-gray-500 mt-1">Large</p>
              </div>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Avatar in Context</h2>
            <div className="space-y-4">
              <div className="flex items-center gap-3 p-3 border rounded-lg">
                <FlutterShadcnAvatar
                  src="https://github.com/shadcn.png"
                  fallback="SC"
                />
                <div>
                  <p className="font-medium">shadcn</p>
                  <p className="text-sm text-gray-500">@shadcn</p>
                </div>
              </div>
              <div className="flex items-center gap-3 p-3 border rounded-lg">
                <FlutterShadcnAvatar fallback="JD" />
                <div>
                  <p className="font-medium">John Doe</p>
                  <p className="text-sm text-gray-500">john.doe@example.com</p>
                </div>
              </div>
              <div className="flex items-center gap-3 p-3 border rounded-lg">
                <FlutterShadcnAvatar fallback="AS" />
                <div>
                  <p className="font-medium">Alice Smith</p>
                  <p className="text-sm text-gray-500">alice.smith@example.com</p>
                </div>
              </div>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Avatar Stack</h2>
            <div className="flex -space-x-2">
              <FlutterShadcnAvatar fallback="A" className="border-2 border-white" />
              <FlutterShadcnAvatar fallback="B" className="border-2 border-white" />
              <FlutterShadcnAvatar fallback="C" className="border-2 border-white" />
              <FlutterShadcnAvatar fallback="D" className="border-2 border-white" />
              <FlutterShadcnAvatar fallback="+3" className="border-2 border-white" />
            </div>
            <p className="text-sm text-gray-500 mt-2">7 team members</p>
          </div>
        </WebFListView>
      </div>
    </FlutterShadcnTheme>
  );
};
