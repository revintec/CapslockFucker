//
//  App.m
//  CapslockFucker
//
//  Created by revin on Dec.7,2014.
//  Copyright (c) 2014 revin. All rights reserved.
//

#import "App.h"
#import "AppDelegate.h"

@implementation App
-(void)sendEvent:(NSEvent*)ev{
    [super sendEvent:ev];
    if(NSFlagsChanged!=[ev type]||[NSEvent modifierFlags])return;
    [(id)[self delegate]backToRAP];
}
@end
