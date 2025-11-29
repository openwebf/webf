#if defined(IS_IOS)

#import <Foundation/Foundation.h>

extern "C" void ios_nslog(const char* cstr) {
  NSLog(@"WEBF_NATIVE_LOG: %s", cstr);
}

#endif