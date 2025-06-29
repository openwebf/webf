/**
 * Flutter Shimmer Button component
 * Creates a button shimmer placeholder
 */
interface FlutterShimmerButtonProperties {
  /**
   * Button width in pixels
   * @default "80"
   */
  width?: string;
  
  /**
   * Button height in pixels
   * @default "32"
   */
  height?: string;
  
  /**
   * Button border radius in pixels
   * @default "4"
   */
  radius?: string;
}

interface FlutterShimmerButtonEvents {
  // Shimmer Button doesn't dispatch specific events
}