//  CMDevice.m
//  CocoaMobileDevice
//
//  Created by Liam Nichols on 29/05/2014.
//  Copyright (c) 2014 Liam Nichols. All rights reserved.
//

#import "CMDevice.h"
#import "CMPlistSerialization.h"
#import "NSError+libmobiledeviceError.h"
#import <libimobiledevice/libimobiledevice.h>
#import <libimobiledevice/lockdown.h>

NSString * CMDeviceReadDomainDiskUsage                      = @"com.apple.disk_usage";
NSString * CMDeviceReadDomainBattery                        = @"com.apple.mobile.battery";
NSString * CMDeviceReadDomainDeveloper                      = @"com.apple.xcode.developerdomain";
NSString * CMDeviceReadDomainInternational                  = @"com.apple.international";
NSString * CMDeviceReadDomainDataSync                       = @"com.apple.mobile.data_sync";
NSString * CMDeviceReadDomainTetheredSync                   = @"com.apple.mobile.tethered_sync";
NSString * CMDeviceReadDomainMobileApplicationUsage         = @"com.apple.mobile.mobile_application_usage";
NSString * CMDeviceReadDomainBackup                         = @"com.apple.mobile.backup";
NSString * CMDeviceReadDomainNikita                         = @"com.apple.mobile.nikita";
NSString * CMDeviceReadDomainRestriction                    = @"com.apple.mobile.restriction";
NSString * CMDeviceReadDomainUserPreferences                = @"com.apple.mobile.user_preferences";
NSString * CMDeviceReadDomainSyncDataClass                  = @"com.apple.mobile.sync_data_class";
NSString * CMDeviceReadDomainSoftwareBehavior               = @"com.apple.mobile.software_behavior";
NSString * CMDeviceReadDomainMusicLibraryProcessComands     = @"com.apple.mobile.iTunes.SQLMusicLibraryPostProcessCommands";
NSString * CMDeviceReadDomainAccessories                    = @"com.apple.mobile.iTunes.accessories";
NSString * CMDeviceReadDomainFairplay                       = @"com.apple.fairplay";
NSString * CMDeviceReadDomainiTunes                         = @"com.apple.iTunes";
NSString * CMDeviceReadDomainMobileiTunesStore              = @"com.apple.mobile.iTunes.store";
NSString * CMDeviceReadDomainMobileiTunes                   = @"com.apple.mobile.iTunes";

@interface CMDevice ()

@property (nonatomic, strong) NSString *UDID;

@property (nonatomic, assign) BOOL connected;

@property (nonatomic, strong) NSString *deviceName;

@end

@implementation CMDevice
{
    lockdownd_client_t client;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[CMDevice class]] && [self.UDID isEqualToString:[object UDID]])
    {
        return YES;
    }
    return NO;
};

- (id)initWithUDID:(NSString *)UDID
{
    self = [super init];
    if (self)
    {
        self.UDID = UDID;
    }
    return self;
}

- (BOOL)connect
{
    _connected = NO;
    client = NULL;
    idevice_t phone = NULL;
    
    idevice_error_t ret = idevice_new(&phone, [self.UDID cStringUsingEncoding:NSUTF8StringEncoding]);
    
    if (ret != IDEVICE_E_SUCCESS)
    {
        NSLog(@"trying to create a device with a UDID that is not connceted.");
        return NO;
    }
    
    ret = lockdownd_client_new_with_handshake(phone, &client, "CMDevice");
    
    if (ret != IDEVICE_E_SUCCESS)
    {
        NSLog(@"unable to complete handshake with phone.");
        return NO;
    }
    
    idevice_free(phone);
    
    _connected = YES;
    return YES;
}

-(id)read
{
    return [self readDomain:nil];
}

-(id)readDomain:(NSString *)domain
{
    return [self readDomain:domain key:nil];
}

- (id)readDomain:(NSString *)domain key:(NSString *)key
{
    plist_t node;
    const char *cDomain = NULL;
	const char *cKey = NULL;
    
    if (domain) {
        cDomain = [domain cStringUsingEncoding:NSUTF8StringEncoding];
    }
    
    if (key) {
        cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];
    }
    
    if(lockdownd_get_value(client, cDomain, cKey, &node) == LOCKDOWN_E_SUCCESS)
    {
        if (node)
        {
            id response = [CMPlistSerialization plistObjectFromNode:node error:nil];
            return response;
            
            plist_free(node);
            node = NULL;
        }
    }
    
    return nil;
}

- (BOOL)writeValue:(id)value toDomain:(NSString *)domain forKey:(NSString *)key error:(NSError **)error
{
    NSAssert(key, @"key must be present when writing a value.");
    
    if (key)
    {
        NSError *plistError = nil;
        plist_t node = [CMPlistSerialization nodeWithPlistObject:value error:&plistError];
        const char *cKey = [key cStringUsingEncoding:NSUTF8StringEncoding];;
        const char *cDomain = NULL;
        
        if (domain) {
            cDomain = [domain cStringUsingEncoding:NSUTF8StringEncoding];
        }
        
        if (node)
        {
            idevice_error_t rtn = lockdownd_set_value(client, cDomain, cKey, node);
            if (rtn == IDEVICE_E_SUCCESS)
            {
                return YES;
            }
            else
            {
                //error about code.
                *error = [NSError errorWithErrorCode:rtn];
                return NO;
            }
            
            plist_free(node);
            node = NULL;
        }
        else
        {
            *error = plistError;
            return NO;
        }
        
    }
    
    //TODO: error about no key.
    return NO;
}

#pragma mark - Device Name

-(BOOL)loadDeviceName
{
    NSString *name = [self readDomain:nil key:@"DeviceName"];
    self.deviceName = name;
    return name != nil;
}

@end
