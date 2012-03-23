//
//  HelloWorldLayer.h
//  ARDemo
//
//  Created by Xiaobin Chen on 12-3-23.
//  Copyright xb 2012年. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#include <CoreMotion/CoreMotion.h>
#import <CoreFoundation/CoreFoundation.h>

#import "EnemyShip.h"


// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
    CMMotionManager *motionManager;
    CCLabelTTF *yawLabel;
    CCLabelTTF *posIn360Label;
    
    NSMutableArray * enemySprites;
    int enemyCount;
    CCSpriteBatchNode *batchNode;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
@property (nonatomic, retain) CMMotionManager *motionManager;
@property (readwrite) int enemyCount;

-(EnemyShip *)addEnemyShip:(int)shipTag;
-(void)checkEnemyShipPosition:(EnemyShip *)enemyShip withYaw:(float)yawPosition;
-(void)updateEnemyShipPostion:(int)postitionIn360 withEnemy:(EnemyShip *)enemyShip;
-(void)runStandardPositionCheck:(int)positionIn360 withDiff:(int)difference withEnemy:(EnemyShip *)enemyShip;



@end
