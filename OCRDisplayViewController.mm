//
//  OCRDisplayViewController.m
//  OCR
//
//  Created by Robert Carlsen on 03.12.2009.
//  Copyright 2009 recv'd productions. All rights reserved.
//

#import "OCRDisplayViewController.h"
#import "baseapi.h"

#import "UIImage+Resize.h"
#import <math.h>

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
    
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
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
    
    [thumbImageView shrinkToThumbnail];
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

- (UIImage*)imageWithImage:(UIImage*)image 
              scaledToSize:(CGSize)newSize;
{
    // calculate aspect ratio:
    float ratio = image.size.height / image.size.width;
    float aspectHeight = newSize.width * ratio;
    CGSize ratioSize = CGSizeMake(newSize.width, aspectHeight);
    
    UIGraphicsBeginImageContext( ratioSize );
    [image drawInRect:CGRectMake(0,0,ratioSize.width,ratioSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

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
    //UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

    // process the selected image:
    [activityView startAnimating];
    
    [statusLabel setText:[NSString stringWithString:@"Processing image..."]];
    [outputView setText:@""];
        
    // set the thumbnail image:
    // get the thumbnailView size
//    NSInteger thumbSize = thumbImageView.frame.size.width;
//    [thumbImageView setImage:[image thumbnailImage:thumbSize 
//                                 transparentBorder:0 cornerRadius:0 
//                              interpolationQuality:kCGInterpolationDefault]];
    
    [thumbImageView setImage:image];
    
    [self dismissModalViewControllerAnimated:YES];
    
    // zoom the thumbnail
    [thumbImageView zoomImageToCenter];
    
    // crop the image to the bounds provided
    // TODO: make this all threaded?
    image = [info objectForKey:UIImagePickerControllerOriginalImage];    
    NSLog(@"orig image size: %@", [[NSValue valueWithCGSize:image.size] description]);
    
    // save the image, only if it's a newly taken image:
    if([picker sourceType] == UIImagePickerControllerSourceTypeCamera){
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil); 
    }
    
    CGRect rect;
    [[info objectForKey:UIImagePickerControllerCropRect] getValue:&rect];
    
    // fake resize to get the orientation right
    image = [image resizedImage:image.size interpolationQuality:kCGInterpolationDefault];

    // crop, but maintain original size:
    image = [image croppedImage:rect];
    NSLog(@"cropped image size: %@", [[NSValue valueWithCGSize:image.size] description]);

    // for testing.
    //[self.view addSubview:[[UIImageView alloc] initWithImage:image]];

    // resize, so as to not choke tesseract:
    CGFloat newWidth = (1000 < image.size.width) ? 1000 : image.size.width;
    CGSize newSize = CGSizeMake(newWidth,newWidth);

    image = [image resizedImage:newSize interpolationQuality:kCGInterpolationHigh];
    NSLog(@"resized image size: %@", [[NSValue valueWithCGSize:image.size] description]);

    //for debugging:
//    [thumbImageView setImage:image];

    // process image, threaded:
    //[NSThread detachNewThreadSelector:@selector(threadedReadAndProcessImage:) toTarget:self withObject:image]; 
    [self performSelector:@selector(threadedReadAndProcessImage:) withObject:image afterDelay:0.05];

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


//#pragma mark Touch events
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"-- I AM TOUCH-ENDED --");
//    
//}

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
