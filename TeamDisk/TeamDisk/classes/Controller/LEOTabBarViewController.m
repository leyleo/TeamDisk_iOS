//
//  LEOTabBarViewController.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-10-23.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOTabBarViewController.h"
#import "../Utilities/LEODefines.h"

@interface LEOTabBarViewController ()
{
    NSMutableArray *_viewControllers;
}
@end

@implementation LEOTabBarViewController

@synthesize selectedIndex;
@synthesize selectedViewController;
@synthesize viewControllers=_viewControllers;
@synthesize tabBar=_tabBar;

#pragma mark -
#pragma mark lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // 设定初始化选项，默认为0
    self.selectedIndex=-1;
    self.selectedViewController=nil;
	[_tabBar setSelectedIndex:kDefaultTabBarIndex];
    
}

-(void)dealloc {
    [_tabBar release];
    [_viewControllers release];
    [super dealloc];
}
#pragma mark - Public methods
- (id)initWithViewControllers:(NSArray *)controllers andItems:(NSArray *)items {
    self = [super init];
    if(self){
        _viewControllers=[[NSMutableArray alloc] initWithArray:controllers];
        _tabBar=[[LEOTabBar alloc] initWithItems:items];
        _tabBar.delegate=self;
        
        [self.view addSubview:_tabBar];
        [self.view setBackgroundColor:[UIColor darkGrayColor]];
        
    }
    return self;
}

-(void)hideTabBar:(BOOL)hide {
    if(hide){
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.tabBar.transform = CGAffineTransformMakeTranslation(320, 0);
                         }
                         completion:nil];
    }else{
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.tabBar.transform = CGAffineTransformMakeTranslation(0, 0);
                         }
                         completion:nil];
    }
}

-(void)hideTabBar:(BOOL)hide fromLeft:(BOOL)left {
    if(hide){
        NSInteger weight=left?1:-1;
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.tabBar.transform = CGAffineTransformMakeTranslation(320*weight, 0);
                         }
                         completion:nil];
    }else{
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.tabBar.transform = CGAffineTransformMakeTranslation(0, 0);
                         }
                         completion:nil];
    }
}

-(void)hideTabBarFromBottom:(BOOL)hide
{
    if(hide){
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.tabBar.transform = CGAffineTransformMakeTranslation(0, 44);
                         }
                         completion:nil];
    }else{
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.tabBar.transform = CGAffineTransformMakeTranslation(0, 0);
                         }
                         completion:nil];
    }
}

-(void)hideTabBarWithoutAnim:(BOOL)hide
{
    if (hide==YES) {
//        self.tabBar.hidden=YES;
        self.tabBar.transform = CGAffineTransformMakeTranslation(-320, 0);
    } else {
//        self.tabBar.hidden=NO;
        self.tabBar.transform = CGAffineTransformMakeTranslation(0, 0);
    }
}

#pragma mark - Delegate
-(void)tabBar:(LEOTabBar *)tabBar didSelectedIndex:(NSInteger)index {
    // 不合理时不处理
    if(index<0 || index==self.selectedIndex)
        return;
    if(!self.viewControllers)
        return;
    NSInteger count=[self.viewControllers count];
    if(count<1 || index>=count)
        return;

    [self.selectedViewController.view removeFromSuperview];
    [self displaySelectedIndex:index];
}

#pragma mark - Private methods
-(void) displaySelectedIndex:(NSInteger)index {
    self.selectedViewController=[self.viewControllers objectAtIndex:index];
    self.selectedIndex=index;
    [self.view insertSubview:self.selectedViewController.view belowSubview:self.tabBar];
    CGRect frame= self.selectedViewController.view.frame;
    frame.origin.y=-20;
//    NSLog(@"selected:%f,%f,%f,%f",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
    self.selectedViewController.view.frame=frame;
}
@end
