//
//  LEOUploadToolBar.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-7.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LEOUploadToolBarDelegate;

@interface LEOUploadToolBar : UIView
{
    UIImageView *_backgroundView;
    NSString *_path;
    UIButton *chooseBtn;
}
@property(assign) id<LEOUploadToolBarDelegate> delegate;

-(void)hideUploadToolBar:(BOOL)hide;
-(void)setDisplayPath:(NSString *)path;
@end

@protocol LEOUploadToolBarDelegate <NSObject>

@required
-(void)chooseButton:(id)sender;
-(void)uploadButton:(id)sender;

@end