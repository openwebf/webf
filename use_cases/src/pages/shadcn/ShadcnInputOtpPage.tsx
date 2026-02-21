import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterShadcnTheme,
  FlutterShadcnInputOtp,
  FlutterShadcnInputOtpGroup,
  FlutterShadcnInputOtpSlot,
  FlutterShadcnInputOtpSeparator,
} from '@openwebf/react-shadcn-ui';

export const ShadcnInputOtpPage: React.FC = () => {
  const [otpValue, setOtpValue] = useState('');
  const [completed, setCompleted] = useState(false);

  return (
    <FlutterShadcnTheme colorScheme="zinc" brightness="light">
      <div className="min-h-screen w-full bg-white">
        <WebFListView className="w-full px-4 py-6 max-w-2xl mx-auto">
          <h1 className="text-2xl font-bold mb-6">Input OTP</h1>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Basic OTP Input</h2>
            <p className="text-sm text-gray-500 mb-4">Enter a 6-digit verification code.</p>
            <FlutterShadcnInputOtp
              maxlength="6"
              onChange={() => {
                setCompleted(false);
              }}
              onComplete={() => {
                setCompleted(true);
              }}
            >
              <FlutterShadcnInputOtpGroup>
                <FlutterShadcnInputOtpSlot />
                <FlutterShadcnInputOtpSlot />
                <FlutterShadcnInputOtpSlot />
              </FlutterShadcnInputOtpGroup>
              <FlutterShadcnInputOtpSeparator />
              <FlutterShadcnInputOtpGroup>
                <FlutterShadcnInputOtpSlot />
                <FlutterShadcnInputOtpSlot />
                <FlutterShadcnInputOtpSlot />
              </FlutterShadcnInputOtpGroup>
            </FlutterShadcnInputOtp>
            {completed && (
              <p className="text-sm text-green-600 mt-2">OTP complete!</p>
            )}
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">4-Digit PIN</h2>
            <p className="text-sm text-gray-500 mb-4">A shorter 4-digit code without separator.</p>
            <FlutterShadcnInputOtp maxlength="4">
              <FlutterShadcnInputOtpGroup>
                <FlutterShadcnInputOtpSlot />
                <FlutterShadcnInputOtpSlot />
                <FlutterShadcnInputOtpSlot />
                <FlutterShadcnInputOtpSlot />
              </FlutterShadcnInputOtpGroup>
            </FlutterShadcnInputOtp>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Disabled State</h2>
            <p className="text-sm text-gray-500 mb-4">OTP input in disabled state.</p>
            <FlutterShadcnInputOtp maxlength="6" disabled>
              <FlutterShadcnInputOtpGroup>
                <FlutterShadcnInputOtpSlot />
                <FlutterShadcnInputOtpSlot />
                <FlutterShadcnInputOtpSlot />
              </FlutterShadcnInputOtpGroup>
              <FlutterShadcnInputOtpSeparator />
              <FlutterShadcnInputOtpGroup>
                <FlutterShadcnInputOtpSlot />
                <FlutterShadcnInputOtpSlot />
                <FlutterShadcnInputOtpSlot />
              </FlutterShadcnInputOtpGroup>
            </FlutterShadcnInputOtp>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Multiple Groups</h2>
            <p className="text-sm text-gray-500 mb-4">6-character code split into groups of 2.</p>
            <FlutterShadcnInputOtp maxlength="6">
              <FlutterShadcnInputOtpGroup>
                <FlutterShadcnInputOtpSlot />
                <FlutterShadcnInputOtpSlot />
              </FlutterShadcnInputOtpGroup>
              <FlutterShadcnInputOtpSeparator />
              <FlutterShadcnInputOtpGroup>
                <FlutterShadcnInputOtpSlot />
                <FlutterShadcnInputOtpSlot />
              </FlutterShadcnInputOtpGroup>
              <FlutterShadcnInputOtpSeparator />
              <FlutterShadcnInputOtpGroup>
                <FlutterShadcnInputOtpSlot />
                <FlutterShadcnInputOtpSlot />
              </FlutterShadcnInputOtpGroup>
            </FlutterShadcnInputOtp>
          </div>
        </WebFListView>
      </div>
    </FlutterShadcnTheme>
  );
};
