//
//  CocoaMobileDeviceTests.m
//  CocoaMobileDeviceTests
//
//  Created by Liam Nichols on 29/05/2014.
//  Copyright (c) 2014 Liam Nichols. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CMDeviceManger.h"

@interface CocoaMobileDeviceTests : XCTestCase

@end

@implementation CocoaMobileDeviceTests

- (void)testConnectedDevicesAreReturned
{
    NSArray *connectedDevices = [CMDeviceManger connectedDeviceUDIDs];
    
    NSLog(@"got connected devices: %@", connectedDevices);
    
    XCTAssert(connectedDevices, @"connected devices must not be nil");
}

@end
