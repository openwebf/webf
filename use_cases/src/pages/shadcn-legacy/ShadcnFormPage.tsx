import React, { useRef, useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterShadcnTheme,
  FlutterShadcnForm,
  FlutterShadcnFormField,
  FlutterShadcnFormLabel,
  FlutterShadcnFormDescription,
  FlutterShadcnFormMessage,
  FlutterShadcnButton,
  FlutterShadcnInput,
  FlutterShadcnTextarea,
  FlutterShadcnCheckbox,
  FlutterShadcnSelect,
  FlutterShadcnSelectTrigger,
  FlutterShadcnSelectContent,
  FlutterShadcnSelectItem,
} from '@openwebf/react-shadcn-ui';
import type { FlutterShadcnFormElement } from '@openwebf/react-shadcn-ui';

export const ShadcnFormPage: React.FC = () => {
  const formRef = useRef<FlutterShadcnFormElement>(null);
  const [formValues, setFormValues] = useState<string>('');
  const [submitStatus, setSubmitStatus] = useState<string>('');

  const handleSubmit = () => {
    if (formRef.current) {
      const isValid = formRef.current.submit();
      if (isValid) {
        const values = formRef.current.value ?? '{}';
        setFormValues(values);
        setSubmitStatus('Form submitted successfully!');
        console.log('Form values:', JSON.parse(values));
      } else {
        setSubmitStatus('Please fix the errors above.');
      }
    }
  };

  const handleReset = () => {
    if (formRef.current) {
      formRef.current.reset();
      setFormValues('');
      setSubmitStatus('');
    }
  };

  const handleChange = () => {
    if (formRef.current) {
      setFormValues(formRef.current.value ?? '{}');
    }
  };

  return (
    <FlutterShadcnTheme colorScheme="zinc" brightness="light">
      <div className="min-h-screen w-full bg-white">
        <WebFListView className="w-full px-4 py-6 max-w-2xl mx-auto">
          <h1 className="text-2xl font-bold mb-6">Form</h1>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Basic Form with Validation</h2>
            <p className="text-sm text-gray-600 mb-4">
              A form with built-in validation using ShadForm.
            </p>

            <FlutterShadcnForm
              ref={formRef}
              onChange={handleChange}
              onSubmit={(e: CustomEvent) => {
                console.log('Form submitted with values:', e.detail);
              }}
              onReset={() => {
                console.log('Form was reset');
              }}
            >
              <div className="space-y-4">
                <FlutterShadcnFormField
                  fieldId="username"
                  label="Username"
                  description="This is your public display name."
                  placeholder="Enter username"
                  required
                />

                <FlutterShadcnFormField
                  fieldId="email"
                  label="Email"
                  description="We'll never share your email."
                  placeholder="Enter email address"
                  required
                />

                <FlutterShadcnFormField
                  fieldId="bio"
                  label="Bio"
                  description="Tell us a little about yourself."
                  placeholder="Enter your bio"
                />

                <div className="flex gap-2 pt-4">
                  <FlutterShadcnButton onClick={handleSubmit}>
                    Submit
                  </FlutterShadcnButton>
                  <FlutterShadcnButton variant="outline" onClick={handleReset}>
                    Reset
                  </FlutterShadcnButton>
                </div>

                {submitStatus && (
                  <FlutterShadcnFormMessage type={submitStatus.includes('success') ? 'success' : 'error'}>
                    {submitStatus}
                  </FlutterShadcnFormMessage>
                )}

                {formValues && (
                  <div className="mt-4 p-4 bg-gray-100 rounded-lg">
                    <p className="text-sm font-medium mb-2">Current Form Values:</p>
                    <pre className="text-xs text-gray-600 whitespace-pre-wrap">
                      {JSON.stringify(JSON.parse(formValues), null, 2)}
                    </pre>
                  </div>
                )}
              </div>
            </FlutterShadcnForm>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Form with Custom Fields</h2>
            <p className="text-sm text-gray-600 mb-4">
              Form fields can wrap custom components using children.
            </p>

            <FlutterShadcnForm>
              <div className="space-y-4">
                <FlutterShadcnFormField fieldId="message" label="Message" required>
                  <FlutterShadcnTextarea placeholder="Enter your message..." />
                </FlutterShadcnFormField>

                <FlutterShadcnFormField fieldId="category" label="Category" description="Select a category for your message.">
                  <FlutterShadcnSelect>
                    <FlutterShadcnSelectTrigger placeholder="Select a category" />
                    <FlutterShadcnSelectContent>
                      <FlutterShadcnSelectItem value="general">General</FlutterShadcnSelectItem>
                      <FlutterShadcnSelectItem value="support">Support</FlutterShadcnSelectItem>
                      <FlutterShadcnSelectItem value="feedback">Feedback</FlutterShadcnSelectItem>
                      <FlutterShadcnSelectItem value="bug">Bug Report</FlutterShadcnSelectItem>
                    </FlutterShadcnSelectContent>
                  </FlutterShadcnSelect>
                </FlutterShadcnFormField>

                <FlutterShadcnFormField fieldId="priority" label="Priority">
                  <div className="flex gap-4">
                    <FlutterShadcnCheckbox label="Urgent" />
                  </div>
                </FlutterShadcnFormField>

                <FlutterShadcnButton>
                  Send Message
                </FlutterShadcnButton>
              </div>
            </FlutterShadcnForm>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Form Labels and Descriptions</h2>
            <p className="text-sm text-gray-600 mb-4">
              You can use separate label and description components for custom layouts.
            </p>

            <FlutterShadcnForm>
              <div className="space-y-4">
                <div>
                  <FlutterShadcnFormLabel>Custom Label</FlutterShadcnFormLabel>
                  <FlutterShadcnInput placeholder="Custom styled input" />
                  <FlutterShadcnFormDescription>
                    This field uses separate label and description components.
                  </FlutterShadcnFormDescription>
                </div>

                <div>
                  <FlutterShadcnFormLabel>Password</FlutterShadcnFormLabel>
                  <FlutterShadcnInput placeholder="Enter password" />
                  <FlutterShadcnFormMessage type="info">
                    Password must be at least 8 characters.
                  </FlutterShadcnFormMessage>
                </div>
              </div>
            </FlutterShadcnForm>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Disabled Form</h2>
            <p className="text-sm text-gray-600 mb-4">
              Forms can be disabled to prevent user interaction.
            </p>

            <FlutterShadcnForm disabled>
              <div className="space-y-4">
                <FlutterShadcnFormField
                  fieldId="disabledField"
                  label="Disabled Field"
                  placeholder="This field is disabled"
                />
                <FlutterShadcnButton disabled>
                  Submit (Disabled)
                </FlutterShadcnButton>
              </div>
            </FlutterShadcnForm>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Auto Validation Modes</h2>
            <p className="text-sm text-gray-600 mb-4">
              Different validation modes control when validation occurs.
            </p>

            <div className="space-y-6">
              <div>
                <p className="text-sm font-medium mb-2">Always After First Validation (Default)</p>
                <FlutterShadcnForm autoValidateMode="alwaysAfterFirstValidation">
                  <FlutterShadcnFormField
                    fieldId="field1"
                    label="Required Field"
                    placeholder="Enter value"
                    required
                  />
                </FlutterShadcnForm>
              </div>

              <div>
                <p className="text-sm font-medium mb-2">On User Interaction</p>
                <FlutterShadcnForm autoValidateMode="onUserInteraction">
                  <FlutterShadcnFormField
                    fieldId="field2"
                    label="Required Field"
                    placeholder="Enter value"
                    required
                  />
                </FlutterShadcnForm>
              </div>

              <div>
                <p className="text-sm font-medium mb-2">Disabled (Manual Validation Only)</p>
                <FlutterShadcnForm autoValidateMode="disabled">
                  <FlutterShadcnFormField
                    fieldId="field3"
                    label="Required Field"
                    placeholder="Enter value"
                    required
                  />
                </FlutterShadcnForm>
              </div>
            </div>
          </div>
        </WebFListView>
      </div>
    </FlutterShadcnTheme>
  );
};
