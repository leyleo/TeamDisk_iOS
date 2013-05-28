//
//  LEOMusicSlider.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-6.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOMusicSlider.h"
#import "LEODefines.h"

@implementation LEOMusicSlider

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *minImage=[UIImage imageNamed:kMusicMinImage];
        UIImage *maxImage=[UIImage imageNamed:kMusicMaxImage];
        UIImage *thumbImage=[UIImage imageNamed:kMusicThumbImage];
//        UIImage *thumbSelImage=[UIImage imageNamed:kMusicThumbSelImage];
        minImage=[minImage stretchableImageWithLeftCapWidth:3.0 topCapHeight:0.0];
        maxImage=[maxImage stretchableImageWithLeftCapWidth:3.0 topCapHeight:0.0];
        
        [self setMinimumTrackImage:minImage forState:UIControlStateNormal];
        [self setMaximumTrackImage:maxImage forState:UIControlStateNormal];
        [self setThumbImage:thumbImage forState:UIControlStateNormal];
//        [self setThumbImage:thumbSelImage forState:UIControlStateHighlighted];

        [self setContinuous:YES];
    }
    return self;
}

@end
