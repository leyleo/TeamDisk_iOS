//
//  LEONewFolderViewController.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-8.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "LEOChoosePathViewController.h"
#import "LEOWebDAVRequest.h"
#import "MBProgressHUD.h"
@class LEOWebDAVClient;
@interface LEONewFolderViewController : UIViewController<UITextFieldDelegate,LEOWebDAVRequestDelegate,MBProgressHUDDelegate>
{
    LEOWebDAVClient *_currentClient;
}
//@property (assign) LEOChoosePathViewController *parentInstance;
@property (assign) id parentInstance;
- (id)initWithCurrentPath:(NSString *)path;
@end
