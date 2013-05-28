//
//  LEOUploadView.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-7.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LEOUploadViewDelegate;

@interface LEOUploadView : UIView
@property (assign) id<LEOUploadViewDelegate> delegate;
@end

@protocol LEOUploadViewDelegate <NSObject>

@required
-(void)pictureButton:(id)sender;
-(void)cameraButton:(id)sender;
@end