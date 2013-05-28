//
//  LEOMusicItem.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-6.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LEOWebDAVItem;

@interface LEOMusicItem : NSObject
@property (readonly) NSString *displayName;
@property (readonly) NSString *cacheName;
@property (readonly) NSString *url;
@property (readonly) NSString *href;
@property (readonly) NSString *createDate;
-(id)initWithItem:(LEOWebDAVItem *)item;
@end
