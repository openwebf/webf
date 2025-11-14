interface FlutterCupertinoToastOptions {
  content: string;
  type?: 'normal' | 'success' | 'warning' | 'error' | 'loading';
  duration?: number;
}

interface FlutterCupertinoToastMethods {
  show(options: FlutterCupertinoToastOptions): void;
  close(): void;
}

interface FlutterCupertinoToastEvents {
  // No events
}