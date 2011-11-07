//
//  CameraViewController.h
//  Camera
//
//  Created by Phitchaya Phothilimthana on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraViewController : UIViewController {
    UIImageView * theimageView;
    UIButton * choosePhoto;
    UIButton * takePhoto;
    int height,width,bytesPerRow;
}

@property (nonatomic, retain) IBOutlet UIImageView * theimageView;
@property (nonatomic, retain) IBOutlet UIButton * takePhoto;
@property (nonatomic, retain) IBOutlet UIButton * choosePhoto;
@property (nonatomic, readwrite) int height, width, bytesPerRow;

-(IBAction) getPhoto:(id) sender;
-(void) getColor:(UIImage*) image;
-(double) getHueFromRed:(unsigned char) red green:(unsigned char) green blue:(unsigned char) blue;
-(double) getAverageHue:(unsigned char*)pixelBytes row:(int) row col:(int) col;

@end
