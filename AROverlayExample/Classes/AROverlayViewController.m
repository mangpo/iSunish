#import "AROverlayViewController.h"

@interface AROverlayViewController ()
@end

@implementation AROverlayViewController

@synthesize captureManager, settingsButton, settingsFrame, overlayButton;

- (void)viewDidLoad {
  
	[self setCaptureManager:[[[CaptureSessionManager alloc] init] autorelease]];
  
	[[self captureManager] addVideoInput];
  
  [[self captureManager] addStillImageOutput];
    fliteEngine=[[FliteTTS alloc] init];
    [fliteEngine setPitch:120.0 variance:50.0 speed:1.2];	// Change the voice 

	[[self captureManager] addVideoPreviewLayer];
	CGRect layerRect = [[[self view] layer] bounds];
	[[[self captureManager] previewLayer] setBounds:layerRect];
	[[[self captureManager] previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),
                                                                CGRectGetMidY(layerRect))];
	[[[self view] layer] addSublayer:[[self captureManager] previewLayer]];
  
  UIImageView *overlayImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlaygraphic.png"]];
  [overlayImageView setFrame:CGRectMake(80, 170, 160, 130)];
  [[self view] addSubview:overlayImageView];
  [overlayImageView release];
  CGRect bounds=[[UIScreen mainScreen] bounds];
  overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [overlayButton setImage:[UIImage imageNamed:@"takePicture.png"] forState:UIControlStateNormal];
  [overlayButton setAccessibilityLabel:NSLocalizedString(@"", @"")];
  [overlayButton setFrame:CGRectMake(bounds.origin.x,bounds.origin.y,bounds.size.width, bounds.size.height)];
  [overlayButton addTarget:self action:@selector(scanButtonPressed) forControlEvents:UIControlEventTouchUpInside];
  [[self view] addSubview:overlayButton];
    
    settingsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [settingsButton setAccessibilityLabel:NSLocalizedString(@"White Balance", @"")];
    [settingsButton setFrame:CGRectMake(bounds.origin.x,bounds.origin.y+430,bounds.size.width, 50)];
    UILabel *settingsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
    [settingsLabel setBackgroundColor:[UIColor clearColor]];
    [settingsLabel setCenter:CGPointMake((bounds.size.width-20)/2, 25)];
    [settingsLabel setText:@"White Balance"];
    settingsLabel.textAlignment = UITextAlignmentCenter;
    [settingsButton addSubview:settingsLabel];
    [settingsButton addTarget:self action:@selector(settingsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:settingsButton];
    
    settingsFrame = [[UIView alloc] initWithFrame:CGRectMake(bounds.origin.x,bounds.origin.y,bounds.size.width, bounds.size.height)];
    [settingsFrame setBackgroundColor:[UIColor grayColor]];
    
    int w = 320, h = 60;
    UIButton *fluorescence = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [fluorescence setAccessibilityLabel:NSLocalizedString(@"Fluorescent Lighting", @"")];
    UIButton *incandescence = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [incandescence setAccessibilityLabel:NSLocalizedString(@"Incandescent Lighting", @"")];
    UIButton *custom = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [custom setAccessibilityLabel:NSLocalizedString(@"Custom Lighting", @"")];
    UIButton *back=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [back setAccessibilityLabel:NSLocalizedString(@"Back", @"")];
    
    [fluorescence setFrame:CGRectMake(0,0,w, h)];
    [incandescence setFrame:CGRectMake(0,0,w, h)];
    [custom setFrame:CGRectMake(0,0,w, h)];
    [back setFrame:CGRectMake(0,0,w, h)];
    [fluorescence setCenter:CGPointMake(bounds.size.width/2, 80)];
    [incandescence setCenter:CGPointMake(bounds.size.width/2, 180)];
    [custom setCenter:CGPointMake(bounds.size.width/2, 280)];
    [back setCenter:CGPointMake(bounds.size.width/2, 450)];
    
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
    
    UILabel *backLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    [backLable setBackgroundColor:[UIColor clearColor]];
    [backLable setCenter:CGPointMake(w/2, h/2)];
    [backLable setText:@"Back"];
    backLable.textAlignment = UITextAlignmentCenter;
    [back addSubview:backLable];
    
    [fluorescence addTarget:self action:@selector(fluorescencePressed) forControlEvents:UIControlEventTouchUpInside];
    [incandescence addTarget:self action:@selector(incandescencePressed) forControlEvents:UIControlEventTouchUpInside];
    [custom addTarget:self action:@selector(customPressed) forControlEvents:UIControlEventTouchUpInside];
    [back addTarget:self action:@selector(backPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [settingsFrame addSubview:fluorescence];
    [settingsFrame addSubview:incandescence];
    [settingsFrame addSubview:custom];
    [settingsFrame addSubview:back];
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
    [[self captureManager] setWhiteR:1];
    [[self captureManager] setWhiteG:1];
    [[self captureManager] setWhiteB:1];
    [[self captureManager] setBlackR:0];
    [[self captureManager] setBlackR:0];
    [[self captureManager] setBlackR:0];
    [self backToMainPanel];
}

- (void)incandescencePressed {
    [[self captureManager] setWhiteR:0.97];
    [[self captureManager] setWhiteG:1];
    [[self captureManager] setWhiteB:0.8];
    [[self captureManager] setBlackR:0];
    [[self captureManager] setBlackR:0];
    [[self captureManager] setBlackR:0];
    [self backToMainPanel];
}

- (void)customPressed {
    [[self captureManager] setSettings:YES];
    [[self captureManager] setCustomType:1];
    [fliteEngine setPitch:120.0 variance:50.0 speed:1.2];	// Change the voice 
    [fliteEngine speakText:@"Calibration. Take a picture of a white object."];
    [self backToMainPanel];
}

- (void)backPressed {
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

