//
//  LEOThumbnailItem.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-15.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LEOThumbnailItem : UIView
{
    UIImageView *overlayView;
    UIImageView *contentView;
}
-(void)setSelected:(BOOL)selected;
-(void)setFrontImage:(UIImage *)image;
-(BOOL)isSelected;
//- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
@end
