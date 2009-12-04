//
//  OCRAppDelegate.h
//  OCR
//
//  Created by Robert Carlsen on 04.09.2009.
//  Copyright recv'd productions 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OCRDisplayViewController;

@interface OCRAppDelegate : NSObject <UIApplicationDelegate, UIActionSheetDelegate> {
    UIWindow *window;
    OCRDisplayViewController *displayViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;


@end

