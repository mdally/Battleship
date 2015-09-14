//
//  BoardSquare.h
//  Lab05
//
//  Created by Labuser on 3/29/15.
//  Copyright (c) 2015 Mark Dally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ship.h"
#import "Board.h"

@interface BoardSquare : UIButton {
    Board* parent;
}

@property BOOL hasBeenAttacked;
@property Ship* ship;

- (id)initWithFrame:(CGRect)frame Parent:(Board*)p;

- (void)buttonPressed;

- (void)beAttacked;

@end
