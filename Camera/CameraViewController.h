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
}

@property (nonatomic, retain) IBOutlet UIImageView * theimageView;
@property (nonatomic, retain) IBOutlet UIButton * takePhoto;
@property (nonatomic, retain) IBOutlet UIButton * choosePhoto;

-(IBAction) getPhoto:(id) sender;

@end
