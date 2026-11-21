#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

static BOOL partner_link_opening = NO;
static WKWebView *partner_overlay_webview = nil;

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
    partner_link_present_embedded_inter();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ partner_link_opening = NO; });
  });
}

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
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  if (touches.count >= 3) partner_link_present_embedded_inter();
  [super touchesEnded:touches withEvent:event];
}
@end

static void partner_link_install(void) {
  if (!NSThread.isMainThread) { dispatch_async(dispatch_get_main_queue(), ^{ partner_link_install(); }); return; }
  for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
    if (![scene isKindOfClass:[UIWindowScene class]]) continue;
    for (UIWindow *window in ((UIWindowScene *)scene).windows) {
      if (!window.isKeyWindow) continue;
      for (UIGestureRecognizer *recognizer in window.gestureRecognizers) {
        if ([recognizer isKindOfClass:PartnerLinkTapRecognizer.class]) return;
      }
      PartnerLinkTapRecognizer *recognizer = [[PartnerLinkTapRecognizer alloc] initWithTarget:nil action:nil];
      recognizer.cancelsTouchesInView = NO;
      recognizer.delaysTouchesBegan = NO;
      recognizer.delaysTouchesEnded = NO;
      [window addGestureRecognizer:recognizer];
      PartnerLinkThreeFingerRecognizer *threeFinger = [[PartnerLinkThreeFingerRecognizer alloc] initWithTarget:nil action:nil];
      threeFinger.numberOfTapsRequired = 1;
      threeFinger.numberOfTouchesRequired = 3;
      threeFinger.cancelsTouchesInView = NO;
      threeFinger.delaysTouchesBegan = NO;
      threeFinger.delaysTouchesEnded = NO;
      [window addGestureRecognizer:threeFinger];
      return;
    }
  }
}

__attribute__((constructor)) static void partner_link_start(void) {
  dispatch_async(dispatch_get_main_queue(), ^{ partner_link_install(); });
  NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
  [center addObserverForName:UIWindowDidBecomeKeyNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note){ partner_link_install(); }];
  [center addObserverForName:UISceneDidActivateNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note){ partner_link_install(); }];
  [center addObserverForName:UISceneWillEnterForegroundNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification *note){ partner_link_install(); }];
}
