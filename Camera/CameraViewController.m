//
//  CameraViewController.m
//  Camera
//
//  Created by Phitchaya Phothilimthana on 10/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CameraViewController.h"

@implementation CameraViewController
@synthesize theimageView, choosePhoto, takePhoto, width, height, bytesPerRow;

-(IBAction) getPhoto:(id)sender {
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    
    if((UIButton *) sender == choosePhoto) {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        NSLog(@"Wassap fool!");
        [self presentModalViewController:picker animated:YES];
    } else {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentModalViewController:picker animated:YES];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissModalViewControllerAnimated:YES];
    theimageView = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    [self getColor:image];
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

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
