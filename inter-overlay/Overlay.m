#import <UIKit/UIKit.h>

static UIWindow *overlayWindow;
static UIViewController *spotifyController;

@interface SpotifyOverlayController : UIViewController
@end

@implementation SpotifyOverlayController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor colorWithRed:0.071 green:0.071 blue:0.071 alpha:1.0];
  [self showLogin];
}

- (UILabel *)label:(NSString *)text size:(CGFloat)size weight:(UIFontWeight)weight {
  UILabel *label = [[UILabel alloc] init];
  label.text = text;
  label.textColor = UIColor.whiteColor;
  label.font = [UIFont systemFontOfSize:size weight:weight];
  label.textAlignment = NSTextAlignmentCenter;
  label.numberOfLines = 0;
  return label;
}

- (UIButton *)button:(NSString *)title filled:(BOOL)filled {
  UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
  [button setTitle:title forState:UIControlStateNormal];
  [button setTitleColor:filled ? UIColor.blackColor : UIColor.whiteColor forState:UIControlStateNormal];
  button.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
  button.layer.cornerRadius = 25;
  button.layer.borderWidth = filled ? 0 : 1;
  button.layer.borderColor = [UIColor colorWithWhite:0.45 alpha:1].CGColor;
  button.backgroundColor = filled ? [UIColor colorWithRed:0.118 green:0.843 blue:0.376 alpha:1] : UIColor.clearColor;
  return button;
}

- (void)showLogin {
  for (UIView *view in self.view.subviews) [view removeFromSuperview];
  UIStackView *stack = [[UIStackView alloc] init];
  stack.axis = UILayoutConstraintAxisVertical;
  stack.spacing = 12;
  stack.alignment = UIStackViewAlignmentFill;
  stack.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:stack];
  UILabel *mark = [self label:@"●\nSpotify" size:25 weight:UIFontWeightBold];
  mark.textColor = [UIColor colorWithRed:0.118 green:0.843 blue:0.376 alpha:1];
  [stack addArrangedSubview:mark];
  [stack addArrangedSubview:[self label:@"Milhões de músicas.\nGrátis no Spotify." size:31 weight:UIFontWeightBold]];
  UIButton *signup = [self button:@"Cadastre-se grátis" filled:YES];
  [signup addTarget:self action:@selector(showHome) forControlEvents:UIControlEventTouchUpInside];
  [stack addArrangedSubview:signup];
  for (NSString *title in @[@"Continuar com Google", @"Continuar com Facebook", @"Continuar com Apple"]) {
    UIButton *social = [self button:title filled:NO];
    [social addTarget:self action:@selector(showHome) forControlEvents:UIControlEventTouchUpInside];
    [stack addArrangedSubview:social];
  }
  UILabel *demo = [self label:@"Acesso demo: sleep128@gmail.com\nSenha: sleepffx9017" size:12 weight:UIFontWeightRegular];
  demo.textColor = [UIColor colorWithWhite:0.65 alpha:1];
  [stack addArrangedSubview:demo];
  UIButton *login = [self button:@"Entrar" filled:NO];
  [login addTarget:self action:@selector(showHome) forControlEvents:UIControlEventTouchUpInside];
  [stack addArrangedSubview:login];
  [NSLayoutConstraint activateConstraints:@[
    [stack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:28],
    [stack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-28],
    [stack.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
  ]];
}

- (void)showHome {
  for (UIView *view in self.view.subviews) [view removeFromSuperview];
  UIStackView *stack = [[UIStackView alloc] init];
  stack.axis = UILayoutConstraintAxisVertical; stack.spacing = 14; stack.alignment = UIStackViewAlignmentFill; stack.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:stack];
  UIButton *avatar = [self button:@"S    Boa noite                                      ⚙" filled:NO];
  [avatar addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
  [stack addArrangedSubview:avatar];
  [stack addArrangedSubview:[self label:@"Suas playlists" size:24 weight:UIFontWeightBold]];
  for (NSString *title in @[@"Sua rotação   •   Lana Del Rey", @"Feito para sleep128   •   Mac Miller", @"Tocadas recentemente   •   Sad Girl"]) {
    UIButton *card = [self button:title filled:NO];
    [card addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [stack addArrangedSubview:card];
  }
  [stack addArrangedSubview:[self label:@"Início          Buscar          Sua Biblioteca" size:13 weight:UIFontWeightSemibold]];
  [NSLayoutConstraint activateConstraints:@[[stack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],[stack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],[stack.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20]]];
}

- (void)showMenu {
  UIAlertController *menu = [UIAlertController alertControllerWithTitle:@"sleep128" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
  [menu addAction:[UIAlertAction actionWithTitle:@"Configurações e privacidade" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) { [self dismissOverlay]; }]];
  [menu addAction:[UIAlertAction actionWithTitle:@"Abrir app original" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) { [self dismissOverlay]; }]];
  [menu addAction:[UIAlertAction actionWithTitle:@"Cancelar" style:UIAlertActionStyleCancel handler:nil]];
  [self presentViewController:menu animated:YES completion:nil];
}

- (void)dismissOverlay {
  [overlayWindow resignKeyWindow]; overlayWindow.hidden = YES; overlayWindow = nil;
}
@end

__attribute__((constructor)) static void spotify_overlay_start(void) {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    UIWindow *host = nil;
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
      if ([scene isKindOfClass:[UIWindowScene class]]) {
        for (UIWindow *window in ((UIWindowScene *)scene).windows) if (window.isKeyWindow) { host = window; break; }
      }
      if (host) break;
    }
    if (!host) return;
    overlayWindow = [[UIWindow alloc] initWithWindowScene:host.windowScene];
    overlayWindow.frame = host.bounds;
    overlayWindow.windowLevel = UIWindowLevelAlert + 1;
    spotifyController = [SpotifyOverlayController new];
    overlayWindow.rootViewController = spotifyController;
    [overlayWindow makeKeyAndVisible];
  });
}
