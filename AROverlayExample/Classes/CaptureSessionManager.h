#import <AVFoundation/AVFoundation.h>
#import "HSL.h"
#import "RGB.h"
#import "FliteTTS.h"

#define kImageCapturedSuccessfully @"imageCapturedSuccessfully"
#define RADIUS 30

@class FliteTTS;

FliteTTS *fliteEngine;

@interface CaptureSessionManager : NSObject {
    int height,width,bytesPerRow;
    //double refR, refG, refB;
    double whiteR, whiteG, whiteB;
    double blackR, blackG, blackB;
    double meanR, meanG, meanB, k;
    Boolean settings;
    int customType;
}

@property (retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (retain) AVCaptureSession *captureSession;
@property (retain) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, retain) UIImage *stillImage;
@property (nonatomic, readwrite) int height, width, bytesPerRow;
//@property (nonatomic, readwrite) double refR, refG, refB;
@property (nonatomic, readwrite) double whiteR, whiteG, whiteB;
@property (nonatomic, readwrite) double blackR, blackG, blackB;
@property (nonatomic, readwrite) double meanR, meanG, meanB, k;
@property (nonatomic, readwrite) Boolean settings;
@property (nonatomic, readwrite) int customType;

//-(void) getColor:(UIImage*) image;
-(RGB*) getAverageRGB:(unsigned char*)pixelBytes row:(int) row col:(int) col;
-(HSL*) convertToHSL:(RGB*) rgb;
-(double) upclamp:(double)num;
-(double) getHueFromRed:(unsigned char) red green:(unsigned char) green blue:(unsigned char) blue;
-(double) getAverageHue:(unsigned char*)pixelBytes row:(int) row col:(int) col;

-(void) fromR:(double) red fromG:(double) green fromB:(double) blue;
-(NSString*) getColorFromHue:(double) hue;
-(NSString*) getColorFromRGB:(RGB*) rgb;
-(NSString*) getColorFromHSL:(HSL*) hsl;
- (void)addVideoPreviewLayer;
- (void)addVideoInput;
- (void)addStillImageOutput;
- (void)captureStillImage;

-(void) setReference:(unsigned char*)pixelBytes;
-(RGB*) correctWithWhite:(RGB*) raw;
-(RGB*) correctWithWhiteBlack:(RGB*) raw;
-(RGB*) correctWithMean:(RGB*) raw;

@end
