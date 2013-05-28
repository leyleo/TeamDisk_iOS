//
//  LEOContentListViewController.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-10-25.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEOEditToolBar.h"
#import "LEOWebDAVRequest.h"
#import "LEOContentListCell.h"
#import "MBProgressHUD.h"
#import "EGORefreshTableHeaderView.h"

@class LEOWebDAVItem;
@interface LEOContentListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate,
LEOEditToolBarDelegate,LEOWebDAVRequestDelegate,
LEOContentListCellDelegate,MBProgressHUDDelegate,
EGORefreshTableHeaderDelegate,
UIActionSheetDelegate,UIDocumentInteractionControllerDelegate>
-(id)initWithPath:(NSString *)path;
-(id)initWithItem:(LEOWebDAVItem *)_item;
-(void)loadCurrentPath;
@end
