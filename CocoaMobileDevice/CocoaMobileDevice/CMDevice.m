//  CMDevice.m
//  CocoaMobileDevice
//
//  Created by Liam Nichols on 29/05/2014.
//  Copyright (c) 2014 Liam Nichols. All rights reserved.
//

#import "CMDevice.h"
#import "CMPlistSerialization.h"
#import <libimobiledevice/libimobiledevice.h>
#import <libimobiledevice/lockdown.h>

@interface CMDevice ()

@property (nonatomic, strong) NSString *UDID;

@property (nonatomic, assign) BOOL connected;

@end

@implementation CMDevice
{
    lockdownd_client_t client;
}

static int indent_level = 0;

static void plist_node_to_string(plist_t node);

static void plist_array_to_string(plist_t node)
{
	/* iterate over items */
	int i, count;
	plist_t subnode = NULL;
    
	count = plist_array_get_size(node);
    
	for (i = 0; i < count; i++) {
		subnode = plist_array_get_item(node, i);
		printf("%*s", indent_level, "");
		printf("%d: ", i);
		plist_node_to_string(subnode);
	}
}

static void plist_dict_to_string(plist_t node)
{
	/* iterate over key/value pairs */
	plist_dict_iter it = NULL;
    
	char* key = NULL;
	plist_t subnode = NULL;
	plist_dict_new_iter(node, &it);
	plist_dict_next_item(node, it, &key, &subnode);
	while (subnode)
	{
		printf("%*s", indent_level, "");
		printf("%s", key);
		if (plist_get_node_type(subnode) == PLIST_ARRAY)
			printf("[%d]: ", plist_array_get_size(subnode));
		else
			printf(": ");
		free(key);
		key = NULL;
		plist_node_to_string(subnode);
		plist_dict_next_item(node, it, &key, &subnode);
	}
	free(it);
}

static void plist_node_to_string(plist_t node)
{
	char *s = NULL;
	char *data = NULL;
	double d;
	uint8_t b;
	uint64_t u = 0;
    
	plist_type t;
    
	if (!node)
		return;
    
	t = plist_get_node_type(node);
    
	switch (t) {
        case PLIST_BOOLEAN:
            plist_get_bool_val(node, &b);
            printf("%s\n", (b ? "true" : "false"));
            break;
            
        case PLIST_UINT:
            plist_get_uint_val(node, &u);
            printf("%llu\n", (long long)u);
            break;
            
        case PLIST_REAL:
            plist_get_real_val(node, &d);
            printf("%f\n", d);
            break;
            
        case PLIST_STRING:
            plist_get_string_val(node, &s);
            printf("%s\n", s);
            free(s);
            break;
            
        case PLIST_KEY:
            plist_get_key_val(node, &s);
            printf("%s: ", s);
            free(s);
            break;
            
        case PLIST_DATA:
//            plist_get_data_val(node, &data, &u);
//            s = g_base64_encode((guchar *)data, u);
//            free(data);
//            printf("%s\n", s);
//            g_free(s);
            break;
            
        case PLIST_DATE:
//            plist_get_date_val(node, (int32_t*)&tv.tv_sec, (int32_t*)&tv.tv_usec);
//            s = g_time_val_to_iso8601(&tv);
//            printf("%s\n", s);
//            free(s);
            break;
            
        case PLIST_ARRAY:
            printf("\n");
            indent_level++;
            plist_array_to_string(node);
            indent_level--;
            break;
            
        case PLIST_DICT:
            printf("\n");
            indent_level++;
            plist_dict_to_string(node);
            indent_level--;
            break;
            
        default:
            break;
	}
}


- (id)initWithUDID:(NSString *)UDID
{
    self = [super init];
    if (self)
    {
        self.UDID = UDID;
    }
    return self;
}

- (BOOL)connect
{
    _connected = NO;
    client = NULL;
    idevice_t phone = NULL;
    
    idevice_error_t ret = idevice_new(&phone, [self.UDID cStringUsingEncoding:NSUTF8StringEncoding]);
    
    if (ret != IDEVICE_E_SUCCESS)
    {
        NSLog(@"trying to create a device with a UDID that is not connceted.");
        return NO;
    }
    
    ret = lockdownd_client_new_with_handshake(phone, &client, "CMDevice");
    
    if (ret != IDEVICE_E_SUCCESS)
    {
        NSLog(@"unable to complete handshake with phone.");
        return NO;
    }
    
    idevice_free(phone);
    
    _connected = YES;
    return YES;
}

- (void)read
{
    plist_t node;
    
    if(lockdownd_get_value(client, NULL, NULL, &node) == LOCKDOWN_E_SUCCESS)
    {
        if (node)
        {
            id response = [CMPlistSerialization plistObjectFromNode:node];
            NSLog(@"got: %@", response);
            
            plist_free(node);
            node = NULL;
        }
    }
}

@end
