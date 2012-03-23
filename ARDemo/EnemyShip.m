//
//  EnemyShip.m
//  ARDemo
//
//  Created by Xiaobin Chen on 12-3-23.
//  Copyright (c) 2012年 xb. All rights reserved.
//

#import "EnemyShip.h"


@implementation EnemyShip

@synthesize yawPosition, timeToLive;

-(id)init {
    self = [super init];
    if (self){ 
        yawPosition = 0;
        timeToLive = 0;
	}
    return self;
}

@end