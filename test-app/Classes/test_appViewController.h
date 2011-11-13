//
//  test_appViewController.h
//  test-app
//
//  Copyright iPhoneDevTips.com All rights reserved.
//

#import <UIKit/UIKit.h>

@class FliteTTS;

FliteTTS *fliteEngine;

@interface test_appViewController : UIViewController  <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
	UIButton *button;
    int height,width,bytesPerRow;

}

@property (nonatomic, readwrite) int height, width, bytesPerRow;

-(void) getColor:(UIImage*) image;
-(double) getHueFromRed:(unsigned char) red green:(unsigned char) green blue:(unsigned char) blue;
-(double) getAverageHue:(unsigned char*)pixelBytes row:(int) row col:(int) col;
-(NSString*) getColorFromHue:(double) hue;

@end

