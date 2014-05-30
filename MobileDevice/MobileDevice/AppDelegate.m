//
//  AppDelegate.m
//  MobileDevice
//
//  Created by Liam Nichols on 29/05/2014.
//  Copyright (c) 2014 Liam Nichols. All rights reserved.
//

#import "AppDelegate.h"
#import <CocoaMobileDevice/CocoaMobileDevice.h>

@interface AppDelegate ()

@property (nonatomic, strong) NSMutableArray *udids;
@property (nonatomic, strong) NSMutableDictionary *deviceNames;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.textView.font = [NSFont fontWithName:@"Courier New" size:12.0];
    self.udids = [NSMutableArray array];
    self.deviceNames = [NSMutableDictionary dictionary];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceAddedNotifcation:) name:CMDeviceMangerDeviceAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceRemovedNotifcation:) name:CMDeviceMangerDeviceRemovedNotification object:nil];
    [[CMDeviceManger sharedManager] subscribe:nil];
    
    NSLog(@"subscription status: %@", [[CMDeviceManger sharedManager] isSubscribed] ? @"Subscribed" : @"Unsubscribed");
}

- (void)deviceAddedNotifcation:(NSNotification *)notification
{
    NSString *UDID = [notification.userInfo objectForKey:CMDeviceMangerNotificationDeviceUDIDKey];
    
    if (![self.udids containsObject:UDID])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.udids addObject:UDID];
            
            if (![self.deviceNames objectForKey:UDID])
            {
                CMDevice *device = [[CMDevice alloc] initWithUDID:UDID];
                if ([device connect])
                {
                    id name = [device readDomain:nil key:@"DeviceName"];
                    if (name)
                    {
                        [self.deviceNames setValue:name forKey:UDID];
                    }
                }
            }
            
            [self.tableView reloadData];
        });
    }
}

- (void)deviceRemovedNotifcation:(NSNotification *)notification
{
    NSString *UDID = [notification.userInfo objectForKey:CMDeviceMangerNotificationDeviceUDIDKey];
    
    if ([self.udids containsObject:UDID])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.udids removeObject:UDID];
            [self.tableView reloadData];
        });
    }
}

#pragma mark NSTableView

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.udids.count;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    
    // get an existing cell with the MyView identifier if it exists
    NSTextField *result = [tableView makeViewWithIdentifier:@"MyView" owner:self];
    
    // There is no existing cell to reuse so we will create a new one
    if (result == nil) {
        
        result = [[NSTextField alloc] initWithFrame:CGRectZero];
        [result setBordered:NO];
        [result setSelectable:NO];
        [result setBackgroundColor:[NSColor clearColor]];
        [result setAlignment:NSCenterTextAlignment];
        [result setIdentifier:@"MyView"];
        [result setEditable:NO];
    }
    
    NSString *udid = [self.udids objectAtIndex:row];
    if ([tableColumn.identifier isEqualToString:@"name"])
        result.stringValue = [self.deviceNames objectForKey:udid] ?: @"Unknown";
    
    if ([tableColumn.identifier isEqualToString:@"udid"])
        result.stringValue = udid;
    
    
    // return the result.
    return result;
    
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification
{
    self.textView.string = @"";
    
    NSInteger row = [self.tableView selectedRow];
    
    if (row == -1)
    {
        return;
    }
    
    NSString *selectedUDID = [self.udids objectAtIndex:row];
    
    CMDevice *device = [[CMDevice alloc] initWithUDID:selectedUDID];
    
    if ([device connect])
    {
        NSMutableDictionary *responses = [NSMutableDictionary dictionary];
        
        [responses setObject:[device read] forKey:@"general"];
        [responses setObject:[device readDomain:CMDeviceReadDomainDiskUsage] forKey:CMDeviceReadDomainDiskUsage];
        [responses setObject:[device readDomain:CMDeviceReadDomainBattery] forKey:CMDeviceReadDomainBattery];
        [responses setObject:[device readDomain:CMDeviceReadDomainDeveloper] forKey:CMDeviceReadDomainDeveloper];
        [responses setObject:[device readDomain:CMDeviceReadDomainInternational] forKey:CMDeviceReadDomainInternational];
        [responses setObject:[device readDomain:CMDeviceReadDomainDataSync] forKey:CMDeviceReadDomainDataSync];
        [responses setObject:[device readDomain:CMDeviceReadDomainTetheredSync] forKey:CMDeviceReadDomainTetheredSync];
        [responses setObject:[device readDomain:CMDeviceReadDomainMobileApplicationUsage] forKey:CMDeviceReadDomainMobileApplicationUsage];
        [responses setObject:[device readDomain:CMDeviceReadDomainBackup] forKey:CMDeviceReadDomainBackup];
        [responses setObject:[device readDomain:CMDeviceReadDomainNikita] forKey:CMDeviceReadDomainNikita];
        [responses setObject:[device readDomain:CMDeviceReadDomainRestriction] forKey:CMDeviceReadDomainRestriction];
        [responses setObject:[device readDomain:CMDeviceReadDomainUserPreferences] forKey:CMDeviceReadDomainRestriction];
        [responses setObject:[device readDomain:CMDeviceReadDomainSyncDataClass] forKey:CMDeviceReadDomainRestriction];
        [responses setObject:[device readDomain:CMDeviceReadDomainSoftwareBehavior] forKey:CMDeviceReadDomainSoftwareBehavior];
        [responses setObject:[device readDomain:CMDeviceReadDomainMusicLibraryProcessComands] forKey:CMDeviceReadDomainMusicLibraryProcessComands];
        [responses setObject:[device readDomain:CMDeviceReadDomainAccessories] forKey:CMDeviceReadDomainAccessories];
        [responses setObject:[device readDomain:CMDeviceReadDomainFairplay] forKey:CMDeviceReadDomainFairplay];
        [responses setObject:[device readDomain:CMDeviceReadDomainiTunes] forKey:CMDeviceReadDomainiTunes];
        [responses setObject:[device readDomain:CMDeviceReadDomainMobileiTunesStore] forKey:CMDeviceReadDomainMobileiTunesStore];
        [responses setObject:[device readDomain:CMDeviceReadDomainMobileiTunes] forKey:CMDeviceReadDomainMobileiTunes];
        
        self.textView.string = [responses description];
    }
}

@end