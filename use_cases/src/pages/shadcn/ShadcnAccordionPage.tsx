import React, { useState } from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterShadcnTheme,
  FlutterShadcnAccordion,
  FlutterShadcnAccordionItem,
  FlutterShadcnAccordionTrigger,
  FlutterShadcnAccordionContent,
  FlutterShadcnButton,
} from '@openwebf/react-shadcn-ui';

export const ShadcnAccordionPage: React.FC = () => {
  // Controlled single accordion state
  const [singleValue, setSingleValue] = useState<string | undefined>(undefined);

  // Controlled multiple accordion state
  const [multipleValues, setMultipleValues] = useState<string[]>([]);

  const handleSingleChange = (e: any) => {
    const newValue = e.target?.value;
    console.log('[React] Single accordion changed to:', newValue);
    setSingleValue(newValue);
  };

  const handleMultipleChange = (e: any) => {
    const newValue = e.target?.value;
    console.log('[React] Multiple accordion changed to:', newValue);
    if (newValue) {
      setMultipleValues(newValue.split(',').filter((v: string) => v.trim()));
    } else {
      setMultipleValues([]);
    }
  };

  return (
    <FlutterShadcnTheme colorScheme="zinc" brightness="light">
      <div className="min-h-screen w-full bg-white">
        <WebFListView className="w-full px-4 py-6 max-w-2xl mx-auto">
          <h1 className="text-2xl font-bold mb-6">Accordion</h1>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Single Accordion</h2>
            <FlutterShadcnAccordion collapsible>
              <FlutterShadcnAccordionItem value="item-1">
                <FlutterShadcnAccordionTrigger>Is it accessible?</FlutterShadcnAccordionTrigger>
                <FlutterShadcnAccordionContent>
                  Yes. It adheres to the WAI-ARIA design pattern.
                </FlutterShadcnAccordionContent>
              </FlutterShadcnAccordionItem>
              <FlutterShadcnAccordionItem value="item-2">
                <FlutterShadcnAccordionTrigger>Is it styled?</FlutterShadcnAccordionTrigger>
                <FlutterShadcnAccordionContent>
                  Yes. It comes with default styles that matches the other components' aesthetic.
                </FlutterShadcnAccordionContent>
              </FlutterShadcnAccordionItem>
              <FlutterShadcnAccordionItem value="item-3">
                <FlutterShadcnAccordionTrigger>Is it animated?</FlutterShadcnAccordionTrigger>
                <FlutterShadcnAccordionContent>
                  Yes. It's animated by default, but you can disable it if you prefer.
                </FlutterShadcnAccordionContent>
              </FlutterShadcnAccordionItem>
            </FlutterShadcnAccordion>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Multiple Accordion</h2>
            <FlutterShadcnAccordion type="multiple">
              <FlutterShadcnAccordionItem value="faq-1">
                <FlutterShadcnAccordionTrigger>What is WebF?</FlutterShadcnAccordionTrigger>
                <FlutterShadcnAccordionContent>
                  WebF is a framework for building cross-platform applications using web technologies
                  with Flutter's rendering engine. It allows you to use HTML, CSS, and JavaScript
                  while getting native-like performance.
                </FlutterShadcnAccordionContent>
              </FlutterShadcnAccordionItem>
              <FlutterShadcnAccordionItem value="faq-2">
                <FlutterShadcnAccordionTrigger>What is Shadcn UI?</FlutterShadcnAccordionTrigger>
                <FlutterShadcnAccordionContent>
                  Shadcn UI is a collection of beautifully designed, accessible, and customizable
                  components that you can copy and paste into your apps. This package brings
                  those components to WebF.
                </FlutterShadcnAccordionContent>
              </FlutterShadcnAccordionItem>
              <FlutterShadcnAccordionItem value="faq-3">
                <FlutterShadcnAccordionTrigger>How do I get started?</FlutterShadcnAccordionTrigger>
                <FlutterShadcnAccordionContent>
                  Install the package using npm or yarn, then import the components you need.
                  Wrap your app with FlutterShadcnTheme to enable theming, and start using
                  the components in your JSX.
                </FlutterShadcnAccordionContent>
              </FlutterShadcnAccordionItem>
              <FlutterShadcnAccordionItem value="faq-4">
                <FlutterShadcnAccordionTrigger>Can I customize the theme?</FlutterShadcnAccordionTrigger>
                <FlutterShadcnAccordionContent>
                  Yes! The FlutterShadcnTheme component accepts a colorScheme prop with 12
                  different color schemes (zinc, slate, stone, gray, neutral, red, rose,
                  orange, green, blue, yellow, violet) and supports both light and dark modes.
                </FlutterShadcnAccordionContent>
              </FlutterShadcnAccordionItem>
            </FlutterShadcnAccordion>
          </div>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">FAQ Section</h2>
            <div className="border rounded-lg p-4">
              <h3 className="text-xl font-bold mb-4">Frequently Asked Questions</h3>
              <FlutterShadcnAccordion type="single" collapsible>
                <FlutterShadcnAccordionItem value="pricing-1">
                  <FlutterShadcnAccordionTrigger>Is there a free trial?</FlutterShadcnAccordionTrigger>
                  <FlutterShadcnAccordionContent>
                    Yes, we offer a 14-day free trial with full access to all features.
                    No credit card required to start your trial.
                  </FlutterShadcnAccordionContent>
                </FlutterShadcnAccordionItem>
                <FlutterShadcnAccordionItem value="pricing-2">
                  <FlutterShadcnAccordionTrigger>Can I cancel anytime?</FlutterShadcnAccordionTrigger>
                  <FlutterShadcnAccordionContent>
                    Absolutely. You can cancel your subscription at any time from your
                    account settings. Your access will continue until the end of your
                    billing period.
                  </FlutterShadcnAccordionContent>
                </FlutterShadcnAccordionItem>
                <FlutterShadcnAccordionItem value="pricing-3">
                  <FlutterShadcnAccordionTrigger>Do you offer refunds?</FlutterShadcnAccordionTrigger>
                  <FlutterShadcnAccordionContent>
                    We offer a 30-day money-back guarantee. If you're not satisfied with
                    our service within the first 30 days, contact support for a full refund.
                  </FlutterShadcnAccordionContent>
                </FlutterShadcnAccordionItem>
              </FlutterShadcnAccordion>
            </div>
          </div>

          {/* Controlled Single Accordion */}
          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Controlled Single Accordion</h2>
            <div className="mb-4 p-3 bg-gray-100 rounded">
              <p className="text-sm">Current value: <strong>{singleValue || '(none)'}</strong></p>
            </div>
            <div className="flex gap-2 mb-4 flex-wrap">
              <FlutterShadcnButton
                variant="outline"
                size="sm"
                onClick={() => setSingleValue('ctrl-1')}
              >
                Open Item 1
              </FlutterShadcnButton>
              <FlutterShadcnButton
                variant="outline"
                size="sm"
                onClick={() => setSingleValue('ctrl-2')}
              >
                Open Item 2
              </FlutterShadcnButton>
              <FlutterShadcnButton
                variant="outline"
                size="sm"
                onClick={() => setSingleValue('ctrl-3')}
              >
                Open Item 3
              </FlutterShadcnButton>
              <FlutterShadcnButton
                variant="ghost"
                size="sm"
                onClick={() => setSingleValue(undefined)}
              >
                Close All
              </FlutterShadcnButton>
            </div>
            <FlutterShadcnAccordion
              type="single"
              collapsible
              value={singleValue}
              onChange={handleSingleChange}
            >
              <FlutterShadcnAccordionItem value="ctrl-1">
                <FlutterShadcnAccordionTrigger>Controlled Item 1</FlutterShadcnAccordionTrigger>
                <FlutterShadcnAccordionContent>
                  This accordion is controlled by React state. Click the buttons above
                  to programmatically open/close items.
                </FlutterShadcnAccordionContent>
              </FlutterShadcnAccordionItem>
              <FlutterShadcnAccordionItem value="ctrl-2">
                <FlutterShadcnAccordionTrigger>Controlled Item 2</FlutterShadcnAccordionTrigger>
                <FlutterShadcnAccordionContent>
                  The current expanded item is synced with React state and displayed above.
                </FlutterShadcnAccordionContent>
              </FlutterShadcnAccordionItem>
              <FlutterShadcnAccordionItem value="ctrl-3">
                <FlutterShadcnAccordionTrigger>Controlled Item 3</FlutterShadcnAccordionTrigger>
                <FlutterShadcnAccordionContent>
                  You can also click on items directly - the state will update accordingly.
                </FlutterShadcnAccordionContent>
              </FlutterShadcnAccordionItem>
            </FlutterShadcnAccordion>
          </div>

          {/* Controlled Multiple Accordion */}
          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Controlled Multiple Accordion</h2>
            <div className="mb-4 p-3 bg-gray-100 rounded">
              <p className="text-sm">
                Current values: <strong>{multipleValues.length > 0 ? multipleValues.join(', ') : '(none)'}</strong>
              </p>
            </div>
            <div className="flex flex-wrap gap-2 mb-4">
              <FlutterShadcnButton
                variant="outline"
                size="sm"
                onClick={() => setMultipleValues(['multi-1'])}
              >
                Only Item 1
              </FlutterShadcnButton>
              <FlutterShadcnButton
                variant="outline"
                size="sm"
                onClick={() => setMultipleValues(['multi-1', 'multi-2'])}
              >
                Items 1 & 2
              </FlutterShadcnButton>
              <FlutterShadcnButton
                variant="outline"
                size="sm"
                onClick={() => setMultipleValues(['multi-1', 'multi-2', 'multi-3'])}
              >
                Open All
              </FlutterShadcnButton>
              <FlutterShadcnButton
                variant="ghost"
                size="sm"
                onClick={() => setMultipleValues([])}
              >
                Close All
              </FlutterShadcnButton>
            </div>
            <FlutterShadcnAccordion
              type="multiple"
              value={multipleValues.join(',')}
              onChange={handleMultipleChange}
            >
              <FlutterShadcnAccordionItem value="multi-1">
                <FlutterShadcnAccordionTrigger>Multiple Item 1</FlutterShadcnAccordionTrigger>
                <FlutterShadcnAccordionContent>
                  This is a controlled multiple accordion. Multiple items can be open simultaneously.
                </FlutterShadcnAccordionContent>
              </FlutterShadcnAccordionItem>
              <FlutterShadcnAccordionItem value="multi-2">
                <FlutterShadcnAccordionTrigger>Multiple Item 2</FlutterShadcnAccordionTrigger>
                <FlutterShadcnAccordionContent>
                  Use the buttons above to control which items are expanded.
                </FlutterShadcnAccordionContent>
              </FlutterShadcnAccordionItem>
              <FlutterShadcnAccordionItem value="multi-3">
                <FlutterShadcnAccordionTrigger>Multiple Item 3</FlutterShadcnAccordionTrigger>
                <FlutterShadcnAccordionContent>
                  The expanded state is stored as a comma-separated string in the value prop.
                </FlutterShadcnAccordionContent>
              </FlutterShadcnAccordionItem>
            </FlutterShadcnAccordion>
          </div>

          {/* Debug Section */}
          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Debug: Default Expanded</h2>
            <FlutterShadcnAccordion type="single" collapsible value="debug-2">
              <FlutterShadcnAccordionItem value="debug-1">
                <FlutterShadcnAccordionTrigger>Debug Item 1</FlutterShadcnAccordionTrigger>
                <FlutterShadcnAccordionContent>
                  Content for debug item 1.
                </FlutterShadcnAccordionContent>
              </FlutterShadcnAccordionItem>
              <FlutterShadcnAccordionItem value="debug-2">
                <FlutterShadcnAccordionTrigger>Debug Item 2 (Default Open)</FlutterShadcnAccordionTrigger>
                <FlutterShadcnAccordionContent>
                  This item should be open by default because value="debug-2" is set on the accordion.
                </FlutterShadcnAccordionContent>
              </FlutterShadcnAccordionItem>
              <FlutterShadcnAccordionItem value="debug-3">
                <FlutterShadcnAccordionTrigger>Debug Item 3</FlutterShadcnAccordionTrigger>
                <FlutterShadcnAccordionContent>
                  Content for debug item 3.
                </FlutterShadcnAccordionContent>
              </FlutterShadcnAccordionItem>
            </FlutterShadcnAccordion>
          </div>
        </WebFListView>
      </div>
    </FlutterShadcnTheme>
  );
};
