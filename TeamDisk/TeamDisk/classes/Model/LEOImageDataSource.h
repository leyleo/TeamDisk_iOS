//
//  LEOImageDataSource.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-14.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTPhotoBrowserDataSource.h"

@interface LEOImageDataSource : NSObject<KTPhotoBrowserDataSource>
{
    NSMutableArray *_images;
}
-(void)addObject:(id)item;
-(id)itemAtIndex:(NSInteger)index;
-(void)removeAllObjects;
-(NSInteger)indexOfObject:(id)item;

//- (UIImage *)imageAtIndex:(NSInteger)index;
//- (void)imageAtIndex:(NSInteger)index photoView:(KTPhotoView *)photoView;
@end
