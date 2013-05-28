//
//  LEOSwitchView.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-22.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LEOSwitchViewDelegate;
@interface LEOSwitchView : UIView
@property(nonatomic,assign) id<LEOSwitchViewDelegate> delegate;
-(void)setEnabled:(BOOL)_enabled;
-(BOOL)enabled;
-(void)setTitle:(NSString *)string;
-(void)setLeftOn:(BOOL)_leftOn;
@end
@protocol LEOSwitchViewDelegate <NSObject>

-(void)toggleAction:(UIButton *)button;

@end