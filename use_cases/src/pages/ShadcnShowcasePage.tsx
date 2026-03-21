import React from 'react';
import { WebFRouter } from '../router';
import { WebFListView } from '@openwebf/react-core-ui';

type ShowcaseItem = {
  label: string;
  desc: string;
  to: string;
};

type ShowcaseSection = {
  title: string;
  items: ShowcaseItem[];
};

const sections: ShowcaseSection[] = [
  {
    title: 'Form Controls',
    items: [
      { label: 'Buttons', desc: 'Primary, secondary, destructive, outline, ghost, and link buttons', to: '/shadcn/buttons' },
      { label: 'Icon Button', desc: 'Compact icon-only actions with Lucide icons', to: '/shadcn/icon-button' },
      { label: 'Input', desc: 'Text, email, password, and textarea inputs with helper states', to: '/shadcn/input' },
      { label: 'Checkbox & Switch', desc: 'Binary toggles for settings and consent flows', to: '/shadcn/checkbox-switch' },
      { label: 'Select', desc: 'Select menu and combobox-style choices', to: '/shadcn/select' },
      { label: 'Slider', desc: 'Range selection with labeled values', to: '/shadcn/slider' },
      { label: 'Radio Group', desc: 'Single-choice grouped selection patterns', to: '/shadcn/radio' },
      { label: 'Form', desc: 'Composed form layout with validation-friendly structure', to: '/shadcn/form' },
    ],
  },
  {
    title: 'Display & Feedback',
    items: [
      { label: 'Card', desc: 'Flexible content containers with header and footer regions', to: '/shadcn/card' },
      { label: 'Alert & Badge', desc: 'Status chips, inline alerts, and emphasis states', to: '/shadcn/alert-badge' },
      { label: 'Avatar', desc: 'Profile surfaces with initials and image fallbacks', to: '/shadcn/avatar' },
      { label: 'Progress', desc: 'Determinate progress indicators for long-running tasks', to: '/shadcn/progress' },
      { label: 'Skeleton', desc: 'Loading placeholders for content-first layouts', to: '/shadcn/skeleton' },
      { label: 'Table', desc: 'Structured row and column presentation for datasets', to: '/shadcn/table' },
    ],
  },
  {
    title: 'Navigation & Layout',
    items: [
      { label: 'Tabs', desc: 'Tabbed views with active state and content switching', to: '/shadcn/tabs' },
      { label: 'Accordion', desc: 'Expandable sections for dense content blocks', to: '/shadcn/accordion' },
      { label: 'Breadcrumb', desc: 'Hierarchy trails and backtracking patterns', to: '/shadcn/breadcrumb' },
    ],
  },
  {
    title: 'Overlays & Menus',
    items: [
      { label: 'Dialog', desc: 'Modal dialog and sheet-style interaction patterns', to: '/shadcn/dialog' },
      { label: 'Popover', desc: 'Floating panels, popovers, and tooltip-style surfaces', to: '/shadcn/popover' },
      { label: 'Dropdown Menu', desc: 'Compact action menus from trigger buttons', to: '/shadcn/dropdown' },
      { label: 'Context Menu', desc: 'Contextual actions for secondary-click workflows', to: '/shadcn/context-menu' },
    ],
  },
  {
    title: 'Date & Scheduling',
    items: [
      { label: 'Calendar', desc: 'Date picking and month-grid scheduling UI', to: '/shadcn/calendar' },
    ],
  },
];

export const ShadcnShowcasePage: React.FC = () => {
  const navigateTo = (path: string) => void WebFRouter.push(path, {});

  const Item = ({ label, desc, to }: ShowcaseItem) => (
    <div
      className="flex items-center p-4 border-b border-[#ececec] cursor-pointer transition-colors hover:bg-surface-hover"
      onClick={() => navigateTo(to)}
    >
      <div className="flex-1">
        <div className="text-[16px] font-semibold text-[#1f2937] mb-1">{label}</div>
        <div className="text-[14px] text-[#6b7280] leading-snug">{desc}</div>
      </div>
      <div className="text-[16px] text-[#9ca3af] font-bold">&gt;</div>
    </div>
  );

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
        <div className="w-full flex justify-center items-center">
          <div className="bg-gradient-to-br from-zinc-950 via-zinc-800 to-stone-700 p-6 rounded-2xl text-white shadow-lg w-full">
            <h1 className="text-[28px] font-bold mb-2 drop-shadow">Shadcn UI Showcase</h1>
            <p className="text-[16px]/[1.5] opacity-90">
              Explore the current WebF demos built with <code>@openwebf/react-shadcn-ui</code>.
            </p>
          </div>
        </div>

        <div className="mt-6">
          {sections.map((section) => (
            <div key={section.title} className="mb-5">
              <h2 className="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-zinc-600">
                {section.title}
              </h2>
              <div className="bg-surface-secondary rounded-xl shadow overflow-hidden border border-line">
                {section.items.map((item) => (
                  <Item key={item.to} {...item} />
                ))}
              </div>
            </div>
          ))}
        </div>
      </WebFListView>
    </div>
  );
};
