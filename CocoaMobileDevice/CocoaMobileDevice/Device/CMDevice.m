//  CMDevice.m
//  CocoaMobileDevice
//
//  Created by Liam Nichols on 29/05/2014.
//  Copyright (c) 2014 Liam Nichols. All rights reserved.
//

#import "CMDevice.h"
#import "CMPlistSerialization.h"
#import "CMCrashLogManager.h"
#import "CMCrashLogManager-Private.h"
#import "NSError+libmobiledeviceError.h"
#import <libimobiledevice/libimobiledevice.h>
#import <libimobiledevice/lockdown.h>
#import <libimobiledevice/screenshotr.h>
#import <libimobiledevice/file_relay.h>
#import <CocoaMobileDevice/CocoaMobileDevice.h>

//Note: if modifying this list, make sure you update the `knownDomains` array.
NSString *CMDeviceDomainDiskUsage = @"com.apple.disk_usage";
NSString *CMDeviceDomainDiskUsageFactory = @"com.apple.disk_usage.factory";
NSString *CMDeviceDomainBattery = @"com.apple.mobile.battery";
NSString *CMDeviceDomainIQAgent = @"com.apple.iqagent";
NSString *CMDeviceDomainpurplebuddy = @"com.apple.purplebuddy";
NSString *CMDeviceDomainPurpleBuddy = @"com.apple.PurpleBuddy";
NSString *CMDeviceDomainChapterOne = @"com.apple.mobile.chaperone";
NSString *CMDeviceDomainThirdPartyTermination = @"com.apple.mobile.third_party_termination";
NSString *CMDeviceDomainLockdownd = @"com.apple.mobile.lockdownd";
NSString *CMDeviceDomainLockdowndCache = @"com.apple.mobile.lockdown_cache";
NSString *CMDeviceDomainDeveloper = @"com.apple.xcode.developerdomain";
NSString *CMDeviceDomainInternational = @"com.apple.international";
NSString *CMDeviceDomainDataSync = @"com.apple.mobile.data_sync";
NSString *CMDeviceDomainTetheredSync = @"com.apple.mobile.tethered_sync";
NSString *CMDeviceDomainMobileApplicationUsage = @"com.apple.mobile.mobile_application_usage";
NSString *CMDeviceDomainBackup = @"com.apple.mobile.backup";
NSString *CMDeviceDomainNikita = @"com.apple.mobile.nikita";
NSString *CMDeviceDomainRestriction = @"com.apple.mobile.restriction";
NSString *CMDeviceDomainUserPreferences = @"com.apple.mobile.user_preferences";
NSString *CMDeviceDomainSyncDataClass = @"com.apple.mobile.sync_data_class";
NSString *CMDeviceDomainSoftwareBehavior = @"com.apple.mobile.software_behavior";
NSString *CMDeviceDomainMusicLibraryProcessComands = @"com.apple.mobile.iTunes.SQLMusicLibraryPostProcessCommands";
NSString *CMDeviceDomainAccessories = @"com.apple.mobile.iTunes.accessories";
NSString *CMDeviceDomainInternal = @"com.apple.mobile.internal";
NSString *CMDeviceDomainWirelessLockdown = @"com.apple.mobile.wireless_lockdown";
NSString *CMDeviceDomainFairplay = @"com.apple.fairplay";
NSString *CMDeviceDomainiTunes = @"com.apple.iTunes";
NSString *CMDeviceDomainMobileiTunesStore = @"com.apple.mobile.iTunes.store";
NSString *CMDeviceDomainMobileiTunes = @"com.apple.mobile.iTunes";

@interface CMDevice ()

@property (nonatomic, strong) NSString *UDID;

@property (nonatomic, assign) BOOL connected;

@property (nonatomic, strong) NSString *deviceName;

@end

@implementation CMDevice
{
    lockdownd_client_t client;
    idevice_t phone;
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[CMDevice class]] && [self.UDID isEqualToString:[object UDID]];
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

- (BOOL)connect:(NSError **)error
{
    _connected = NO;
    client = NULL;
    phone = NULL;
    
    idevice_error_t ret = idevice_new(&phone, [self.UDID cStringUsingEncoding:NSUTF8StringEncoding]);
    
    if (ret != IDEVICE_E_SUCCESS)
    {
        if (error) {
            *error = [NSError errorWithDeviceErrorCode:ret];
        }
        return NO;
    }
    
    ret = lockdownd_client_new_with_handshake(phone, &client, "CMDevice");
    
    if (ret != IDEVICE_E_SUCCESS)
    {
        if (error) {
            *error = [NSError errorWithDeviceErrorCode:ret];
        }
        return NO;
    }
    
    _connected = YES;
    return YES;
}

-(BOOL)disconnect
{
    if (client)
    {
        lockdownd_client_free(client);
        client = NULL;
    }
    
    if (phone)
    {
        idevice_free(phone);
        phone = NULL;
    }
    
    _connected = NO;
    return YES;
}

#pragma mark - reading

-(id)readDomain:(NSString *)domain error:(NSError *__autoreleasing *)error
{
    return [self readDomain:domain key:nil error:error];
}

-(id)readDomain:(NSString *)domain key:(NSString *)key error:(NSError *__autoreleasing *)error
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

    lockdownd_error_t rtn = lockdownd_get_value(client, cDomain, cKey, &node);
    if(rtn == LOCKDOWN_E_SUCCESS)
    {
        if (node)
        {
            id response = [CMPlistSerialization plistObjectFromNode:node error:nil];
            return response;
            
            plist_free(node);
            node = NULL;
        }
    }

    if (error) {
        *error = [NSError errorWithLockdownErrorCode:rtn];
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
            lockdownd_error_t rtn = lockdownd_set_value(client, cDomain, cKey, node);
            if (rtn == LOCKDOWN_E_SUCCESS)
            {
                return YES;
            }
            else
            {
                //error about code.
                *error = [NSError errorWithLockdownErrorCode:rtn];
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
    NSError *error = nil;
    NSString *name = [self readDomain:nil key:@"DeviceName" error:&error];
    self.deviceName = name;

    if (error)
    {
        NSLog(@"failed to read device name due to error: %@", error);
    }

    return name != nil;
}

#pragma mark - Debugging

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@ %p UDID: %@; connected: %@; deviceName: %@>",self.className, self, self.UDID, self.connected ? @"YES" : @"NO", self.deviceName];
}

#pragma mark - Screenshot

-(NSData *)getScreenshot:(NSError *__autoreleasing *)error
{
    NSData *data = nil;
    
    lockdownd_service_descriptor_t service = NULL;
    screenshotr_client_t shotr = NULL;
    
    lockdownd_error_t rtn = lockdownd_start_service(client, "com.apple.mobile.screenshotr", &service);
    if (rtn == LOCKDOWN_E_SUCCESS)
    {
        if (service && service->port > 0)
        {
            screenshotr_error_t err = screenshotr_client_new(phone, service, &shotr);
            if (err == SCREENSHOTR_E_SUCCESS)
            {
                char *imgdata = NULL;
                uint64_t imgsize = 0;
                err = screenshotr_take_screenshot(shotr, &imgdata, &imgsize);

                if (err == SCREENSHOTR_E_SUCCESS)
                {
                    data = [NSData dataWithBytes:imgdata length:imgsize];
                }
                else
                {
                    *error = [NSError errorWithScreenshorErrorCode:err];
                }
            }
            else
            {
                *error = [NSError errorWithScreenshorErrorCode:err];
            }
            
            if (shotr)
                screenshotr_client_free(shotr);
            lockdownd_service_descriptor_free(service);
        }
        else
        {
            *error = [NSError errorWithScreenshorErrorCode:SCREENSHOTR_E_UNKNOWN_ERROR];
        }
    }
    else
    {
        *error = [NSError errorWithLockdownErrorCode:rtn];
    }
    
    return data;
}

#pragma mark - Crash Logs

- (BOOL)reloadDeviceCrashLogs:(NSError *__autoreleasing *)error
{
    lockdownd_service_descriptor_t service = NULL;
    const char *sources[] = {"CrashReporter", NULL};
    idevice_connection_t dump = NULL;
    file_relay_client_t frc = NULL;
    
    //start a new file relay service.
    if ((lockdownd_start_service(client, "com.apple.mobile.file_relay", &service) != LOCKDOWN_E_SUCCESS) || !service) {
        if (error) {
            *error = [NSError new]; //TODO: make error.
        }
        return NO;
    }
    
    //create the relay client
    if (file_relay_client_new(phone, service, &frc) != FILE_RELAY_E_SUCCESS) {
        if (error) {
            *error = [NSError new]; //TODO: make error.
        }
        return NO;
    }
    
    //request the CrashReporter sources
    if (file_relay_request_sources(frc, sources, &dump) != FILE_RELAY_E_SUCCESS) {
        if (error) {
            *error = [NSError new]; //TODO: make error.
        }
        return NO;
    }
    
    //verify the connection has been made.
    if (!dump) {
        if (error) {
            *error = [NSError new]; //TODO: make error.
        }
        return NO;
    }
    
    uint32_t cnt = 0;
    uint32_t len = 0;
    char buf[4096];
    char* dumpTmpFile = tmpnam(NULL);
    FILE *f = fopen(dumpTmpFile, "w");
    
    //receiving file
    while (idevice_connection_receive(dump, buf, 4096, &len) == IDEVICE_E_SUCCESS) {
        fwrite(buf, 1, len, f);
        cnt += len;
        len = 0;
    }
    fclose(f);
    
    //unarchiving
    BOOL result = [CMCrashLogManager importCrashLogArchiveAtPath:[NSString stringWithCString:dumpTmpFile encoding:NSUTF8StringEncoding] forDevice:self error:error];
    
    return result;
}

#pragma mark - Misc

+ (NSArray *)knownDomains
{
    static NSArray *domains = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        domains = @[
            CMDeviceDomainDiskUsage,
            CMDeviceDomainDiskUsageFactory,
            CMDeviceDomainBattery,
            CMDeviceDomainIQAgent,
            CMDeviceDomainpurplebuddy,
            CMDeviceDomainPurpleBuddy,
            CMDeviceDomainChapterOne,
            CMDeviceDomainThirdPartyTermination,
            CMDeviceDomainLockdownd,
            CMDeviceDomainLockdowndCache,
            CMDeviceDomainDeveloper,
            CMDeviceDomainInternational,
            CMDeviceDomainDataSync,
            CMDeviceDomainTetheredSync,
            CMDeviceDomainMobileApplicationUsage,
            CMDeviceDomainBackup,
            CMDeviceDomainNikita,
            CMDeviceDomainRestriction,
            CMDeviceDomainUserPreferences,
            CMDeviceDomainSyncDataClass,
            CMDeviceDomainSoftwareBehavior,
            CMDeviceDomainMusicLibraryProcessComands,
            CMDeviceDomainAccessories,
            CMDeviceDomainInternal,
            CMDeviceDomainWirelessLockdown,
            CMDeviceDomainFairplay,
            CMDeviceDomainiTunes,
            CMDeviceDomainMobileiTunesStore,
            CMDeviceDomainMobileiTunes
        ];
    });
    return domains;
}

+ (BOOL)isDomainKnown:(NSString *)domain
{
    if (domain && ![[self knownDomains] containsObject:domain])
    {
        return NO;
    }
    return YES;
}

@end
