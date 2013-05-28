//
//  LEOThumbnailItem.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-15.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOThumbnailItem.h"
#import "LEODefines.h"

@implementation LEOThumbnailItem

- (id)init
{
    self = [super init];
    if (self) {
        self.frame=CGRectMake(0, 0, kImageThumbnailSz, kImageThumbnailSz);
        contentView=[[UIImageView alloc] initWithFrame:self.frame];
        [self addSubview: contentView];
        overlayView=[[UIImageView alloc] initWithFrame:self.frame];
        [overlayView setImage:[UIImage imageNamed:@"Overlay.png"]];
        [self addSubview:overlayView];
        [self setSelected:NO];
    }
    return self;
}

-(void)setSelected:(BOOL)selected
{
    overlayView.hidden=!selected;
}

-(void)setFrontImage:(UIImage *)image
{
    [contentView setImage:image];
}

-(BOOL)isSelected
{
    return !overlayView.hidden;
}

-(void)dealloc
{
    [overlayView release];
    [contentView release];
    [super dealloc];
}
@end
