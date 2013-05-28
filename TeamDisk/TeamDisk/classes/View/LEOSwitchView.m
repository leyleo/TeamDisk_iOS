//
//  LEOSwitchView.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-22.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOSwitchView.h"
#import "LEODefines.h"

@interface LEOSwitchView ()
{
    UIButton *_left;
    UIButton *_right;
    UILabel *_contentLabel;
}
@end

@implementation LEOSwitchView
@synthesize delegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGRect rect=frame;
        rect.origin.x=rect.size.width/2.0-kNavSwitcherWidth;
        rect.size.width=kNavSwitcherWidth;
        _left=[[UIButton alloc] initWithFrame:rect];
        _left.adjustsImageWhenHighlighted=NO;
        UIImage *leftOff=[UIImage imageNamed:@"/res/leftoff.png"];
        leftOff=[leftOff stretchableImageWithLeftCapWidth:3 topCapHeight:4];
        UIImage *leftOn=[UIImage imageNamed:@"/res/lefton.png"];
        [leftOn stretchableImageWithLeftCapWidth:3 topCapHeight:4];
        [_left setImage:[UIImage imageNamed:@"/res/thumbIcon.png"] forState:UIControlStateNormal];
        [_left setImage:[UIImage imageNamed:@"/res/thumbIcon.png"] forState:UIControlStateHighlighted];
        [_left setImage:[UIImage imageNamed:@"/res/thumbIcon.png"] forState:UIControlStateDisabled];
        [_left setBackgroundImage:leftOff forState:UIControlStateNormal];
//        [_left setBackgroundImage:nil forState:UIControlStateDisabled];
//        [_left setBackgroundImage:leftOff forState:UIControlStateHighlighted];
//        [_left setBackgroundImage:leftOn forState:UIControlStateSelected];
        [_left setBackgroundImage:leftOn forState:UIControlStateDisabled];
        
        [_left addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_left];
        
        rect.origin.x+=rect.size.width;
        _right=[[UIButton alloc] initWithFrame:rect];
        _right.adjustsImageWhenHighlighted=NO;
        UIImage *rightOff=[UIImage imageNamed:@"/res/rightoff.png"];
        rightOff=[rightOff stretchableImageWithLeftCapWidth:3 topCapHeight:4];
        UIImage *rightOn=[UIImage imageNamed:@"/res/righton.png"];
        [rightOn stretchableImageWithLeftCapWidth:3 topCapHeight:4];
        [_right setImage:[UIImage imageNamed:@"/res/listIcon.png"] forState:UIControlStateNormal];
        [_right setImage:[UIImage imageNamed:@"/res/listIcon.png"] forState:UIControlStateHighlighted];
        [_right setImage:[UIImage imageNamed:@"/res/listIcon.png"] forState:UIControlStateDisabled];
        [_right setBackgroundImage:rightOff forState:UIControlStateNormal];
//        [_right setBackgroundImage:rightOff forState:UIControlStateHighlighted];
//        [_right setBackgroundImage:rightOn forState:UIControlStateSelected];
        
        [_right setBackgroundImage:rightOn forState:UIControlStateDisabled];
        [_right addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_right];
        
        _contentLabel=[[UILabel alloc] initWithFrame:frame];
        [_contentLabel setBackgroundColor:[UIColor clearColor]];
        [_contentLabel setTextColor:[UIColor whiteColor]];
        [_contentLabel setFont:[UIFont boldSystemFontOfSize:20]];
        _contentLabel.textAlignment=UITextAlignmentCenter;
        [self addSubview:_contentLabel];
        [self setEnabled:NO];
    }
    return self;
}

-(void)setEnabled:(BOOL)_enabled
{
    _contentLabel.hidden=_enabled;
    _left.hidden=!_enabled;
    _right.hidden=!_enabled;
}

-(BOOL)enabled
{
    return _contentLabel.hidden;
}

-(void)buttonClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(toggleAction:)]) {
        [self.delegate toggleAction:sender];
    }
}

-(void)setTitle:(NSString *)string
{
    _contentLabel.text=string;
}

-(void)setLeftOn:(BOOL)_leftOn
{
    if (!_contentLabel.hidden) {
        return;
    }else {
//        _left.selected=_leftOn;
        _left.enabled=!_leftOn;
//        _right.selected=!_leftOn;
        _right.enabled=_leftOn;
    }
}

-(void)dealloc
{
    [_left release];
    [_right release];
    [_contentLabel release];
    [super dealloc];
}

@end
