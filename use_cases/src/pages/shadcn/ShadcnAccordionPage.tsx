import React from 'react';
import { WebFListView } from '@openwebf/react-core-ui';
import {
  FlutterShadcnTheme,
  FlutterShadcnAccordion,
  FlutterShadcnAccordionItem,
  FlutterShadcnAccordionTrigger,
  FlutterShadcnAccordionContent,
} from '@openwebf/react-shadcn-ui';

export const ShadcnAccordionPage: React.FC = () => {
  return (
    <FlutterShadcnTheme colorScheme="zinc" brightness="light">
      <div className="min-h-screen w-full bg-white">
        <WebFListView className="w-full px-4 py-6 max-w-2xl mx-auto">
          <h1 className="text-2xl font-bold mb-6">Accordion</h1>

          <div className="mb-8">
            <h2 className="text-lg font-semibold mb-4">Single Accordion</h2>
            <FlutterShadcnAccordion type="single" collapsible>
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
        </WebFListView>
      </div>
    </FlutterShadcnTheme>
  );
};
