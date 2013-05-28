//
//  LEONewServerViewController.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-10-29.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
@class LEOServerListViewController;
@class LEOServerInfo;

@interface LEONewServerViewController : UIViewController<UITextFieldDelegate,MBProgressHUDDelegate>
-(void)setServerListVCInstance:(LEOServerListViewController *)one;
-(id)initWithServerInfo:(LEOServerInfo *)info atIndex:(NSInteger)index;
@end