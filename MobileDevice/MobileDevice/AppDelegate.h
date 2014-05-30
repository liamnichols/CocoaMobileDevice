//
//  AppDelegate.h
//  MobileDevice
//
//  Created by Liam Nichols on 29/05/2014.
//  Copyright (c) 2014 Liam Nichols. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, weak) IBOutlet NSPopUpButton *deviceList;

- (IBAction)deviceListValueChanged:(id)sender;

- (IBAction)updateDeviceName:(id)sender;

@property (nonatomic, weak) IBOutlet NSTextField *deviceNameTextField;

@property (nonatomic, weak) IBOutlet NSTextField *modelLabel;

@property (nonatomic, weak) IBOutlet NSTextField *versionLabel;

@property (nonatomic, weak) IBOutlet NSTextField *identifierLabel;

@property (nonatomic, weak) IBOutlet NSTextField *serialNumberLabel;

@property (nonatomic, weak) IBOutlet NSTextField *capacityLabel;

@property (nonatomic, weak) IBOutlet NSTextField *phoneNumberLabel;

@end
