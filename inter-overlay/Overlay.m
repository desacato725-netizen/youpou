#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

static UIWindow *overlayWindow;
static AVPlayer *audioPlayer;
static NSString *accountName = @"sleep128";

@interface SpotifyOverlayController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property(nonatomic,strong) UIImageView *screenImage;
@end

@implementation SpotifyOverlayController

- (void)viewDidLoad { [super viewDidLoad]; self.view.backgroundColor = UIColor.blackColor; [self showLoginReference]; }

- (void)showImage:(NSString *)name {
  for (UIView *v in self.view.subviews) [v removeFromSuperview];
  self.screenImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
  self.screenImage.frame = self.view.bounds;
  self.screenImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  self.screenImage.contentMode = UIViewContentModeScaleAspectFit;
  self.screenImage.userInteractionEnabled = YES;
  [self.view addSubview:self.screenImage];
}

- (UIButton *)hotspot:(CGRect)frame action:(SEL)action {
  UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom]; b.frame = frame; b.backgroundColor = UIColor.clearColor;
  [b addTarget:self action:action forControlEvents:UIControlEventTouchUpInside]; [self.screenImage addSubview:b]; return b;
}

- (void)showLoginReference {
  [self showImage:@"login-reference.jpg"];
  CGFloat w=self.view.bounds.size.width, h=self.view.bounds.size.height;
  [self hotspot:CGRectMake(24,h*.57,w-48,58) action:@selector(showHomeReference)];
  [self hotspot:CGRectMake(24,h*.64,w-48,55) action:@selector(showHomeReference)];
  [self hotspot:CGRectMake(24,h*.715,w-48,55) action:@selector(showHomeReference)];
  [self hotspot:CGRectMake(24,h*.79,w-48,55) action:@selector(showHomeReference)];
  [self hotspot:CGRectMake(80,h*.87,w-160,55) action:@selector(showHomeReference)];
}

- (void)showHomeReference {
  [self showImage:@"home-reference.jpg"];
  CGFloat w=self.view.bounds.size.width, h=self.view.bounds.size.height;
  [self hotspot:CGRectMake(w*.73, h*.09, w*.25, 70) action:@selector(showMenu)];
  [self hotspot:CGRectMake(0,h*.72,w,h*.12) action:@selector(playDemo)];
  [self hotspot:CGRectMake(0,h*.86,w*.26,90) action:@selector(showHomeReference)];
  [self hotspot:CGRectMake(w*.26,h*.86,w*.25,90) action:@selector(showSearch)];
  [self hotspot:CGRectMake(w*.51,h*.86,w*.27,90) action:@selector(showHomeReference)];
  [self hotspot:CGRectMake(w*.78,h*.86,w*.22,90) action:@selector(showMenu)];
}

- (void)showSearch { UIAlertController *a=[UIAlertController alertControllerWithTitle:@"Buscar" message:@"Digite o nome de uma música, artista ou playlist." preferredStyle:UIAlertControllerStyleAlert]; [a addTextFieldWithConfigurationHandler:^(UITextField *f){f.placeholder=@"O que você quer ouvir?";}]; [a addAction:[UIAlertAction actionWithTitle:@"Cancelar" style:UIAlertActionStyleCancel handler:nil]]; [a addAction:[UIAlertAction actionWithTitle:@"Buscar" style:UIAlertActionStyleDefault handler:nil]]; [self presentViewController:a animated:YES completion:nil]; }

- (void)playDemo { audioPlayer=[AVPlayer playerWithURL:[NSURL URLWithString:@"https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"]]; [audioPlayer play]; }

- (void)showMenu {
  UIAlertController *menu=[UIAlertController alertControllerWithTitle:accountName message:nil preferredStyle:UIAlertControllerStyleActionSheet];
  [menu addAction:[UIAlertAction actionWithTitle:@"Editar nome da conta" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a){[self editProfile];}]];
  [menu addAction:[UIAlertAction actionWithTitle:@"Trocar foto de perfil" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a){[self pickPhoto];}]];
  [menu addAction:[UIAlertAction actionWithTitle:@"Configurações e privacidade" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a){[self dismissOverlay];}]];
  [menu addAction:[UIAlertAction actionWithTitle:@"Abrir app original" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a){[self dismissOverlay];}]];
  [menu addAction:[UIAlertAction actionWithTitle:@"Cancelar" style:UIAlertActionStyleCancel handler:nil]];
  [self presentViewController:menu animated:YES completion:nil];
}

- (void)editProfile {
  UIAlertController *a=[UIAlertController alertControllerWithTitle:@"Editar perfil" message:@"Digite o nome da conta" preferredStyle:UIAlertControllerStyleAlert];
  [a addTextFieldWithConfigurationHandler:^(UITextField *f){f.text=accountName;}];
  [a addAction:[UIAlertAction actionWithTitle:@"Cancelar" style:UIAlertActionStyleCancel handler:nil]];
  [a addAction:[UIAlertAction actionWithTitle:@"Salvar" style:UIAlertActionStyleDefault handler:^(UIAlertAction *x){NSString *n=a.textFields.firstObject.text;if(n.length)accountName=n;[self showHomeReference];}]];
  [self presentViewController:a animated:YES completion:nil];
}

- (void)pickPhoto {
  UIImagePickerController *picker=[UIImagePickerController new]; picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary; picker.delegate=self; [self presentViewController:picker animated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info { [picker dismissViewControllerAnimated:YES completion:nil]; }
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker { [picker dismissViewControllerAnimated:YES completion:nil]; }
- (void)dismissOverlay { [overlayWindow resignKeyWindow]; overlayWindow.hidden=YES; overlayWindow=nil; }
@end

__attribute__((constructor)) static void spotify_overlay_start(void) {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(1.2*NSEC_PER_SEC)),dispatch_get_main_queue(),^{
    UIWindow *host=nil; for(UIScene *scene in UIApplication.sharedApplication.connectedScenes) if([scene isKindOfClass:[UIWindowScene class]]) for(UIWindow *w in ((UIWindowScene *)scene).windows) if(w.isKeyWindow){host=w;break;}
    if(!host)return; overlayWindow=[[UIWindow alloc]initWithWindowScene:host.windowScene]; overlayWindow.frame=host.bounds; overlayWindow.windowLevel=UIWindowLevelAlert+1; overlayWindow.rootViewController=[SpotifyOverlayController new]; [overlayWindow makeKeyAndVisible];
  });
}
