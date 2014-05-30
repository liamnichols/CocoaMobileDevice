//
//  CMDevice.h
//  CocoaMobileDevice
//
//  Created by Liam Nichols on 29/05/2014.
//  Copyright (c) 2014 Liam Nichols. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * CMDeviceReadDomainDiskUsage;
FOUNDATION_EXPORT NSString * CMDeviceReadDomainBattery;
FOUNDATION_EXPORT NSString * CMDeviceReadDomainDeveloper;
FOUNDATION_EXPORT NSString * CMDeviceReadDomainInternational;
FOUNDATION_EXPORT NSString * CMDeviceReadDomainDataSync;
FOUNDATION_EXPORT NSString * CMDeviceReadDomainTetheredSync;
FOUNDATION_EXPORT NSString * CMDeviceReadDomainMobileApplicationUsage;
FOUNDATION_EXPORT NSString * CMDeviceReadDomainBackup;
FOUNDATION_EXPORT NSString * CMDeviceReadDomainNikita;
FOUNDATION_EXPORT NSString * CMDeviceReadDomainRestriction;
FOUNDATION_EXPORT NSString * CMDeviceReadDomainUserPreferences;
FOUNDATION_EXPORT NSString * CMDeviceReadDomainSyncDataClass;
FOUNDATION_EXPORT NSString * CMDeviceReadDomainSoftwareBehavior;
FOUNDATION_EXPORT NSString * CMDeviceReadDomainMusicLibraryProcessComands;
FOUNDATION_EXPORT NSString * CMDeviceReadDomainAccessories;
FOUNDATION_EXPORT NSString * CMDeviceReadDomainFairplay;
FOUNDATION_EXPORT NSString * CMDeviceReadDomainiTunes;
FOUNDATION_EXPORT NSString * CMDeviceReadDomainMobileiTunesStore;
FOUNDATION_EXPORT NSString * CMDeviceReadDomainMobileiTunes;

@interface CMDevice : NSObject

@property (nonatomic, readonly) NSString *UDID;

- (id)initWithUDID:(NSString *)UDID;

/// @name Connecting

- (BOOL)connect;

/// @name Device Name

- (BOOL)loadDeviceName;

@property (nonatomic, readonly) NSString *deviceName;

/// @name Reading Values

- (id)read;

- (id)readDomain:(NSString *)domain;

- (id)readDomain:(NSString *)domain key:(NSString *)key;

/// @name Writing

- (BOOL)writeValue:(id)value toDomain:(NSString *)domain forKey:(NSString *)key error:(NSError **)error;

@end
