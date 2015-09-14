//
//  GameViewController.h
//  Lab05
//

//  Copyright (c) 2015 Mark Dally. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Board.h"
#import "Ship.h"

@interface GameViewController : UIViewController {
    UIButton* p1button;
    UIButton* p2button;
    UIButton* finalizeButton;
    UILabel* headerLabel;
    UIButton* playerSwitchButton;
    
    Board* p1Board;
    Board* p2Board;
    
    UILabel* topBoardLabel;
    UILabel* bottomBoardLabel;
    Board* bottomBoard;
    Board* topBoard;
    CGRect topRect;
    CGRect bottomRect;
    
    BOOL setupComplete;
    int currentPlayer;
    int firstPlayer;
    
    NSString* p1Text;
    NSString* p2Text;
    
    int winner;
}

@property float pauseTime;
@property BOOL twoPlayers;

- (void)beginGame1P;

- (void)beginGame2P;

- (void)switchPlayers;

- (void)getP1Ships;

- (void)getP2Ships;

- (void)confirmShipLocations;

- (void)shipsPlaced;

- (void)beginGameLoop;

- (void)beginTurn;

- (void)endTurn;

- (void)endGame;

- (void)playExplosion;

- (void)playSplash;

- (void)playWoo;

@end
