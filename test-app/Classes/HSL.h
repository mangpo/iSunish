//
//  HSL.h
//  test-app
//
//  Created by Phitchaya Phothilimthana on 11/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HSL : NSObject {
    double hue,saturation,light;
}

@property (nonatomic, readwrite) double hue,saturation,light;
@end
