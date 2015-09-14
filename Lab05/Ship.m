//
//  Ship.m
//  Lab05
//
//  Created by Labuser on 3/30/15.
//  Copyright (c) 2015 Mark Dally. All rights reserved.
//

#import "Ship.h"

@implementation Ship

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@synthesize movable;
@synthesize headRow;
@synthesize headCol;
@synthesize orientation;
@synthesize length;
@synthesize sunk;

- (id)initWithFrame:(CGRect)frame Length:(int)l Orientation:(Orientation)o {
    self = [super initWithFrame:frame];
    
    movable = YES;
    sunk = NO;
    beingMoved = NO;
    length = l;
    orientation = o;
    hits = 0;
    
    return self;
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(movable){
        touchStartTime = CACurrentMediaTime();
        
        beingMoved = YES;
        
        originalPosition = self.center;
        UITouch *touch = [touches anyObject];
        touchStartPosition = [touch locationInView:self.superview];
    }
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(movable){
        UITouch *touch = [touches anyObject];
        CGPoint currentPosition = [touch locationInView: self.superview];
        
        
        [UIView animateWithDuration:.0001
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^ {
                             self.center = CGPointMake(originalPosition.x+currentPosition.x-touchStartPosition.x,
                                                       originalPosition.y+currentPosition.y-touchStartPosition.y);
                         }
                         completion:^(BOOL finished) {}];
    }
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(movable){
        CFTimeInterval elapsedTime = CACurrentMediaTime() - touchStartTime;
        beingMoved = NO;
        
        if(elapsedTime < 0.1){
            [self rotate];
        }
    }
}

- (void)rotate {
    if(orientation == Horizontal){
        orientation = Vertical;
        self.transform = CGAffineTransformRotate(self.transform, M_PI/2);
    }
    else{
        orientation = Horizontal;
        self.transform = CGAffineTransformRotate(self.transform, -M_PI/2);
    }
}

- (void)takeHit {
    ++hits;
    if(hits == length) sunk = YES;
}

@end
