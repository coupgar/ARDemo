//
//  EnemyShip.h
//  ARDemo
//
//  Created by Xiaobin Chen on 12-3-23.
//  Copyright (c) 2012年 xb. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "cocos2d.h"

@interface EnemyShip : CCSprite {
    int yawPosition;
    int timeToLive;
}

@property (readwrite) int yawPosition;
@property (readwrite) int timeToLive;

@end
