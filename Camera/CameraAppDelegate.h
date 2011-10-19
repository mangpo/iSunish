//
//  CameraAppDelegate.h
//  Camera
//
//  Created by Phitchaya Phothilimthana on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CameraViewController;

@interface CameraAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet CameraViewController *viewController;

@end
