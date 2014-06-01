//
//  AppDelegate.m
//  MobileDevice
//
//  Created by Liam Nichols on 29/05/2014.
//  Copyright (c) 2014 Liam Nichols. All rights reserved.
//

#import "AppDelegate.h"
#import <CocoaMobileDevice/CocoaMobileDevice.h>

@interface AppDelegate () <NSAlertDelegate>

@property (nonatomic, strong) CMDevice *selectedDevice;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //configure logger
    self.loggerTextView.font = [NSFont fontWithName:@"Courier New" size:12.0];
    
    //configure combo picker
    [self.domainPicker addItemWithObjectValue:@""];
    [self.domainPicker addItemsWithObjectValues:[CMDevice knownDomains]];
    [self.domainPicker setNumberOfVisibleItems:self.domainPicker.objectValues.count];
    
    [self reloadDeviceList];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceAddedNotification:) name:CMDeviceMangerDeviceAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceRemovedNotification:) name:CMDeviceMangerDeviceRemovedNotification object:nil];
    [[CMDeviceManger sharedManager] subscribe:nil];
    
    LogToUI(@"CMDeviceManger subscibed for connection notifications: %@", [[CMDeviceManger sharedManager] isSubscribed] ? @"YES" : @"NO");
}

- (void)deviceAddedNotification:(NSNotification *)notification
{
    CMDevice *device = [notification.userInfo objectForKey:CMDeviceMangerNotificationDeviceKey];
    LogToUI(@"Device added: %@", device);
    
    [self reloadDeviceList];
}

- (void)deviceRemovedNotification:(NSNotification *)notification
{
    CMDevice *device = [notification.userInfo objectForKey:CMDeviceMangerNotificationDeviceKey];
    LogToUI(@"Device removed: %@", device);
    
    [self reloadDeviceList];
}

- (void)reloadDeviceList
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.deviceList removeAllItems];
        [self.deviceList addItemWithTitle:@"Select a Device"];
        [[[CMDeviceManger sharedManager] devices] enumerateObjectsUsingBlock:^(CMDevice *device, NSUInteger idx, BOOL *stop) {

            if (!device.deviceName)
            {
                if ([device connect:nil])
                {
                    [device loadDeviceName];
                    [device disconnect];
                }
            }
            
            if (device.deviceName)
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
    
    
    if (selectedDevice)
    {
        NSError *error = nil;
        if (!selectedDevice.connected) {
            if (![selectedDevice connect:&error]) {
                [[NSAlert alertWithError:error] runModal];
                return;
            }
        }
        
    }
}

#pragma mark - Reading

-(void)didPressReadButton:(id)sender
{
    NSString *domain = [self.domainPicker stringValue];
    NSString *key = [self.keyTextField stringValue];
    
    if (key.length == 0)
        key = nil;
    
    if (domain.length == 0)
        domain = nil;
    
    if (!self.selectedDevice)
    {
        [[NSAlert alertWithMessageText:@"No Device Selected" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please select a device to read from before trying to read."] runModal];
        return;
    }
    
    if (![CMDevice isDomainKnown:domain])
    {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Warning" defaultButton:@"Yes" alternateButton:@"No" otherButton:nil informativeTextWithFormat:@"The domain '%@' is not a known domain. Are you sure you want to send this query?", domain];
        
        if ([alert runModal] != 1)
            return;
    }
    
    [self readAndPrintDomain:domain key:key];
}

- (void)readAndPrintDomain:(NSString *)domain key:(NSString *)key
{
    [self connectIfNeeded];

    LogToUI(@"Reading from device. domain: %@ key: %@", domain, key);
 
    NSError *error = nil;
    
    id response = [self.selectedDevice readDomain:domain key:key error:&error];
    
    if (!error)
    {
        LogToUI(@"Response: %@", response);
    }
    else
    {
        LogToUI(@"Error Reading: %@", error);
    }
    
    [self.selectedDevice disconnect];
}

#pragma mark - Write

-(void)didPressWriteButton:(id)sender
{
    NSString *domain = [self.domainPicker stringValue];
    NSString *key = [self.keyTextField stringValue];
    NSString *value = [self.valueTextField stringValue];
    
    if (domain.length == 0)
        domain = nil;
    
    if (!self.selectedDevice)
    {
        [[NSAlert alertWithMessageText:@"No Device Selected" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please select a device to read from before trying to read."] runModal];
        return;
    }
    
    if (![CMDevice isDomainKnown:domain])
    {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Warning" defaultButton:@"Yes" alternateButton:@"No" otherButton:nil informativeTextWithFormat:@"The domain '%@' is not a known domain. Are you sure you want to send this query?", domain];
        
        if ([alert runModal] != 1)
            return;
    }
    
    if (key.length <= 0)
    {
        [[NSAlert alertWithMessageText:@"No Key Provided" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please specify a key to write to before trying to write."] runModal];
        return;
    }
    
    if (value.length <= 0)
    {
        [[NSAlert alertWithMessageText:@"No Value Provided" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please specify a value to write before trying to write."] runModal];
        return;
    }
    
    [self writeAndPrintDomain:domain key:key value:value];
}

- (void)writeAndPrintDomain:(NSString *)domain key:(NSString *)key value:(id)value
{
    [self connectIfNeeded];
    
    LogToUI(@"Writing to device. domain: %@ key: %@ value: %@", domain, key, value);
    
    NSError *error = nil;
    
    BOOL success = [self.selectedDevice writeValue:value toDomain:domain forKey:key error:&error];
    
    if (success)
    {
        LogToUI(@"Value successfully written to device");
    }
    else
    {
        LogToUI(@"Error Writing: %@", error);
    }
    
    [self.selectedDevice disconnect];
}

#pragma mark - Both

- (void)connectIfNeeded
{
    NSError *error = nil;
    if (!self.selectedDevice.connected)
    {
        if ([self.selectedDevice connect:&error])
        {
            LogToUI(@"successfully connected to device: %@", self.selectedDevice);
        }
        else
        {
            LogToUI(@"error connecting to device: %@ error: %@", self.selectedDevice, error);
            return;
        }
    }
    else
    {
        LogToUI(@"already connected to device for read: %@", self.selectedDevice);
    }
}

#pragma mark - Screenshot

-(void)takeScreenshot:(id)sender
{
    if (!self.selectedDevice)
    {
        [[NSAlert alertWithMessageText:@"No Device Selected" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please select a device to read from before trying to read."] runModal];
        return;
    }
    
    [self readAndShowScreenshot];
}

- (void)readAndShowScreenshot
{
    [self connectIfNeeded];
    
    NSError *error = nil;
    NSData *screenshot = [self.selectedDevice getScreenshot:&error];
    
    [self.selectedDevice disconnect];
    
    if (!error)
    {
        NSString *desktop = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"];
        
        static NSDateFormatter *dateFormatter = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"yyy-MM-dd 'at' HH.mm.ss";
        });
        
        NSString *name = [NSString stringWithFormat:@"Screen Shot %@.tiff", [dateFormatter stringFromDate:[NSDate date]]];
        NSString *file = [desktop stringByAppendingPathComponent:name];
        
        [screenshot writeToFile:file atomically:YES];
        
        LogToUI(@"Screenshot saved to: %@", file);
    }
    else
    {
        LogToUI(@"Error saving screenshot: %@", error);
        [[NSAlert alertWithError:error] runModal];
    }
}

#pragma mark - Logging

void LogToUI(NSString *format, ...)
{
    AppDelegate *delegate = (AppDelegate*)[[NSApplication sharedApplication] delegate];
    
    va_list args;
	va_start (args, format);
    NSString *string = [[NSString alloc] initWithFormat:format arguments:args];
    
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm:ss.SSS";
    });
    
    NSLog(@"%@", string);
    
    string = [[dateFormatter stringFromDate:[NSDate date]] stringByAppendingFormat:@" %@", string];
    
    // Smart Scrolling
    BOOL scroll = (NSMaxY(delegate.loggerTextView.visibleRect) == NSMaxY(delegate.loggerTextView.bounds));
    
    dispatch_async(dispatch_get_main_queue(), ^{
        delegate.loggerTextView.string = [delegate.loggerTextView.string stringByAppendingFormat:@"%@\n", string];
        
        if (scroll) // Scroll to end of the textview contents
            [delegate.loggerTextView scrollRangeToVisible: NSMakeRange(delegate.loggerTextView.string.length, 0)];
    });
}

@end