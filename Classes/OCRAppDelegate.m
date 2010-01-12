//
//  OCRAppDelegate.m
//  OCR
//
//  Created by Robert Carlsen on 04.09.2009.
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

#import "OCRAppDelegate.h"
#import "OCRDisplayViewController.h"

@implementation OCRAppDelegate

@synthesize window;


- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
    displayViewController = [[OCRDisplayViewController alloc] initWithNibName:@"OCRDisplayViewController" bundle:nil];
    displayViewController.view.frame = [UIScreen mainScreen].applicationFrame;
    
    [window addSubview:displayViewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc 
{
    [displayViewController release];
    [window release];
    
    [super dealloc];
}


@end
