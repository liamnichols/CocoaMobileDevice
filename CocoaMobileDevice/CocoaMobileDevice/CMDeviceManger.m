//
//  CMDeviceManger.m
//  CocoaMobileDevice
//
//  Created by Liam Nichols on 29/05/2014.
//  Copyright (c) 2014 Liam Nichols. All rights reserved.
//

#import "CMDeviceManger.h"
#import "CMDevice.h"
#import <libimobiledevice/libimobiledevice.h>
#import <libimobiledevice/lockdown.h>

NSString *const CMDeviceMangerDeviceAddedNotification = @"CMDeviceMangerDeviceAddedNotification";
NSString *const CMDeviceMangerDeviceRemovedNotification = @"CMDeviceMangerDeviceRemovedNotification";
NSString *const CMDeviceMangerNotificationDeviceKey = @"CMDevice";

@interface CMDeviceManger ()

@property (nonatomic, assign, getter = isSubscribed) BOOL subscribed;

@property (nonatomic, strong) NSMutableArray *asyncDevices;

- (void)handleEventCallback:(const idevice_event_t *)event;

@end

@implementation CMDeviceManger

+ (instancetype)sharedManager
{
    static CMDeviceManger *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CMDeviceManger alloc] init];
    });
    return manager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.subscribed = NO;
    }
    return self;
}

- (NSArray *)readConnectedDeviceUDIDs
{
    char **dev_list = NULL;
	int i;
    
    idevice_error_t error = idevice_get_device_list(&dev_list, &i);
    if (error < 0)
    {
        NSLog(@"idevice_get_device_list() returned error %i", error);
        return nil;
    }
    
    NSMutableArray *udids = [NSMutableArray arrayWithCapacity:i];
    
    for (i = 0; dev_list[i] != NULL; i++)
    {
        NSString *udid = [[NSString alloc] initWithCString:dev_list[i] encoding:NSUTF8StringEncoding];
        [udids addObject:udid];
    }
    
    idevice_device_list_free(dev_list);
    
    return [udids copy];
}

-(BOOL)subscribe:(NSError **)error
{
    if (!self.isSubscribed)
    {
        [self.asyncDevices removeAllObjects];
        idevice_error_t errCode = idevice_event_subscribe(coreEventCallback, NULL);
        if (error < 0)
        {
            self.subscribed = NO; //TODO: if subscribing fails, does that mean we're not subscribed?
            NSLog(@"got error subscribing: %i", errCode);
            return NO;
        }
        self.subscribed = YES;
        return YES;
    }
    return YES;
}

-(BOOL)unsubscribe:(NSError **)error
{
    if (self.isSubscribed)
    {
        idevice_error_t errCode = idevice_event_unsubscribe();
        if (error < 0)
        {
            NSLog(@"got error unsubscribing: %i", errCode);
            return NO;
        }
        [self.asyncDevices removeAllObjects];
        self.subscribed = NO;
        return YES;
    }
    return YES;
}

void coreEventCallback (const idevice_event_t *event, void *user_data)
{
    [[CMDeviceManger sharedManager] handleEventCallback:event];
}

-(void)handleEventCallback:(const idevice_event_t *)event
{
    NSString *udid = [[NSString alloc] initWithCString:event->udid encoding:NSUTF8StringEncoding];
    CMDevice *device = [[CMDevice alloc] initWithUDID:udid];
    if (event->event == IDEVICE_DEVICE_ADD)
    {
        [self deviceAdded:device];
        [[NSNotificationCenter defaultCenter] postNotificationName:CMDeviceMangerDeviceAddedNotification
                                                            object:nil
                                                          userInfo:@{ CMDeviceMangerNotificationDeviceKey : device }];
    }
    else if (event->event == IDEVICE_DEVICE_REMOVE)
    {
        [self deviceRemoved:device];
        [[NSNotificationCenter defaultCenter] postNotificationName:CMDeviceMangerDeviceRemovedNotification
                                                            object:nil
                                                          userInfo:@{ CMDeviceMangerNotificationDeviceKey : device }];
        
    }
}

#pragma mark - Keeping Track of Devices.

- (void)deviceAdded:(CMDevice *)device
{
    if (![self.asyncDevices containsObject:device])
    {
        [self.asyncDevices addObject:device];
    }
}

- (void)deviceRemoved:(CMDevice *)device
{
    if ([self.asyncDevices containsObject:device])
    {
        [self.asyncDevices removeObject:device];
    }
}

-(NSArray *)devices
{
    return self.asyncDevices;
}

-(NSMutableArray *)asyncDevices
{
    if (!_asyncDevices)
    {
        _asyncDevices = [NSMutableArray array];
    }
    return _asyncDevices;
}

@end
