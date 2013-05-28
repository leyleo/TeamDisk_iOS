//
//  LEOEditToolBar.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-10-26.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LEOEditToolBarDelegate;

@interface LEOEditToolBar : UIView
@property(assign) id<LEOEditToolBarDelegate> delegate;
- (id)initWithItems:(NSArray *)items;
-(void)setBackgroudImage:(NSString *)resPath;
-(void)setupItems:(NSArray *)items;
-(void)hideEditTooBar:(BOOL)hide;
-(void)hideEditTooBar:(BOOL)hide fromLeft:(BOOL)left;
-(void)hideEditToolBarWithoutAnim:(BOOL)hide;
-(void)setButtonStatus:(BOOL)enabled AtIndex:(NSInteger)index;
-(void)setToggleTextMore:(NSString *)string1 AtIndex:(NSInteger)index;
@end

@protocol LEOEditToolBarDelegate <NSObject>
@required
-(void)didSelectedEditToolBarIndex:(NSInteger)index;
@optional
-(void)didClickToggleButton:(UIButton *)button;
@end