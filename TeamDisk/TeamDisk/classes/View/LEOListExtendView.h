//
//  LEOListExtendView.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-12.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LEOListExtendViewDelegate;

@interface LEOListExtendView : UIView
@property(assign) id<LEOListExtendViewDelegate> delegate;
- (id)initWithItems:(NSArray *)items;
- (id)initWithItems:(NSArray *)items withOriginalHeight:(CGFloat)height;
-(void)setupButtons:(NSArray *)items;
-(void)hideExtendView:(BOOL)hide;
@end

@protocol LEOListExtendViewDelegate <NSObject>

-(void)didSelectedExtendIndex:(NSInteger)index;

@end