import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterShadcnTheme,
  FlutterShadcnSkeleton,
  FlutterShadcnCard,
  FlutterShadcnCardHeader,
  FlutterShadcnCardContent,
} from '@openwebf/react-shadcn-ui';

export const ShadcnSkeletonPage: React.FC = () => {
  return (
    <FlutterShadcnTheme colorScheme="zinc" brightness="light">
      <div className="min-h-screen w-full bg-white">
        <WebFListView className="w-full px-4 py-6 max-w-2xl mx-auto">
          <h1 className="text-2xl font-bold mb-6">Skeleton</h1>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Basic Skeleton</h2>
            <div className="space-y-3">
              <FlutterShadcnSkeleton className="h-4 w-full" />
              <FlutterShadcnSkeleton className="h-4 w-3/4" />
              <FlutterShadcnSkeleton className="h-4 w-1/2" />
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Skeleton Shapes</h2>
            <div className="flex gap-4 items-center">
              <FlutterShadcnSkeleton className="h-12 w-12 rounded-full" />
              <FlutterShadcnSkeleton className="h-12 w-12 rounded" />
              <FlutterShadcnSkeleton className="h-12 w-24 rounded" />
              <FlutterShadcnSkeleton className="h-6 w-32 rounded" />
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Card Skeleton</h2>
            <FlutterShadcnCard>
              <FlutterShadcnCardHeader>
                <div className="flex items-center gap-4">
                  <FlutterShadcnSkeleton className="h-12 w-12 rounded-full" />
                  <div className="space-y-2">
                    <FlutterShadcnSkeleton className="h-4 w-32" />
                    <FlutterShadcnSkeleton className="h-3 w-24" />
                  </div>
                </div>
              </FlutterShadcnCardHeader>
              <FlutterShadcnCardContent>
                <div className="space-y-3">
                  <FlutterShadcnSkeleton className="h-4 w-full" />
                  <FlutterShadcnSkeleton className="h-4 w-full" />
                  <FlutterShadcnSkeleton className="h-4 w-3/4" />
                </div>
              </FlutterShadcnCardContent>
            </FlutterShadcnCard>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">List Skeleton</h2>
            <div className="space-y-4">
              {[1, 2, 3].map((i) => (
                <div key={i} className="flex items-center gap-4 p-3 border rounded-lg">
                  <FlutterShadcnSkeleton className="h-10 w-10 rounded-full" />
                  <div className="flex-1 space-y-2">
                    <FlutterShadcnSkeleton className="h-4 w-40" />
                    <FlutterShadcnSkeleton className="h-3 w-24" />
                  </div>
                  <FlutterShadcnSkeleton className="h-8 w-16 rounded" />
                </div>
              ))}
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Article Skeleton</h2>
            <div className="space-y-4">
              <FlutterShadcnSkeleton className="h-48 w-full rounded-lg" />
              <div className="space-y-2">
                <FlutterShadcnSkeleton className="h-6 w-3/4" />
                <FlutterShadcnSkeleton className="h-4 w-1/4" />
              </div>
              <div className="space-y-2">
                <FlutterShadcnSkeleton className="h-4 w-full" />
                <FlutterShadcnSkeleton className="h-4 w-full" />
                <FlutterShadcnSkeleton className="h-4 w-2/3" />
              </div>
            </div>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Table Skeleton</h2>
            <div className="border rounded-lg overflow-hidden">
              <div className="bg-gray-50 p-3 border-b">
                <div className="flex gap-4">
                  <FlutterShadcnSkeleton className="h-4 w-24" />
                  <FlutterShadcnSkeleton className="h-4 w-32" />
                  <FlutterShadcnSkeleton className="h-4 w-20" />
                  <FlutterShadcnSkeleton className="h-4 w-16" />
                </div>
              </div>
              {[1, 2, 3, 4].map((i) => (
                <div key={i} className="p-3 border-b last:border-b-0">
                  <div className="flex gap-4">
                    <FlutterShadcnSkeleton className="h-4 w-24" />
                    <FlutterShadcnSkeleton className="h-4 w-32" />
                    <FlutterShadcnSkeleton className="h-4 w-20" />
                    <FlutterShadcnSkeleton className="h-4 w-16" />
                  </div>
                </div>
              ))}
            </div>
          </div>
        </WebFListView>
      </div>
    </FlutterShadcnTheme>
  );
};
