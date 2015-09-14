//
//  Board.h
//  Lab05
//
//  Created by Labuser on 3/30/15.
//  Copyright (c) 2015 Mark Dally. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Board : UIView {
    NSMutableArray* buttons;
    NSMutableArray* gridLines;
    
    UIColor* shipColor;
    UIColor* bgColor;
    UIColor* borderColor;
    
    float spacing;
    int spacingsPerButton;
    
    BOOL aiFoundShip;
    int foundX;
    int foundY;
    
    BOOL aiFoundOrientation;
    BOOL checkedNorth;
    BOOL checkedWest;
    BOOL checkedSouth;
    BOOL checkedEast;
    
    BOOL aiFoundHead;
    BOOL aiFoundTail;
    int headPos;
    int tailPos;
}

@property int player;
@property NSMutableArray* ships;
@property BOOL acceptingMoves;

- (void)spawnShips;

- (void)aiSpawnShips;

- (void)aiSpawnShip:(int)len;

- (void)confirmShipLocations;

- (void)hideShips;

- (void)showShips;

- (void)aiMove;

- (void)checkDirection:(int)d fromX:(int)x fromY:(int)y;

- (void)findHead;

- (void)findTail;

@end
