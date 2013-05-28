//
//  LEORenameViewController.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-12.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEOWebDAVRequest.h"
#import "MBProgressHUD.h"

@class LEOWebDAVItem;
@class LEOWebDAVClient;
@interface LEORenameViewController : UIViewController<UITextFieldDelegate,LEOWebDAVRequestDelegate,MBProgressHUDDelegate>
{
    LEOWebDAVClient *_currentClient;
}
@property (assign) id parentInstance;
- (id)initWithCurrentItem:(LEOWebDAVItem *)item;
@end
