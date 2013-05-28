//
//  LEOUploadViewController.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-10-25.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEOEditToolBar.h"
#import "LEOUploadView.h"
#import "ELCImagePickerController.h"
#import "LEOCameraPickerController.h"
#import "MBProgressHUD.h"

@class LEOWebDAVClient;
@interface LEOUploadViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,
LEOEditToolBarDelegate,LEOUploadViewDelegate,
ELCImagePickerControllerDelegate,LEOCameraPickerControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MBProgressHUDDelegate>
{
    LEOWebDAVClient *_currentClient;
}
-(void)setupClient;
-(void)removeClient;
-(void)clearUploadController;
@end
