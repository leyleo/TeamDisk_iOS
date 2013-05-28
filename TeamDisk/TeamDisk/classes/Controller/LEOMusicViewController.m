//
//  LEOMusicViewController.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-10-25.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOMusicViewController.h"
#import "LEODefines.h"
#import "LEOAppDelegate.h"
#import "LEOMusicView.h"
#import "LEOMusicListCell.h"
#import "LEOUtility.h"
#import "LEOWebDAVDownloadRequest.h"
#import "LEOWebDAVClient.h"
#import "LEOMusicItem.h"
#import "LEOServerInfo.h"

@interface LEOMusicViewController ()
{
    UIButton *editButtonView;
    LEOMusicView *_playbackMenu;
    UITableView *_musicListView;
    NSMutableArray *_musicList;
    NSInteger currentIndex;
    LEOMusicItem *_currentMusic;
    CGFloat currentTime;
    CGFloat maxTime;
    
    AVAudioPlayer *player;
    NSTimer *updateTimer;
    
    UIBackgroundTaskIdentifier oldTaskId;
}
@end

@implementation LEOMusicViewController

- (id)init
{
    self=[super init];
    if(self){
        self.title=NSLocalizedString(@"Music",@"");
        editButtonView=[UIButton buttonWithType:UIButtonTypeCustom];
        editButtonView.frame=CGRectMake(0,kLEONavBarBtnTopY,kDefalutNavItemWidth,kLEONavBarBtnHeight);
        [editButtonView setTitle:NSLocalizedString(@"Clear", @"") forState:UIControlStateNormal];
        [editButtonView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [editButtonView setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
        [editButtonView setBackgroundImage:[UIImage imageNamed:kNavigationEditBg] forState:UIControlStateNormal];
        [editButtonView setBackgroundImage:[UIImage imageNamed:kNavigationEditBgHighlight] forState:UIControlStateHighlighted];
        [editButtonView.titleLabel setFont:[UIFont systemFontOfSize:kLEONavBarFontSz]];
        [editButtonView addTarget:self action:@selector(clearPlayList) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *editButton=[[[UIBarButtonItem alloc] initWithCustomView:editButtonView] autorelease];
        self.navigationItem.rightBarButtonItem=editButton;
        
        _musicList=[[NSMutableArray alloc] init];
        currentIndex=-1;
        _currentMusic=nil;
        currentTime=0.0;
        maxTime=0.0;
        editButtonView.enabled=NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	UIImage *stretchImage=[UIImage imageNamed:kNavigationBg];
    stretchImage=[stretchImage stretchableImageWithLeftCapWidth:1 topCapHeight:0];
	[self.navigationController.navigationBar setBackgroundImage:stretchImage forBarMetrics:UIBarMetricsDefault];
    
    CGRect frame=self.view.frame;
    _playbackMenu = [[LEOMusicView alloc] initWithFrame:CGRectMake(frame.origin.x, 0, frame.size.width, kMusicViewPlaybackHeight)];
    [_playbackMenu setDelegate:self];
    
    [self.view addSubview:_playbackMenu];
    
    _musicListView = [[UITableView alloc] initWithFrame:CGRectMake(frame.origin.x, 0+kMusicViewPlaybackHeight, frame.size.width, frame.size.height-kMusicViewPlaybackHeight-kLEOTabBarHeight-kLEONavBarHeight) style:UITableViewStylePlain];
    [_musicListView setDataSource:self];
    [_musicListView setDelegate:self];
    [_musicListView setBounces:NO];
    _musicListView.backgroundColor=[UIColor colorWithRed:kBackgroundColorR green:kBackgroundColorG blue:kBackgroundColorB alpha:kBackgroundColorA];
    [self.view addSubview:_musicListView];
    
    UIView *footer=[[UIView alloc]initWithFrame:CGRectZero];
    [_musicListView setTableFooterView:footer];
    [footer release];
    
    if (_musicList && [_musicList count]>0) {
        [_playbackMenu setEnableToUser:YES];
        editButtonView.enabled=YES;
    }
    
//    AVAudioSession *session = [AVAudioSession sharedInstance];
//    [session setActive:YES error:nil];
//    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
//    
//    oldTaskId = UIBackgroundTaskInvalid;
//    oldTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
    
    
    if (player) {
        [_playbackMenu setSliderMax:maxTime];
        [_playbackMenu setSliderCurrent:currentTime];
        [_playbackMenu setStatus:player.playing];
    }
    [self becomeFirstResponder];

    NSLog(@"music did load");
}

-(void)dealloc
{
//    [self clearMusicController];
//    if (oldTaskId!= UIBackgroundTaskInvalid){
//        [[UIApplication sharedApplication] endBackgroundTask: oldTaskId];
//    }
    [self resignFirstResponder];
    [_playbackMenu removeFromSuperview];
    [_playbackMenu release];
    [_musicListView removeFromSuperview];
    [_musicListView release];
    [super dealloc];
}

#pragma mark -

//- (void) viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
//    [self becomeFirstResponder];
//}
//
//- (void) viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
//    [self resignFirstResponder];
//}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

//- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
//    if (receivedEvent.type == UIEventTypeRemoteControl) {
//        
//        switch (receivedEvent.subtype) {
//                
//            case UIEventSubtypeRemoteControlTogglePlayPause:
//                [self playButton:nil];
//                break;
//                
//            case UIEventSubtypeRemoteControlPreviousTrack:
//                [self previousButton:nil];
//                break;
//                
//            case UIEventSubtypeRemoteControlNextTrack:
//                [self nextButton:nil];
//                break;
//                
//            default:
//                break;  
//        }  
//    }  
//}
#pragma mark -
-(void)clearMusicController
{
    [self clearPlayList];
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self removeClient];
}

-(NSInteger)addMusic:(LEOWebDAVItem *)one
{
    NSInteger i=0;
    LEOMusicItem *item;
    NSInteger count=[_musicList count];
    for (i=0; i<count; i++) {
        LEOMusicItem *item=[_musicList objectAtIndex:i];
        if ([item.url isEqualToString:one.url]) {
            break;
        }
    }
    if (i>count-1) {
        // 不存在对应元素
        item=[[LEOMusicItem alloc] initWithItem:one];
        [_musicList addObject:item];
        [item release];
        [_playbackMenu setEnableToUser:YES];
        editButtonView.enabled=YES;
        [_musicListView reloadData];
        return [_musicList indexOfObject:item];
    }else{
        return i;
    }
}

-(void)playMusic:(LEOWebDAVItem *)one
{
    NSLog(@"play");
    currentIndex=[self addMusic:one];
    _currentMusic=[_musicList objectAtIndex:currentIndex];
    currentTime=0.0;
    if (player) {
        [player stop];
        player.delegate=nil;
        [player release];
        player=nil;
    }
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self playCurrentMusic];
}

-(void)pauseCurrentMusic
{
    [player pause];
    currentTime=player.currentTime;
    [self updateViewForPlayer];
}

-(BOOL)isPlaying
{
    BOOL result=NO;
    if (player!=nil) {
        if (player.isPlaying) {
            result = YES;
        }
    }
    return result;
}

#pragma mark - Request Methods
-(void)setupClient
{
    if (_currentClient!=nil) {
        [self removeClient];
    }
    LEOAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    LEOServerInfo *info=delegate.currentServer;
    _currentClient=[[LEOWebDAVClient alloc] initWithRootURL:[NSURL URLWithString:info.url]
                                                andUserName:info.userName
                                                andPassword:info.password];
}

-(void)removeClient
{
    if (_currentClient!=nil) {
        [_currentClient cancelRequest];
        [_currentClient release];
        _currentClient=nil;
    }
}

-(void)downloadUnderBackground
{
    if (_currentClient==nil) {
        [self setupClient];
    }
    LEOWebDAVDownloadRequest *downRequest=[[LEOWebDAVDownloadRequest alloc] initWithPath:_currentMusic.href];
    [downRequest setDelegate:self];
    [_currentClient enqueueRequest:downRequest];
}
#pragma mark - Private method
-(void)clearPlayList
{
    if (player) {
        [player stop];
        player.delegate=nil;
        [self updateViewForPlayer];
        [player release];
        player=nil;
    }
    [_musicList removeAllObjects];
    [_musicListView reloadData];
    [_playbackMenu setEnableToUser:NO];
    currentIndex=-1;
    _currentMusic=nil;
    currentTime=0.0;
    maxTime=0.0;
    editButtonView.enabled=NO;
}

-(void)playCurrentMusic
{
    LEOUtility *utility=[LEOUtility getInstance];
    LEOWebDAVItem *curMusic=[_musicList objectAtIndex:currentIndex];
    NSString *path=[[utility cachePathWithName:@"download"] stringByAppendingPathComponent:curMusic.cacheName];
    path=[path stringByAppendingPathExtension:[curMusic.displayName pathExtension]];
    if ([utility isExistFile:path]) {
        // 播放
        NSURL *fileURL=[[NSURL alloc] initFileURLWithPath:path];
        NSError *error=nil;
        if (player==nil) {
            player=[[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
            if (error) {
                NSLog(@"##error:%@",error);
                [fileURL release];
                return;
            }
            player.delegate=self;
            [player setNumberOfLoops:0];
            [player prepareToPlay];
            maxTime=player.duration;
        }
        [fileURL release];
        [player setCurrentTime:currentTime];
        [player play];
        [self updateViewForPlayer];
        [_musicListView reloadData];
    }else{
        [self downloadUnderBackground];
    }
    
}

-(void)updateViewForPlayer
{
    [_playbackMenu setSliderMax:maxTime];
    if (updateTimer)
		[updateTimer invalidate];
	if (player.playing)
	{
		updateTimer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateCurrentTime) userInfo:player repeats:YES];
        [_playbackMenu setStatus:YES];
	}
	else
	{
		updateTimer = nil;
        [_playbackMenu setStatus:NO];
	}
}

-(void)updateCurrentTime
{
    [_playbackMenu setSliderCurrent:player.currentTime];
}

#pragma mark - Music View delegate
-(void)sliderValueChanged:(id)sender
{
    UISlider *slider=sender;
    player.currentTime=slider.value;
}
-(void)previousButton:(id)sender
{
    if (currentIndex<=0) {
        [self playMusic:[_musicList lastObject]];
    }else{
        [self playMusic:[_musicList objectAtIndex:currentIndex-1]];
    }
}
-(void)playButton:(id)sender
{
    if (player.playing) {
        [self pauseCurrentMusic];
    }else {
        
        if (currentIndex>-1) {
            [self playCurrentMusic];
            return;
        }
        [self playMusic:[_musicList objectAtIndex:0]];
    }
}
-(void)nextButton:(id)sender
{
    if (currentIndex >= [_musicList count]-1) {
        [self playMusic:[_musicList objectAtIndex:0]];
    }else{
        [self playMusic:[_musicList objectAtIndex:currentIndex+1]];
    }
}

#pragma mark - AVAudio Player delegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self nextButton:nil];
}

#pragma mark - LEOWebDAV delegate
- (void)request:(LEOWebDAVRequest *)aRequest didFailWithError:(NSError *)error
{
    NSLog(@"error:%@",[error description]);
}

- (void)request:(LEOWebDAVRequest *)aRequest didSucceedWithResult:(id)result
{
    NSLog(@"sucess");
    if ([aRequest isKindOfClass:[LEOWebDAVDownloadRequest class]]) {
        // 下载类请求
        NSData *myDate=result;
        NSString *cacheFolder=[[LEOUtility getInstance] cachePathWithName:@"download"];
        LEOMusicItem *curMusic=[_musicList objectAtIndex:currentIndex];
        NSString *cacheUrl=[[cacheFolder stringByAppendingPathComponent:curMusic.cacheName] stringByAppendingPathExtension:[curMusic.displayName pathExtension]];
        [myDate writeToFile:cacheUrl atomically:YES];
        if (player.isPlaying==NO) {
            [self playCurrentMusic];
        }
    }
}

#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_musicList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MusicListCell";
    LEOMusicListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil){
        cell = [[[LEOMusicListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    LEOMusicItem *item=[_musicList objectAtIndex:indexPath.row];
    cell.fileNameLabel.text=item.displayName;
    cell.detailLabel.text=item.createDate;
    if (indexPath.row==currentIndex) {
        [cell isPlaying:YES];
//        cell.accessoryType=UITableViewCellAccessoryCheckmark;
    }else{
        [cell isPlaying:NO];
//        cell.accessoryType=UITableViewCellAccessoryNone;
//        cell.selected=NO;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_musicListView.editing) {
        
    }
    else {
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self playMusic:[_musicList objectAtIndex:indexPath.row]];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 圆圈
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kContentListCellHeight;
}
@end
