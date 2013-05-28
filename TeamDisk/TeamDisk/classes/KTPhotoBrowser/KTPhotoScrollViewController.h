//
//  KTPhotoScrollViewController.h
//  KTPhotoBrowser
//
//  Created by Kirby Turner on 2/4/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEODetailViewController.h"
#import "LEOEditToolBar.h"
#import "MBProgressHUD.h"

@class LEOImageDataSource;
@protocol KTPhotoBrowserDataSource;

@interface KTPhotoScrollViewController : LEODetailViewController<UIScrollViewDelegate, UIActionSheetDelegate,MBProgressHUDDelegate>
{
    LEOImageDataSource* dataSource_;
    UIScrollView *scrollView_;
    
    NSUInteger startWithIndex_;
    NSInteger currentIndex_;
    NSInteger photoCount_;

    NSMutableArray *photoViews_;

    // these values are stored off before we start rotation so we adjust our content offset appropriately during rotation
    int firstVisiblePageIndexBeforeRotation_;
    CGFloat percentScrolledIntoFirstVisiblePage_;

    UIStatusBarStyle statusBarStyle_;

    BOOL statusbarHidden_; // Determines if statusbar is hidden at initial load. In other words, statusbar remains hidden when toggling chrome.
    BOOL isChromeHidden_;
    BOOL rotationInProgress_;

    BOOL viewDidAppearOnce_;
    BOOL navbarWasTranslucent_;

    NSTimer *chromeHideTimer_;
}

@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@property (nonatomic, assign, getter=isStatusbarHidden) BOOL statusbarHidden;

- (id)initWithDataSource:(LEOImageDataSource *)dataSource andStartWithPhotoAtIndex:(NSUInteger)index;
- (void)toggleChromeDisplay;

@end
