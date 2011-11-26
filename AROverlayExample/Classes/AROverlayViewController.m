#import "AROverlayViewController.h"

@interface AROverlayViewController ()
@end

@implementation AROverlayViewController

@synthesize captureManager;

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
  UIButton *overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [overlayButton setImage:[UIImage imageNamed:@"takePicture.png"] forState:UIControlStateNormal];
  [overlayButton setAccessibilityLabel:NSLocalizedString(@"", @"")];
  [overlayButton setFrame:CGRectMake(bounds.origin.x,bounds.origin.y,bounds.size.width, bounds.size.height)];
  [overlayButton addTarget:self action:@selector(scanButtonPressed) forControlEvents:UIControlEventTouchUpInside];
  [[self view] addSubview:overlayButton];
  
	[[captureManager captureSession] startRunning];
}

- (void)scanButtonPressed {
  [[self captureManager] captureStillImage];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)dealloc {
  [captureManager release], captureManager = nil;
  [super dealloc];
}

@end

