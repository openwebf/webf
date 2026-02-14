import React from 'react';
import { WebFRouter } from '../router';
import { WebFListView } from '@openwebf/react-core-ui';

export const ShadcnShowcasePage: React.FC = () => {
  const navigateTo = (path: string) => WebFRouter.pushState({}, path);

  const Item = (props: { label: string; desc: string; to?: string }) => (
    <div
      className={`flex items-center p-4 border-b border-[#f0f0f0] cursor-pointer transition-colors hover:bg-surface-hover ${props.to ? '' : 'pointer-events-none opacity-60'}`}
      onClick={props.to ? () => navigateTo(props.to!) : undefined}
    >
      <div className="flex-1">
        <div className="text-[16px] font-semibold text-[#2c3e50] mb-1">{props.label}</div>
        <div className="text-[14px] text-[#7f8c8d] leading-snug">{props.desc}</div>
      </div>
      <div className="text-[16px] text-[#bdc3c7] font-bold">&gt;</div>
    </div>
  );

  return (
    <div id="main" className="min-h-screen w-full bg-surface">
      <WebFListView className="w-full px-3 md:px-6 max-w-4xl mx-auto py-6">
        <div className="w-full flex justify-center items-center">
          <div className="bg-gradient-to-tr from-zinc-800 to-zinc-600 p-6 rounded-2xl text-white shadow">
            <h1 className="text-[28px] font-bold mb-2 drop-shadow">Shadcn UI</h1>
            <p className="text-[16px]/[1.5] opacity-90">Beautiful components built with WebF and shadcn_ui</p>
          </div>
        </div>

        <div className="mt-6">
          <h2 className="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-zinc-500">Form Controls</h2>
          <div className="mb-5 bg-surface-secondary rounded-xl shadow overflow-hidden border border-line">
            <Item label="Buttons" desc="Primary, secondary, destructive, outline, ghost variants" to="/shadcn/buttons" />
            <Item label="Icon Button" desc="Icon-only buttons with Lucide icons" to="/shadcn/icon-button" />
            <Item label="Input" desc="Text input with various types and states" to="/shadcn/input" />
            <Item label="Checkbox & Switch" desc="Toggle controls for forms" to="/shadcn/checkbox-switch" />
            <Item label="Select & Combobox" desc="Dropdown selection components" to="/shadcn/select" />
            <Item label="Slider" desc="Range selection slider" to="/shadcn/slider" />
            <Item label="Radio Group" desc="Single selection from multiple options" to="/shadcn/radio" />
            <Item label="Input OTP" desc="One-time password input with grouped slots" to="/shadcn/input-otp" />
            <Item label="Form" desc="Form state management with validation" to="/shadcn/form" />
          </div>

          <h2 className="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-zinc-500">Display Components</h2>
          <div className="mb-5 bg-surface-secondary rounded-xl shadow overflow-hidden border border-line">
            <Item label="Card" desc="Container with header, content, and footer" to="/shadcn/card" />
            <Item label="Alert & Badge" desc="Notifications and status indicators" to="/shadcn/alert-badge" />
            <Item label="Avatar" desc="User profile images" to="/shadcn/avatar" />
            <Item label="Progress" desc="Loading and progress indicators" to="/shadcn/progress" />
            <Item label="Skeleton" desc="Loading placeholder animations" to="/shadcn/skeleton" />
          </div>

          <h2 className="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-zinc-500">Navigation & Layout</h2>
          <div className="mb-5 bg-surface-secondary rounded-xl shadow overflow-hidden border border-line">
            <Item label="Tabs" desc="Tabbed content navigation" to="/shadcn/tabs" />
            <Item label="Accordion" desc="Collapsible content sections" to="/shadcn/accordion" />
            <Item label="Dialog & Sheet" desc="Modal dialogs and bottom sheets" to="/shadcn/dialog" />
            <Item label="Breadcrumb" desc="Navigation hierarchy" to="/shadcn/breadcrumb" />
          </div>

          <h2 className="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-zinc-500">Data & Pickers</h2>
          <div className="mb-5 bg-surface-secondary rounded-xl shadow overflow-hidden border border-line">
            <Item label="Table" desc="Data table with headers and rows" to="/shadcn/table" />
            <Item label="Calendar & Date Picker" desc="Date selection components" to="/shadcn/calendar" />
          </div>

          <h2 className="text-lg font-semibold text-fg-primary mb-3 pl-3 border-l-4 border-zinc-500">Menus & Overlays</h2>
          <div className="mb-5 bg-surface-secondary rounded-xl shadow overflow-hidden border border-line">
            <Item label="Dropdown Menu" desc="Action menu dropdowns" to="/shadcn/dropdown" />
            <Item label="Context Menu" desc="Right-click context menus" to="/shadcn/context-menu" />
            <Item label="Popover & Tooltip" desc="Floating content and hints" to="/shadcn/popover" />
          </div>
        </div>
      </WebFListView>
    </div>
  );
};
