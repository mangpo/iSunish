#import "AROverlayViewController.h"

@interface AROverlayViewController ()
@end

@implementation AROverlayViewController

@synthesize captureManager, settingsButton, settingsFrame;

- (void)viewDidLoad {
  
	[self setCaptureManager:[[[CaptureSessionManager alloc] init] autorelease]];
  
	[[self captureManager] addVideoInput];
  
  [[self captureManager] addStillImageOutput];
  
	[[self captureManager] addVideoPreviewLayer];
	CGRect layerRect = [[[self view] layer] bounds];
	[[[self captureManager] previewLayer] setBounds:layerRect];
	[[[self captureManager] previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),
                                                                CGRectGetMidY(layerRect))];
	[[[self view] layer] addSublayer:[[self captureManager] previewLayer]];
  
  //UIImageView *overlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlaygraphic.png"]];
  //[overlayImageView setFrame:CGRectMake(30, 100, 260, 200)];
 // [[self view] addSubview:overlayImageView];
 // [overlayImageView release];
  CGRect bounds=[[UIScreen mainScreen] bounds];
  overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [overlayButton setImage:[UIImage imageNamed:@"takePicture.png"] forState:UIControlStateNormal];
  [overlayButton setAccessibilityLabel:NSLocalizedString(@"", @"")];
  [overlayButton setFrame:CGRectMake(bounds.origin.x,bounds.origin.y,bounds.size.width, bounds.size.height)];
  [overlayButton addTarget:self action:@selector(scanButtonPressed) forControlEvents:UIControlEventTouchUpInside];
  [[self view] addSubview:overlayButton];
    
    settingsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [settingsButton setFrame:CGRectMake(bounds.origin.x+110,bounds.origin.y+420,bounds.size.width-220, 40)];
    UILabel *settingsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [settingsLabel setBackgroundColor:[UIColor clearColor]];
    [settingsLabel setCenter:CGPointMake((bounds.size.width-220)/2, 20)];
    [settingsLabel setText:@"settings"];
    settingsLabel.textAlignment = UITextAlignmentCenter;
    [settingsButton addSubview:settingsLabel];
    [settingsButton addTarget:self action:@selector(settingsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:settingsButton];
    
    settingsFrame = [[UIView alloc] initWithFrame:CGRectMake(bounds.origin.x,bounds.origin.y,bounds.size.width, bounds.size.height)];
    [settingsFrame setBackgroundColor:[UIColor grayColor]];
    
    int w = 200, h = 30;
    UIButton *fluorescence = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIButton *incandescence = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIButton *custom = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIButton *custom2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIButton *custom3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIButton *custom4 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [fluorescence setFrame:CGRectMake(0,0,w, h)];
    [incandescence setFrame:CGRectMake(0,0,w, h)];
    [custom setFrame:CGRectMake(0,0,w, h)];
    [custom2 setFrame:CGRectMake(0,0,w, h)];
    [custom3 setFrame:CGRectMake(0,0,w, h)];
    [custom4 setFrame:CGRectMake(0,0,w, h)];
    [fluorescence setCenter:CGPointMake(bounds.size.width/2, 50)];
    [incandescence setCenter:CGPointMake(bounds.size.width/2, 100)];
    [custom setCenter:CGPointMake(bounds.size.width/2, 150)];
    [custom2 setCenter:CGPointMake(bounds.size.width/2, 200)];
    [custom3 setCenter:CGPointMake(bounds.size.width/2, 250)];
    [custom4 setCenter:CGPointMake(bounds.size.width/2, 300)];
    
    UILabel *fluorescenceLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    [fluorescenceLable setBackgroundColor:[UIColor clearColor]];
    [fluorescenceLable setCenter:CGPointMake(w/2, h/2)];
    [fluorescenceLable setText:@"Fluorescent Lighting"];
    fluorescenceLable.textAlignment = UITextAlignmentCenter;
    [fluorescence addSubview:fluorescenceLable];
    
    UILabel *incandescenceLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    [incandescenceLable setBackgroundColor:[UIColor clearColor]];
    [incandescenceLable setCenter:CGPointMake(w/2, h/2)];
    [incandescenceLable setText:@"Incandescent Lighting"];
    incandescenceLable.textAlignment = UITextAlignmentCenter;
    [incandescence addSubview:incandescenceLable];
    
    UILabel *customLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    [customLable setBackgroundColor:[UIColor clearColor]];
    [customLable setCenter:CGPointMake(w/2, h/2)];
    [customLable setText:@"Custom Lighting"];
    customLable.textAlignment = UITextAlignmentCenter;
    [custom addSubview:customLable];
    
    UILabel *customLable2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    [customLable2 setBackgroundColor:[UIColor clearColor]];
    [customLable2 setCenter:CGPointMake(w/2, h/2)];
    [customLable2 setText:@"Custom Lighting2"];
    customLable2.textAlignment = UITextAlignmentCenter;
    [custom2 addSubview:customLable2];
    
    UILabel *customLable3 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    [customLable3 setBackgroundColor:[UIColor clearColor]];
    [customLable3 setCenter:CGPointMake(w/2, h/2)];
    [customLable3 setText:@"Custom Lighting3"];
    customLable3.textAlignment = UITextAlignmentCenter;
    [custom3 addSubview:customLable3];
    
    UILabel *customLable4 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    [customLable4 setBackgroundColor:[UIColor clearColor]];
    [customLable4 setCenter:CGPointMake(w/2, h/2)];
    [customLable4 setText:@"Custom Lighting3"];
    customLable4.textAlignment = UITextAlignmentCenter;
    [custom4 addSubview:customLable4];
    
    [fluorescence addTarget:self action:@selector(fluorescencePressed) forControlEvents:UIControlEventTouchUpInside];
    [incandescence addTarget:self action:@selector(incandescencePressed) forControlEvents:UIControlEventTouchUpInside];
    [custom addTarget:self action:@selector(customPressed) forControlEvents:UIControlEventTouchUpInside];
    [custom2 addTarget:self action:@selector(customPressed2) forControlEvents:UIControlEventTouchUpInside];
    [custom3 addTarget:self action:@selector(customPressed3) forControlEvents:UIControlEventTouchUpInside];
    [custom4 addTarget:self action:@selector(customPressed4) forControlEvents:UIControlEventTouchUpInside];
    
    [settingsFrame addSubview:fluorescence];
    [settingsFrame addSubview:incandescence];
    [settingsFrame addSubview:custom];
    [settingsFrame addSubview:custom2];
    [settingsFrame addSubview:custom3];
    [settingsFrame addSubview:custom4];
    [settingsFrame setHidden:YES];
    [[self view] addSubview:settingsFrame];
    
  [[captureManager captureSession] startRunning];
}

- (void)scanButtonPressed {
  [[self captureManager] captureStillImage];
}

- (void)settingsButtonPressed {
    [settingsButton setHidden:YES];
    [overlayButton setHidden:YES];
    [settingsFrame setHidden:NO];
}

- (void)fluorescencePressed {
    [[self captureManager] setRed:0 setGreen:0 setBlue:0];
    [self backToMainPanel];
}

- (void)incandescencePressed {
    [[self captureManager] setRed:7 setGreen:0 setBlue:51];
    [self backToMainPanel];
}

- (void)customPressed {
    [[self captureManager] setSettings:YES];
    [[self captureManager] setCustomType:1];
    [self backToMainPanel];
}

- (void)customPressed2 {
    [[self captureManager] setSettings:YES];
    [[self captureManager] setCustomType:2];
    [self backToMainPanel];
}

- (void)customPressed3 {
    [[self captureManager] setSettings:YES];
    [[self captureManager] setCustomType:3];
    [self backToMainPanel];
}

- (void)customPressed4 {
    [[self captureManager] setSettings:YES];
    [[self captureManager] setCustomType:4];
    [self backToMainPanel];
}

- (void) backToMainPanel {
    [settingsButton setHidden:NO];
    [overlayButton setHidden:NO];
    [settingsFrame setHidden:YES];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)dealloc {
  [captureManager release], captureManager = nil;
  [super dealloc];
}

@end

