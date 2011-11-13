#import "test_appViewController.h"
#import "FliteTTS.h"

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
    [fliteEngine speakText:@"dude the color is red."];	// Make it talk
    NSLog(@"finishe dtalking");

    NSData* pixelData = (NSData*) CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    unsigned char* pixelBytes = (unsigned char *)[pixelData bytes];
    CGImageRef imageRef = [image CGImage];
    
    width = CGImageGetWidth(imageRef);
    height = CGImageGetHeight(imageRef);
    CGImageRelease(imageRef);
    int bytesPerPixel = 4;
    bytesPerRow = bytesPerPixel * width;
    int index = height/2*bytesPerRow + width/2*bytesPerPixel;
    printf("RGB at pixel: %d %d %d",pixelBytes[index],pixelBytes[index+1],pixelBytes[index+2]);
    double hue = [self getHueFromRed:pixelBytes[index] green:pixelBytes[index+1] blue:pixelBytes[index+2]];
    printf("hue at pixel(%d,%d) = %.2lf\n",height/2,width/2,hue);
    
    double averageHue = [self getAverageHue:pixelBytes row:height/2 col:width/2];
    printf("average hue around pixel(%d,%d) = %.2lf\n",height/2,width/2,averageHue);
    
    NSLog([self getColorFromHue:averageHue]);
}

-(NSString*) getColorFromHue:(double) hue
{
    //hue = hue/3.14159265*180;
    NSString *s;
    s = @"red";
    if(hue < 15)
        s = @"red";
    else if(hue < 37.5)
        s = @"orange";
    else if(hue < 52.5)
        s = @"gold";
    else if(hue < 60)
        s = @"yellow";
    else if(hue < 67.5)
        s = @"apple greem";
    else if(hue < 75)
        s = @"lime green";
    else if(hue < 82.5)
        s = @"spring bud green";
    else if(hue < 97.5)
        s = @"pistachio green";
    else if(hue < 120)
        s = @"green";
    else if(hue < 135)
        s = @"emerald green";
    else if(hue < 142.5)
        s = @"sea green";
    else if(hue < 150)
        s = @"spring green";
    else if(hue < 157.5)
        s = @"aquamarine";
    else if(hue < 165)
        s = @"turquoise";
    else if(hue < 172.5)
        s = @"opal";
    else if(hue < 180)
        s = @"cyan";
    else if(hue < 195)
        s = @"arctic blue";
    else if(hue < 210)
        s = @"azure";
    else if(hue < 247.5)
        s = @"blue";
    else if(hue < 255)
        s = @"indigo";
    else if(hue < 262.5)
        s = @"blue violet";
    else if(hue < 270)
        s = @"violet";
    else if(hue < 285)
        s = @"purple";
    else if(hue < 300)
        s = @"magenta";
    else if(hue < 315)
        s = @"orchid pink";
    else if(hue < 322.5)
        s = @"rose pink";
    else if(hue < 337.5)
        s = @"rasberry";
    else if(hue < 345)
        s = @"crimson";
    else
        s = @"red";
    return s;
}

-(double) getHueFromRed:(unsigned char) red green:(unsigned char) green blue:(unsigned char) blue
{
    double r = red;
    double g = green;
    double b = blue;
    printf("after hue %f %f %f, cal %f %f %f\n",r,g,b,(2*r - g - b),sqrt(3) * (g - b),atan2(sqrt(3) * (g - b),(2*r - g - b)));
    double hue = atan2(sqrt(3) * (g - b),(2*r - g - b))/3.14159265*180;
    if(hue < 0)
        hue += 360;
    return hue;
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
    red /= count*255;
    green /= count*255;
    blue /= count*255;
    double hue = atan2(sqrt(3) * (green - blue),2*red - green - blue)/3.14159265*180;
    if(hue < 0)
        hue += 360;
    return hue;
}


- (id)init
{
  if ((self = [super init])) 
  {
    self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
		self.view.backgroundColor = [UIColor grayColor];

    // Button to activate camera
    button = [[UIButton alloc] initWithFrame:CGRectMake(80, 55, 162, 53)];    
    [button setBackgroundImage:[UIImage imageNamed:@"Camera.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents: UIControlEventTouchUpInside];      
    [self.view addSubview:button];
    [button release];
      
      
    //speech synthesis
      fliteEngine=[[FliteTTS alloc] init];
      [fliteEngine setPitch:180.0 variance:50.0 speed:1.2];	// Change the voice 
      [fliteEngine speakText:@"The color is Red"];
      NSLog(@"finishe dtalking");
      
  }
    NSLog([self getColorFromHue:6.2]);
  return self;  
}

- (void)dealloc 
{
  [super dealloc];
}

@end
