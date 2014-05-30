//
//  AppDelegate.h
//  MobileDevice
//
//  Created by Liam Nichols on 29/05/2014.
//  Copyright (c) 2014 Liam Nichols. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource>

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, weak) IBOutlet NSTableView *tableView;

@property (nonatomic, strong) IBOutlet NSTextView *textView;

@end
