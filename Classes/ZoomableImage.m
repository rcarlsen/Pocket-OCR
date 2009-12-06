//
//  ZoomableImage.m
//  OCR
//
//  Created by Robert Carlsen on 06.12.2009.
//  Copyright 2009 recv'd productions. All rights reserved.
//

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
