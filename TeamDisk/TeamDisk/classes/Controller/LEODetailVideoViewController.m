//
//  LEODetailVideoViewController.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-5.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEODetailVideoViewController.h"
#import "LEOUtility.h"
#import "LEOWebDAVItem.h"
#import "LEOVideoViewController.h"
#import "LEOAppDelegate.h"
#import "LEOMusicViewController.h"

@interface LEODetailVideoViewController ()
{
    UIButton *imageView;
//    UIProgressView *_progressView;
}
@end

@implementation LEODetailVideoViewController
- (void)prepareDetail
{
    [super prepareDetail];
    
	imageView=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 95, 95)];
    [imageView setImage:[UIImage imageNamed:@"/res/music_play.png"] forState:UIControlStateNormal];
    [_displayView addSubview:imageView];
    [imageView addTarget:self action:@selector(startPlay) forControlEvents:UIControlEventTouchUpInside];
    imageView.center=_displayView.center;
    [imageView setHidden:YES];
}

-(void)detailTodo
{
    [super detailTodo];
    [imageView setHidden: NO];
}

-(void)detailTodo:(id)sender
{
    [super detailTodo];
    [imageView setHidden: NO];
}

-(void)dealloc
{
    [imageView release];
    [super dealloc];
}

-(void)configAppMusic
{
    LEOAppDelegate *delegate=[[UIApplication sharedApplication]delegate];
    if (delegate.musicVC!=nil && [delegate.musicVC isPlaying]) {
        [delegate.musicVC pauseCurrentMusic];
    }
}

-(void)startPlay
{
    [self configAppMusic];
    
    LEOUtility *utility=[LEOUtility getInstance];
    NSString *path=[[utility cachePathWithName:@"download"] stringByAppendingPathComponent:_item.cacheName];
    path=[path stringByAppendingPathExtension:[_item.displayName pathExtension]];
    NSURL *url=[NSURL fileURLWithPath:path];
    
    LEOVideoViewController *movieController=[[LEOVideoViewController alloc] initWithContentURL:url];
    [movieController.moviePlayer setMovieSourceType:MPMovieSourceTypeFile];
    
    [self presentMoviePlayerViewControllerAnimated:movieController];
    [[movieController moviePlayer] play];
    [movieController release];
}
@end
