//
//  LEODetailPictureViewController.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-2.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEODetailPictureViewController.h"
#import "LEOWebDAVItem.h"
#import "LEOUtility.h"

@interface LEODetailPictureViewController ()
{
    UIImageView *imageView;
}
@end

@implementation LEODetailPictureViewController


- (void)prepareDetail
{
    [super prepareDetail];
	imageView=[[UIImageView alloc] init];
    [_displayView addSubview:imageView];
    imageView.frame=imageView.superview.frame;
    imageView.backgroundColor=[UIColor blackColor];
    imageView.contentMode=UIViewContentModeScaleAspectFit;
    imageView.multipleTouchEnabled=YES;
}


-(void)detailTodo
{
    [super detailTodo];
    LEOUtility *utility=[LEOUtility getInstance];
    NSString *path=[[utility cachePathWithName:@"download"] stringByAppendingPathComponent:_item.cacheName];
    path=[path stringByAppendingPathExtension:[_item.displayName pathExtension]];
    NSData *data=[NSData dataWithContentsOfFile:path];
    UIImage *image=[UIImage imageWithData:data];
    [imageView setImage:image];
}

#pragma mark - LEOWebDAV delegate
- (void)request:(LEOWebDAVRequest *)aRequest didFailWithError:(NSError *)error
{
    [super request:aRequest didSucceedWithResult:error];
}

- (void)request:(LEOWebDAVRequest *)aRequest didSucceedWithResult:(id)result
{
    [super request:aRequest didSucceedWithResult:result];
}
@end
