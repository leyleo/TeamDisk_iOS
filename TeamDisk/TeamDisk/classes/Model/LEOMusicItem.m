//
//  LEOMusicItem.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-6.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOMusicItem.h"
#import "LEOWebDAVItem.h"

@interface LEOMusicItem ()
{
    NSString *_displayName;
    NSString *_cacheName;
    NSString *_url;
    NSString *_href;
    NSString *_createDate;
}
@end
@implementation LEOMusicItem
@synthesize displayName=_displayName;
@synthesize cacheName=_cacheName;
@synthesize url=_url;
@synthesize href=_href;
@synthesize createDate=_createDate;

-(id)initWithItem:(LEOWebDAVItem *)item
{
    self = [self init];
	if (self) {
        _href=[[NSString alloc] initWithFormat:@"%@",item.href];
        _displayName=[[NSString alloc] initWithFormat:@"%@",item.displayName];
        _url=[[NSString alloc] initWithFormat:@"%@",item.url];
        _cacheName=[[NSString alloc] initWithFormat:@"%@",item.cacheName];
        _createDate=[[NSString alloc] initWithFormat:@"%@",item.creationDate];
	}
	return self;
}
-(void)dealloc
{
    [_href release];
    [_displayName release];
    [_url release];
    [_cacheName release];
    [_createDate release];
    [super dealloc];
}
@end
