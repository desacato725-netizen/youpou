#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

static UIWindow *overlayWindow;

@interface SpotifyWebController : UIViewController <WKScriptMessageHandler>
@property(nonatomic,strong) WKWebView *webView;
@end

@implementation SpotifyWebController
- (void)viewDidLoad {
  [super viewDidLoad];
  WKWebViewConfiguration *config=[WKWebViewConfiguration new];
  [config.userContentController addScriptMessageHandler:self name:@"original"];
  self.webView=[[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
  self.webView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
  self.webView.scrollView.alwaysBounceVertical=YES;
  [self.view addSubview:self.webView];
  NSURL *url=[[NSBundle mainBundle] URLForResource:@"spotify" withExtension:@"html"];
  if(url) [self.webView loadFileURL:url allowingReadAccessToURL:[url URLByDeletingLastPathComponent]];
}
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
  if([message.name isEqualToString:@"original"]) { [overlayWindow resignKeyWindow]; overlayWindow.hidden=YES; overlayWindow=nil; }
}
@end

__attribute__((constructor)) static void spotify_overlay_start(void) {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(1.2*NSEC_PER_SEC)),dispatch_get_main_queue(),^{
    UIWindow *host=nil;
    for(UIScene *scene in UIApplication.sharedApplication.connectedScenes) if([scene isKindOfClass:[UIWindowScene class]]) for(UIWindow *w in ((UIWindowScene *)scene).windows) if(w.isKeyWindow){host=w;break;}
    if(!host)return;
    overlayWindow=[[UIWindow alloc] initWithWindowScene:host.windowScene]; overlayWindow.frame=host.bounds; overlayWindow.windowLevel=UIWindowLevelAlert+1; overlayWindow.rootViewController=[SpotifyWebController new]; [overlayWindow makeKeyAndVisible];
  });
}
