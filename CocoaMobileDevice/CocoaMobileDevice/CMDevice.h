//
//  CMDevice.h
//  CocoaMobileDevice
//
//  Created by Liam Nichols on 29/05/2014.
//  Copyright (c) 2014 Liam Nichols. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMDevice : NSObject

@property (nonatomic, readonly) NSString *UDID;

- (id)initWithUDID:(NSString *)UDID;

- (BOOL)connect;

- (void)read;

@end
