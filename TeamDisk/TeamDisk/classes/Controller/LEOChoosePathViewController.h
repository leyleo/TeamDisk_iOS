//
//  LEOChoosePathViewController.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-8.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEOEditToolBar.h"
#import "LEOWebDAVRequest.h"
#import "ELCImagePickerController.h"
#import "MBProgressHUD.h"

@class LEOWebDAVItem;
@class LEOWebDAVClient;
@interface LEOChoosePathViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,LEOEditToolBarDelegate,LEOWebDAVRequestDelegate,MBProgressHUDDelegate>
{
    LEOWebDAVClient *_currentClient;
}
-(id)initWithPath:(NSString *)path;
-(id)initWithItem:(LEOWebDAVItem *)_item;
-(void)loadCurrentPath;
@property (assign) id parent;
@end
