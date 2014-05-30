//
//  NSError+libmobiledeviceError.h
//  CocoaMobileDevice
//
//  Created by Liam Nichols on 30/05/2014.
//  Copyright (c) 2014 Liam Nichols. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libimobiledevice/libimobiledevice.h>

FOUNDATION_EXPORT NSString *CMErrorDomain;

@interface NSError (libmobiledeviceError)

+ (NSError *)errorWithErrorCode:(idevice_error_t)errorCode;

@end
