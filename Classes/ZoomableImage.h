//
//  ZoomableImage.h
//  OCR
//
//  Created by Robert Carlsen on 06.12.2009.
//  Copyright 2009 recv'd productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZoomableImage : UIImageView {
    BOOL zoomed;
}
@property BOOL zoomed;

-(void)zoomImageToCenter;
-(void)shrinkToThumbnail;

@end
