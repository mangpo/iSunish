#import "CaptureSessionManager.h"
#import <ImageIO/ImageIO.h>
#import "FliteTTS.h"

@implementation CaptureSessionManager

@synthesize captureSession;
@synthesize previewLayer;
@synthesize stillImageOutput;
@synthesize stillImage;
@synthesize width, height, bytesPerRow;
//@synthesize refR, refG, refB;
@synthesize whiteR, whiteG, whiteB, blackR, blackG, blackB, meanR, meanG, meanB, k;
@synthesize settings, customType;

#pragma mark Capture Session Configuration

- (id)init {
	if ((self = [super init])) {
		[self setCaptureSession:[[AVCaptureSession alloc] init]];
        //speech synthesis
        settings = NO;
        [self setWhiteR:1];
        [self setWhiteG:1];
        [self setWhiteB:1];
        [self setBlackR:0];
        [self setBlackR:0];
        [self setBlackR:0];
        meanR = 1;
        meanG = 1;
        meanB = 1;
        k = 1;
	}
	return self;
}

- (void)addVideoPreviewLayer {
	[self setPreviewLayer:[[[AVCaptureVideoPreviewLayer alloc] initWithSession:[self captureSession]] autorelease]];
	[[self previewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
  
}

- (void)addVideoInput {
	AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];	
	if (videoDevice) {
		NSError *error;
		AVCaptureDeviceInput *videoIn = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
		if (!error) {
			if ([[self captureSession] canAddInput:videoIn])
				[[self captureSession] addInput:videoIn];
			else
				NSLog(@"Couldn't add video input");		
		}
		else
			NSLog(@"Couldn't create video input");
        /*if([videoDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeLocked]) {
            [videoDevice setWhiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
            NSLog(@"Lock White Balance");
        }*/
	}
	else
		NSLog(@"Couldn't create video capture device");
}

- (void)addStillImageOutput 
{
  [self setStillImageOutput:[[[AVCaptureStillImageOutput alloc] init] autorelease]];
  NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
  [[self stillImageOutput] setOutputSettings:outputSettings];
  
  AVCaptureConnection *videoConnection = nil;
  for (AVCaptureConnection *connection in [[self stillImageOutput] connections]) {
    for (AVCaptureInputPort *port in [connection inputPorts]) {
      if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
        videoConnection = connection;
        break;
      }
    }
    if (videoConnection) { 
      break; 
    }
  }
  
  [[self captureSession] addOutput:[self stillImageOutput]];
}

- (void)captureStillImage
{  
	AVCaptureConnection *videoConnection = nil;
	for (AVCaptureConnection *connection in [[self stillImageOutput] connections]) {
		for (AVCaptureInputPort *port in [connection inputPorts]) {
			if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
				videoConnection = connection;
				break;
			}
		}
		if (videoConnection) { 
      break; 
    }
	}
  
	NSLog(@"about to request a capture from: %@", [self stillImageOutput]);
	[[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:videoConnection 
                                                       completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) { 
                                                         CFDictionaryRef exifAttachments = CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
                                                         if (exifAttachments) {
                                                           NSLog(@"attachements: %@", exifAttachments);
                                                         } else { 
                                                           NSLog(@"no attachments");
                                                         }
                                                         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];    
                                                           UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                           NSData* pixelData = (NSData*) CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));

                                                           //CALCULATIONS HERE
                                                           unsigned char* pixelBytes = (unsigned char *)[pixelData bytes];
                                                           CGImageRef imageRef = [image CGImage];
                                                           width = CGImageGetWidth(imageRef);
                                                           height = CGImageGetHeight(imageRef);    int bytesPerPixel = 4;
                                                           bytesPerRow = bytesPerPixel * width;
                                                           int index = height/2*bytesPerRow + width/2*bytesPerPixel;                                                           printf("RGB at pixel: %d %d %d",pixelBytes[index],pixelBytes[index+1],pixelBytes[index+2]);
                                                           
                                                           if(settings) {
                                                               [self setReference:pixelBytes];
                                                               [fliteEngine speakText:@"Calibration complete."];
                                                           }
                                                           else {
                                                               RGB *rgb = [self getAverageRGB:pixelBytes row:height/2 col:width/2];
                                                               /*HSL *hsl = [self convertToHSL:rgb];
                                                               NSLog(@"non-corrected");
                                                               NSLog([self getColorFromRGB:rgb]);*/
                                                               //[fliteEngine speakText:[self getColorFromRGB:rgb]];
                                                               //[NSThread sleepForTimeInterval:1.5];
                                                               
                                                               RGB *rgb_white = [self correctWithWhite:rgb];
                                                               HSL *hsl_white = [self convertToHSL:rgb_white];
                                                               NSLog(@"corrected with white");
                                                               NSLog([self getColorFromHSL:hsl_white]);
                                                               [fliteEngine speakText:[self getColorFromRGB:rgb_white]];
                                                               //[NSThread sleepForTimeInterval:1.5];
                                                               
                                                               /*RGB *rgb_wb = [self correctWithWhiteBlack:rgb];
                                                               HSL *hsl_wb = [self convertToHSL:rgb_wb];
                                                               NSLog(@"corrected with white & black");
                                                               NSLog([self getColorFromHSL:hsl_wb]);
                                                               //[fliteEngine speakText:[self getColorFromRGB:rgb_wb]];
                                                               //[NSThread sleepForTimeInterval:1.5];
                                                               
                                                               RGB *rgb_mean = [self correctWithMean:rgb];
                                                               HSL *hsl_mean = [self convertToHSL:rgb_mean];
                                                               NSLog(@"corrected with white & black");
                                                               NSLog([self getColorFromHSL:hsl_mean]);
                                                              // [fliteEngine speakText:[self getColorFromRGB:rgb_mean]];*/
                                                           }
                                                           
                                                         [self setStillImage:image];
                                                         [image release];
                                                         [[NSNotificationCenter defaultCenter] postNotificationName:kImageCapturedSuccessfully object:nil];
                                                       }];
}

-(double) upclamp:(double)num
{
    num*=2;
    if(num>255)
        num=255;
    return num;
}

- (void)updateRGB:(double*)num str:(NSString**) str color:(NSString*) color cr:(double) cr cg:(double) cg cb:(double) cb r:(double) r g:(double) g b:(double) b leeway:(double) leeway
{
    double mag=fabs(cr-r)+fabs(cg-g)+fabs(cb-b);
    //double lightmag=fabs([self upclamp:cr]-r)+fabs([self upclamp:cg]-g)+fabs([self upclamp:cb]-b);
    //double darkmag=fabs(.5*cr-r)+fabs(.5*cg-g)+fabs(.5*cb-b);
    mag*=(1-leeway);
    //double avgprops=(fabs(r/g-cr/cg)+fabs(r/b-cr/cb)+fabs(b/g-cb/cg))/3.0;
    //printf("Average Proportions: %f",avgprops);
    //NSLog(color);
    //lightmag*=(1-leeway);
    //darkmag*=(1-leeway);
    if(mag< *num)
    {
        *num=mag;
        *str=color;
    }
/*    if(lightmag< *num && ![color isEqualToString:@"black"] && ![color isEqualToString:@"white"])
    {
        *num=mag;
        *str=[NSString stringWithFormat:@"%@ %@",@"light",color];
    }
    if(darkmag< *num && ![color isEqualToString:@"black"] && ![color isEqualToString:@"white"])
    {
        *num=mag;
        *str=[NSString stringWithFormat:@"%@ %@",@"dark",color];
    }*/
}

-(NSString*) getColorFromRGB:(RGB *)rgb
{
    double red= [rgb red];
    double green = [rgb green];
    double blue = [rgb blue];
    NSString * s=@"unknown"; 
    double num=1000000;
    printf("RGB: %f %f %f\n",red*255,green*255,blue*255);
    [self updateRGB:&num str:&s color:@"black" cr:red cg:green cb:blue r:.15 g:.15 b:.15 leeway:0];
    [self updateRGB:&num str:&s color:@"blue" cr:red cg:green cb:blue r:.2 g:.2 b:.8 leeway:0];
    [self updateRGB:&num str:&s color:@"light blue" cr:red cg:green cb:blue r:.5 g:.7 b:.9 leeway:0];
    [self updateRGB:&num str:&s color:@"dark blue" cr:red cg:green cb:blue r:.05 g:.05 b:.4 leeway:0];
    [self updateRGB:&num str:&s color:@"red" cr:red cg:green cb:blue r:.8 g:.2 b:.2 leeway:0];
    [self updateRGB:&num str:&s color:@"hot pink" cr:red cg:green cb:blue r:.8 g:.2 b:.4 leeway:0];
    [self updateRGB:&num str:&s color:@"pink" cr:red cg:green cb:blue r:.9 g:.4 b:.9 leeway:0];  
    [self updateRGB:&num str:&s color:@"light pink" cr:red cg:green cb:blue r:.95 g:.7 b:.95 leeway:0];  
    [self updateRGB:&num str:&s color:@"maroon" cr:red cg:green cb:blue r:.5 g:.05 b:.05 leeway:0];
    [self updateRGB:&num str:&s color:@"green" cr:red cg:green cb:blue r:.2 g:.8 b:.2 leeway:0];
    [self updateRGB:&num str:&s color:@"light green" cr:red cg:green cb:blue r:.5 g:.9 b:.5 leeway:0];
    [self updateRGB:&num str:&s color:@"dark green" cr:red cg:green cb:blue r:.15 g:.25 b:.15 leeway:0];
    [self updateRGB:&num str:&s color:@"greyish green" cr:red cg:green cb:blue r:.3 g:.5 b:.3 leeway:0];
    //[self updateRGB:&num str:&s color:@"cyan" cr:red cg:green cb:blue r:0 g:.9 b:.9 leeway:0];
    //[self updateRGB:&num str:&s color:@"fuchsia" cr:red cg:green cb:blue r:.7 g:0 b:.7 leeway:0];
    //[self updateRGB:&num str:&s color:@"gold" cr:red cg:green cb:blue r:1 g:.84 b:0 leeway:0];
    [self updateRGB:&num str:&s color:@"grey" cr:red cg:green cb:blue r:.5 g:.5 b:.5 leeway:0];
    [self updateRGB:&num str:&s color:@"dark grey" cr:red cg:green cb:blue r:.3 g:.3 b:.3 leeway:0];
    //[self updateRGB:&num str:&s color:@"lime" cr:red cg:green cb:blue r:0 g:1 b:0 leeway:0];
    //[self updateRGB:&num str:&s color:@"maroon" cr:red cg:green cb:blue r:.5 g:0 b:0 leeway:0];
    [self updateRGB:&num str:&s color:@"purple" cr:red cg:green cb:blue r:.5 g:.2 b:.5 leeway:0];
    [self updateRGB:&num str:&s color:@"dark purple" cr:red cg:green cb:blue r:.3 g:.1 b:.3 leeway:0];
    //[self updateRGB:&num str:&s color:@"silver" cr:red cg:green cb:blue r:.75 g:.75 b:.75 leeway:0];
    //[self updateRGB:&num str:&s color:@"teal" cr:red cg:green cb:blue r:0 g:.5 b:.5 leeway:0];
    //[self updateRGB:&num str:&s color:@"turqoise" cr:red cg:green cb:blue r:.19 g:.84 b:.78 leeway:0];
    [self updateRGB:&num str:&s color:@"white" cr:red cg:green cb:blue r:.85 g:.85 b:.85 leeway:0];
    [self updateRGB:&num str:&s color:@"yellow" cr:red cg:green cb:blue r:.9 g:.9 b:.1 leeway:0];
    [self updateRGB:&num str:&s color:@"light yellow" cr:red cg:green cb:blue r:.95 g:.95 b:.6 leeway:0];
    [self updateRGB:&num str:&s color:@"orange" cr:red cg:green cb:blue r:.8 g:.4 b:.1 leeway:0];
    [self updateRGB:&num str:&s color:@"brown" cr:red cg:green cb:blue r:.4 g:.2 b:.1 leeway:0];
    [self updateRGB:&num str:&s color:@"dark brown" cr:red cg:green cb:blue r:.3 g:.2 b:.1 leeway:0];
    [self updateRGB:&num str:&s color:@"tan" cr:red cg:green cb:blue r:.9 g:.7 b:.5 leeway:0];
    //[self updateRGB:&num str:&s color:@"pink" cr:red cg:green cb:blue r:1 g:.75 b:.80 leeway:0];
    
    return s;
}

-(NSString*) getColorFromHSL:(HSL *)hsl
{
    double light= [hsl light];
    double sat = [hsl saturation];
    double hue = [hsl hue];
    NSString * s;
    if(light < 1){
        s = @"black";
    }
    else if(light < 5){
        if(sat < 50){
            s = @"black";
        }
        else{
            s = @"dark ";
            s = [s stringByAppendingString:[self getColorFromHue:hue]];
        }
    }
    else if(light < 40){
        if(sat < 15){
            s = @"black";
        }
        else if(sat < 35){
            s = @"dark ";
            s = [s stringByAppendingString:[self getColorFromHue:hue]];
        }
        else{
            s = [self getColorFromHue:hue];
        }
    }
    else if(light < 75){
        if(sat < 2.5){
            s = @"dark grey";
        }
        else if(sat < 10){
            s = @"grey";
        }
        else if(sat < 20){
            s = @"greyish ";
            s = [s stringByAppendingString:[self getColorFromHue:hue]];
        }
        else{
            s = [self getColorFromHue:hue];
        }    
    }
    else if(light < 80){
        if(sat < 10){
            s = @"grey";
        }
        else if(sat < 30){
            s = @"light ";
            s = [s stringByAppendingString:[self getColorFromHue:hue]];
        }
        else{
            s = [self getColorFromHue:hue];
        } 
    }
    else if(light < 90){
        if(sat < 15){
            s = @"light grey";
        }
        else if(sat < 50){
            s = @"light ";
            s = [s stringByAppendingString:[self getColorFromHue:hue]];
        }
        else{
            s = [self getColorFromHue:hue];
        } 
    }
    else if(light < 95){
        if(sat < 50){
            s = @"white";
        }
        else{
            s = @"light ";
            s = [s stringByAppendingString:[self getColorFromHue:hue]];
        }
    }
    else{
        s = @"white";
    }
    
    // Red or Brown
    if(hue < 15 || hue > 345){
        if(light < 15){
            if(sat < 10){
                s = @"black";
            }
            else if(sat < 50){
                s = @"brown";
            }
            else{
                s = @"red";
            } 
        }
        else if(light < 30){
            if(sat < 10){
                s = @"grey";
            }
            else if(sat < 20){
                s = @"greyish brown";
            }
            else if(sat < 50){
                s = @"brown";
            }
            else{
                s = @"red";
            } 
        }
    }
    return s;
}

-(NSString*) getColorFromHue:(double) hue
{
    //hue = hue/3.14159265*180;
    NSString *s;
    if(hue < 15)
        s = @"red";
    else if(hue < 37.5)
        s = @"orange";
    else if(hue < 44)
        s = @"gold";
    else if(hue < 52.5)
        s = @"tan";
    else if(hue < 65)
        s = @"yellow";
    else if(hue < 70)
        s = @"apple greem";
    else if(hue < 75)
        s = @"lime green";
    else if(hue < 157.5)
        s = @"green";
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
    else if(hue < 335)
        s = @"pink";
    else if(hue < 342.5)
        s = @"rose pink";
    else if(hue < 350)
        s = @"rasberry";
    else if(hue < 352.5)
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
    double hue = atan2(sqrt(3) * (g - b),(2*r - g - b))/3.14159265*180;
    if(hue < 0)
        hue += 360;
    return hue;
}

-(double) getAverageHue:(unsigned char*)pixelBytes row:(int) row col:(int) col
{
    // 9-points average
    int row_min = (row - RADIUS >= 0)? row-RADIUS:0;
    int row_max = (row + RADIUS < height)? row+RADIUS: height-1;
    int col_min = (col - RADIUS >= 0)? col-RADIUS:0;
    int col_max = (col + RADIUS < width)? col+RADIUS: width-1;
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
    printf("H = %.2f\n",hue);
    return hue;
}

-(void) fromR:(double) red fromG:(double) green fromB:(double) blue
{
    red /= 255;
    green /= 255;
    blue /= 255;
    
    double hue = atan2(sqrt(3) * (green - blue),2*red - green - blue)/3.14159265*180;
    if(hue < 0)
        hue += 360;
    
    double M = MAX(MAX(red,green),blue);
    double m = MIN(MIN(red,green),blue);
    double light = (M + m)/2;
    
    double C = M - m;
    double sat = (C == 0)? 0: C/(1 - ABS(2*light - 1)); 
    
    light *= 100;
    sat *= 100;
    printf("H = %.2f S = %.2f L = %.2f\n",hue,sat,light);
    
    HSL *hsl = [[HSL alloc] init];
    [hsl setHue:hue];
    [hsl setLight:light];
    [hsl setSaturation:sat];
    NSLog([self getColorFromHSL:hsl]);
}

-(HSL*) getAverageHSL:(unsigned char*)pixelBytes row:(int) row col:(int) col
{
    HSL *hsl = [[HSL alloc] init];
    int row_min = (row - RADIUS >= 0)? row-RADIUS:0;
    int row_max = (row + RADIUS < height)? row+RADIUS: height-1;
    int col_min = (col - RADIUS >= 0)? col-RADIUS:0;
    int col_max = (col + RADIUS < width)? col+RADIUS: width-1;
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
    
    red = red/(count*255);
    green = green/(count*255);
    blue = blue/(count*255);
    
    double hue = atan2(sqrt(3) * (green - blue),2*red - green - blue)/3.14159265*180;
    if(hue < 0)
        hue += 360;
    
    double M = MAX(MAX(red,green),blue);
    double m = MIN(MIN(red,green),blue);
    double light = (M + m)/2;
    
    double C = M - m;
    double sat = (C == 0)? 0: C/(1 - ABS(2*light - 1)); 
    
    light *= 100;
    sat *= 100;
    
    [hsl setHue:hue];
    [hsl setLight:light];
    [hsl setSaturation:sat];
    
    printf("averaging over [%d,%d] [%d,%d]\n",row_min,row_max,col_min,col_max);
    printf("H = %.2f S = %.2f L = %.2f\n",hue,sat,light);
    
    return hsl;
}

-(RGB*) getAverageRGB:(unsigned char*)pixelBytes row:(int) row col:(int) col
{
    RGB *rgb = [[RGB alloc] init];
    int row_min = (row - RADIUS >= 0)? row-RADIUS:0;
    int row_max = (row + RADIUS < height)? row+RADIUS: height-1;
    int col_min = (col - RADIUS >= 0)? col-RADIUS:0;
    int col_max = (col + RADIUS < width)? col+RADIUS: width-1;
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
    
    red = red/(count*255);
    green = green/(count*255);
    blue = blue/(count*255);
    
    [rgb setRed:red];
    [rgb setGreen:green];
    [rgb setBlue:blue];
    return rgb;
}

-(HSL*) convertToHSL:(RGB*) rgb {
    printf("R = %.2f G = %.2f B = %.2f\n",rgb.red,rgb.green,rgb.blue);
    HSL *hsl = [[HSL alloc] init];
    double red = rgb.red;
    double green = rgb.green;
    double blue = rgb.blue;
    double hue = atan2(sqrt(3) * (green - blue),2*red - green - blue)/3.14159265*180;
    if(hue < 0)
        hue += 360;
    
    double M = MAX(MAX(red,green),blue);
    double m = MIN(MIN(red,green),blue);
    double light = (M + m)/2;
    
    double C = M - m;
    double sat = (C == 0)? 0: C/(1 - ABS(2*light - 1)); 
    
    light *= 100;
    sat *= 100;
    
    [hsl setHue:hue];
    [hsl setLight:light];
    [hsl setSaturation:sat];
    
    printf("H = %.2f S = %.2f L = %.2f\n",hue,sat,light);
    
    return hsl;
}

-(void) setReference:(unsigned char*)pixelBytes
{
    int bytesPerPixel = 4;
    double red_max = 0, green_max = 0, blue_max = 0;
    double red_min = 255, green_min = 255, blue_min = 255;
    double red_mean = 0, green_mean = 0, blue_mean = 0;
    
    for(int i = 0; i < height; i++)
        for(int j = 0; j < width; j++) {
            int index = i*bytesPerRow + j*bytesPerPixel;
            if(pixelBytes[index] > red_max) {
                red_max = pixelBytes[index];
            }
            if(pixelBytes[index+1] > green_max) {
                green_max = pixelBytes[index+1];
            }
            if(pixelBytes[index+2] > blue_max) {
                blue_max = pixelBytes[index+2];
            }
            if(pixelBytes[index] < red_min) {
                red_min = pixelBytes[index];
            }
            if(pixelBytes[index+1] < green_min) {
                green_min = pixelBytes[index+1];
            }
            if(pixelBytes[index+2] < blue_min) {
                blue_min = pixelBytes[index+2];
            }
            red_mean += pixelBytes[index];
            green_mean += pixelBytes[index+1];
            blue_mean += pixelBytes[index+1];
        }

    whiteR = red_max/255;
    whiteG = green_max/255;
    whiteB = blue_max/255;
    blackR = red_min/255;
    blackG = green_min/255;
    blackB = blue_min/255;
    meanR = red_mean/(height*width*255);
    meanG = green_mean/(height*width*255);
    meanB = blue_mean/(height*width*255);
    k = MIN(MIN(meanR/whiteR, meanG/whiteG), meanB/whiteB);
    settings = NO;
}

-(RGB*) correctWithWhite:(RGB*) raw {
    RGB *correct = [[RGB alloc] init];
    correct.red = raw.red/whiteR;
    correct.green = raw.green/whiteG;
    correct.blue = raw.blue/whiteB;
    printf("raw R = %.2f G = %.2f B = %.2f\n",raw.red,raw.green,raw.blue);
    printf("white R = %.2f G = %.2f B = %.2f\n",whiteR,whiteG,whiteB);
    printf("correct R = %.2f G = %.2f B = %.2f\n",correct.red,correct.green,correct.blue);
    return correct;
}

-(RGB*) correctWithWhiteBlack:(RGB*) raw {
    RGB *correct = [[RGB alloc] init];
    correct.red = (raw.red - blackR)/(whiteR - blackR);
    correct.green = (raw.green - blackG)/(whiteG - blackG);
    correct.blue = (raw.blue - blackB)/(whiteB - blackB);
    if(correct.red < 0)
        correct.red = 0;
    if(correct.green < 0)
        correct.green = 0;
    if(correct.blue < 0)
        correct.blue = 0;
    printf("raw R = %.2f G = %.2f B = %.2f\n",raw.red,raw.green,raw.blue);
    printf("white R = %.2f G = %.2f B = %.2f\n",whiteR,whiteG,whiteB);
    printf("black R = %.2f G = %.2f B = %.2f\n",blackR,blackG,blackB);
    printf("correct R = %.2f G = %.2f B = %.2f\n",correct.red,correct.green,correct.blue);
    return correct;
}

-(RGB*) correctWithMean:(RGB*) raw {
    RGB *correct = [[RGB alloc] init];
    correct.red = k*raw.red/meanR;
    correct.green = k*raw.green/meanG;
    correct.blue = k*raw.blue/meanB;
    return correct;
}

- (void)dealloc {

	[[self captureSession] stopRunning];

	[previewLayer release], previewLayer = nil;
	[captureSession release], captureSession = nil;
    [stillImageOutput release], stillImageOutput = nil;
    [stillImage release], stillImage = nil;

	[super dealloc];
}

@end
