//
//  LEOAppDelegate.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-10-22.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEOTabBarViewController.h"
@class LEOContentListViewController;
@class LEOUploadViewController;
@class LEOMusicViewController;
@class LEOWebDAVClient;
@class LEOServerInfo;
@class LEODoubleModeViewController;
@class LEOSettingsViewController;
@class LEONetworkController;

@interface LEOAppDelegate : UIResponder <UIApplicationDelegate>{
    LEOTabBarViewController *_rootTabBarController;
    LEOTabBarViewController *_serverTabBarController;
//    LEOContentListViewController *_contentListVC;
    LEODoubleModeViewController *_contentListVC;
    LEOUploadViewController *_uploadVC;
    LEOMusicViewController *_musicVC;
    LEOSettingsViewController *_settingsVC;
    UINavigationController *_navSettingsVC;
    LEOWebDAVClient *client;
    LEONetworkController *networkController;
    
    LEOServerInfo *_currentServer;
    
    UIBackgroundTaskIdentifier oldTaskId;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readonly) LEOTabBarViewController *rootTabBarController;
@property (nonatomic, readonly) LEOTabBarViewController *serverTabBarController;
@property (nonatomic, readonly) LEOServerInfo *currentServer;
//@property (nonatomic, readonly) LEOContentListViewController *contentListVC;
@property (nonatomic, readonly) LEODoubleModeViewController *contentListVC;
@property (nonatomic, readonly) LEOMusicViewController *musicVC;
@property (nonatomic, readonly) LEOWebDAVClient *client;
@property (nonatomic, readonly) LEONetworkController *networkController;

-(LEOWebDAVClient *)setupClient:(LEOServerInfo *)info;
-(LEONetworkController *)setupNetwork:(LEOServerInfo *)info;
-(void)setupCurrentServer:(LEOServerInfo *)info;
-(void)clearCurrentServer;
@end
