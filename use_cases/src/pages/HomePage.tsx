import React from 'react';
import { WebFRouter } from '../router';
import { WebFListView } from '@openwebf/react-core-ui';
import { FlutterLucideIcon, LucideIcons } from '@openwebf/react-lucide-icons';

type Item = { label: string; path: string };
type Section = {
  title: string;
  icon: LucideIcons;
  color: string;
  items: Item[];
};

const sections: Section[] = [
  {
    title: 'Core UI',
    icon: LucideIcons.layers,
    color: '#3b82f6',
    items: [
      { label: 'GestureDetector', path: '/gesture' },
      { label: 'WebFListView', path: '/listview' },
      { label: 'Draggable List', path: '/dragable-list' },
      { label: 'Routing', path: '/routing' },
    ],
  },
  {
    title: 'CSS Layout',
    icon: LucideIcons.layoutGrid,
    color: '#8b5cf6',
    items: [
      { label: 'Flexbox', path: '/css/flex-layout' },
      { label: 'Display / Flow', path: '/css/display-flow' },
      { label: 'Sizing', path: '/css/sizing' },
      { label: 'Inline Formatting', path: '/css/inline-formatting' },
    ],
  },
  {
    title: 'CSS Visual',
    icon: LucideIcons.palette,
    color: '#ec4899',
    items: [
      { label: 'Background', path: '/css/bg' },
      { label: 'Gradient', path: '/css/bg-gradient' },
      { label: 'Radial Gradient', path: '/css/bg-radial' },
      { label: 'Background Image', path: '/css/bg-image' },
      { label: 'Border', path: '/css/border' },
      { label: 'Border Radius', path: '/css/border-radius' },
      { label: 'Box Shadow', path: '/css/box-shadow' },
      { label: 'Overflow', path: '/css/overflow' },
      { label: 'Transforms', path: '/css/transforms' },
      { label: 'Transitions', path: '/css/transitions' },
      { label: 'Keyframes', path: '/css/keyframes' },
      { label: 'Animations', path: '/css/animation' },
      { label: 'Filter', path: '/css/filter' },
    ],
  },
  {
    title: 'CSS Text & Position',
    icon: LucideIcons.type,
    color: '#f59e0b',
    items: [
      { label: 'Position', path: '/css/position' },
      { label: 'Typography', path: '/typography' },
      { label: '@font-face', path: '/fontface' },
      { label: 'Responsive', path: '/responsive' },
      { label: 'Values & Units', path: '/css/values-units' },
    ],
  },
  {
    title: 'DOM',
    icon: LucideIcons.braces,
    color: '#10b981',
    items: [
      { label: 'getBoundingClientRect', path: '/dom-bounding-rect' },
      { label: 'MutationObserver', path: '/mutation-observer' },
      { label: 'Events', path: '/dom/events' },
      { label: 'Geometry', path: '/dom/geometry' },
      { label: 'Offsets', path: '/dom/offsets' },
      { label: 'classList', path: '/dom/classlist' },
      { label: 'innerHTML', path: '/dom/innerhtml' },
      { label: 'element.style', path: '/dom/style' },
    ],
  },
  {
    title: 'Web APIs',
    icon: LucideIcons.globe,
    color: '#06b6d4',
    items: [
      { label: 'Fetch / XHR', path: '/network' },
      { label: 'WebSocket', path: '/websocket' },
      { label: 'localStorage', path: '/web-storage' },
      { label: 'Cookies', path: '/cookies' },
      { label: 'URL / Base64', path: '/url-encoding' },
      { label: 'Tailwind CSS', path: '/tailwind' },
    ],
  },
  {
    title: 'Graphics',
    icon: LucideIcons.image,
    color: '#f97316',
    items: [
      { label: 'Image Gallery', path: '/image' },
      { label: 'Canvas 2D', path: '/canvas-2d' },
      { label: 'SVG via <img>', path: '/svg-image' },
    ],
  },
  {
    title: 'Native',
    icon: LucideIcons.smartphone,
    color: '#6366f1',
    items: [
      { label: 'Share', path: '/webf-share' },
      { label: 'SQFlite', path: '/webf-sqflite' },
      { label: 'Bluetooth', path: '/webf-bluetooth' },
      { label: 'Video Player', path: '/webf-video-player' },
      { label: 'Camera', path: '/webf-camera' },
    ],
  },
];

type QuickStartItem = {
  title: string;
  desc: string;
  to: string;
  icon: LucideIcons;
  gradient: string;
};

const quickStart: QuickStartItem[] = [
  {
    title: 'Cupertino UI',
    desc: 'Native iOS components',
    to: '/cupertino-showcase',
    icon: LucideIcons.smartphone,
    gradient: 'linear-gradient(135deg, #3b82f6, #6366f1)',
  },
  {
    title: 'Lucide Icons',
    desc: '1600+ open source icons',
    to: '/lucide-showcase',
    icon: LucideIcons.sparkles,
    gradient: 'linear-gradient(135deg, #f97316, #f59e0b)',
  },
];

export const HomePage: React.FC = () => {
  const go = (path: string) => WebFRouter.pushState({}, path);

  const QuickStartCard = ({ item }: { item: QuickStartItem }) => (
    <div
      style={{
        background: item.gradient,
        borderRadius: '16px',
        padding: '20px 16px',
        cursor: 'pointer',
        flex: '1',
        minWidth: '0',
        display: 'flex',
        flexDirection: 'column',
        gap: '10px',
      }}
      onClick={() => go(item.to)}
    >
      <div style={{
        width: '36px',
        height: '36px',
        borderRadius: '10px',
        backgroundColor: 'rgba(255,255,255,0.2)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
      }}>
        <FlutterLucideIcon name={item.icon} className="text-lg text-white" />
      </div>
      <div>
        <div style={{
          fontSize: '16px',
          fontWeight: 700,
          color: '#fff',
          marginBottom: '2px',
        }}>{item.title}</div>
        <div style={{
          fontSize: '12px',
          color: 'rgba(255,255,255,0.8)',
        }}>{item.desc}</div>
      </div>
      <div style={{
        fontSize: '11px',
        color: 'rgba(255,255,255,0.6)',
        display: 'flex',
        alignItems: 'center',
        gap: '4px',
        marginTop: 'auto',
      }}>
        Explore
        <FlutterLucideIcon name={LucideIcons.arrowRight} className="text-xs text-white" />
      </div>
    </div>
  );

  const SectionBlock = ({ section }: { section: Section }) => (
    <div style={{
      marginBottom: '20px',
      backgroundColor: 'var(--background-secondary)',
      borderRadius: '16px',
      border: '1px solid var(--border-color)',
      overflow: 'hidden',
    }}>
      {/* Section header */}
      <div style={{
        display: 'flex',
        alignItems: 'center',
        gap: '10px',
        padding: '14px 16px 10px',
      }}>
        <div style={{
          width: '28px',
          height: '28px',
          borderRadius: '8px',
          backgroundColor: section.color + '18',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          flexShrink: 0,
        }}>
          <FlutterLucideIcon
            name={section.icon}
            style={{ fontSize: '14px', color: section.color }}
          />
        </div>
        <span style={{
          fontSize: '14px',
          fontWeight: 600,
          color: 'var(--font-color-primary)',
        }}>{section.title}</span>
        <span style={{
          fontSize: '11px',
          color: 'var(--font-color-secondary)',
          marginLeft: 'auto',
          backgroundColor: 'var(--background-tertiary)',
          padding: '2px 8px',
          borderRadius: '10px',
        }}>{section.items.length}</span>
      </div>

      {/* Items list */}
      <div style={{ padding: '0 8px 8px' }}>
        {section.items.map((item, i) => (
          <div
            key={item.path}
            onClick={() => go(item.path)}
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              padding: '11px 12px',
              cursor: 'pointer',
              borderRadius: '10px',
              borderBottom: i < section.items.length - 1
                ? '1px solid var(--border-color)'
                : 'none',
            }}
          >
            <span style={{
              fontSize: '14px',
              color: 'var(--font-color-primary)',
            }}>{item.label}</span>
            <FlutterLucideIcon
              name={LucideIcons.chevronRight}
              style={{ fontSize: '14px', color: 'var(--font-color-secondary)' }}
            />
          </div>
        ))}
      </div>
    </div>
  );

  return (
    <div id="main">
      <WebFListView className="min-h-screen w-full bg-surface" style={{ padding: '0 16px' }}>
        {/* Hero */}
        <div style={{
          marginTop: '16px',
          marginBottom: '20px',
          padding: '24px 20px',
          borderRadius: '20px',
          background: 'linear-gradient(135deg, #3b82f6 0%, #8b5cf6 50%, #ec4899 100%)',
          position: 'relative',
          overflow: 'hidden',
        }}>
          {/* Decorative circles */}
          <div style={{
            position: 'absolute',
            top: '-20px',
            right: '-20px',
            width: '100px',
            height: '100px',
            borderRadius: '50%',
            backgroundColor: 'rgba(255,255,255,0.1)',
          }} />
          <div style={{
            position: 'absolute',
            bottom: '-30px',
            left: '30px',
            width: '80px',
            height: '80px',
            borderRadius: '50%',
            backgroundColor: 'rgba(255,255,255,0.07)',
          }} />

          <div style={{
            display: 'flex',
            alignItems: 'center',
            gap: '10px',
            marginBottom: '8px',
          }}>
            <FlutterLucideIcon name={LucideIcons.rocket} className="text-xl text-white" />
            <h1 style={{
              fontSize: '24px',
              fontWeight: 800,
              color: '#fff',
              margin: 0,
            }}>WebF Showcase</h1>
          </div>
          <p style={{
            fontSize: '14px',
            color: 'rgba(255,255,255,0.85)',
            margin: 0,
            lineHeight: 1.5,
          }}>
            Explore components, CSS features, DOM APIs, and native integrations.
          </p>
        </div>

        {/* Quick Start */}
        <div style={{
          marginBottom: '24px',
        }}>
          <div style={{
            fontSize: '13px',
            fontWeight: 600,
            color: 'var(--font-color-secondary)',
            textTransform: 'uppercase' as const,
            letterSpacing: '0.5px',
            marginBottom: '10px',
            paddingLeft: '4px',
          }}>Quick Start</div>
          <div style={{
            display: 'flex',
            gap: '12px',
          }}>
            {quickStart.map((qs) => (
              <QuickStartCard key={qs.to} item={qs} />
            ))}
          </div>
        </div>

         Feature Sections
        <div style={{
          fontSize: '13px',
          fontWeight: 600,
          color: 'var(--font-color-secondary)',
          textTransform: 'uppercase' as const,
          letterSpacing: '0.5px',
          marginBottom: '12px',
          paddingLeft: '4px',
        }}>Features</div>

        {sections.map((section) => (
          <SectionBlock key={section.title} section={section} />
        ))}

        {/* Bottom spacer */}
        <div style={{ height: '32px' }} />
      </WebFListView>
    </div>
  );
};
