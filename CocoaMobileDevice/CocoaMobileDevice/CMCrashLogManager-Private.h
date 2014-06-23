//
//  CMCrashLogManager-Private.h
//  CocoaMobileDevice
//
//  Created by Liam Nichols on 22/06/2014.
//  Copyright (c) 2014 Liam Nichols. All rights reserved.
//

@interface CMCrashLogManager (Private)

+ (BOOL)importCrashLogArchiveAtPath:(NSString *)path forDevice:(CMDevice *)device error:(NSError **)error;

@end