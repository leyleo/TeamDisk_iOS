//
//  LEOCameraUploadViewController.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-12-6.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEOUploadToolBar.h"
#import "MBProgressHUD.h"

@protocol LEOCameraPickerControllerDelegate;

@interface LEOCameraPickerController : UIViewController<LEOUploadToolBarDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MBProgressHUDDelegate>
{
    
}
@property (nonatomic, assign) id<LEOCameraPickerControllerDelegate> delegate;
@property (readonly) NSString *uploadPath;
-(void)setPreviewImage:(UIImage *)image;
-(void)setUploadPath:(NSString *)path;
@end


@protocol LEOCameraPickerControllerDelegate <NSObject>
-(void)leoCameraPickerController:(LEOCameraPickerController *)picker didFinishPickingPictureWithInfo:(NSDictionary *)info andPath:(NSString *)path;
-(void)leoCameraPickerControllerDidCancel:(LEOCameraPickerController *)picker;
@end