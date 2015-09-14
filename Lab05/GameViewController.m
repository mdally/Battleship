//
//  GameViewController.m
//  Lab05
//
//  Created by Labuser on 3/30/15.
//  Copyright (c) 2015 Mark Dally. All rights reserved.
//

#import "GameViewController.h"
#import <AVFoundation/AVFoundation.h>

@implementation GameViewController {
    AVAudioPlayer* explosion;
    AVAudioPlayer* splash;
    AVAudioPlayer* woo;
}

@synthesize pauseTime;
@synthesize twoPlayers;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    
    pauseTime = 0.5;
    setupComplete = NO;
    
    p1Text = @"Player One";
    p2Text = @"Player Two";
    
    CGRect myRect = self.view.frame;
    CGFloat width = CGRectGetWidth(myRect);
    CGFloat height = CGRectGetHeight(myRect);
    
    CGFloat boardScaling = 0.8;
    CGFloat verticalSpacing = (height-(width*2*boardScaling))/3.0;
    CGFloat horizontalSpacing = (width-(width*boardScaling))/2.0;
    
    CGFloat buttonWidth = width - 2*horizontalSpacing;
    CGFloat buttonHeight = 0.3*buttonWidth;
    
    p1button = [[UIButton alloc] initWithFrame:CGRectMake(horizontalSpacing, height/2 + 2*verticalSpacing - buttonHeight/2.0, buttonWidth, buttonHeight)];
    [p1button.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [p1button.layer setBorderWidth:1];
    [p1button setTitle:@"One Player" forState:UIControlStateNormal];
    [p1button addTarget:self action:@selector(beginGame1P) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:p1button];
    
    p2button = [[UIButton alloc] initWithFrame:CGRectMake(horizontalSpacing, height/2.0 - 2*verticalSpacing - buttonHeight/2.0, buttonWidth, buttonHeight)];
    [p2button.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [p2button.layer setBorderWidth:1];
    [p2button setTitle:@"Two Players" forState:UIControlStateNormal];
    [p2button addTarget:self action:@selector(beginGame2P) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:p2button];
    
    playerSwitchButton = [[UIButton alloc] initWithFrame:CGRectMake(horizontalSpacing, (height - buttonHeight)/2.0, buttonWidth, buttonHeight)];
    [playerSwitchButton.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [playerSwitchButton.layer setBorderWidth:1];
    [playerSwitchButton setTitle:@"Switch Players" forState:UIControlStateNormal];
    [self.view addSubview:playerSwitchButton];
    playerSwitchButton.hidden = YES;
    

    NSString *path = [NSString stringWithFormat:@"%@/explosion.mp3", [[NSBundle mainBundle] resourcePath]];
    NSURL *soundUrl = [NSURL fileURLWithPath:path];
    explosion = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
    [explosion prepareToPlay];
    
    path = [NSString stringWithFormat:@"%@/splash.wav", [[NSBundle mainBundle] resourcePath]];
    soundUrl = [NSURL fileURLWithPath:path];
    splash = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
    [splash prepareToPlay];
    
    path = [NSString stringWithFormat:@"%@/woo.wav", [[NSBundle mainBundle] resourcePath]];
    soundUrl = [NSURL fileURLWithPath:path];
    woo = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
    woo.volume = 3.0;
    [woo prepareToPlay];
}

- (void)beginGame1P {
    firstPlayer = 1 + arc4random() % 2;
    twoPlayers = NO;
    p1button.hidden = YES;
    p2button.hidden = YES;
    [self performSelectorOnMainThread:@selector(getP1Ships) withObject:nil waitUntilDone:NO];
}

- (void)beginGame2P {
    firstPlayer = 1 + arc4random() % 2;
    twoPlayers = YES;
    p1button.hidden = YES;
    p2button.hidden = YES;
    [self performSelectorOnMainThread:@selector(getP1Ships) withObject:nil waitUntilDone:NO];
}

- (void)switchPlayers {
    p1Board.hidden = YES;
    p2Board.hidden = YES;
    topBoardLabel.hidden = YES;
    bottomBoardLabel.hidden = YES;
    headerLabel.hidden = YES;
    
    currentPlayer = 3-currentPlayer;
    
    NSString* currentPlayerText;
    if(currentPlayer == 1) currentPlayerText = p1Text;
    else currentPlayerText = p2Text;
    [headerLabel setText:[currentPlayerText stringByAppendingString:@"'s turn"]];
    
    if(twoPlayers) playerSwitchButton.hidden = NO;
    
    if(setupComplete){
        if(twoPlayers){
            Board* tmp = bottomBoard;
            bottomBoard = topBoard;
            topBoard = tmp;
            
            topBoard.frame = topRect;
            [topBoard hideShips];
            
            bottomBoard.frame = bottomRect;
            [bottomBoard showShips];
        }
        
        if(twoPlayers || currentPlayer == 1) topBoard.acceptingMoves = YES;
        bottomBoard.acceptingMoves = NO;
    }
    
    if(!twoPlayers) [self performSelectorOnMainThread:@selector(beginTurn) withObject:nil waitUntilDone:NO];
}

- (void)getP1Ships {
    currentPlayer = 1;
    
    CGRect myRect = self.view.frame;
    CGFloat width = CGRectGetWidth(myRect);
    CGFloat height = CGRectGetHeight(myRect);
    
    CGFloat boardScaling = 0.8;
    CGFloat verticalSpacing = (height-(width*boardScaling))/2.0;
    CGFloat horizontalSpacing = (width-(width*boardScaling))/2.0;
    
    headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(width*0.1, verticalSpacing*0.1, width*0.8, verticalSpacing*0.6)];
    headerLabel.text = @"Player One, place your ships.\nTap to rotate.";
    headerLabel.numberOfLines = 0;
    headerLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:headerLabel];
    
    p1Board = [[Board alloc] initWithFrame:CGRectMake(horizontalSpacing,
                                                      verticalSpacing,
                                                      width*boardScaling,
                                                      width*boardScaling)];
    p1Board.player = firstPlayer;
    [self.view addSubview:p1Board];
    
    finalizeButton = [[UIButton alloc] initWithFrame:CGRectMake(width*0.1, height-0.8*verticalSpacing, width*0.8, verticalSpacing*0.6)];
    [finalizeButton addTarget:self
                       action:@selector(confirmShipLocations)
             forControlEvents:UIControlEventTouchUpInside];
    [finalizeButton setTitle:@"Confirm Ship Placement" forState:UIControlStateNormal];
    [p1button.layer setBorderColor:[[UIColor blackColor] CGColor]];
    [p1button.layer setBorderWidth:1];
    [self.view addSubview:finalizeButton];
    
    [p1Board performSelectorOnMainThread:@selector(spawnShips) withObject:nil waitUntilDone:NO];
}

- (void)getP2Ships {
    currentPlayer = 2;
    
    CGRect myRect = self.view.frame;
    CGFloat width = CGRectGetWidth(myRect);
    CGFloat height = CGRectGetHeight(myRect);
    
    headerLabel.text = @"Player Two, place your ships.\nTap to rotate.";
    headerLabel.hidden = NO;
    
    CGFloat boardScaling = 0.8;
    CGFloat verticalSpacing = (height-(width*boardScaling))/2.0;
    CGFloat horizontalSpacing = (width-(width*boardScaling))/2.0;
    
    p2Board = [[Board alloc] initWithFrame:CGRectMake(horizontalSpacing,
                                                      verticalSpacing,
                                                      width*boardScaling,
                                                      width*boardScaling)];
    p2Board.player = 1 + (2-firstPlayer);
    [self.view addSubview:p2Board];
    
    if(twoPlayers){
        finalizeButton.hidden = NO;
        
        [p2Board performSelectorOnMainThread:@selector(spawnShips) withObject:nil waitUntilDone:NO];
    }
    else{
        p2Board.hidden = YES;
        [p2Board performSelectorOnMainThread:@selector(aiSpawnShips) withObject:nil waitUntilDone:NO];
    }
}

- (void)confirmShipLocations {
    if(currentPlayer == 1){
        [p1Board performSelectorOnMainThread:@selector(confirmShipLocations) withObject:nil waitUntilDone:NO];
    }
    else {
        [p2Board performSelectorOnMainThread:@selector(confirmShipLocations) withObject:nil waitUntilDone:NO];
    }
}

- (void)shipsPlaced {
    if(currentPlayer == 1){
        finalizeButton.hidden = YES;
        headerLabel.hidden = YES;
        
        if(twoPlayers){
            [playerSwitchButton addTarget:self action:@selector(getP2Ships) forControlEvents:UIControlEventTouchUpInside];
            [NSTimer scheduledTimerWithTimeInterval:pauseTime target:self selector:@selector(switchPlayers) userInfo:nil repeats:NO];
        }
        else{
            [NSTimer scheduledTimerWithTimeInterval:pauseTime target:self selector:@selector(getP2Ships) userInfo:nil repeats:NO];
        }
    }
    else{
        finalizeButton.hidden = YES;
        headerLabel.hidden = YES;
        playerSwitchButton.hidden = YES;
        
        if(twoPlayers){
            [NSTimer scheduledTimerWithTimeInterval:pauseTime target:self selector:@selector(beginGameLoop) userInfo:nil repeats:NO];
        }
        else{
            [self performSelectorOnMainThread:@selector(beginGameLoop) withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)beginGameLoop {
    p1Board.hidden = YES;
    p2Board.hidden = YES;
    
    CGRect myRect = self.view.frame;
    CGFloat width = CGRectGetWidth(myRect);
    CGFloat height = CGRectGetHeight(myRect);
    
    CGFloat boardScaling = 0.45;
    CGFloat verticalSpacing = (height-(width*2*boardScaling))/3.0;
    CGFloat horizontalSpacing = (width-(width*boardScaling))/2.0;
    
    topRect = CGRectMake(horizontalSpacing, verticalSpacing, width*boardScaling, width*boardScaling);
    bottomRect = CGRectMake(horizontalSpacing, verticalSpacing*2 + width*boardScaling, width*boardScaling, width*boardScaling);
    
    p1Board.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.45/0.8, 0.45/0.8);
    topBoardLabel = [[UILabel alloc] initWithFrame:CGRectMake(topRect.origin.x, topRect.origin.y - topRect.size.height*0.1, topRect.size.width, topRect.size.height*0.1)];
    [topBoardLabel setText:@"Enemy Board"];
    [topBoardLabel setTextAlignment:NSTextAlignmentCenter];
    topBoardLabel.hidden = YES;
    [self.view addSubview:topBoardLabel];
    
    p2Board.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.45/0.8, 0.45/0.8);
    bottomBoardLabel = [[UILabel alloc] initWithFrame:CGRectMake(bottomRect.origin.x, bottomRect.origin.y - bottomRect.size.height*0.1, bottomRect.size.width, bottomRect.size.height*0.1)];
    [bottomBoardLabel setText:@"Your Board"];
    [bottomBoardLabel setTextAlignment:NSTextAlignmentCenter];
    bottomBoardLabel.hidden = YES;
    [self.view addSubview:bottomBoardLabel];
    
    NSString* currentPlayerText;
    if(currentPlayer == 1) currentPlayerText = p1Text;
    else currentPlayerText = p2Text;
    
    headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, verticalSpacing*0.5)];
    [headerLabel setText:[currentPlayerText stringByAppendingString:@"'s turn"]];
    [headerLabel setTextAlignment:NSTextAlignmentCenter];
    headerLabel.hidden = YES;
    [self.view addSubview:headerLabel];
    
    setupComplete = YES;
    
    topBoard = p1Board;
    topBoard.frame = topRect;
    [topBoard hideShips];
    
    bottomBoard = p2Board;
    bottomBoard.frame = bottomRect;
    [bottomBoard showShips];
    
    if(!twoPlayers) {
        topBoard = p2Board;
        topBoard.frame = topRect;
        [topBoard hideShips];
        topBoard.hidden = NO;
        
        bottomBoard = p1Board;
        bottomBoard.frame = bottomRect;
        [bottomBoard showShips];
        bottomBoard.hidden = NO;
    }
    else {
        topBoard.acceptingMoves = YES;
        bottomBoard.acceptingMoves = NO;
    }
    
    if(firstPlayer == 2){
        [self performSelectorOnMainThread:@selector(beginTurn) withObject:nil waitUntilDone:NO];
    }
    else{
        [playerSwitchButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
        [playerSwitchButton addTarget:self action:@selector(beginTurn) forControlEvents:UIControlEventTouchUpInside];
        
        [self performSelectorOnMainThread:@selector(switchPlayers) withObject:nil waitUntilDone:NO];
    }
}

- (void)beginTurn {
    topBoard.hidden = NO;
    bottomBoard.hidden = NO;
    
    topBoardLabel.hidden = NO;
    bottomBoardLabel.hidden = NO;
    
    headerLabel.hidden = NO;
    playerSwitchButton.hidden = YES;
    
    if(!twoPlayers && currentPlayer == 2){
        [p1Board performSelectorOnMainThread:@selector(aiMove) withObject:nil waitUntilDone:NO];
    }
}

- (void)endTurn {
    if(twoPlayers || currentPlayer == 1) topBoard.acceptingMoves = NO;
    else bottomBoard.acceptingMoves = NO;
    
    int shipsSunk = 0;
    for(int i = 0; i < 5; ++i){
        Board* b = topBoard;
        if(!twoPlayers && currentPlayer == 2) b = bottomBoard;
                                                   
        Ship* s = [b.ships objectAtIndex:i];
                                                   
        if(s.sunk) ++shipsSunk;
    }
    
    if(shipsSunk == 5){
        winner = currentPlayer;
        
        finalizeButton.hidden = YES;
        finalizeButton = nil;
        
        headerLabel.hidden = YES;
        headerLabel = nil;
        
        playerSwitchButton.hidden = YES;
        
        topBoardLabel.hidden = YES;
        topBoardLabel = nil;
        
        bottomBoardLabel.hidden = YES;
        bottomBoardLabel = nil;
        
        p1Board.hidden = YES;
        p2Board.hidden = YES;
        
        p1Board = nil;
        p2Board = nil;
        topBoard = nil;
        bottomBoard = nil;
        
        [NSTimer scheduledTimerWithTimeInterval:pauseTime target:self selector:@selector(endGame) userInfo:nil repeats:NO];
        return;
    }
    
    [playerSwitchButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [playerSwitchButton addTarget:self action:@selector(beginTurn) forControlEvents:UIControlEventTouchUpInside];
    [NSTimer scheduledTimerWithTimeInterval:pauseTime target:self selector:@selector(switchPlayers) userInfo:nil repeats:NO];
}

- (void)endGame {
    NSString* winnerText;
    if(winner == 1) winnerText = p1Text;
    else winnerText = p2Text;
    
    [self playWoo];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Game Over"
                                                    message:[winnerText stringByAppendingString:@" has won!"]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    p1button.hidden = NO;
    p2button.hidden = NO;
}

- (void)playExplosion {
    if([explosion isPlaying]) {
        [explosion pause];
    }
    explosion.currentTime = 0;
    [explosion play];
}

- (void)playSplash {
    if([splash isPlaying]) {
        [splash pause];
    }
    splash.currentTime = 0;
    [splash play];
}

- (void)playWoo {
    if([splash isPlaying]){
        [splash pause];
    }
    if([explosion isPlaying]){
        [explosion pause];
    }
    
    [woo play];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    }
    else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
