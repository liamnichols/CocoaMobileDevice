//
//  CMDeviceManger.h
//  CocoaMobileDevice
//
//  Created by Liam Nichols on 29/05/2014.
//  Copyright (c) 2014 Liam Nichols. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const CMDeviceMangerDeviceAddedNotification;
FOUNDATION_EXPORT NSString *const CMDeviceMangerDeviceRemovedNotification;
FOUNDATION_EXPORT NSString *const CMDeviceMangerNotificationDeviceKey;

@interface CMDeviceManger : NSObject

+ (instancetype)sharedManager;

- (NSArray *)readConnectedDeviceUDIDs;

@property (nonatomic, readonly, getter = isSubscribed) BOOL subscribed;

- (BOOL)subscribe:(NSError **)error;

- (BOOL)unsubscribe:(NSError **)error;

- (NSArray *)devices;

@end
