// Additional type declarations for the React Use Cases project
// WebF core types are provided by @openwebf/webf-enterprise-typings

declare global {
  // Custom component props for WebF components
  interface WebFListViewProps {
    className?: string;
    children?: React.ReactNode;
  }

  interface FlutterCupertinoTabBarProps {
    currentIndex?: number;
    backgroundColor?: string;
    activeColor?: string;
    inactiveColor?: string;
    height?: number;
    iconSize?: number;
    onTabchange?: (event: any) => void;
    children?: React.ReactNode;
  }

  interface FlutterCupertinoTabBarItemProps {
    title?: string;
    icon?: string;
    path?: string;
    children?: React.ReactNode;
  }

  // React Hook Form types for complex forms
  interface HTMLElementTagNameMap {
    'webf-listview': HTMLElement & WebFListViewProps;
    'flutter-cupertino-tab-bar': HTMLElement & FlutterCupertinoTabBarProps;
    'flutter-cupertino-tab-bar-item': HTMLElement & FlutterCupertinoTabBarItemProps;
  }
}

export {};