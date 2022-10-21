#import "WebFPlugin.h"

static FlutterMethodChannel *methodChannel = nil;

@implementation WebFPlugin

+ (FlutterMethodChannel *) getMethodChannel {
  return methodChannel;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  NSObject<FlutterBinaryMessenger>* messager = [registrar messenger];
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"webf"
            binaryMessenger:messager];
  methodChannel = channel;

  WebFPlugin* instance = [[WebFPlugin alloc] initWithRegistrar: registrar];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype) initWithRegistrar: (NSObject<FlutterPluginRegistrar>*)registrar{
  self = [super init];
  self.registrar = registrar;
  return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getTemporaryDirectory" isEqualToString: call.method]) {
    result([self getTemporaryDirectory]);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (NSString*) getTemporaryDirectory {
  NSArray<NSString *>* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  return [paths.firstObject stringByAppendingString: @"/WebF"];
}

@end
