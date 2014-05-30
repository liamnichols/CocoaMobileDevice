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

@property (nonatomic, strong) CMDevice *selectedDevice;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self reloadDeviceList];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceAddedNotifcation:) name:CMDeviceMangerDeviceAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceRemovedNotifcation:) name:CMDeviceMangerDeviceRemovedNotification object:nil];
    [[CMDeviceManger sharedManager] subscribe:nil];
    
    NSLog(@"subscription status: %@", [[CMDeviceManger sharedManager] isSubscribed] ? @"Subscribed" : @"Unsubscribed");
}

- (void)deviceAddedNotifcation:(NSNotification *)notification
{
    [self reloadDeviceList];
}

- (void)deviceRemovedNotifcation:(NSNotification *)notification
{
    [self reloadDeviceList];
}

- (void)reloadDeviceList
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.deviceList removeAllItems];
        [self.deviceList addItemWithTitle:@"Select a Device"];
        [[[CMDeviceManger sharedManager] devices] enumerateObjectsUsingBlock:^(CMDevice *device, NSUInteger idx, BOOL *stop) {

            if (device.deviceName)
            {
                [self.deviceList addItemWithTitle:device.deviceName];
            }
            else if ([device connect] && [device loadDeviceName] && device.deviceName)
            {
                [self.deviceList addItemWithTitle:device.deviceName];
            }
            else
            {
                [self.deviceList addItemWithTitle:device.UDID];
            }
            
        }];
        
        if (self.selectedDevice && ![[[CMDeviceManger sharedManager] devices] containsObject:self.selectedDevice])
        {
            self.selectedDevice = nil;
        }
    });
}

-(void)deviceListValueChanged:(id)sender
{
    NSInteger selectedIndex = [self.deviceList indexOfSelectedItem];
    if (selectedIndex >= 0 && selectedIndex != NSNotFound)
    {
        if (selectedIndex == 0)
        {
            self.selectedDevice = nil;
        }
        else
        {
            [self setSelectedDevice:[[[CMDeviceManger sharedManager] devices] objectAtIndex:selectedIndex-1]];
        }
        
    }
}

- (void)setSelectedDevice:(CMDevice *)selectedDevice
{
    _selectedDevice = selectedDevice;
    
    self.deviceNameTextField.stringValue = @"";
    self.modelLabel.stringValue = @"";
    self.versionLabel.stringValue = @"";
    self.identifierLabel.stringValue = @"";
    self.serialNumberLabel.stringValue = @"";
    self.capacityLabel.stringValue = @"";
    self.phoneNumberLabel.stringValue = @"";
    
    if (selectedDevice && [selectedDevice connect])
    {
        NSNumber *capacity = [selectedDevice readDomain:CMDeviceReadDomainDiskUsage key:@"TotalDataCapacity"];
        
        self.deviceNameTextField.stringValue = selectedDevice.deviceName;
        self.modelLabel.stringValue = [selectedDevice readDomain:nil key:@"ProductType"];
        self.versionLabel.stringValue = [NSString stringWithFormat:@"iOS %@", [selectedDevice readDomain:nil key:@"ProductVersion"]];
        self.identifierLabel.stringValue = selectedDevice.UDID;
        self.serialNumberLabel.stringValue = [selectedDevice readDomain:nil key:@"SerialNumber"];
        self.capacityLabel.stringValue = [NSByteCountFormatter stringFromByteCount:capacity.longLongValue countStyle:NSByteCountFormatterCountStyleFile];
        self.phoneNumberLabel.stringValue = [selectedDevice readDomain:nil key:@"PhoneNumber"];
    }
}

- (IBAction)updateDeviceName:(id)sender
{
    if (self.deviceNameTextField.stringValue.length > 0 && self.selectedDevice && [self.selectedDevice connect])
    {
        BOOL result = [self.selectedDevice writeValue:self.deviceNameTextField.stringValue toDomain:nil forKey:@"DeviceName" error:nil];
        if (result)
        {
            NSLog(@"device name updated.");
        }
        else
        {
            NSLog(@"error updating device name.");
        }
    }
}

@end