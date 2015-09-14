//
//  Board.m
//  Lab05
//
//  Created by Labuser on 3/30/15.
//  Copyright (c) 2015 Mark Dally. All rights reserved.
//

#import "BoardSquare.h"
#import "Ship.h"
#import "Board.h"
#import "GameViewController.h"

@implementation Board{
    Orientation foundOrientation;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@synthesize player;
@synthesize ships;
@synthesize acceptingMoves;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    shipColor = [UIColor blackColor];
    bgColor = [UIColor blueColor];
    borderColor = [UIColor whiteColor];
    
    [self setBackgroundColor:bgColor];
    buttons = [[NSMutableArray alloc] init];
    gridLines = [[NSMutableArray alloc] init];
    
    CGRect myRect = self.frame;
    float width = CGRectGetWidth(myRect);
    
    spacingsPerButton = 5;
    spacing = width / (spacingsPerButton*10 + 11);
    float button = spacing * spacingsPerButton;
    
    //spawn grid borders
    UIView* v;
    for(int i = 0; i < 11; ++i){
        v = [[UIView alloc] initWithFrame:CGRectMake(6*spacing*i, 0, spacing, width)];
        [v setBackgroundColor:borderColor];
        [self addSubview:v];
        [gridLines addObject:v];
        
        v = [[UIView alloc] initWithFrame:CGRectMake(0, 6*spacing*i, width, spacing)];
        [v setBackgroundColor:borderColor];
        [self addSubview:v];
        [gridLines addObject:v];
    }
    
    //spawn buttons
    float y = spacing;
    for(int i = 0; i < 10; ++i){
        NSMutableArray* row = [[NSMutableArray alloc] init];
        [buttons addObject:row];
        
        float x = spacing;
        for(int j = 0; j < 10; ++j){
            BoardSquare* sq = [[BoardSquare alloc] initWithFrame:CGRectMake(x, y, button, button) Parent:self];
            [sq setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [row addObject:sq];
            
            [self addSubview:sq];
            
            x += spacing+button;
        }
        
        y += spacing+button;
    }
    
    ships = [[NSMutableArray alloc] init];
    
    acceptingMoves = NO;
    
    aiFoundShip = NO;
    aiFoundOrientation = NO;
    aiFoundHead = NO;
    aiFoundTail = NO;
    
    return self;
}

- (void)spawnShips {
    int len = 5;
    Ship* ship = [[Ship alloc] initWithFrame:CGRectMake(spacing,
                                                        spacing,
                                                        spacing*spacingsPerButton,
                                                        len*spacing*spacingsPerButton + (len-1)*spacing)
                                      Length:len
                                 Orientation:Vertical];
    ship.backgroundColor = shipColor;
    [self addSubview:ship];
    [ships addObject:ship];
    
    len = 4;
    ship = [[Ship alloc] initWithFrame:CGRectMake(7*spacing,
                                                  spacing,
                                                  spacing*spacingsPerButton,
                                                  len*spacing*spacingsPerButton + (len-1)*spacing)
                                Length:len
                           Orientation:Vertical];
    ship.backgroundColor = shipColor;
    [self addSubview:ship];
    [ships addObject:ship];
    
    len = 3;
    ship = [[Ship alloc] initWithFrame:CGRectMake(13*spacing,
                                                  spacing,
                                                  spacing*spacingsPerButton,
                                                  len*spacing*spacingsPerButton + (len-1)*spacing)
                                Length:len
                           Orientation:Vertical];
    ship.backgroundColor = shipColor;
    [self addSubview:ship];
    [ships addObject:ship];
    
    len = 3;
    ship = [[Ship alloc] initWithFrame:CGRectMake(19*spacing,
                                                  spacing,
                                                  spacing*spacingsPerButton,
                                                  len*spacing*spacingsPerButton + (len-1)*spacing)
                                Length:len
                           Orientation:Vertical];
    ship.backgroundColor = shipColor;
    [self addSubview:ship];
    [ships addObject:ship];
    
    len = 2;
    ship = [[Ship alloc] initWithFrame:CGRectMake(25*spacing,
                                                  spacing,
                                                  spacing*spacingsPerButton,
                                                  len*spacing*spacingsPerButton + (len-1)*spacing)
                                Length:len
                           Orientation:Vertical];
    ship.backgroundColor = shipColor;
    [self addSubview:ship];
    [ships addObject:ship];
}

- (void)aiSpawnShips {
    [self aiSpawnShip:5];
    [self aiSpawnShip:4];
    [self aiSpawnShip:3];
    [self aiSpawnShip:3];
    [self aiSpawnShip:2];
    
    for(int i = 0; i < 5; ++i){
        Ship* ship = [ships objectAtIndex:i];
        
        ship.movable = NO;
        [self sendSubviewToBack:ship];
    }
    
    UIResponder* resp = self;
    while(![resp isKindOfClass:[GameViewController class]]){
        resp = [resp nextResponder];
    }
    
    GameViewController* gvc = (GameViewController*)resp;
    [gvc performSelectorOnMainThread:@selector(shipsPlaced) withObject:nil waitUntilDone:NO];
}

- (void)aiSpawnShip:(int)len {
    int row = 0;
    int tailRow;
    int col = 0;
    int tailCol;
    Orientation orientation = 0;
    
    BOOL validPlacement = NO;
    
    while(!validPlacement){
        orientation = arc4random() % 2;
        row = arc4random() % 10;
        col = arc4random() % 10;
        tailRow = row;
        if(orientation == Vertical){
            tailRow += (len-1);
        }
        if(tailRow > 9){
            row += (9-tailRow);
        }
        
        tailCol = col;
        if(orientation == Horizontal){
            tailCol += (len-1);
        }
        if(tailCol > 9){
            col += (9-tailCol);
        }
        
        BOOL spaceOccupied = NO;
        for(int i = 0; i < len; ++i){
            BoardSquare* bs;
            if(orientation == Horizontal){
                bs = [[buttons objectAtIndex:row] objectAtIndex:col+i];
            }
            else{
                bs = [[buttons objectAtIndex:row+i] objectAtIndex:col];
            }
            if(bs.ship){
                spaceOccupied = YES;
            }
        }
        
        if(!spaceOccupied) validPlacement = YES;
    }
    
    float width;
    float height;
    if(orientation == Horizontal){
        width = len*spacing*spacingsPerButton + (len-1)*spacing;
        height = spacingsPerButton*spacing;
    }
    else{
        width = spacingsPerButton*spacing;
        height = len*spacing*spacingsPerButton + (len-1)*spacing;
    }
    
    Ship* ship = [[Ship alloc] initWithFrame:CGRectMake((col+1)*spacing + col*spacing*spacingsPerButton,
                                                        (row+1)*spacing + row*spacing*spacingsPerButton,
                                                        width,
                                                        height)
                                      Length:len
                                 Orientation:orientation];
    ship.backgroundColor = shipColor;
    ship.headRow = row;
    ship.headCol = col;
    [self addSubview:ship];
    [ships addObject:ship];
    
    for(int i = 0; i < len; ++i){
        BoardSquare* bs;
        if(ship.orientation == Horizontal){
            bs = [[buttons objectAtIndex:row] objectAtIndex:col+i];
        }
        else{
            bs = [[buttons objectAtIndex:row+i] objectAtIndex:col];
        }
        bs.ship = ship;
    }
}

- (void)confirmShipLocations {
    //snap ships to grid
    BOOL offGrid = NO;
    for(int i = 0; i < 5; ++i){
        Ship* ship = [ships objectAtIndex:i];
        
        int row = (int)lroundf((ship.frame.origin.y - spacing)/((spacingsPerButton+1)*spacing));
        int tailRow = row;
        if(ship.orientation == Vertical) tailRow += (ship.length-1);
        if(row < 0){
            row = 0;
            offGrid = YES;
        }
        if(tailRow > 9){
            row += (9-tailRow);
            offGrid = YES;
        }
        
        int col = (int)lroundf((ship.frame.origin.x - spacing)/((spacingsPerButton+1)*spacing));
        int tailCol = col;
        if(ship.orientation == Horizontal) tailCol += (ship.length-1);
        if(col < 0){
            col = 0;
            offGrid = YES;
        }
        if(tailCol > 9){
            col += (9-tailCol);
            offGrid = YES;
        }
        
        CGRect shipFrame = ship.frame;
        shipFrame.origin.x = (col+1)*spacing + (col)*spacingsPerButton*spacing;
        shipFrame.origin.y = (row+1)*spacing + (row)*spacingsPerButton*spacing;
        
        ship.frame = shipFrame;
        
        ship.headRow = row;
        ship.headCol = col;
    }
    if(offGrid){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Ships Not Placed Correctly"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    //check for overlaps
    for(int i = 0; i < 5; ++i){
        Ship* ship = [ships objectAtIndex:i];
        
        for(int j = 0; j < ship.length; ++j){
            BoardSquare* bs;
            if(ship.orientation == Horizontal){
                bs = [[buttons objectAtIndex:ship.headRow] objectAtIndex:ship.headCol+j];
            }
            else{
                bs = [[buttons objectAtIndex:ship.headRow+j] objectAtIndex:ship.headCol];
            }
            if(!bs.ship){
                bs.ship = ship;
            }
            else{
                //found an overlap
                for(int a = 0; a < 10; ++a){
                    for(int b = 0; b < 10; ++b){
                        BoardSquare* sq = [[buttons objectAtIndex:a] objectAtIndex:b];
                        sq.ship = nil;
                    }
                }
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Ships Cannot Overlap"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                
                return;
            }
        }
    }
    
    //ship locations are all fine
    for(int i = 0; i < 5; ++i){
        Ship* ship = [ships objectAtIndex:i];
        
        ship.movable = NO;
        [self sendSubviewToBack:ship];
    }
    for(int i = 0; i < 22; ++i){
        UIView* v = [gridLines objectAtIndex:i];
        [self sendSubviewToBack:v];
    }
    
    UIResponder* resp = self;
    while(![resp isKindOfClass:[GameViewController class]]){
        resp = [resp nextResponder];
    }
    
    GameViewController* gvc = (GameViewController*)resp;
    [gvc performSelectorOnMainThread:@selector(shipsPlaced) withObject:nil waitUntilDone:NO];
}

- (void)hideShips {
    for(int i = 0; i < 5; ++i){
        Ship* ship = [ships objectAtIndex:i];
        ship.hidden = YES;
    }
}

- (void)showShips {
    for(int i = 0; i < 5; ++i){
        Ship* ship = [ships objectAtIndex:i];
        ship.hidden = NO;
    }
}

- (void)aiMove {
    if(aiFoundShip){
        if(aiFoundOrientation){
            if(aiFoundHead){
                if(aiFoundTail){
                    aiFoundShip = NO;
                    
                    aiFoundOrientation = NO;
                    checkedNorth = NO;
                    checkedWest = NO;
                    checkedSouth = NO;
                    checkedEast = NO;
                    
                    aiFoundHead = NO;
                    aiFoundTail = NO;
                    
                    [self performSelector:@selector(aiMove) withObject:nil afterDelay:0];
                }
                else{
                    [self findTail];
                }
            }
            else{
                [self findHead];
            }
        }
        else{
            if(checkedNorth) {
                if(checkedWest){
                    if(checkedSouth){
                        if(checkedEast){
                            aiFoundShip = NO;
                            [self aiMove];
                        }
                        else{
                            [self checkDirection:3 fromX:foundX fromY:foundY];
                        }
                    }
                    else{
                        [self checkDirection:2 fromX:foundX fromY:foundY];
                    }
                }
                else{
                    [self checkDirection:1 fromX:foundX fromY:foundY];
                }
            }
            else{
                [self checkDirection:0 fromX:foundX fromY:foundY];
            }
        }
    }
    else{
        BOOL keepLooking = YES;
        while(keepLooking){
            int x = arc4random() % 10;
            int y = arc4random() % 10;
            
            BoardSquare* sq = [[buttons objectAtIndex:y] objectAtIndex:x];
            if(!sq.hasBeenAttacked){
                keepLooking = NO;
                
                [sq beAttacked];
                
                if(sq.ship){
                    aiFoundShip = YES;
                    foundX = x;
                    foundY = y;
                }
            }
        }
    }
}

- (void)checkDirection:(int)d fromX:(int)x fromY:(int)y {
    int checkX = x;
    int checkY = y;
    
    switch (d) {
        case 0:
            --checkY;
            if(checkY < 0){
                checkedNorth = YES;
                [self performSelector:@selector(aiMove) withObject:nil afterDelay:0];
                return;
            }
            break;
        case 1:
            --checkX;
            if(checkX < 0){
                checkedWest = YES;
                [self performSelector:@selector(aiMove) withObject:nil afterDelay:0];
                return;
            }
            break;
        case 2:
            ++checkY;
            if(checkY > 9){
                checkedSouth = YES;
                [self performSelector:@selector(aiMove) withObject:nil afterDelay:0];
                return;
            }
            break;
        case 3:
            ++checkX;
            if(checkX > 9){
                checkedEast = YES;
                [self performSelector:@selector(aiMove) withObject:nil afterDelay:0];
                return;
            }
            break;
    }
    
    BoardSquare* sq = [[buttons objectAtIndex:checkY] objectAtIndex:checkX];
    
    if(sq.hasBeenAttacked){
        if(sq.ship){
            [self checkDirection:d fromX:checkX fromY:checkY];
        }
        else{
            switch (d) {
                case 0:
                    checkedNorth = YES;
                    [self performSelector:@selector(aiMove) withObject:nil afterDelay:0];
                    break;
                case 1:
                    checkedWest = YES;
                    [self performSelector:@selector(aiMove) withObject:nil afterDelay:0];
                    break;
                case 2:
                    checkedSouth = YES;
                    [self performSelector:@selector(aiMove) withObject:nil afterDelay:0];
                    break;
                case 3:
                    checkedEast = YES;
                    [self performSelector:@selector(aiMove) withObject:nil afterDelay:0];
                    break;
            }
        }
    }
    else{
        if(sq.ship){
            switch (d) {
                case 0:
                case 2:
                    foundOrientation = Vertical;
                    headPos = MAX(foundY, checkY);
                    tailPos = MIN(foundY, checkY);
                    break;
                case 1:
                case 3:
                    foundOrientation = Horizontal;
                    headPos = MAX(foundX, checkX);
                    tailPos = MIN(foundX, checkX);
                    break;
            }
            
            aiFoundOrientation = YES;
        }
        else{
            switch (d) {
                case 0:
                    checkedNorth = YES;
                    break;
                case 1:
                    checkedWest = YES;
                    break;
                case 2:
                    checkedSouth = YES;
                    break;
                case 3:
                    checkedEast = YES;
                    break;
            }
        }
        
        [sq performSelector:@selector(beAttacked) withObject:nil afterDelay:0];
    }
}

- (void)findHead {
    int check = headPos+1;
    
    if(check > 9){
        aiFoundHead = YES;
        [self performSelector:@selector(aiMove) withObject:nil afterDelay:0];
    }
    else{
        BoardSquare* sq;
        
        if(foundOrientation == Vertical){
            sq = [[buttons objectAtIndex:check] objectAtIndex:foundX];
        }
        else{
            sq = [[buttons objectAtIndex:foundY] objectAtIndex:check];
        }
        
        if(sq.hasBeenAttacked){
            if(sq.ship){
                headPos = check;
                [self performSelector:@selector(findHead) withObject:nil afterDelay:0];
            }
            else{
                aiFoundHead = YES;
                [self performSelector:@selector(aiMove) withObject:nil afterDelay:0];
            }
        }
        else{
            if(sq.ship){
                headPos = check;
            }
            else{
                aiFoundHead = YES;
            }
            
            [sq performSelector:@selector(beAttacked) withObject:nil afterDelay:0];
        }
    }
}

- (void)findTail {
    int check = tailPos-1;
    
    if(check < 0){
        aiFoundTail = YES;
        [self performSelector:@selector(aiMove) withObject:nil afterDelay:0];
    }
    else{
        BoardSquare* sq;
        
        if(foundOrientation == Vertical){
            sq = [[buttons objectAtIndex:check] objectAtIndex:foundX];
        }
        else{
            sq = [[buttons objectAtIndex:foundY] objectAtIndex:check];
        }
        
        if(sq.hasBeenAttacked){
            if(sq.ship){
                tailPos = check;
                [self performSelector:@selector(findTail) withObject:nil afterDelay:0];
            }
            else{
                aiFoundTail = YES;
                [self performSelector:@selector(aiMove) withObject:nil afterDelay:0];
            }
        }
        else{
            if(sq.ship){
                tailPos = check;
            }
            else{
                aiFoundTail = YES;
            }
            
            [sq performSelector:@selector(beAttacked) withObject:nil afterDelay:0];
        }
    }
}

@end
