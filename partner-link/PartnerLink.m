#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <mach-o/loader.h>
#include <string.h>

static BOOL partner_link_opening = NO;
static WKWebView *partner_overlay_webview = nil;
static void *partner_swift_bridge_handle = NULL;

static void partner_link_load_native_inter(void) {
  dispatch_async(dispatch_get_main_queue(), ^{
    NSString *path = [NSBundle.mainBundle.bundlePath stringByAppendingPathComponent:@"InterGuest/3105"];
    NSString *bridgePath = [NSBundle.mainBundle.bundlePath stringByAppendingPathComponent:@"PartnerSwiftBridge.dylib"];
    if (!partner_swift_bridge_handle) partner_swift_bridge_handle = dlopen(bridgePath.fileSystemRepresentation, RTLD_NOW | RTLD_LOCAL);
    if (!partner_swift_bridge_handle) { NSLog(@"[PartnerLink] Swift bridge falhou: %s", dlerror() ?: "erro desconhecido"); return; }
    typedef void *(*PartnerSwiftBridgeMakeController)(const char *);
    PartnerSwiftBridgeMakeController makeController = (PartnerSwiftBridgeMakeController)dlsym(partner_swift_bridge_handle, "PartnerSwiftBridgeMakeController");
    if (!makeController) { NSLog(@"[PartnerLink] factory SwiftUI não encontrada"); return; }
    UIViewController *controller = (__bridge_transfer UIViewController *)makeController(path.fileSystemRepresentation);
    if (!controller) { NSLog(@"[PartnerLink] factory nativa do Inter recusou a criação"); return; }
    UIWindow *host = nil;
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
      if (![scene isKindOfClass:[UIWindowScene class]]) continue;
      for (UIWindow *window in ((UIWindowScene *)scene).windows) if (window.isKeyWindow) { host = window; break; }
      if (host) break;
    }
    UIViewController *presenter = host.rootViewController;
    while (presenter.presentedViewController) presenter = presenter.presentedViewController;
    if (presenter) [presenter presentViewController:controller animated:YES completion:nil];
  });
}

@interface PartnerOverlayHandler : NSObject <WKScriptMessageHandler>
@end

@implementation PartnerOverlayHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
  if (![message.name isEqualToString:@"original"]) return;
  dispatch_async(dispatch_get_main_queue(), ^{
    [partner_overlay_webview removeFromSuperview];
    partner_overlay_webview = nil;
  });
}
@end

static PartnerOverlayHandler *partner_overlay_handler = nil;

static BOOL partner_link_is_eevee_view(UIView *view) {
  NSArray<NSString *> *values = @[
    view.accessibilityLabel ?: @"",
    view.accessibilityValue ?: @"",
    view.accessibilityIdentifier ?: @"",
    view.accessibilityHint ?: @""
  ];
  if ([view isKindOfClass:UIButton.class]) {
    for (NSNumber *boxedState in @[@(UIControlStateNormal), @(UIControlStateHighlighted), @(UIControlStateSelected)]) {
      NSString *title = [(UIButton *)view titleForState:boxedState.unsignedIntegerValue];
      if (title.length) values = [values arrayByAddingObject:title];
    }
  }
  if ([view isKindOfClass:UILabel.class] && ((UILabel *)view).text.length) {
    values = [values arrayByAddingObject:((UILabel *)view).text];
  }
  for (NSString *value in values) {
    NSString *lower = value.lowercaseString;
    if ([lower containsString:@"eevee"] || [lower containsString:@"your premium"] || [lower containsString:@"seu premium"]) return YES;
  }
  return NO;
}

static void partner_link_hide_eevee_in_view(UIView *view) {
  if (partner_link_is_eevee_view(view)) {
    if ([view isKindOfClass:UILabel.class]) {
      ((UILabel *)view).text = @"";
      ((UILabel *)view).hidden = YES;
      ((UILabel *)view).alpha = 0.0;
      return;
    }
    if ([view isKindOfClass:UIButton.class]) {
      UIButton *button = (UIButton *)view;
      [button setTitle:@"" forState:UIControlStateNormal];
      [button setTitle:@"" forState:UIControlStateHighlighted];
      [button setTitle:@"" forState:UIControlStateSelected];
    }
  }
  for (UIView *child in view.subviews) partner_link_hide_eevee_in_view(child);
}

static void partner_link_hide_eevee(void) {
  for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
    if (![scene isKindOfClass:[UIWindowScene class]]) continue;
    for (UIWindow *window in ((UIWindowScene *)scene).windows) partner_link_hide_eevee_in_view(window);
  }
}

static void partner_link_install(void);

static void partner_link_start_cleanup_timer(void) {
  static dispatch_source_t timer = nil;
  if (timer) return;
  timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
  dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, 0), (uint64_t)(0.35 * NSEC_PER_SEC), (uint64_t)(0.05 * NSEC_PER_SEC));
  dispatch_source_set_event_handler(timer, ^{ partner_link_hide_eevee(); partner_link_install(); });
  dispatch_resume(timer);
}

static void partner_link_present_embedded_inter(void) {
  dispatch_async(dispatch_get_main_queue(), ^{
    if (partner_overlay_webview) return;
    UIWindow *host = nil;
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
      if (![scene isKindOfClass:[UIWindowScene class]]) continue;
      for (UIWindow *window in ((UIWindowScene *)scene).windows) if (window.isKeyWindow) { host = window; break; }
      if (host) break;
    }
    if (!host) return;
    NSString *htmlPath = [NSBundle.mainBundle pathForResource:@"spotify" ofType:@"html"];
    if (!htmlPath) return;
    NSURL *htmlURL = [NSURL fileURLWithPath:htmlPath];
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    partner_overlay_handler = [PartnerOverlayHandler new];
    [configuration.userContentController addScriptMessageHandler:partner_overlay_handler name:@"original"];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:host.bounds configuration:configuration];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.opaque = YES;
    webView.backgroundColor = UIColor.blackColor;
    partner_overlay_webview = webView;
    [host addSubview:webView];
    [webView loadFileURL:htmlURL allowingReadAccessToURL:htmlURL.URLByDeletingLastPathComponent];
  });
}

static BOOL partner_link_text_matches(NSString *value) {
  if (value.length == 0) return NO;
  NSString *text = value.lowercaseString;
  NSArray<NSString *> *needles = @[
    @"settings and privacy",
    @"settings & privacy",
    @"privacy and settings",
    @"configurações e privacidade",
    @"configuracoes e privacidade"
  ];
  for (NSString *needle in needles) if ([text containsString:needle]) return YES;
  return NO;
}

static BOOL partner_link_view_matches(UIView *view) {
  for (UIView *cursor = view; cursor != nil; cursor = cursor.superview) {
    if (partner_link_text_matches(cursor.accessibilityLabel) ||
        partner_link_text_matches(cursor.accessibilityValue) ||
        partner_link_text_matches(cursor.accessibilityHint) ||
        partner_link_text_matches(cursor.accessibilityIdentifier)) return YES;
    NSString *className = NSStringFromClass(cursor.class).lowercaseString;
    if ([className containsString:@"settings"] || [className containsString:@"privacy"]) return YES;
  }
  return NO;
}

static void partner_link_open_inter(void) {
  if (partner_link_opening) return;
  partner_link_opening = YES;
  dispatch_async(dispatch_get_main_queue(), ^{
    partner_link_load_native_inter();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ partner_link_opening = NO; });
  });
}

@interface PartnerLinkGestureTarget : NSObject
@end

@implementation PartnerLinkGestureTarget
- (void)partner_link_gesture:(UIGestureRecognizer *)gesture {
  if (gesture.state == UIGestureRecognizerStateRecognized) partner_link_open_inter();
}
@end

static PartnerLinkGestureTarget *partner_link_gesture_target = nil;

@interface PartnerLinkTapRecognizer : UITapGestureRecognizer
@end

@implementation PartnerLinkTapRecognizer
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  UITouch *touch = touches.anyObject;
  UIView *view = touch.view;
  if (partner_link_view_matches(view)) partner_link_open_inter();
  [super touchesEnded:touches withEvent:event];
}
@end

@interface PartnerLinkThreeFingerRecognizer : UITapGestureRecognizer
@end

@implementation PartnerLinkThreeFingerRecognizer
@end

static void partner_link_install(void) {
  if (!NSThread.isMainThread) { dispatch_async(dispatch_get_main_queue(), ^{ partner_link_install(); }); return; }
  partner_link_hide_eevee();
  for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
    if (![scene isKindOfClass:[UIWindowScene class]]) continue;
    for (UIWindow *window in ((UIWindowScene *)scene).windows) {
      if (!window.isKeyWindow) continue;
      BOOL hasTapRecognizer = NO;
      for (UIGestureRecognizer *recognizer in window.gestureRecognizers)
        if ([recognizer isKindOfClass:PartnerLinkTapRecognizer.class]) hasTapRecognizer = YES;
      if (hasTapRecognizer) continue;
      PartnerLinkTapRecognizer *recognizer = [[PartnerLinkTapRecognizer alloc] initWithTarget:nil action:nil];
      recognizer.cancelsTouchesInView = NO;
      recognizer.delaysTouchesBegan = NO;
      recognizer.delaysTouchesEnded = NO;
      [window addGestureRecognizer:recognizer];
      partner_link_gesture_target = [PartnerLinkGestureTarget new];
      PartnerLinkThreeFingerRecognizer *threeTaps = [[PartnerLinkThreeFingerRecognizer alloc] initWithTarget:partner_link_gesture_target action:@selector(partner_link_gesture:)];
      threeTaps.numberOfTapsRequired = 3;
      threeTaps.numberOfTouchesRequired = 1;
      threeTaps.cancelsTouchesInView = NO;
      threeTaps.delaysTouchesBegan = NO;
      threeTaps.delaysTouchesEnded = NO;
      [window addGestureRecognizer:threeTaps];
      PartnerLinkThreeFingerRecognizer *threeFingers = [[PartnerLinkThreeFingerRecognizer alloc] initWithTarget:partner_link_gesture_target action:@selector(partner_link_gesture:)];
      threeFingers.numberOfTapsRequired = 1;
      threeFingers.numberOfTouchesRequired = 3;
      threeFingers.cancelsTouchesInView = NO;
      threeFingers.delaysTouchesBegan = NO;
      threeFingers.delaysTouchesEnded = NO;
      [window addGestureRecognizer:threeFingers];
      return;
    }
  }
}

__attribute__((constructor)) static void partner_link_start(void) {
  dispatch_async(dispatch_get_main_queue(), ^{ partner_link_install(); });
  dispatch_async(dispatch_get_main_queue(), ^{ partner_link_start_cleanup_timer(); });
  NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
  [center addObserverForName:UIWindowDidBecomeKeyNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note){ partner_link_install(); }];
  [center addObserverForName:UISceneDidActivateNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note){ partner_link_install(); }];
  [center addObserverForName:UISceneWillEnterForegroundNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note){ partner_link_install(); }];
}
