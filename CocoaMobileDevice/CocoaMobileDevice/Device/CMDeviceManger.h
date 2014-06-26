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

/**
 *  The CMDeviceManager class provides methods wrapping the libimobiledevice library that allow you to retrieve a list of connected devices along with subscribing for notifcations about device connections and disconnections.
 *  @warning Methods in the CMDeviceManager should only be used through the shared instance obtained by calling `+sharedManager`.
 */

@interface CMDeviceManger : NSObject

/// @name Accessing the Manager

/**
 *  The shared instance of CMDeviceManager used to retrieve information about connected devices.
 *
 *  @return An instance of CMDeviceManager.
 */
+ (instancetype)sharedManager;

/// @name Synchronous Methods

/**
 *  Queries for a list of devices connected to the machine.
 *
 *  @return an NSArray of the UDIDs connected.
 */
- (NSArray *)readConnectedDeviceUDIDs;

/// @name Asynchronous Methods

/**
 *  Indicates if the manager is currently subscribed for notifications when devices are connected or disconnected.
 */
@property (nonatomic, readonly, getter = isSubscribed) BOOL subscribed;

/**
 *  Tells the manager to begin listening for device connection/disconnection notifications.
 *
 *  When the manager is successfully subscribed, you can listen for notifcations via the `NSNotificationCenter` by observing `CMDeviceMangerDeviceAddedNotification` and `CMDeviceMangerDeviceRemovedNotification`.
 *
 *  The notifcation's userInfo dictionary will have a key `CMDeviceMangerNotificationDeviceKey` which contains the `CMDevice` object that has just been added or removed.
 *
 *  @param error An error with information about why the manager failed to subscibe (if there was an error).
 *
 *  @return YES if the manager successfully subcribed or NO if there was an error.
 */
- (BOOL)subscribe:(NSError **)error;

/**
 *  Tells the manager to stop listening for device connection/disconnection notifications.
 *
 *  @param error An error with information about why the manager failed to unsubscibe (if there was an error).
 *
 *  @return YES if the manager successfully unsubcribed or NO if there was an error.
 */
- (BOOL)unsubscribe:(NSError **)error;

/**
 *  The list of devices current connected or disconnected. This array is populated internally by the notifcations that libimobiledevice provide so can be checked for changes after you have received a notification.
 *
 *  @return an NSArray of `CMDevice` objects.
 */
- (NSArray *)devices;

@end
