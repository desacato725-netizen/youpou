#import <UIKit/UIKit.h>

static BOOL partner_link_opening = NO;

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
    NSURL *url = [NSURL URLWithString:@"interparceria://home"];
    NSURL *containerURL = [NSURL URLWithString:@"livecontainer://livecontainer-launch?bundle-name=3105.app&urlscheme=interparceria%3A%2F%2Fhome"];
    if (@available(iOS 10.0, *)) {
      [UIApplication.sharedApplication openURL:url options:@{} completionHandler:^(BOOL success) {
        if (!success) {
          [UIApplication.sharedApplication openURL:containerURL options:@{} completionHandler:nil];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ partner_link_opening = NO; });
      }];
    } else {
      BOOL success = [UIApplication.sharedApplication openURL:url];
      if (!success) [UIApplication.sharedApplication openURL:containerURL];
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ partner_link_opening = NO; });
    }
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
