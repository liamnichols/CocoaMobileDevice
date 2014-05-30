//
//  CMDevice.h
//  CocoaMobileDevice
//
//  Created by Liam Nichols on 29/05/2014.
//  Copyright (c) 2014 Liam Nichols. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *CMDeviceDomainDiskUsage;
FOUNDATION_EXPORT NSString *CMDeviceDomainBattery;
FOUNDATION_EXPORT NSString *CMDeviceDomainDeveloper;
FOUNDATION_EXPORT NSString *CMDeviceDomainInternational;
FOUNDATION_EXPORT NSString *CMDeviceDomainDataSync;
FOUNDATION_EXPORT NSString *CMDeviceDomainTetheredSync;
FOUNDATION_EXPORT NSString *CMDeviceDomainMobileApplicationUsage;
FOUNDATION_EXPORT NSString *CMDeviceDomainBackup;
FOUNDATION_EXPORT NSString *CMDeviceDomainNikita;
FOUNDATION_EXPORT NSString *CMDeviceDomainRestriction;
FOUNDATION_EXPORT NSString *CMDeviceDomainUserPreferences;
FOUNDATION_EXPORT NSString *CMDeviceDomainSyncDataClass;
FOUNDATION_EXPORT NSString *CMDeviceDomainSoftwareBehavior;
FOUNDATION_EXPORT NSString *CMDeviceDomainMusicLibraryProcessComands;
FOUNDATION_EXPORT NSString *CMDeviceDomainAccessories;
FOUNDATION_EXPORT NSString *CMDeviceDomainFairplay;
FOUNDATION_EXPORT NSString *CMDeviceDomainiTunes;
FOUNDATION_EXPORT NSString *CMDeviceDomainMobileiTunesStore;
FOUNDATION_EXPORT NSString *CMDeviceDomainMobileiTunes;

@interface CMDevice : NSObject

@property (nonatomic, readonly) NSString *UDID;

- (id)initWithUDID:(NSString *)UDID;

/// @name Connecting

- (BOOL)connect;

/// @name Device Name

- (BOOL)loadDeviceName;

@property (nonatomic, readonly) NSString *deviceName;

/// @name Reading Values

- (id)readDomain:(NSString *)domain;

- (id)readDomain:(NSString *)domain key:(NSString *)key;

/// @name Writing

- (BOOL)writeValue:(id)value toDomain:(NSString *)domain forKey:(NSString *)key error:(NSError **)error;

@end
