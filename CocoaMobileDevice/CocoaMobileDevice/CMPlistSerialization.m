//
//  CMPlistSerialization.m
//  CocoaMobileDevice
//
//  Created by Liam Nichols on 29/05/2014.
//  Copyright (c) 2014 Liam Nichols. All rights reserved.
//

#import "CMPlistSerialization.h"

@implementation CMPlistSerialization

#pragma mark - node -> NSObject

+ (id)plistObjectFromNode:(plist_t)node error:(NSError *__autoreleasing *)error
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
            return @((BOOL)b);
            
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
            return [self dateFromNode:node error:error];
            
        case PLIST_ARRAY:
            return [self arrayFromNode:node error:error];
            
        case PLIST_DICT:
            return [self dictionaryFromNode:node error:error];
            
        default:
            break;
	}

    return nil;
}

+ (NSArray *)arrayFromNode:(plist_t)node error:(NSError **)error;
{
    int count;
	plist_t subnode = NULL;
    
    count = plist_array_get_size(node);
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count; i++)
    {
		subnode = plist_array_get_item(node, i);
		
        id item = [self plistObjectFromNode:subnode error:error];
        
        if (!item) {
            item = [NSNull null];
        }
        [array addObject:item];
	}
    
    return [array copy];
}

+ (NSDate *)dateFromNode:(plist_t)node error:(NSError **)error;
{
    int32_t seconds, microseconds;
    plist_get_date_val(node, &seconds, &microseconds);

    return [NSDate dateWithTimeIntervalSinceReferenceDate:seconds + microseconds];
}

+ (NSDictionary *)dictionaryFromNode:(plist_t)node error:(NSError **)error;
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
        
        id item = [self plistObjectFromNode:subnode error:error];
        
        if (!item) {
            item = [NSNull null];
        }
        
        [dictionary setObject:item forKey:stringKey];
        
		plist_dict_next_item(node, it, &key, &subnode);
	}
	free(it);

    return [dictionary copy];
}

#pragma mark - NSObect > node

+ (plist_t)nodeWithPlistObject:(id)object error:(NSError *__autoreleasing *)error
{
    if ([object isKindOfClass:[NSString class]])
    {
        const char *s = [object cStringUsingEncoding:NSASCIIStringEncoding];
        plist_t node = plist_new_string(s);
        s = NULL;
        return node;
    }
    else if ([object isKindOfClass:[NSNumber class]])
    {
        if (strcmp([object objCType], @encode(BOOL)) == 0)
        {
            //bool
            plist_t node = plist_new_bool([object boolValue]);
            return node;
        }
        else if (strcmp([object objCType], @encode(double)) == 0 || strcmp([object objCType], @encode(float)) == 0)
        {
            //double
            double d = [object doubleValue];
            return plist_new_real(d);
        }
        else
        {
            //treat all else as a uint.
            uint64_t i = [object unsignedIntegerValue];
            return plist_new_uint(i);
        }
    }
    else if ([object isKindOfClass:[NSData class]])
    {
        char *data = NULL;
        uint64_t len = [object length];
        [object getBytes:&data length:len];

        plist_t node = plist_new_data(data, len);
        
        free(&data);
        return node;
    }
    else if ([object isKindOfClass:[NSDate class]])
    {
        NSTimeInterval timeInterval = [object timeIntervalSinceReferenceDate];
        int32_t seconds,microseconds;
        seconds = (int32_t)floor(timeInterval);
        microseconds = 0; //TODO: do the math to calculate the microseconds from a timeInterval.
        
        return plist_new_date(seconds, microseconds);
    }
    else if ([object isKindOfClass:[NSArray class]])
    {
        plist_t node = plist_new_array();
        
        for (NSUInteger i = 0; i < [object count]; i++)
        {
            id itemObj = [object objectAtIndex:i];
            plist_t item = [self nodeWithPlistObject:itemObj error:error];
         
            plist_array_append_item(node, item);
        }
        
        return node;
    }
    else if ([object isKindOfClass:[NSDictionary class]])
    {
        const char *k = NULL;
        plist_t node = plist_new_dict();
        
        for (id key in object)
        {
            if ([key isKindOfClass:[NSString class]])
            {
                id itemObj = [object objectForKey:key];
                plist_t item = [self nodeWithPlistObject:itemObj error:error];
                k = [key cStringUsingEncoding:NSASCIIStringEncoding];
                
                plist_dict_set_item(node, k, item);
                
                free(&k);
                k = NULL;
            }
        }
        
        return node;
    }
    
    //TODO: error about not being a valid object type.
    return NULL;
}

@end
