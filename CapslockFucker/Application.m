//
//  AppDelegate.m
//  KillZombies
//
//  Created by revin on Dec.3,2014.
//  Copyright (c) 2014 revin. All rights reserved.
//

#import "Application.h"

@interface Application()
@property NSWindow*window;
@property pid_t pid;
@property NSRunningApplication*rap;
@end

@implementation Application
-(void)finishLaunching{
    self.delegate=self;
    [super finishLaunching];
    self.window=self.windows[0];
    NSControl*v=[self.window contentView];
    v=[v viewWithTag:0];
    [v setTarget:self];
    [v setAction:@selector(quitButtonPressed)];
}
-(void)someotherAppGotActivated:(NSNotification*)notification{
    NSDictionary*_n=[notification userInfo];if(_n==nil)return;
    NSRunningApplication*ra=[_n objectForKey:NSWorkspaceApplicationKey];if(ra==nil)return;
    if(![@"IntelliJ IDEA" isEqual:[ra localizedName]]){
        if([ra processIdentifier]!=self.pid)
            self.rap=nil;
        return;
    }else self.rap=ra;
    if(![NSEvent modifierFlags])return;
    [NSApp performSelector:@selector(activateIgnoringOtherApps:) withObject:@YES afterDelay:0.3];
    [self.window center];
}
-(void)applicationWillBecomeActive:(NSNotification*)notification{
    ProcessSerialNumber psn={0,kCurrentProcess};
    TransformProcessType(&psn,kProcessTransformToForegroundApplication);
    [self.window makeKeyAndOrderFront:nil];
}
-(void)quitButtonPressed{
    [NSApp terminate:self];
}
-(void)applicationDidResignActive:(NSNotification*)notification{
    ProcessSerialNumber psn={0,kCurrentProcess};
    TransformProcessType(&psn,kProcessTransformToUIElementApplication);
}
-(void)sendEvent:(NSEvent*)ev{
    [super sendEvent:ev];
    if(NSFlagsChanged!=[ev type]||[NSEvent modifierFlags])return;
    if(!self.rap)AudioServicesPlayAlertSound(kSystemSoundID_UserPreferredAlert);
    else [self.rap activateWithOptions:NSApplicationActivateAllWindows|NSApplicationActivateIgnoringOtherApps];
}
-(void)applicationDidFinishLaunching:(NSNotification*)notification{
    if(!AXIsProcessTrusted()){
        [self.window close];
        NSAlert*alert=[[NSAlert alloc]init];
        [alert addButtonWithTitle:@"Quit"];
        [alert setMessageText:@"CapslockFucker"];
        [alert setInformativeText:@"Can't acquire Accessibility Permissions"];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert runModal];
        [NSApp terminate:self];
    }else{
        self.pid=getpid();
        NSNotificationCenter*ncc=[[NSWorkspace sharedWorkspace]notificationCenter];
        [ncc addObserver:self selector:@selector(someotherAppGotActivated:) name:NSWorkspaceDidActivateApplicationNotification object:nil];
        [NSEvent addGlobalMonitorForEventsMatchingMask:NSFlagsChangedMask handler:^(NSEvent*ev){
            if(!self.rap)return;
            if([ev modifierFlags]&NSAlphaShiftKeyMask){
                [self.window center];
                [NSApp activateIgnoringOtherApps:true];
            }else [self.rap activateWithOptions:NSApplicationActivateAllWindows|NSApplicationActivateIgnoringOtherApps];
        }];
    }
}
-(void)applicationWillTerminate:(NSNotification*)notification{
    // Insert code here to tear down your application
}
-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)theApplication{
    return false;
}
@end
