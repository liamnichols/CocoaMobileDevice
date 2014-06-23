//
//  CMCrashLogManager.m
//  CocoaMobileDevice
//
//  Created by Liam Nichols on 22/06/2014.
//  Copyright (c) 2014 Liam Nichols. All rights reserved.
//
 
#import "CMCrashLogManager.h"
#import "CMCrashLogManager-Private.h"
#import "CMDevice.h"
#import <archive.h>
#import <archive_entry.h>

@interface _CMCrashLogStorageLocationManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, copy) NSString *storageLocation;

@end

@implementation _CMCrashLogStorageLocationManager

+ (instancetype)sharedManager
{
    static _CMCrashLogStorageLocationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [_CMCrashLogStorageLocationManager new];
    });
    return manager;
}

@end

@interface CMCrashLogManager ()

@property (nonatomic, strong) CMDevice *device;

@property (nonatomic, strong) NSDictionary *directoryListing;
@property (nonatomic, strong) NSDate *lastUpdated;

@end

@implementation CMCrashLogManager

#pragma mark - Storage Location

+ (void)setStorageLocation:(NSString *)location
{
    [[_CMCrashLogStorageLocationManager sharedManager] setStorageLocation:location];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:location]) {
        NSError *error = nil;
        BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:location withIntermediateDirectories:YES attributes:nil error:&error];
        NSAssert(result, @"error creating direcotry at location: %@ error: %@", location, error);
    }
}

+ (NSString *)storageLocation
{
    return [[_CMCrashLogStorageLocationManager sharedManager] storageLocation];
}

+ (void)verifyLocationAndAssertIfNeeded
{
    NSAssert([self storageLocation], @"[CMCrashLogManager setStorageLocation:] must be called before using the crash log manager.");
    
    BOOL canWrite = [[NSFileManager defaultManager] isWritableFileAtPath:[self storageLocation]];
    NSAssert(canWrite, @"CMCrashLogManager is not able to write to the storage location specified (%@)", [self storageLocation]);
}

#pragma mark - Private

+ (BOOL)importCrashLogArchiveAtPath:(NSString *)path forDevice:(CMDevice *)device error:(NSError *__autoreleasing *)error
{
    [self verifyLocationAndAssertIfNeeded];
    NSAssert(device.UDID, @"must supply a device with a UDID");
    
    NSString *tempDir = [NSString stringWithCString:tmpnam(NULL) encoding:NSUTF8StringEncoding];
    [[NSFileManager defaultManager] createDirectoryAtPath:tempDir withIntermediateDirectories:YES attributes:nil error:nil];
    
    //TODO: do we need to reset this?
    chdir([tempDir cStringUsingEncoding:NSUTF8StringEncoding]);
    
    const char *filename = [path cStringUsingEncoding:NSUTF8StringEncoding];
    struct archive *a;
    struct archive *ext;
    struct archive_entry *entry;
    int r;
    
    a = archive_read_new();
    ext = archive_write_disk_new();
    archive_write_disk_set_options(ext, ARCHIVE_EXTRACT_TIME);
    archive_read_support_compression_gzip(a);
    archive_read_support_format_cpio(a);
    
    if ((r = archive_read_open_filename(a, filename, 10240)))
    {
        NSLog(@"error: %s", archive_error_string(a));
        return NO;
    }
    
    for (;;)
    {
        r = archive_read_next_header(a, &entry);

        if (r == ARCHIVE_EOF)
        {
            break;
        }
        
        if (r != ARCHIVE_OK)
        {
            NSLog(@"error: %s", archive_error_string(a));
            return NO;
        }
        
        r = archive_write_header(ext, entry);
        
//        NSLog(@"extracting: %s", archive_entry_pathname(entry));
        
        if (r != ARCHIVE_OK)
        {
            NSLog(@"error: %s", archive_error_string(a));
            return NO;
        }
        else
        {
            copy_data(a, ext);
            r = archive_write_finish_entry(ext);
            if (r != ARCHIVE_OK)
            {
                NSLog(@"error: %s", archive_error_string(a));
                return NO;
            }
        }
    }
    
    archive_read_close(a);
    archive_read_finish(a);
    archive_write_finish(ext);
    
    //we've extracted everything... now to fish out the crash logs, index them and move them to the right directory.
    BOOL success = [self findAndIndexCrashLogsInDirectory:tempDir forDevice:device error:error];
    
    [[NSFileManager defaultManager] removeItemAtPath:tempDir error:nil];
    
    return success;
}

+ (BOOL)findAndIndexCrashLogsInDirectory:(NSString *)directory forDevice:(CMDevice *)device error:(NSError *__autoreleasing*)error
{
    NSArray *crashReports = [self filesMatchingExtension:@[ @"ips", @"ips.synced" ] inDirectory:directory];
    NSString *deviceDirectory = [[self storageLocation] stringByAppendingPathComponent:device.UDID];
    NSMutableArray *crashReportInformation = [NSMutableArray arrayWithCapacity:crashReports.count];

    [[NSFileManager defaultManager] removeItemAtPath:deviceDirectory error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:deviceDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    
    [crashReports enumerateObjectsUsingBlock:^(NSString *filePath, NSUInteger idx, BOOL *stop) {
       
        NSData *rawCrashData = [NSData dataWithContentsOfFile:filePath];
        NSRange eoj = [rawCrashData rangeOfData:[NSData dataWithBytes:(Byte[1]){ 0x0A } length:1] options:0 range:NSMakeRange(0, rawCrashData.length)];
        
        NSRange jsonRange = NSMakeRange(0, eoj.location);
        NSRange crashRange = NSMakeRange(eoj.location + eoj.length, rawCrashData.length - (eoj.location + eoj.length));
        
        NSData *jsonData = [rawCrashData subdataWithRange:jsonRange];
        NSData *crashData = [rawCrashData subdataWithRange:crashRange];
        
        NSString *fileName = [filePath lastPathComponent];
        fileName = [fileName stringByReplacingOccurrencesOfString:@".ips.synced" withString:@""];
        fileName = [fileName stringByReplacingOccurrencesOfString:@".ips" withString:@""];
        fileName = [fileName stringByAppendingString:@".crash"];
        
        NSMutableDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        [jsonObject setObject:fileName forKey:@"cmd_filename"];
        
        [crashReportInformation addObject:jsonObject];
        
        [crashData writeToFile:[deviceDirectory stringByAppendingPathComponent:fileName] atomically:YES];
    }];
    
    
    NSData *jsonInfo = [NSJSONSerialization dataWithJSONObject:@{
        @"crashes" : crashReportInformation,
        @"updated" : @([NSDate timeIntervalSinceReferenceDate]),
        @"device" : device.UDID
    } options:0 error:nil];
    
    [jsonInfo writeToFile:[deviceDirectory stringByAppendingPathComponent:@"directory_listing.json"] atomically:YES];
    
    return YES;
}

+ (NSArray *)filesMatchingExtension:(NSArray *)extensions inDirectory:(NSString *)directory
{
    NSMutableArray *files = [NSMutableArray array];
    
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:nil])
    {
        NSString *filePath = [directory stringByAppendingPathComponent:file];
        BOOL isDirectory;
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory]) {
            
            if (isDirectory) {
                [files addObjectsFromArray:[self filesMatchingExtension:extensions inDirectory:filePath]];
            }
            else
            {
                for (NSString *extension in extensions)
                {
                    if ([file hasSuffix:extension]) {
                        [files addObject:filePath];
                    }
                }
            }
            
        }
    }
    
    return [files copy];
}

static int
copy_data(struct archive *ar, struct archive *aw)
{
    int r;
    const void *buff;
    size_t size;
#if ARCHIVE_VERSION_NUMBER >= 3000000
    int64_t offset;
#else
    off_t offset;
#endif
    
    for (;;) {
        r = archive_read_data_block(ar, &buff, &size, &offset);
        if (r == ARCHIVE_EOF)
            return (ARCHIVE_OK);
        if (r != ARCHIVE_OK)
            return (r);
        
        r = archive_write_data_block(aw, buff, size, offset);
        if (r != ARCHIVE_OK)
        {
            NSLog(@"error: %s", archive_error_string(aw));
            return r;
        }
    }
}

#pragma mark - Reading Logs

- (instancetype)initWithDevice:(CMDevice *)device
{
    self = [super init];
    if (self)
    {
        [[self class] verifyLocationAndAssertIfNeeded];
        
        self.device = device;
        
        [self loadDirectoryListing];
    }
    return self;
}

- (void)loadDirectoryListing
{
    NSString *path = [[[CMCrashLogManager storageLocation] stringByAppendingPathComponent:self.device.UDID] stringByAppendingPathComponent:@"directory_listing.json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    if (data) {
        self.directoryListing = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        self.lastUpdated = [NSDate dateWithTimeIntervalSinceReferenceDate:[[self.directoryListing objectForKey:@"updated"] doubleValue]];
    }
}

- (BOOL)hasCrashLogs
{
    return self.directoryListing != nil;
}

- (NSArray *)crashLogMetadata
{
    return [self.directoryListing objectForKey:@"crashes"];
}

- (NSURL *)crashLogLocation:(NSString *)name
{
    NSString *path = [[[CMCrashLogManager storageLocation] stringByAppendingPathComponent:self.device.UDID] stringByAppendingPathComponent:name];
    return [NSURL fileURLWithPath:path];
}

- (NSArray *)crashLogBundleIdentifiers
{
    NSArray *bundleIDs = [[self crashLogMetadata] valueForKeyPath:@"@distinctUnionOfObjects.bundleID"];
    return bundleIDs;
}

@end

@implementation NSDictionary (CMCrashLogManager)

- (NSString *)crashLogName
{
    return [self objectForKey:@"cmd_filename"];
}

@end
