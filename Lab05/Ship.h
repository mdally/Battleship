//
//  Ship.h
//  Lab05
//
//  Created by Labuser on 3/30/15.
//  Copyright (c) 2015 Mark Dally. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, Orientation) { Horizontal, Vertical };

@interface Ship : UIView {
    int hits;
    
    BOOL beingMoved;
    CGPoint originalPosition;
    CGPoint touchStartPosition;
    CFTimeInterval touchStartTime;
}

@property BOOL movable;
@property int headRow;
@property int headCol;
@property Orientation orientation;
@property int length;
@property BOOL sunk;

- (id)initWithFrame:(CGRect)frame Length:(int)l Orientation:(Orientation)o;

- (void)rotate;

- (void)takeHit;

@end
