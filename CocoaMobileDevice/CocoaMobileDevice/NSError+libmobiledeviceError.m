//
//  NSError+libmobiledeviceError.m
//  CocoaMobileDevice
//
//  Created by Liam Nichols on 30/05/2014.
//  Copyright (c) 2014 Liam Nichols. All rights reserved.
//

#import "NSError+libmobiledeviceError.h"

NSString *CMErrorDomain = @"CMErrorDomain";

@implementation NSError (libmobiledeviceError)

+ (NSError *)errorWithErrorCode:(idevice_error_t)errorCode
{
    if (errorCode == IDEVICE_E_INVALID_ARG)
    {
        return [NSError errorWithDomain:CMErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"An invalid argument was used." }];
    }
    else if (errorCode == IDEVICE_E_NO_DEVICE)
    {
        return [NSError errorWithDomain:CMErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"No device was found." }];
    }
    else if (errorCode == IDEVICE_E_NOT_ENOUGH_DATA)
    {
        return [NSError errorWithDomain:CMErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"Not enough data." }];
    }
    else if (errorCode == IDEVICE_E_BAD_HEADER)
    {
        return [NSError errorWithDomain:CMErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"Bad Header." }];
    }
    else if (errorCode == IDEVICE_E_SSL_ERROR)
    {
        return [NSError errorWithDomain:CMErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"SSL Error." }];
    }
    else if (errorCode == IDEVICE_E_SUCCESS)
    {
        return nil; //no error.
    }
    return [NSError errorWithDomain:CMErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"Unknown error." }];
}

@end
