//
//  OCRAppDelegate.m
//  OCR
//
//  Created by Robert Carlsen on 04.09.2009.
//  Copyright recv'd productions 2009. All rights reserved.
//

#import "OCRAppDelegate.h"
#import "OCRDisplayViewController.h"

@implementation OCRAppDelegate

@synthesize window;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    

    displayViewController = [[OCRDisplayViewController alloc] initWithNibName:@"OCRDisplayViewController" bundle:nil];
    displayViewController.view.frame = [UIScreen mainScreen].applicationFrame;
    
    [window addSubview:displayViewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [displayViewController release];
    [window release];
    
    [super dealloc];
}


@end
