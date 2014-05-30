//
//  AppDelegate.m
//  MobileDevice
//
//  Created by Liam Nichols on 29/05/2014.
//  Copyright (c) 2014 Liam Nichols. All rights reserved.
//

#import "AppDelegate.h"
#import <CocoaMobileDevice/CocoaMobileDevice.h>

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceAddedNotifcation:) name:CMDeviceMangerDeviceAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceRemovedNotifcation:) name:CMDeviceMangerDeviceRemovedNotification object:nil];
    [[CMDeviceManger sharedManager] subscribe:nil];
    
    NSLog(@"subscription status: %@", [[CMDeviceManger sharedManager] isSubscribed] ? @"Subscribed" : @"Unsubscribed");
}

- (void)deviceAddedNotifcation:(NSNotification *)notification
{
    NSLog(@"device added notificaiton triggered: %@", notification.userInfo);
    
    NSString *UDID = [notification.userInfo objectForKey:CMDeviceMangerNotificationDeviceUDIDKey];
    CMDevice *device = [[CMDevice alloc] initWithUDID:UDID];

    if ([device connect])
    {
        [device read];
    }
}

- (void)deviceRemovedNotifcation:(NSNotification *)notification
{
    NSLog(@"device removed notificaiton triggered: %@", notification.userInfo);
}

@end
