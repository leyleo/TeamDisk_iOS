//
//  LEOChooseCopyPathViewController.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-12-20.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEOEditToolBar.h"
#import "LEOWebDAVRequest.h"
#import "ELCImagePickerController.h"
#import "MBProgressHUD.h"

@class LEOWebDAVItem;
@class LEOWebDAVClient;
@class LEOServerInfo;

@interface LEOChooseCopyPathViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,
LEOEditToolBarDelegate,LEOWebDAVRequestDelegate,MBProgressHUDDelegate>
{
    LEOWebDAVClient *_currentClient;
}
-(id)initWithPath:(NSString *)path;
-(id)initWithItem:(LEOWebDAVItem *)_item;
-(void)loadCurrentPath;
-(void)setupClient:(LEOServerInfo *)info;
@property (assign) id parent;

@end
