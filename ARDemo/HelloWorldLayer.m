//
//  HelloWorldLayer.m
//  ARDemo
//
//  Created by Xiaobin Chen on 12-3-23.
//  Copyright xb 2012年. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#include <stdlib.h>

// HelloWorldLayer implementation
@implementation HelloWorldLayer
@synthesize motionManager;

@synthesize enemyCount;
#define kXPositionMultiplier 15
#define kTimeToLive 100

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        // add and position the labels
        yawLabel = [CCLabelTTF labelWithString:@"Yaw: " fontName:@"Marker Felt" fontSize:12];
        posIn360Label = [CCLabelTTF labelWithString:@"360Pos: " fontName:@"Marker Felt" fontSize:12];
        yawLabel.position =  ccp(50, 240);
        posIn360Label.position =  ccp(50, 300);
        [self addChild: yawLabel];
        [self addChild:posIn360Label];
        
        //add motion manager
        self.motionManager = [[[CMMotionManager alloc] init] autorelease];
        motionManager.deviceMotionUpdateInterval = 1.0/60.0;
        if (motionManager.isDeviceMotionAvailable) {
            [motionManager startDeviceMotionUpdates];
        }
        
        [self scheduleUpdate];
        
        batchNode = [CCSpriteBatchNode batchNodeWithFile:@"Sprites.pvr.ccz"];
        [self addChild:batchNode];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Sprites.plist"];
        
        
        // Loop through 1 - 5 and add space ships
        enemySprites = [[NSMutableArray alloc] init];
        for(int i = 0; i < 5; ++i) {
            EnemyShip *enemyShip = [self addEnemyShip:i];
            [enemySprites addObject:enemyShip];
            enemyCount += 1;
        }
        
    
	}
	return self;
}


-(EnemyShip *)addEnemyShip:(int)shipTag
{
    EnemyShip *enemyShip = [EnemyShip spriteWithSpriteFrameName:@"enemy_spaceship.png"];
    
    int x = arc4random() % 360;
    enemyShip.yawPosition = x;
    
    [enemyShip setPosition:ccp(5000, 160)];
    
    enemyShip.timeToLive = kTimeToLive;
    enemyShip.visible = YES;
    
    [batchNode addChild:enemyShip z:3 tag:shipTag];
    
    return enemyShip;
    
}

-(void)checkEnemyShipPosition:(EnemyShip *)enemyShip withYaw:(float)yawPosition
{
    int positionIn360 = yawPosition;
    if (positionIn360 < 0) {
        positionIn360 = 360 + positionIn360;
    }
    
    BOOL checkAlternateRange = NO;
    int rangeMin = positionIn360 - 23;
    if (rangeMin < 0) {
        rangeMin = 360 + rangeMin;
        checkAlternateRange = YES;
        
    }
    
    int rangeMax = positionIn360 + 23;
    if (rangeMax > 360) {
        rangeMax = rangeMax - 360;
        checkAlternateRange = YES;
    }
    
    if (checkAlternateRange) {
        if ((enemyShip.yawPosition < rangeMax || enemyShip.yawPosition > rangeMin ) || (enemyShip.yawPosition > rangeMin || enemyShip.yawPosition < rangeMax)) {
            [self updateEnemyShipPosition:positionIn360 withEnemy:enemyShip];
        }        
    } else {
        if (enemyShip.yawPosition > rangeMin && enemyShip.yawPosition < rangeMax) {
            [self updateEnemyShipPosition:positionIn360 withEnemy:enemyShip];
        } 
    }
    
}


-(void)updateEnemyShipPosition:(int)positionIn360 withEnemy:(EnemyShip *)enemyShip {
    int difference = 0;
    if (positionIn360 < 23) {
        // Run 1
        if (enemyShip.yawPosition > 337) {
            difference = (360 - enemyShip.yawPosition) + positionIn360;
            int xPosition = 240 + (difference * kXPositionMultiplier);
            [enemyShip setPosition:ccp(xPosition, enemyShip.position.y)];
        } else {
            // Run Standard Position Check
            [self runStandardPositionCheck:positionIn360 withDiff:difference withEnemy:enemyShip];
        }
    } else if(positionIn360 > 337) {
        // Run 2
        if (enemyShip.yawPosition < 23) {
            difference = enemyShip.yawPosition + (360 - positionIn360);
            int xPosition = 240 - (difference * kXPositionMultiplier);
            [enemyShip setPosition:ccp(xPosition, enemyShip.position.y)];
        } else {
            // Run Standard Position Check
            [self runStandardPositionCheck:positionIn360 withDiff:difference withEnemy:enemyShip];
        }
    } else {
        // Run Standard Position Check
        [self runStandardPositionCheck:positionIn360 withDiff:difference withEnemy:enemyShip];
    }
}

-(void)runStandardPositionCheck:(int)positionIn360 withDiff:(int)difference withEnemy:(EnemyShip *)enemyShip {
    if (enemyShip.yawPosition > positionIn360) {
        difference = enemyShip.yawPosition - positionIn360;
        int xPosition = 240 - (difference * kXPositionMultiplier);
        [enemyShip setPosition:ccp(xPosition, enemyShip.position.y)];
    } else {
        difference = positionIn360 - enemyShip.yawPosition;
        int xPosition = 240 + (difference * kXPositionMultiplier);
        [enemyShip setPosition:ccp(xPosition, enemyShip.position.y)];
    }
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
    [enemySprites release];
}

-(void)update:(ccTime)delta {
    CMDeviceMotion *currentDeviceMotion = motionManager.deviceMotion;
    CMAttitude *currentAttitude = currentDeviceMotion.attitude;
    
    // 1: Convert the radians yaw value to degrees then round up/down
    float yaw = roundf((float)(CC_RADIANS_TO_DEGREES(currentAttitude.yaw)));
    
    // 2: Convert the degrees value to float and use Math function to round the value
    [yawLabel setString:[NSString stringWithFormat:@"Yaw: %.0f", yaw]];
    
    // 3: Convert the yaw value to a value in the range of 0 to 360
    int positionIn360 = yaw;
    if (positionIn360 < 0) {
        positionIn360 = 360 + positionIn360;
    }
    
    [posIn360Label setString:[NSString stringWithFormat:@"360Pos: %d", positionIn360]];
    
    for (EnemyShip *enemyShip in enemySprites) {
        [self checkEnemyShipPosition:enemyShip withYaw:yaw];
    }
}
@end
