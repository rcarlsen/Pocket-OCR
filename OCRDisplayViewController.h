//
//  OCRDisplayViewController.h
//  OCR
//
//  Created by Robert Carlsen on 03.12.2009.
//  Copyright 2009 recv'd productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

// conditionally import or forward declare to contain objective-c++ code to here.
#ifdef __cplusplus
#import "baseapi.h"
#else
@class TessBaseAPI;
#endif

@interface OCRDisplayViewController : UIViewController
<UIActionSheetDelegate, UINavigationControllerDelegate, MFMailComposeViewControllerDelegate, UIImagePickerControllerDelegate> {
    TessBaseAPI *tess;
    UIImage *imageForOCR;
    NSString *outputString;
    
    UIActivityIndicatorView *activityView;
    
    IBOutlet UIBarButtonItem *cameraButton;
    IBOutlet UIBarButtonItem *actionButton;

    IBOutlet UIImageView    *thumbImageView;
    IBOutlet UILabel        *statusLabel;
    IBOutlet UITextView *outputView;
}

@property(nonatomic,retain)NSString *outputString;
@property(nonatomic,retain)IBOutlet UITextView *outputView;
@property(nonatomic,retain)IBOutlet UIBarButtonItem *cameraButton;
@property(nonatomic,retain)IBOutlet UIBarButtonItem *actionButton;
@property(nonatomic,retain)IBOutlet UIImageView *thumbImageView;
@property(nonatomic,retain)IBOutlet UILabel *statusLabel;

- (NSString *)readAndProcessImage:(UIImage *)uiImage;
- (void)threadedReadAndProcessImage:(UIImage *)uiImage;
-(void)updateTextDisplay;

- (NSString *)applicationDocumentsDirectory;
- (IBAction) selectImage: (id) sender;
-(void) displayImagePickerWithSource:(UIImagePickerControllerSourceType)src;

-(IBAction)displayComposerSheet;
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;

- (UIImage*)rotateImage:(UIImage*)img byOrientationFlag:(UIImageOrientation)orient;
- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
@end
