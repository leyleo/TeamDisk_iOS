//
//  LEOTabBar.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-10-23.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LEOTabBarDelegate;

@interface LEOTabBar : UIView {
    UIImageView *_backgroundView;
    NSMutableArray *_buttons;
}
@property (assign) id<LEOTabBarDelegate> delegate;
- (id)initWithItems:(NSArray *)items;
- (void)setupButtons:(NSArray *)items;
- (void)setSelectedIndex:(NSInteger)index;
@end


// 代理类
@protocol LEOTabBarDelegate<NSObject>

//-(void)switchViewController:(UIViewController *)viewController;
-(void)tabBar:(LEOTabBar *)tabBar didSelectedIndex:(NSInteger)index;
@end