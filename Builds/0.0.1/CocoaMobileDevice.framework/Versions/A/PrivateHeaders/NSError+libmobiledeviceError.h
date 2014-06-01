//
//  NSError+libmobiledeviceError.h
//  CocoaMobileDevice
//
//  Created by Liam Nichols on 30/05/2014.
//  Copyright (c) 2014 Liam Nichols. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libimobiledevice/libimobiledevice.h>
#import <libimobiledevice/lockdown.h>
#import <libimobiledevice/screenshotr.h>

@interface NSError (libmobiledeviceError)

+ (NSError *)errorWithDeviceErrorCode:(idevice_error_t)errorCode;

+ (NSError *)errorWithLockdownErrorCode:(lockdownd_error_t)errorCode;

+ (NSError *)errorWithScreenshorErrorCode:(screenshotr_error_t)errorCode;

@end
