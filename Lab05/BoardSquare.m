//
//  BoardSquare.m
//  Lab05
//
//  Created by Labuser on 3/29/15.
//  Copyright (c) 2015 Mark Dally. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "BoardSquare.h"
#import "GameViewController.h"

@implementation BoardSquare

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@synthesize hasBeenAttacked;
@synthesize ship;

- (id)initWithFrame:(CGRect)frame Parent:(Board*)p {
    self = [super initWithFrame:frame];
    
    parent = p;
    hasBeenAttacked = NO;
    ship = nil;
    
    [self addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self setTitle:@"" forState:UIControlStateNormal];
    [self.titleLabel setFont:[UIFont systemFontOfSize:30]];
    
    return self;
}

- (void)buttonPressed {
    if(!hasBeenAttacked && parent.acceptingMoves){
        [self beAttacked];
    }
}

- (void)beAttacked {
    hasBeenAttacked = YES;
    
    UIResponder* resp = self;
    while(![resp isKindOfClass:[GameViewController class]]){
        resp = [resp nextResponder];
    }
    GameViewController* gvc = (GameViewController*)resp;
    
    if(ship){
        [self setTitle:@"X" forState:UIControlStateNormal];
        [self setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [ship performSelectorOnMainThread:@selector(takeHit) withObject:nil waitUntilDone:NO];
        
        [gvc playExplosion];
    }
    else{
        [self setTitle:@"O" forState:UIControlStateNormal];
        
        [gvc playSplash];
    }
    
    float pause = gvc.pauseTime;
    if(!gvc.twoPlayers) pause = 0;
    
    [NSTimer scheduledTimerWithTimeInterval:pause target:gvc selector:@selector(endTurn) userInfo:nil repeats:NO];
}

@end
