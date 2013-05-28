//
//  LEOServerListViewController.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-10-22.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEOEditToolBar.h"
#import "LEOServerInfo.h"
#import "LEOWebDAVRequest.h"

@interface LEOServerListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,LEOEditToolBarDelegate,LEOWebDAVRequestDelegate>
-(BOOL)updateNewServerInfo:(LEOServerInfo *)info atIndex:(NSInteger)index;
@end
