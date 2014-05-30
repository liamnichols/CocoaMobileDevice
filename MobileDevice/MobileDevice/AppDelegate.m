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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceAddedNotification:) name:CMDeviceMangerDeviceAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceRemovedNotification:) name:CMDeviceMangerDeviceRemovedNotification object:nil];
    [[CMDeviceManger sharedManager] subscribe:nil];
    
    NSLog(@"subscription status: %@", [[CMDeviceManger sharedManager] isSubscribed] ? @"Subscribed" : @"Unsubscribed");
}

- (void)deviceAddedNotification:(NSNotification *)notification
{
    [self reloadDeviceList];
}

- (void)deviceRemovedNotification:(NSNotification *)notification
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
            else if (!device.connected && [device connect:nil] && [device loadDeviceName])
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
    
    if (selectedDevice)
    {
        NSError *error = nil;
        if (!selectedDevice.connected) {
            if (![selectedDevice connect:&error]) {
                [[NSAlert alertWithError:error] runModal];
                return;
            }
        }
        NSNumber *capacity = [selectedDevice readDomain:CMDeviceDomainDiskUsage key:@"TotalDataCapacity" error:&error];
        
        self.deviceNameTextField.stringValue = selectedDevice.deviceName;
        self.modelLabel.stringValue = [selectedDevice readDomain:nil key:@"ProductType" error:&error];
        self.versionLabel.stringValue = [NSString stringWithFormat:@"iOS %@", [selectedDevice readDomain:nil key:@"ProductVersion" error:&error]];
        self.identifierLabel.stringValue = selectedDevice.UDID;
        self.serialNumberLabel.stringValue = [selectedDevice readDomain:nil key:@"SerialNumber" error:&error];
        self.capacityLabel.stringValue = [NSByteCountFormatter stringFromByteCount:capacity.longLongValue countStyle:NSByteCountFormatterCountStyleFile];
        self.phoneNumberLabel.stringValue = [selectedDevice readDomain:nil key:@"PhoneNumber"  error:&error];
        
        if (error)
        {
            [[NSAlert alertWithError:error] runModal];
        }
    }
}

- (IBAction)updateDeviceName:(id)sender
{
    if (self.deviceNameTextField.stringValue.length > 0 && self.selectedDevice)
    {
        NSError *error = nil;
        if (!self.selectedDevice.connected)
        {
            if (![self.selectedDevice connect:&error]) {
                [[NSAlert alertWithError:error] runModal];
                return;
            }
        }
        BOOL result = [self.selectedDevice writeValue:self.deviceNameTextField.stringValue toDomain:nil forKey:@"DeviceName" error:&error];
        if (!result)
        {
            [[NSAlert alertWithError:error] runModal];
        }
    }
}

@end