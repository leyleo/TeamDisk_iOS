//
//  KTThumbView.h
//  KTPhotoBrowser
//
//  Created by Kirby Turner on 2/3/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LEODoubleModeViewController;

@interface KTThumbView : UIButton 
{
@private
   LEODoubleModeViewController *controller_;
}

@property (nonatomic, assign) LEODoubleModeViewController *controller;

- (id)initWithFrame:(CGRect)frame;
- (void)setThumbImage:(UIImage *)newImage;
- (void)setHasBorder:(BOOL)hasBorder;

@end

