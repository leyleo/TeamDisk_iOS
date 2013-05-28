//
//  LEOTabBarViewController.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-10-23.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEOTabBar.h"

@interface LEOTabBarViewController : UIViewController<LEOTabBarDelegate> {
    LEOTabBar *_tabBar;
}

@property(nonatomic) NSUInteger selectedIndex;
@property(nonatomic, assign) UIViewController *selectedViewController;
@property(nonatomic, readonly) NSMutableArray *viewControllers;
@property(nonatomic, retain) LEOTabBar *tabBar;

- (id)initWithViewControllers:(NSArray *)controllers andItems:(NSArray *)items;
-(void)hideTabBar:(BOOL)hide;
-(void)hideTabBar:(BOOL)hide fromLeft:(BOOL)left;
-(void)hideTabBarFromBottom:(BOOL)hide;
-(void)hideTabBarWithoutAnim:(BOOL)hide;
@end
