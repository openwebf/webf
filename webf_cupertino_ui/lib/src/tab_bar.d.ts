// Available icon names for FlutterCupertinoTabBarItem
type CupertinoTabBarIcon =
  // Common navigation icons
  | 'home' | 'house' | 'house_fill'
  | 'search' | 'search_circle' | 'search_circle_fill'

  // Action icons
  | 'add' | 'add_circled' | 'add_circled_solid'
  | 'plus' | 'plus_circle' | 'plus_circle_fill'

  // User/Account icons
  | 'person' | 'person_fill' | 'person_circle' | 'person_circle_fill' | 'profile_circled'

  // Communication icons
  | 'bell' | 'bell_fill' | 'bell_circle' | 'bell_circle_fill'
  | 'chat_bubble' | 'chat_bubble_fill' | 'chat_bubble_2' | 'chat_bubble_2_fill'
  | 'mail' | 'mail_solid' | 'envelope' | 'envelope_fill'
  | 'phone' | 'phone_fill'

  // Navigation/Direction icons
  | 'compass' | 'compass_fill'
  | 'location' | 'location_fill'
  | 'map' | 'map_fill'

  // Media icons
  | 'photo' | 'photo_fill'
  | 'camera' | 'camera_fill'
  | 'video_camera' | 'video_camera_solid'
  | 'play' | 'play_fill' | 'play_circle' | 'play_circle_fill'

  // Settings/System icons
  | 'gear' | 'gear_solid'
  | 'settings' | 'settings_solid'
  | 'ellipsis' | 'ellipsis_circle' | 'ellipsis_circle_fill'

  // Business/Finance icons
  | 'creditcard' | 'creditcard_fill'
  | 'cart' | 'cart_fill'
  | 'bag' | 'bag_fill'

  // Document/File icons
  | 'doc' | 'doc_fill' | 'doc_text' | 'doc_text_fill'
  | 'folder' | 'folder_fill'
  | 'book' | 'book_fill'

  // Social/Interaction icons
  | 'heart' | 'heart_fill'
  | 'star' | 'star_fill'
  | 'hand_thumbsup' | 'hand_thumbsup_fill'
  | 'bookmark' | 'bookmark_fill'

  // Currency icons
  | 'money_dollar' | 'money_dollar_circle' | 'money_dollar_circle_fill'

  // Utility icons
  | 'info' | 'info_circle' | 'info_circle_fill'
  | 'question' | 'question_circle' | 'question_circle_fill'
  | 'exclamationmark' | 'exclamationmark_circle' | 'exclamationmark_circle_fill';

interface FlutterCupertinoTabBarProperties {
  'current-index'?: string;
  'background-color'?: string;
  'active-color'?: string;
  'inactive-color'?: string;
  'icon-size'?: string;
  height?: string;
}

interface FlutterCupertinoTabBarMethods {
  // Methods
  switchTab(path: string): void;
}

interface FlutterCupertinoTabBarEvents {
  tabchange: CustomEvent<int>;
}

interface FlutterCupertinoTabBarItemProperties {
  title?: string;
  icon?: CupertinoTabBarIcon;
  path?: string;
}

// Type alias for clarity
type int = number;
