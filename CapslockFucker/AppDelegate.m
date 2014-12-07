//
//  AppDelegate.m
//  KillZombies
//
//  Created by revin on Dec.3,2014.
//  Copyright (c) 2014 revin. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate()

@property (weak)IBOutlet NSWindow*window;
@property int activationIndicator;
@property NSRunningApplication*rap;
@end

@implementation AppDelegate
-(void)backToRAP{
    if(!self.rap)return;
    [self.rap activateWithOptions:NSApplicationActivateAllWindows|NSApplicationActivateIgnoringOtherApps];
    self.rap=nil;
}
-(void)someotherAppGotActivated:(NSNotification*)notification{
    if(self.activationIndicator){
        --self.activationIndicator;
        return;
    }
    NSDictionary*_n=[notification userInfo];if(_n==nil)return;
    NSRunningApplication*ra=[_n objectForKey:NSWorkspaceApplicationKey];if(ra==nil)return;
    NSString*name=[ra localizedName];
    if(![@"IntelliJ IDEA" isEqual:name]||![NSEvent modifierFlags])return;
    self.rap=ra;
    [NSApp performSelector:@selector(activateIgnoringOtherApps:) withObject:@YES afterDelay:0.3];
    [self.window center];
    self.activationIndicator=2; // one for our self, one for whatever got activated next
}
-(void)applicationWillBecomeActive:(NSNotification*)notification{
    ProcessSerialNumber psn={0,kCurrentProcess};
    TransformProcessType(&psn,kProcessTransformToForegroundApplication);
    [self.window makeKeyAndOrderFront:nil];
}
-(IBAction)buttonTapped:(NSButton*)sender
{
    [NSApp terminate:self];
}
-(void)applicationDidResignActive:(NSNotification*)notification{
    ProcessSerialNumber psn={0,kCurrentProcess};
    TransformProcessType(&psn,kProcessTransformToUIElementApplication);
}
-(void)applicationDidFinishLaunching:(NSNotification*)notification{
    NSNotificationCenter*ncc=[[NSWorkspace sharedWorkspace]notificationCenter];
    [ncc addObserver:self selector:@selector(someotherAppGotActivated:) name:NSWorkspaceDidActivateApplicationNotification object:nil];
}
-(void)applicationWillTerminate:(NSNotification*)notification{
    // Insert code here to tear down your application
}
-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)theApplication{
    return false;
}
@end
