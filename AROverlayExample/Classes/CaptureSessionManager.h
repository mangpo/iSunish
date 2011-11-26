#import <AVFoundation/AVFoundation.h>
#import "HSL.h"

#define kImageCapturedSuccessfully @"imageCapturedSuccessfully"
#define RADIUS 30

@class FliteTTS;

FliteTTS *fliteEngine;

@interface CaptureSessionManager : NSObject {
    int height,width,bytesPerRow;
    double refR, refG, refB;
}

@property (retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (retain) AVCaptureSession *captureSession;
@property (retain) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, retain) UIImage *stillImage;
@property (nonatomic, readwrite) int height, width, bytesPerRow;
@property (nonatomic, readwrite) double refR, refG, refB;

//-(void) getColor:(UIImage*) image;
-(double) getHueFromRed:(unsigned char) red green:(unsigned char) green blue:(unsigned char) blue;
-(double) getAverageHue:(unsigned char*)pixelBytes row:(int) row col:(int) col;
-(void) fromR:(double) red fromG:(double) green fromB:(double) blue;
-(NSString*) getColorFromHue:(double) hue;
-(NSString*) getColorFromHSL:(HSL*) hsl;
- (void)addVideoPreviewLayer;
- (void)addVideoInput;
- (void)addStillImageOutput;
- (void)captureStillImage;

@end
