#import <UIKit/UIKit.h>
#import "CaptureSessionManager.h"

@interface AROverlayViewController : UIViewController {
    UIButton *settingsButton;
    UIButton *overlayButton;
    UIView *settingsFrame;
}

@property (retain) CaptureSessionManager *captureManager;
@property (retain) UIButton *settingsButton;
@property (retain) UIButton *overlayButton;
@property (retain) UIView *settingsFrame;

@end
