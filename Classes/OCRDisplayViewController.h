//
//    OCRDisplayViewController.h
//    OCR
//
//    Created by Robert Carlsen on 03.12.2009.
//
//    Copyright (C) 2009, Robert Carlsen | robertcarlsen.net
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.


#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "ZoomableImage.h"

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

    IBOutlet ZoomableImage    *thumbImageView;
    IBOutlet UILabel        *statusLabel;
    IBOutlet UITextView *outputView;
}

@property(nonatomic,retain)NSString *outputString;
@property(nonatomic,retain)IBOutlet UITextView *outputView;
@property(nonatomic,retain)IBOutlet UIBarButtonItem *cameraButton;
@property(nonatomic,retain)IBOutlet UIBarButtonItem *actionButton;
@property(nonatomic,retain)IBOutlet ZoomableImage *thumbImageView;
@property(nonatomic,retain)IBOutlet UILabel *statusLabel;

- (NSString *)readAndProcessImage:(UIImage *)uiImage;
- (void)threadedReadAndProcessImage:(UIImage *)uiImage;
-(void)updateTextDisplay;

- (NSString *)applicationDocumentsDirectory;
- (IBAction)selectImage: (id) sender;
-(void)displayImagePickerWithSource:(UIImagePickerControllerSourceType)src;

-(IBAction)displayComposerSheet;
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error;

- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
@end
