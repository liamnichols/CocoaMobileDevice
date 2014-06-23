//
//  CMCrashLogManager.h
//  CocoaMobileDevice
//
//  Created by Liam Nichols on 22/06/2014.
//  Copyright (c) 2014 Liam Nichols. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CMDevice;

@interface CMCrashLogManager : NSObject

+ (void)setStorageLocation:(NSString *)location;

+ (NSString *)storageLocation;

@end
