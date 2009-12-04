//
//  OCRDisplayViewController.m
//  OCR
//
//  Created by Robert Carlsen on 03.12.2009.
//  Copyright 2009 recv'd productions. All rights reserved.
//

#import "OCRDisplayViewController.h"
#import "baseapi.h"

@implementation OCRDisplayViewController

@synthesize outputString,outputView,cameraButton, actionButton, thumbImageView, statusLabel;

- (void)dealloc {
    tess->End(); // shutdown tesseract
    [imageForOCR release];
    [outputView release];
    [thumbImageView release];
    [statusLabel release];
    
    [super dealloc];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.center = self.view.center;
    activityView.hidesWhenStopped = YES;
    [self.view addSubview:activityView];
    
    // imageForOCR = [UIImage imageNamed:@"moretext.png"];
    //    UIImageView *dummyView = [[UIImageView alloc] initWithImage:input];
    //    
    //    // Override point for customization after application launch
    //    [window addSubview:dummyView];
    //    [dummyView release];
    
    
    NSString *dataPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"tessdata"];
    /*
     Set up the data in the docs dir
     want to copy the data to the documents folder if it doesn't already exist
     */
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // If the expected store doesn't exist, copy the default store.
    if (![fileManager fileExistsAtPath:dataPath]) {
        // get the path to the app bundle (with the tessdata dir)
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        NSString *tessdataPath = [bundlePath stringByAppendingPathComponent:@"tessdata"];
        if (tessdataPath) {
            [fileManager copyItemAtPath:tessdataPath toPath:dataPath error:NULL];
        }
    }
    
    NSString *dataPathWithSlash = [[self applicationDocumentsDirectory] stringByAppendingString:@"/"];
    setenv("TESSDATA_PREFIX", [dataPathWithSlash UTF8String], 1);
    
    // can't find the variable name for this.
    // init the tesseract engine.
    tess = new TessBaseAPI();

    //int result = tess->Init([tessdataPath cStringUsingEncoding:NSUTF8StringEncoding], "eng");
    
    tess->SimpleInit([dataPath cStringUsingEncoding:NSUTF8StringEncoding],  // Path to tessdata-no ending /.
                     "eng",  // ISO 639-3 string or NULL.
                     false);
    
    //NSLog(@"tess init result: %d", result);
    
    //[activityView startAnimating];
    
    // need to make this *heavy* process threaded:
    //NSString *output = [self readAndProcessImage:imageForOCR];
    //NSLog(@"%@",output);
    
    // process image, threaded:
    //[NSThread detachNewThreadSelector:@selector(threadedReadAndProcessImage:) toTarget:self withObject:imageForOCR];  
    
    NSString *output = [NSString stringWithString:@"Select an image to process."];
    [outputView setText:output];

}





-(void)updateTextDisplay;
{
    [activityView stopAnimating];
    
    [statusLabel setText:[NSString stringWithString:@"iPhone tesseract-ocr"]];
    [outputView setText:outputString]; 
}

// non-threaded...don't use.
- (NSString *)readAndProcessImage:(UIImage *)uiImage {
    CGSize imageSize = [uiImage size];
    double bytes_per_line	= CGImageGetBytesPerRow([uiImage CGImage]);
    double bytes_per_pixel	= CGImageGetBitsPerPixel([uiImage CGImage]) / 8.0;
    
    CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider([uiImage CGImage]));
    const UInt8 *imageData = CFDataGetBytePtr(data);
    
    // this could take a while. maybe needs to happen asynchronously?
    char* text = tess->TesseractRect(imageData,
                                     bytes_per_pixel,
                                     bytes_per_line,
                                     0, 0,
                                     imageSize.width, imageSize.height);
    
    return [NSString stringWithUTF8String:text];
}

// preferred, threaded method:
- (void)threadedReadAndProcessImage:(UIImage *)uiImage {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    CGSize imageSize = [uiImage size];
    double bytes_per_line	= CGImageGetBytesPerRow([uiImage CGImage]);
    double bytes_per_pixel	= CGImageGetBitsPerPixel([uiImage CGImage]) / 8.0;
    
    CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider([uiImage CGImage]));
    const UInt8 *imageData = CFDataGetBytePtr(data);
    
    // this could take a while. maybe needs to happen asynchronously?
    char* text = tess->TesseractRect(imageData,
                                     bytes_per_pixel,
                                     bytes_per_line,
                                     0, 0,
                                     imageSize.width, imageSize.height);
    
    [self setOutputString:[NSString stringWithCString:text encoding:NSUTF8StringEncoding]];
    
    delete[] text;
    
    // update the text:
    [self performSelectorOnMainThread:@selector(updateTextDisplay) withObject:nil waitUntilDone:NO];
    
    [pool release];
}

//- (UIImage*)imageWithImage:(UIImage*)image 
//              scaledToSize:(CGSize)newSize;
//{
//    // calculate aspect ratio:
//    float ratio = image.size.height / image.size.width;
//    float aspectHeight = newSize.width * ratio;
//    CGSize ratioSize = CGSizeMake(newSize.width, aspectHeight);
//    
//    UIGraphicsBeginImageContext( ratioSize );
//    [image drawInRect:CGRectMake(0,0,ratioSize.width,ratioSize.height)];
//    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return newImage;
//}

#pragma mark -
#pragma mark Application's documents directory
/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


#pragma mark Image Selection methods
- (IBAction) selectImage: (id) sender{
	//NSLog(@"Button pressed: %d",[sender tag]);
    
    // present an alert sheet if a camera is visible and allow the user to select
    // the camera or photo library.
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
//    if(1)  // for testing the alert sheet only
    {
        // this device has a camera, display the alert sheet:
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:@"Select Image Source"
                                      delegate:self 
                                      cancelButtonTitle:@"Cancel" 
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"Camera",@"Photo Library", nil];
        [actionSheet setActionSheetStyle:UIActionSheetStyleBlackOpaque];
        [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]]; // the tab bar was interferring in the current view
        // dismiss the keyboard if visible:
        //[titleField resignFirstResponder];
        //[descriptionField resignFirstResponder];
        [actionSheet release];
    } else {
        // without a camera, there is no choice to make. just display the modal image picker
        [self displayImagePickerWithSource:UIImagePickerControllerSourceTypePhotoLibrary];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;
{
    switch (buttonIndex) {
        case 0:
            // Camera Button
            //NSLog(@"Button 0 pressed");
            [self displayImagePickerWithSource:UIImagePickerControllerSourceTypeCamera];
            break;
        case 1:
            // Library Button
            //NSLog(@"Button 1 pressed");
            [self displayImagePickerWithSource:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
        case 2:
            // Cancel Button
            //NSLog(@"Button 2 pressed");
            break;
        default:
            break;
    }
}

-(void) displayImagePickerWithSource:(UIImagePickerControllerSourceType)src;{
    if([UIImagePickerController isSourceTypeAvailable:src]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        [picker setSourceType:src];
        [picker setDelegate:self];
        [picker setAllowsImageEditing:YES]; // allowing editing is nice, but returns a small 320px image
        [self presentModalViewController:picker animated:YES];
        [picker release];
    } // TODO: display alert if there is a problem with the source type
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"Picker has returned");
    // send the edited image to the imageField (view)
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
//    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    // [imageForOCR setImage:image];
//    
//    NSLog(@"%@",[[info objectForKey:UIImagePickerControllerCropRect] description]);
//    
//    imageForOCR = [self imageWithImage:image scaledToSize:CGSizeMake(1000, 1000)];
    
    // process the selected image:
    [activityView startAnimating];
    
    [statusLabel setText:[NSString stringWithString:@"Processing image..."]];
    [outputView setText:@""];
        
    // set the thumbnail image:
    [thumbImageView setImage:image];
    
    [picker dismissModalViewControllerAnimated:YES];
    
    NSDictionary * assets = [NSDictionary dictionaryWithObjectsAndKeys:image, @"smallCroppedImage", info, @"editInfo", nil];
    [self performSelector:@selector(imagePickerControllerDidFinishThreaded:) withObject:assets afterDelay:0.05];
    
    // process image, threaded:
//    [NSThread detachNewThreadSelector:@selector(threadedReadAndProcessImage:) toTarget:self withObject:imageForOCR];  
}


- (void)imagePickerControllerDidFinishThreaded:(NSDictionary*)assets
{
    NSDictionary        * editInfo = [assets objectForKey: @"editInfo"];
    CGRect                editCropRect = [[editInfo valueForKey:UIImagePickerControllerCropRect] CGRectValue];  
    
    // 1. Determine original image orientation and size
    UIImage             * originalImage = [editInfo valueForKey: UIImagePickerControllerOriginalImage];
    UIImageOrientation    originalOrientation = originalImage.imageOrientation;
    CGSize                originalSize = originalImage.size;
    CGSize                desiredSize = CGSizeMake(1024,1024);
    
    // 2. Modify crop rect to reflect image orientation
    CGFloat oldY = editCropRect.origin.y;
    CGFloat oldOriginalW = originalSize.width;
    CGFloat tmp;
    
    switch (originalOrientation) {
        case UIImageOrientationUp:      //EXIF 1
            break;
            
        case UIImageOrientationDown:    //EXIF 3
            // X flipped horizontally
            // Y flipped vertically
            editCropRect.origin.x = originalSize.width - (editCropRect.size.width + editCropRect.origin.x);
            editCropRect.origin.y = originalSize.height - (editCropRect.size.height + editCropRect.origin.y);
            break;
            
        case UIImageOrientationLeft:    //EXIF 6
            // fix info for original image.
            originalSize.width = originalSize.height;
            originalSize.height = oldOriginalW;
            
            // fix crop rect
			tmp = editCropRect.size.height;
			editCropRect.size.height = editCropRect.size.width;
			editCropRect.size.width = tmp;
            
            // rotation to the left
            editCropRect.origin.y = originalSize.height - (editCropRect.origin.x + editCropRect.size.height);
            editCropRect.origin.x = oldY;
            break;
            
        case UIImageOrientationRight:   //EXIF 8
            // fix info for original image.
            originalSize.width = originalSize.height;
            originalSize.height = oldOriginalW;
            
            // fix crop rect
			tmp = editCropRect.size.height;
			editCropRect.size.height = editCropRect.size.width;
			editCropRect.size.width = tmp;
            
            // rotate to the right
            editCropRect.origin.y = editCropRect.origin.x;
            editCropRect.origin.x = originalSize.height - oldY;
            break;
            
        default:
            break;
    }
    
    // 2.5. make the damn thing square if it's ALMOST square
    if (fabs((editCropRect.size.height - editCropRect.size.width) / fminf(originalSize.height, originalSize.width)) < 0.0295){
        editCropRect.size.width = fminf(editCropRect.size.width, editCropRect.size.height);
        editCropRect.size.height = editCropRect.size.width;
    }
    
    // 3. Crop image using crop rect
    UIGraphicsBeginImageContext(desiredSize);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGImageRef image = CGImageCreateWithImageInRect([originalImage CGImage], editCropRect);
    CGRect imageRect = CGRectMake(0.0f, 0.0f, desiredSize.width, desiredSize.height);
    
    // Image width < Image height. Just center vertically
    if (editCropRect.size.width / editCropRect.size.height < 1){
        imageRect.origin.x = (desiredSize.width - editCropRect.size.width * desiredSize.height/editCropRect.size.height)/2;
        imageRect.size.width -= imageRect.origin.x * 2;
        
        // Image width > Image height
    } else if (editCropRect.size.width / editCropRect.size.height > 1){
        float extraHeight = desiredSize.height - editCropRect.size.height * (desiredSize.width / editCropRect.size.width);
        
        // If the crop rect's origin is at the top of the screen, some of it might be clear (IE, the user may
        // have dragged "too far" and have some white space at the top of the preview box
        if (editCropRect.origin.y == 0) {
            imageRect.size.height -= extraHeight;
            if (roundf(editCropRect.size.height) == roundf(originalSize.height))
                imageRect.origin.y = extraHeight / 2;
            else
                imageRect.origin.y = 0;
            
            // User dragged "too far" down, and white space is visible at the bottom of preview box
        } else if (fabs(editCropRect.origin.y - (originalSize.height - roundf(editCropRect.size.height))) <= 1.1) {
            imageRect.origin.y = extraHeight;
            imageRect.size.height -= extraHeight;
            
        }else {
            imageRect.origin.y = (desiredSize.height - editCropRect.size.height * desiredSize.width/editCropRect.size.width)/2;
            imageRect.size.height -= imageRect.origin.y * 2;
        }
    }
    
    CGContextClearRect(context, CGRectMake(0,0,desiredSize.width,desiredSize.height));
	CGContextDrawImage(context, imageRect, image);
	UIImage* croppedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	CGImageRelease(image);
    
    // 4. Perform image rotation
    UIImage * finalImage = [self rotateImage: croppedImage byOrientationFlag: originalOrientation];
    
    // DO SOMETHING WITH finalImage!
    imageForOCR = finalImage;
    [self threadedReadAndProcessImage:imageForOCR]; // should already be threaded.
}

#pragma mark Convenience Functions for Image Picking

- (UIImage*)rotateImage:(UIImage*)img byOrientationFlag:(UIImageOrientation)orient
{
	CGImageRef          imgRef = img.CGImage;
	CGFloat             width = CGImageGetWidth(imgRef);
	CGFloat             height = CGImageGetHeight(imgRef);
	CGAffineTransform   transform = CGAffineTransformIdentity;
	CGRect              bounds = CGRectMake(0, 0, width, height);
    CGSize              imageSize = bounds.size;
	CGFloat             boundHeight;
    
	switch(orient) {
            
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
            
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
            
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
            
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
            
		default:
            // image is not auto-rotated by the photo picker, so whatever the user
            // sees is what they expect to get. No modification necessary
            transform = CGAffineTransformIdentity;
            break;
            
	}
    
	UIGraphicsBeginImageContext(bounds.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    if ((orient == UIImageOrientationDown) || (orient == UIImageOrientationRight) || (orient == UIImageOrientationUp)){
        // flip the coordinate space upside down
        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, -height);
    }
    
	CGContextConcatCTM(context, transform);
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	return imageCopy;
}


#pragma mark MailComposer delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;
{
    
    NSString *message;
    message = nil;
    
    
    // Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			break;
		case MFMailComposeResultSent:
			break;
		case MFMailComposeResultFailed:
            message = [NSString stringWithString:@"Mail Failed."];
			break;
		default:
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
    
    if(message != nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Status"
                                                        message:message delegate:nil 
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(IBAction)displayComposerSheet 
{
    if(![MFMailComposeViewController canSendMail]) {
        // can't send mail.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Mail not configured or available." 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:@"iPhoneOCR Text"];
	
    
	// Set up recipients
    //	NSArray *toRecipients = [NSArray arrayWithObject:@"first@example.com"]; 
    //	NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil]; 
    //	NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"]; 
	
    //	[picker setToRecipients:toRecipients];
    //	[picker setCcRecipients:ccRecipients];	
    //	[picker setBccRecipients:bccRecipients];
	
	// Attach an image to the email
    //	NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"png"];
    //    NSData *myData = [NSData dataWithContentsOfFile:path];
    //	[picker addAttachmentData:myData mimeType:@"image/png" fileName:@"rainy"];
	
    
	// Fill out the email body text
    //	NSString *emailBody = @"It is raining in sunny California!";
    	[picker setMessageBody:outputString isHTML:NO];
	
	[self presentModalViewController:picker animated:YES];
    [picker release];
    
}



/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}



@end
