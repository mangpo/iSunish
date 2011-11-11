//
//  test_appViewController.m
//  test-app
//
//  Copyright iPhoneDevTips.com All rights reserved.
//


#import "test_appViewController.h"

@implementation test_appViewController
@synthesize width, height, bytesPerRow;


- (void)buttonPressed:(UIButton *)button
{
	// Create image picker controller
  UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
  
  // Set source to the camera
	imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
  
  // Delegate is self
	imagePicker.delegate = self;
  
  // Show image picker
	[self presentModalViewController:imagePicker animated:YES];	

}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// After saving iamge, dismiss camera
	[self dismissModalViewControllerAnimated:YES];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
  UIAlertView *alert;

	// Unable to save the image  
  if (error)
  	alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                            message:@"Unable to save image to Photo Album." 
                            delegate:self cancelButtonTitle:@"Ok" 
                            otherButtonTitles:nil];
	else // All is well
  	alert = [[UIAlertView alloc] initWithTitle:@"Success" 
                            message:@"Image saved to Photo Album." 
                            delegate:self cancelButtonTitle:@"Ok" 
                            otherButtonTitles:nil];

  [alert show];
  [alert release];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"HARRO");
	// Access the uncropped image from info dictionary
	UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];

	// Save image
  UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    [self getColor:image];
	[picker release];
}

-(void)getColor:(UIImage*)image
{
    NSData* pixelData = (NSData*) CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    unsigned char* pixelBytes = (unsigned char *)[pixelData bytes];
    CGImageRef imageRef = [image CGImage];
    
    width = CGImageGetWidth(imageRef);
    height = CGImageGetHeight(imageRef);
    int bytesPerPixel = 4;
    bytesPerRow = bytesPerPixel * width;
    int index = height/2*bytesPerRow + width/2*bytesPerPixel;
    double hue = [self getHueFromRed:pixelBytes[index] green:pixelBytes[index+1] blue:pixelBytes[index+2]];
    printf("hue at pixel(%d,%d) = %.2lf\n",height/2,width/2,hue);
    
    double averageHue = [self getAverageHue:pixelBytes row:height/2 col:width/2];
    printf("average hue around pixel(%d,%d) = %.2lf\n",height/2,width/2,averageHue);
    
    // Take away the red pixel, assuming 32-bit RGBA
    /*for(int i = 0; i < [pixelData length]; i += 4) {
     pixelBytes[i] = pixelBytes[i]; // red
     pixelBytes[i+1] = pixelBytes[i+1]; // green
     pixelBytes[i+2] = pixelBytes[i+2]; // blue
     pixelBytes[i+3] = pixelBytes[i+3]; // alpha
     printf("%c ",pixelBytes[i]); 
     }*/
}

-(double) getHueFromRed:(unsigned char) red green:(unsigned char) green blue:(unsigned char) blue
{
    double r = (float) red;
    double g = (float) green;
    double b = (float) blue;
    return atan2((2*r - g - b)/2, sqrt(3)/2 * (g - b));
}

-(double) getAverageHue:(unsigned char*)pixelBytes row:(int) row col:(int) col
{
    // 9-points average
    int row_min = (row > 0)? row-1:0;
    int row_max = (row + 1 < height)? row+1:height-1;
    int col_min = (col > 0)? col-1:0;
    int col_max = (col + 1 < width)? col+1:width-1;
    int bytesPerPixel = 4;
    double red = 0, green = 0, blue = 0;
    int count = 0;
    
    for(int i = row_min; i <= row_max; i++)
        for(int j = col_min; j <= col_max; j++) {
            int index = i*bytesPerRow + j*bytesPerPixel;
            red += pixelBytes[index];
            green += pixelBytes[index+1];
            blue += pixelBytes[index+2];
            count++;
        }
    red /= count;
    green /= count;
    blue /= count;
    return atan2((2*red - green - blue)/2, sqrt(3)/2 * (green - blue));
}


- (id)init
{
  if (self = [super init]) 
  {
    self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
		self.view.backgroundColor = [UIColor grayColor];

    // Button to activate camera
    button = [[UIButton alloc] initWithFrame:CGRectMake(80, 55, 162, 53)];    
    [button setBackgroundImage:[UIImage imageNamed:@"Camera.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents: UIControlEventTouchUpInside];      
    [self.view addSubview:button];
    [button release];
  }
  
  return self;  
}

- (void)dealloc 
{
  [super dealloc];
}

@end
