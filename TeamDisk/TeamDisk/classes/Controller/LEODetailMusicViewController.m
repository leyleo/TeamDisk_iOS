//
//  LEODetailMusicViewController.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-23.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEODetailMusicViewController.h"
#import "LEOUtility.h"
#import "LEOWebDAVItem.h"
#import "LEOAppDelegate.h"
#import "LEOMusicViewController.h"
#import "LEOTabBarViewController.h"
#import "AudioButton.h"

@interface LEODetailMusicViewController ()
{
    AudioButton *imageView;
    MBProgressHUD *_hub;
    BOOL jump;
    
    AVAudioPlayer *player;
    NSTimer *updateTimer;
    NSTimeInterval maxTime;
    NSTimeInterval currentTime;
}
@end

@implementation LEODetailMusicViewController

- (void)prepareDetail
{
    [super prepareDetail];
    
//	imageView=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
//    [imageView setImage:[UIImage imageNamed:@"/res/detail_playBtn.png"] forState:UIControlStateNormal];
//    [_displayView addSubview:imageView];
//    [imageView addTarget:self action:@selector(startPlay) forControlEvents:UIControlEventTouchUpInside];
//    imageView.center=_displayView.center;
//    [imageView setHidden:YES];
    imageView=[[AudioButton alloc] initWithFrame:CGRectMake(0, 0, 95, 95)];
    [imageView addTarget:self action:@selector(toggleMusicControl) forControlEvents:UIControlEventTouchUpInside];
    [_displayView addSubview: imageView];
    imageView.center=_displayView.center;
    [imageView setColourR:120.0/255.0 G:172.0/255.0 B:210.0/255.0 A:1];
    [imageView setHidden:YES];
    [imageView setProgress:0.0];
    
    NSArray *items=[NSArray arrayWithObjects:NSLocalizedString(@"Open In",@""), NSLocalizedString(@"Add to Music List",@""), NSLocalizedString(@"Delete",@""),nil];
    [_editToolBar setupItems:items];
    [_editToolBar setButtonStatus:NO AtIndex:0]; //初始将“打开为”设置为不可用
    jump=NO;
    
    player=nil;
    currentTime=0.0001;
    maxTime=1.0;
}

-(void)viewWillAppear:(BOOL)animated
{
    if (jump==YES) {
        [self hideToolBar:YES];
        jump=NO;
    }
    [super viewWillAppear:animated];
}

-(void)backToList
{
    if (_hub) {
        [_hub hide:NO];
        _hub.delegate=nil;
    }
    [self stopPlay];
    [super backToList];
}

-(void)dealloc
{
    if (_hub) {
        [_hub release];
    }
    [imageView release];
    [super dealloc];
}

-(void)detailTodo
{
    [super detailTodo];
    [imageView setHidden: NO];
}

-(void)configAppMusic
{
    LEOAppDelegate *delegate=[[UIApplication sharedApplication]delegate];
    if (delegate.musicVC!=nil && [delegate.musicVC isPlaying]) {
        [delegate.musicVC pauseCurrentMusic];
    }
}

-(void)detailTodo:(id)sender
{
    [super detailTodo];
    [imageView setHidden: NO];
}

-(void)toggleMusicControl
{
    if (player.playing) {
        [self pausePlay];
    } else {
        [self configAppMusic];
        [self startPlay];
    }
}

//-(void)startPlay
//{
//    LEOAppDelegate *delegate=[[UIApplication sharedApplication]delegate];
//    [delegate.serverTabBarController.tabBar setSelectedIndex:kLEOTabBarMusicIndex];
//    jump=YES;
//    [self hideToolBar:NO];
//    [delegate.musicVC playMusic:_item];
//}

-(void)startPlay
{
    if (player==nil) {
        LEOUtility *utility=[LEOUtility getInstance];
        NSString *path=[[utility cachePathWithName:@"download"] stringByAppendingPathComponent:_item.cacheName];
        path=[path stringByAppendingPathExtension:[_item.displayName pathExtension]];
        NSURL *fileURL=[[NSURL alloc] initFileURLWithPath:path];
        NSError *error=nil;
        player=[[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
        if (error) {
            NSLog(@"error:%@",error);
            [fileURL release];
            return;
        }
        player.delegate=self;
        [player prepareToPlay];
        [player setNumberOfLoops:-1];
        currentTime=0.0001;
        maxTime=player.duration;
        [fileURL release];
    }
    [player play];
    [self updateViews];
}

-(void)pausePlay
{
    if (player==nil) {
        return;
    }
    [player pause];
    currentTime=player.currentTime;
    [self updateViews];
}

-(void)stopPlay
{
    if (player==nil) {
        return;
    }
    [player stop];
    [self updateViews];
    player.delegate=nil;
    [player release];
    player=nil;
    maxTime=1.0;
    currentTime=0.0001;
}

-(void)updateViews
{
    if (updateTimer) {
        [updateTimer invalidate];
    }
    if (player==nil) {
        return;
    }
    if (player.playing) {
        updateTimer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(updateCurrentTime) userInfo:player repeats:YES];
        [imageView setImage:[UIImage imageNamed:stopImage]];
    }else {
        [imageView setImage:[UIImage imageNamed:playImage]];
        updateTimer=nil;
        
    }
    [imageView setNeedsDisplay];
}

-(void)updateCurrentTime
{
    [imageView setProgress:player.currentTime/maxTime];
}

-(void)hideToolBar:(BOOL)isHide
{
    LEOAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    if (isHide) {
        if([delegate.window.rootViewController respondsToSelector:@selector(hideTabBarWithoutAnim:)]){
            [delegate.window.rootViewController hideTabBarWithoutAnim:YES];
        }
        if([_editToolBar respondsToSelector:@selector(hideEditToolBarWithoutAnim:)]){
            [_editToolBar hideEditToolBarWithoutAnim:NO];
        }
    }else {
        if([delegate.window.rootViewController respondsToSelector:@selector(hideTabBarWithoutAnim:)]){
            [delegate.window.rootViewController hideTabBarWithoutAnim:NO];
        }
        if([_editToolBar respondsToSelector:@selector(hideEditToolBarWithoutAnim:)]){
            [_editToolBar hideEditToolBarWithoutAnim:YES];
        }
    }
}

-(void)addMusicToList
{
    LEOAppDelegate *delegate=[[UIApplication sharedApplication]delegate];
    BOOL result=[delegate.musicVC addMusic:_item];
    if (result>-1) {
        [self setupProgressHD:NSLocalizedString(@"Add Success", @"") isDone:YES];
    } else {
        [self setupProgressHDFailure:NSLocalizedString(@"Add Failure", @"")];
    }
}

#pragma mark - LEOEditToolBar delegate
-(void)didSelectedEditToolBarIndex:(NSInteger)index
{
    if (index==-1 || index==1) {
        // 打开为
        [self openFileIn];
    } else if (index==2 || index==-2) {
        //删除
        [self addMusicToList];
    } else if (index==3 || index==-3) {
        //删除
        [self showDeleteSheet:LEOContentSheetTagSingle];
    }
}

#pragma mark - MBProgress
-(void)setupProgressHD:(NSString *)text isDone:(BOOL)done
{
    if (_hub) {
        [_hub hide:YES];
        [_hub release];
        _hub=nil;
    }
    _hub=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_hub];
    _hub.delegate=self;
    _hub.labelText=text;
    _hub.customView=[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"/res/Checkmark.png"]] autorelease];
    _hub.mode=done?MBProgressHUDModeCustomView:MBProgressHUDModeIndeterminate;
    _hub.removeFromSuperViewOnHide=YES;
    [_hub show:YES];
    if (done) {
        [_hub hide:YES afterDelay:1.5];
    }
}

-(void)setupProgressHDFailure:(NSString *)text
{
    if (_hub) {
        [_hub hide:YES];
        [_hub release];
        _hub=nil;
    }
    _hub=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_hub];
    _hub.delegate=self;
    _hub.labelText=text;
    _hub.mode=MBProgressHUDModeCustomView;
    _hub.removeFromSuperViewOnHide=YES;
    [_hub show:YES];
    [_hub hide:YES afterDelay:1.5];
}
@end
