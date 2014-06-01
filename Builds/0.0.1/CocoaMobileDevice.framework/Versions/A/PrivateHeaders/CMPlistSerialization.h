//
//  CMPlistSerialization.h
//  CocoaMobileDevice
//
//  Created by Liam Nichols on 29/05/2014.
//  Copyright (c) 2014 Liam Nichols. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <plist/plist.h>

@interface CMPlistSerialization : NSObject

+ (id)plistObjectFromNode:(plist_t)node error:(NSError **)error;

+ (plist_t)nodeWithPlistObject:(id)object error:(NSError **)error;

@end
