//
//  CMDevice.h
//  CocoaMobileDevice
//
//  Created by Liam Nichols on 29/05/2014.
//  Copyright (c) 2014 Liam Nichols. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  com.apple.disk_usage
 */
FOUNDATION_EXPORT NSString *CMDeviceDomainDiskUsage;

/**
 *  com.apple.disk_usage.factory
 */
FOUNDATION_EXPORT NSString *CMDeviceDomainDiskUsageFactory;

/**
 *  com.apple.mobile.battery
 */
FOUNDATION_EXPORT NSString *CMDeviceDomainBattery;

/**
 *  com.apple.iqagent
 */
FOUNDATION_EXPORT NSString *CMDeviceDomainIQAgent;

/**
 *  com.apple.purplebuddy
 */
FOUNDATION_EXPORT NSString *CMDeviceDomainpurplebuddy;

/**
 *  com.apple.PurpleBuddy
 */
FOUNDATION_EXPORT NSString *CMDeviceDomainPurpleBuddy;

/**
 *  com.apple.mobile.chaperone
 */
FOUNDATION_EXPORT NSString *CMDeviceDomainChapterOne;

/**
 *  com.apple.mobile.third_party_termination
 */
FOUNDATION_EXPORT NSString *CMDeviceDomainThirdPartyTermination;

/**
 *  com.apple.mobile.lockdownd
 */
FOUNDATION_EXPORT NSString *CMDeviceDomainLockdownd;

/**
 *  com.apple.mobile.lockdown_cache
 */
FOUNDATION_EXPORT NSString *CMDeviceDomainLockdowndCache;

/**
 *  com.apple.xcode.developerdomain
 */
FOUNDATION_EXPORT NSString *CMDeviceDomainDeveloper;

/**
 *  com.apple.international
 */
FOUNDATION_EXPORT NSString *CMDeviceDomainInternational;

/**
 *  com.apple.mobile.data_sync
 */
FOUNDATION_EXPORT NSString *CMDeviceDomainDataSync;

/**
 *  com.apple.mobile.tethered_sync
 */
FOUNDATION_EXPORT NSString *CMDeviceDomainTetheredSync;

/**
 *  com.apple.mobile.mobile_application_usage
 */
FOUNDATION_EXPORT NSString *CMDeviceDomainMobileApplicationUsage;

/**
 *  com.apple.mobile.backup
 */
FOUNDATION_EXPORT NSString *CMDeviceDomainBackup;

/**
 *  com.apple.mobile.nikita
 */
FOUNDATION_EXPORT NSString *CMDeviceDomainNikita;

/**
 *  com.apple.mobile.restriction
 */
FOUNDATION_EXPORT NSString *CMDeviceDomainRestriction;

/**
 *  com.apple.mobile.user_preferences
 */
FOUNDATION_EXPORT NSString *CMDeviceDomainUserPreferences;

/**
 *  com.apple.mobile.sync_data_class
 */
FOUNDATION_EXPORT NSString *CMDeviceDomainSyncDataClass;

/**
 *  com.apple.mobile.software_behavior
 */
FOUNDATION_EXPORT NSString *CMDeviceDomainSoftwareBehavior;

/**
 *  com.apple.mobile.iTunes.SQLMusicLibraryPostProcessCommands
 */
FOUNDATION_EXPORT NSString *CMDeviceDomainMusicLibraryProcessComands;

/**
 *  com.apple.mobile.iTunes.accessories
 */
FOUNDATION_EXPORT NSString *CMDeviceDomainAccessories;

/**
 *  com.apple.mobile.internal
 *  iOS 4 +
 */
FOUNDATION_EXPORT NSString *CMDeviceDomainInternal;

/**
 *  com.apple.mobile.wireless_lockdown
 *  iOS 4 +
 */
FOUNDATION_EXPORT NSString *CMDeviceDomainWirelessLockdown;

/**
 *  com.apple.fairplay
 */
FOUNDATION_EXPORT NSString *CMDeviceDomainFairplay;

/**
 *  com.apple.iTunes
 */
FOUNDATION_EXPORT NSString *CMDeviceDomainiTunes;

/**
 *  com.apple.mobile.iTunes.store
 */
FOUNDATION_EXPORT NSString *CMDeviceDomainMobileiTunesStore;

/**
 *  com.apple.mobile.iTunes
 */
FOUNDATION_EXPORT NSString *CMDeviceDomainMobileiTunes;



/**
 *  The CMDevice class handles all communications with the physical device. Objects are generally intialized by the CMDeviceManager with the UDID it detects however you could also manually initalize a CMDevice providing you know the UDID of the device and know that it is connected.
 *
 *  Before you try to interact with the physical device, you must make sure that you are connected to the device. You are also responsible for disconnecting when you have finished making requests to the device.
 *  It has become apparent that if you are connected to the device but idle for more than 20seconds, the connection is broken but libimobiledevice does not inform us about this. This would mean that the CMDevice object thinks that it is still connceted however when making a request, the application will crash with a SIGPIPE error. To avoid this, you must ensure that you disconnect yourself when you have finished requesting information.
 *
 *  Example:
 *      CMDevice *device = ...
 *
 *      if (!device.connected) {
 *          NSError *error = nil;
 *          [device connect:&error];
 *          if (error) {
 *              NSLog(@"Error connecting to device: %@", error);
 *          }
 *      }
 *
 *      NSError *error = nil;
 *      id response = [device readDomain:nil key:nil error:&error]; //reads all the information in the default domain.
 * 
 *      if (error) {
 *          NSLog(@"Error reading from the device: %@", error);
 *      }
 *      else {
 *          NSLog(@"Got response from the device: %@", response);
 *      }
 *
 *      [device disconnect]; //we've finsihed reading from the device so lets disconnect.
 *
 */



@interface CMDevice : NSObject

/**
 *  The UDID of the device this object is related to.
 */
@property (nonatomic, readonly) NSString *UDID;

/**
 *  Initalizes a new CMDevice object with the specific UDID.
 *
 *  @param UDID The UDID of the device.
 *
 *  @return a CMDevice object with the UDID set.
 */
- (id)initWithUDID:(NSString *)UDID;

/// @name Connecting

/**
 *  A Boolean value to represent if a connection has been made to the physical device or not.
 */
@property (nonatomic, readonly) BOOL connected;

/**
 *  Attemts to establish a connection to the lockdownd client on the device.
 *
 *  @warning You are responsible for disconnecting after you have finished requesting/sending information. If the connection is left open and idle for over ~20 seconds the next request can cause a SIGPIPE error. You should always call `-disconnect:` when you have finished.
 *
 *  @param error The error returned if the client failed to connect.
 *
 *  @return YES if the conncetion was successfly made or NO if there was an error.
 */
- (BOOL)connect:(NSError **)error;

/**
 *  Disconnects from the lockdownd client on the device.
 *
 *  @note: This current release does not check for errors and always returns YES however future releases may check for errors.
 *
 *  @return YES if the disconnection was successful or NO if there was an error disconnecting.
 */
- (BOOL)disconnect;

/// @name Device Name

/**
 *  Loads the device name. You are responsible for connecting before calling and disconnecting after.
 *
 *  @return YES if the device name was obtained successfully or NO if there was an error.
 */
- (BOOL)loadDeviceName;

/**
 *  The device name obtained by `loadDeviceName`.
 */
@property (nonatomic, readonly) NSString *deviceName;

/// @name Reading Values

/**
 *  Reads information from the physical device with a specific domain.
 *
 *  Return values are parsed by an internal parser (currently private) and can be a NSString, NSNumber, NSDate, NSData, NSArray or NSDictionary.
 *
 *  @param domain The domain to read from. See CMDevice.h for a list of known domains. You can also pass in nil to get the nil domain info.
 *  @param error  The error returned if the value could not be read
 *
 *  @return returns the value read from the device or nil if there was an error.
 */
- (id)readDomain:(NSString *)domain error:(NSError **)error;

/**
 *  Reads information from the physical device with a specific domain and key.
 *
 *  Return values are parsed by an internal parser (currently private) and can be a NSString, NSNumber, NSDate, NSData, NSArray or NSDictionary.
 *
 *  @param domain The domain to read from. See CMDevice.h for a list of known domains. You can also pass in nil to get the nil domain info.
 *  @param key The specific key to read. If nil is passed in then the whole domain will be read.
 *  @param error
 *
 *  @return returns the value read from the device or nil if there was an error.
 */
- (id)readDomain:(NSString *)domain key:(NSString *)key error:(NSError **)error;

/// @name Writing

/**
 *  Writes information to the physical device.
 *
 *  @param value  The value to be written. Must be an NSString, NSNumber, NSDate, NSData, NSArray or NSDictionary.
 *  @param domain The domain to write to. See CMDevice.h for a list of known domains. You can also pass in nil to write to the nil domain.
 *  @param key    The key to write to within the domain. This must **not** be nil.
 *  @param error  The error returned if the value could not be written
 *
 *  @return YES if the write succeeded or NO if there was an error.
 */
- (BOOL)writeValue:(id)value toDomain:(NSString *)domain forKey:(NSString *)key error:(NSError **)error;

/// @name Screenshot

/**
 *  Takes a screenshot of the content present on the screen of the physical device.
 *  @note For this to work, the device must have the development image mounted (must be used for development by xcode).
 *
 *  @param error The error returned if taking a screenshot failed.
 *
 *  @return The NSData representing the device screenshot.
 */
- (NSData *)getScreenshot:(NSError **)error;

/// @name Misc

/**
 *  An array of known domains. See CMDevice.h for more info.
 *
 *  @return An NSArray of NSString objects representing the know domains.
 */
+ (NSArray *)knownDomains;

/**
 *  Checks if the domain is part of the knownDomains array.
 *
 *  @param domain The domain to check
 *
 *  @return YES if the domain is known or NO if not.
 */
+ (BOOL)isDomainKnown:(NSString *)domain;

@end
