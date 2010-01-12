//
//  ZoomableImage.m
//  OCR
//
//  Created by Robert Carlsen on 06.12.2009.
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

#import "ZoomableImage.h" 

@implementation ZoomableImage

@synthesize zoomed;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        [self setUserInteractionEnabled:YES];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        // Initialization code
        [self setUserInteractionEnabled:YES];
    }
    return self;
}

//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"-- I AM TOUCHED --");
//}
//
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"-- I AM TOUCH-ENDED --");
//    
//    // don't zoom an empty frame
//    if (self.image == nil) {
//        return;
//    }
//    
//    // if the touch ended in this view, then zoom
//    UITouch *touch = [touches anyObject];
//    if (touch.view == self) {
//        if ([touch tapCount] >= 2) {
//            // do the zoom magic
//            if(![self zoomed]){
//                [self zoomImageToCenter];
//            } else {
//                [self shrinkToThumbnail];
//            }
//        }
//    }
//}

-(void)zoomImageToCenter;
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(growAnimationDidStop:finished:context:)];

    CGAffineTransform transform;

    CGAffineTransform scale = CGAffineTransformMakeScale(6.0, 6.0); // original is 52px

    CGPoint thumbCenter = self.center;
    CGPoint screenCenter = [[[UIApplication sharedApplication] keyWindow] center];
    CGAffineTransform move = CGAffineTransformMakeTranslation(screenCenter.x - thumbCenter.x, screenCenter.y - thumbCenter.y);

    transform = CGAffineTransformConcat(scale, move);
    [self setZoomed:YES];

    self.transform = transform;
    [UIView commitAnimations];
}

-(void)shrinkToThumbnail;
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(growAnimationDidStop:finished:context:)];
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    self.transform = transform;
    [self setZoomed:NO];
    
    [UIView commitAnimations];

}

- (void)growAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.5];
//    self.transform = CGAffineTransformIdentity;    
//    [UIView commitAnimations];
    [self setUserInteractionEnabled:YES];
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}

- (void)dealloc {
    [super dealloc];
}

@end
