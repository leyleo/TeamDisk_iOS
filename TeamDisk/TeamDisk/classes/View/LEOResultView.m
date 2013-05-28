//
//  LEOResultView.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-12-3.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOResultView.h"
#import "LEODefines.h"

@implementation LEOResultView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGRect rect=frame;
        rect.size.height-=2*kLEOResultViewLabelHeight;
        _imageView=[[UIImageView alloc] initWithFrame:rect];
        [_imageView setContentMode:UIViewContentModeCenter];
        [self addSubview:_imageView];
        rect.origin.y=rect.size.height/2.0+kLEOResultViewLabelTopY;
        rect.size.height=kLEOResultViewLabelHeight*3;
        _reasonLabel=[[UILabel alloc] initWithFrame:rect];
        _reasonLabel.numberOfLines=0;
        _reasonLabel.textAlignment=UITextAlignmentCenter;
        [_reasonLabel setBackgroundColor:[UIColor clearColor]];
        _reasonLabel.font=[UIFont systemFontOfSize:kLEOResultViewLabelFontSz];
        [self addSubview:_reasonLabel];
    }
    return self;
}

-(void)setImage:(UIImage*)image
{
    _imageView.image=image;
}

-(void)setText:(NSString *)string
{
    _reasonLabel.text=string;
}
@end
