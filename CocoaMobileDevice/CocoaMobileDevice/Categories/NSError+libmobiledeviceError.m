//
//  NSError+libmobiledeviceError.m
//  CocoaMobileDevice
//
//  Created by Liam Nichols on 30/05/2014.
//  Copyright (c) 2014 Liam Nichols. All rights reserved.
//

#import "NSError+libmobiledeviceError.h"
#import "CMConstants.h"

@implementation NSError (libmobiledeviceError)

//TODO: make these error messages a little nicer.

+ (NSError *)errorWithDeviceErrorCode:(idevice_error_t)errorCode
{
    if (errorCode == IDEVICE_E_INVALID_ARG)
    {
        return [NSError errorWithDomain:CMDeviceErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"An invalid argument was used." }];
    }

    else if (errorCode == IDEVICE_E_NO_DEVICE)
    {
        return [NSError errorWithDomain:CMDeviceErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"No device was found." }];
    }

    else if (errorCode == IDEVICE_E_NOT_ENOUGH_DATA)
    {
        return [NSError errorWithDomain:CMDeviceErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"Not enough data." }];
    }

    else if (errorCode == IDEVICE_E_BAD_HEADER)
    {
        return [NSError errorWithDomain:CMDeviceErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"Bad Header." }];
    }

    else if (errorCode == IDEVICE_E_SSL_ERROR)
    {
        return [NSError errorWithDomain:CMDeviceErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"SSL Error." }];
    }

    else if (errorCode == IDEVICE_E_SUCCESS)
    {
        return nil; //no error.
    }
    return [NSError errorWithDomain:CMDeviceErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"Unknown error (idevice)." }];
}

+ (NSError *)errorWithLockdownErrorCode:(lockdownd_error_t)errorCode
{
    if (errorCode == LOCKDOWN_E_INVALID_ARG)
    {
        return [NSError errorWithDomain:CMLockdowndErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"Invalid argument." }];
    }

    else if (errorCode == LOCKDOWN_E_INVALID_CONF)
    {
        return [NSError errorWithDomain:CMLockdowndErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"Invalid config." }];
    }

    else if (errorCode == LOCKDOWN_E_PLIST_ERROR)
    {
        return [NSError errorWithDomain:CMLockdowndErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"Plist error." }];
    }

    else if (errorCode == LOCKDOWN_E_PAIRING_FAILED)
    {
        return [NSError errorWithDomain:CMLockdowndErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"Pairing failed." }];
    }

    else if (errorCode == LOCKDOWN_E_SSL_ERROR)
    {
        return [NSError errorWithDomain:CMLockdowndErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"SSL error." }];
    }

    else if (errorCode == LOCKDOWN_E_DICT_ERROR)
    {
        return [NSError errorWithDomain:CMLockdowndErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"Dict error." }];
    }

    else if (errorCode == LOCKDOWN_E_START_SERVICE_FAILED)
    {
        return [NSError errorWithDomain:CMLockdowndErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"Start service failed." }];
    }

    else if (errorCode == LOCKDOWN_E_NOT_ENOUGH_DATA)
    {
        return [NSError errorWithDomain:CMLockdowndErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"Not enough data." }];
    }

    else if (errorCode == LOCKDOWN_E_SET_VALUE_PROHIBITED)
    {
        return [NSError errorWithDomain:CMLockdowndErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"Set value prohibited." }];
    }

    else if (errorCode == LOCKDOWN_E_GET_VALUE_PROHIBITED)
    {
        return [NSError errorWithDomain:CMLockdowndErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"Get value prohibited." }];
    }

    else if (errorCode == LOCKDOWN_E_REMOVE_VALUE_PROHIBITED)
    {
        return [NSError errorWithDomain:CMLockdowndErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"Remove value prohibited." }];
    }

    else if (errorCode == LOCKDOWN_E_MUX_ERROR)
    {
        return [NSError errorWithDomain:CMLockdowndErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"Mux error." }];
    }

    else if (errorCode == LOCKDOWN_E_ACTIVATION_FAILED)
    {
        return [NSError errorWithDomain:CMLockdowndErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"Activation failed." }];
    }

    else if (errorCode == LOCKDOWN_E_PASSWORD_PROTECTED)
    {
        return [NSError errorWithDomain:CMLockdowndErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"Password protected." }];
    }

    else if (errorCode == LOCKDOWN_E_NO_RUNNING_SESSION)
    {
        return [NSError errorWithDomain:CMLockdowndErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"No running session." }];
    }

    else if (errorCode == LOCKDOWN_E_INVALID_HOST_ID)
    {
        return [NSError errorWithDomain:CMLockdowndErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"Invalid host ID." }];
    }

    else if (errorCode == LOCKDOWN_E_INVALID_SERVICE)
    {
        return [NSError errorWithDomain:CMLockdowndErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"Invalid service." }];
    }

    else if (errorCode == LOCKDOWN_E_INVALID_ACTIVATION_RECORD)
    {
        return [NSError errorWithDomain:CMLockdowndErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"Invalid activation record." }];
    }

    else if (errorCode == LOCKDOWN_E_SUCCESS)
    {
        return nil; //no error.
    }
    return [NSError errorWithDomain:CMLockdowndErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"Unknown error (lockdownd)." }];
}

+ (NSError *)errorWithScreenshorErrorCode:(screenshotr_error_t)errorCode
{
    if (errorCode == SCREENSHOTR_E_INVALID_ARG)
    {
        return [NSError errorWithDomain:CMScreenshotrErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"Invalid arg." }];
    }
    
    else if (errorCode == SCREENSHOTR_E_PLIST_ERROR)
    {
        return [NSError errorWithDomain:CMScreenshotrErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"Plist error." }];
    }
    
    else if (errorCode == SCREENSHOTR_E_MUX_ERROR)
    {
        return [NSError errorWithDomain:CMScreenshotrErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"Mux error." }];
    }
    
    else if (errorCode == SCREENSHOTR_E_BAD_VERSION)
    {
        return [NSError errorWithDomain:CMScreenshotrErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"Bad version." }];
    }
    
    else if (errorCode == SCREENSHOTR_E_SUCCESS)
    {
        return nil; //no error.
    }
    return [NSError errorWithDomain:CMScreenshotrErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : @"Unknown error (screenshotr)." }];
}


@end
