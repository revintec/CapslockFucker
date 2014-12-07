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
@property pid_t pid;
@property NSRunningApplication*rap;
@end

@implementation AppDelegate
-(BOOL)backToRAP{
    if(!self.rap)return false;
    [self.rap activateWithOptions:NSApplicationActivateAllWindows|NSApplicationActivateIgnoringOtherApps];
    return true;
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
-(IBAction)buttonTapped:(NSButton*)sender
{
    [NSApp terminate:self];
}
-(void)applicationDidResignActive:(NSNotification*)notification{
    ProcessSerialNumber psn={0,kCurrentProcess};
    TransformProcessType(&psn,kProcessTransformToUIElementApplication);
}
-(void)applicationDidFinishLaunching:(NSNotification*)notification{
    if(!AXIsProcessTrusted()){
        [self.window close];
        NSAlert*alert=[[NSAlert alloc]init];
        [alert addButtonWithTitle:@"Quit"];
        [alert setMessageText:@"Can't acquire Accessibility Permissions"];
        [alert setInformativeText:@"Click Quit to quit"];
        [alert setAlertStyle:NSCriticalAlertStyle];
        [alert runModal];
        [NSApp terminate:self];
    }else{
        self.pid=getpid();
        NSNotificationCenter*ncc=[[NSWorkspace sharedWorkspace]notificationCenter];
        [ncc addObserver:self selector:@selector(someotherAppGotActivated:) name:NSWorkspaceDidActivateApplicationNotification object:nil];
        [NSEvent addGlobalMonitorForEventsMatchingMask:NSFlagsChangedMask handler:^(NSEvent*ev){
            if([ev modifierFlags]&NSAlphaShiftKeyMask&&self.rap){
                [NSApp activateIgnoringOtherApps:true];
                [self.window center];
            }
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
