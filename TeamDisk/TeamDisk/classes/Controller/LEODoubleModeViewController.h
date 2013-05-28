//
//  LEODoubleModeViewController.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-14.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEOEditToolBar.h"
#import "LEOWebDAVRequest.h"
#import "LEOContentListCell.h"
#import "LEOImageThumbnailCell.h"
#import "MBProgressHUD.h"
#import "EGORefreshTableHeaderView.h"
#import "LEOSwitchView.h"
#import "LEOWebDAVClient.h"
#import "LEOChooseCopyPathViewController.h"
#import "LEOChoosePathViewController.h"
//#import "KTPhotoBrowserDataSource.h"

@class LEOWebDAVItem;
@interface LEODoubleModeViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate,
LEOEditToolBarDelegate,LEOWebDAVRequestDelegate,
LEOContentListCellDelegate,LEOImageThumbnailCellDelegate,
MBProgressHUDDelegate, EGORefreshTableHeaderDelegate,
LEOSwitchViewDelegate,
UIActionSheetDelegate,UIDocumentInteractionControllerDelegate>
{
    LEOWebDAVClient *_currentClient;
}
-(id)initWithPath:(NSString *)path;
-(id)initWithItem:(LEOWebDAVItem *)_item;
-(void)loadCurrentPath;
-(void)reloadData;
// move delegate
-(void)setUploadPath:(NSString *)path;
-(void)beforeFinishChooseMovePath;
// copy delegate
-(void)setCopyPath:(NSString *)path withServer:(LEOServerInfo *)serverInfo;
@end
