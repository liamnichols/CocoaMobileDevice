//
//  AppDelegate.h
//  MobileDevice
//
//  Created by Liam Nichols on 29/05/2014.
//  Copyright (c) 2014 Liam Nichols. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

//windows

@property (assign) IBOutlet NSWindow *window;

//ui

@property (nonatomic, strong) IBOutlet NSPopUpButton *deviceList;

@property (nonatomic, strong) IBOutlet NSTextView *loggerTextView;

- (IBAction)deviceListValueChanged:(id)sender;

//read and write

@property (nonatomic, strong) IBOutlet NSComboBox *domainPicker;

@property (nonatomic, strong) IBOutlet NSTextField *keyTextField;

@property (nonatomic, strong) IBOutlet NSTextField *valueTextField;

- (IBAction)didPressReadButton:(id)sender;

- (IBAction)didPressWriteButton:(id)sender;

//screenshotr

- (IBAction)takeScreenshot:(id)sender;

@end
