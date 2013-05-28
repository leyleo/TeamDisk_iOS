//
//  LEOMusicViewController.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-10-25.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEOEditToolBar.h"
#import "LEOMusicView.h"
#import "LEOWebDAVItem.h"
#import "LEOWebDAVRequest.h"
#import <AVFoundation/AVFoundation.h>
@class LEOWebDAVClient;
@interface LEOMusicViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,LEOMusicViewDelegate,AVAudioPlayerDelegate,LEOWebDAVRequestDelegate>
{
    LEOWebDAVClient *_currentClient;
}
-(NSInteger)addMusic:(LEOWebDAVItem *)one;
-(void)playMusic:(LEOWebDAVItem *)one;
-(void)pauseCurrentMusic;
-(void)setupClient;
-(void)removeClient;
-(void)clearMusicController;
-(BOOL)isPlaying;
@end
