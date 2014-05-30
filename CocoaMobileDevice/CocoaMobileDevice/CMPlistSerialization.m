//
//  CMPlistSerialization.m
//  CocoaMobileDevice
//
//  Created by Liam Nichols on 29/05/2014.
//  Copyright (c) 2014 Liam Nichols. All rights reserved.
//

#import "CMPlistSerialization.h"

@implementation CMPlistSerialization

+ (id)plistObjectFromNode:(plist_t)node
{
    plist_type t;
    uint8_t b;
    uint64_t u = 0;
    char *s = NULL;
	char *data = NULL;
	double d;
    
	if (!node)
		return nil;
    
	t = plist_get_node_type(node);
    
    switch (t) {
        case PLIST_BOOLEAN:
            plist_get_bool_val(node, &b);
            return @(b);
            
        case PLIST_UINT:
            plist_get_uint_val(node, &u);
            return @(u);
            
        case PLIST_REAL:
            plist_get_real_val(node, &d);
            return @(d);
            
        case PLIST_STRING:
        case PLIST_KEY:
        {
            plist_get_string_val(node, &s);
            NSString *string = [[NSString alloc] initWithCString:s encoding:NSUTF8StringEncoding];
            free(s);
            return string;
        }
            
        case PLIST_DATA:
        {
            plist_get_data_val(node, &data, &u);
            NSData *nsData = [NSData dataWithBytes:data length:u];
            free(data);
            return nsData;
        }
            
        case PLIST_DATE:
            return [self dateFromNode:node];
            
        case PLIST_ARRAY:
            return [self arrayFromNode:node];
            
        case PLIST_DICT:
            return [self dictionaryFromNode:node];
            
        default:
            break;
	}

    return nil;
}

+ (NSArray *)arrayFromNode:(plist_t)node
{
    int count;
	plist_t subnode = NULL;
    
    count = plist_array_get_size(node);
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count; i++)
    {
		subnode = plist_array_get_item(node, i);
		
        id item = [self plistObjectFromNode:subnode];
        
        if (!item) {
            item = [NSNull null];
        }
        [array addObject:item];
	}
    
    return [array copy];
}

+ (NSDate *)dateFromNode:(plist_t)node
{
    int32_t seconds, microseconds;
    plist_get_date_val(node, &seconds, &microseconds);

    return [NSDate dateWithTimeIntervalSinceReferenceDate:seconds + microseconds];
}

+ (NSDictionary *)dictionaryFromNode:(plist_t)node
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    plist_dict_iter it = NULL;
    
	char* key = NULL;
	plist_t subnode = NULL;
	plist_dict_new_iter(node, &it);
	plist_dict_next_item(node, it, &key, &subnode);
	while (subnode)
	{
		NSString *stringKey = [[NSString alloc] initWithCString:key encoding:NSUTF8StringEncoding];
        
		free(key);
		key = NULL;
        
        id item = [self plistObjectFromNode:subnode];
        
        if (!item) {
            item = [NSNull null];
        }
        
        [dictionary setObject:item forKey:stringKey];
        
		plist_dict_next_item(node, it, &key, &subnode);
	}
	free(it);

    return [dictionary copy];
}

@end
