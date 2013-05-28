//
//  LEOImageDataSource.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-14.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOImageDataSource.h"
#import "LEOWebDAVItem.h"
#import "LEOUtility.h"

@implementation LEOImageDataSource
- (id)init {
    self = [super init];
    if (self) {
        _images=[[NSMutableArray alloc] init];
    }
    return self;
}

-(void)dealloc
{
    [_images release];
    _images=nil;
    [super dealloc];
}

-(void)addObject:(id)item
{
    [_images addObject:item];
}

-(NSInteger)indexOfObject:(id)item
{
    return [_images indexOfObject:item];
}

-(id)itemAtIndex:(NSInteger)index
{
    return [_images objectAtIndex:index];
}

-(void)removeAllObjects
{
    [_images removeAllObjects];
}
#pragma mark - Data Source Delegate
- (NSInteger)numberOfPhotos
{
    return [_images count];
}

- (UIImage *)imageAtIndex:(NSInteger)index
{
    LEOWebDAVItem *_item=[_images objectAtIndex:index];
    
    NSString *path=[[[LEOUtility getInstance] cachePathWithName:@"download"] stringByAppendingPathComponent:_item.cacheName];
    path=[path stringByAppendingPathExtension:[_item.displayName pathExtension]];
    if ([[LEOUtility getInstance] isExistFile:path]) {
        // 在cache download中存在
        return [UIImage imageWithContentsOfFile:path];
    }
    else {
        // 需要先下载，再打开
        return nil;
    }
}
- (void)imageAtIndex:(NSInteger)index photoView:(KTPhotoView *)photoView
{
    return;
}

- (void)deleteImageAtIndex:(NSInteger)index
{
    LEOWebDAVItem *_item=[_images objectAtIndex:index];
    [_images removeObject:_item];
}
@end
