//
//  LEOMusicView.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-6.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LEOMusicViewDelegate;

@interface LEOMusicView : UIView
@property (assign) id<LEOMusicViewDelegate> delegate;
-(void)setSliderMax:(CGFloat)max;
-(void)setSliderCurrent:(CGFloat)cur;
-(void)setStatus:(BOOL)isPlaying;
-(void)setEnableToUser:(BOOL)enable;
@end

@protocol LEOMusicViewDelegate <NSObject>

@required
-(void)sliderValueChanged:(id)sender;
-(void)previousButton:(id)sender;
-(void)playButton:(id)sender;
-(void)nextButton:(id)sender;
@end