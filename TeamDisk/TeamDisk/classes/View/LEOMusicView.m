//
//  LEOMusicView.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-6.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOMusicView.h"
#import "LEODefines.h"
#import "LEOMusicSlider.h"
#import <AVFoundation/AVFoundation.h>

@interface LEOMusicView ()
{
    LEOMusicSlider *_processSlider;
    AVAudioPlayer *_currentPlayer;
    UIImageView *_backgroundView;
    UIButton *preMusic;
    UIButton *playMusic;
    UIButton *nextMusic;
}
@end

@implementation LEOMusicView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate=nil;
        _backgroundView=[[UIImageView alloc] initWithFrame:frame];
        UIImage *strech=[UIImage imageNamed:kMusicViewBg];
        strech=[strech stretchableImageWithLeftCapWidth:3 topCapHeight:0];
        [_backgroundView setImage:strech];
        [self addSubview:_backgroundView];
        
        CGFloat left=(frame.size.width-kMusicSliderWidth)/2;
        _processSlider=[[LEOMusicSlider alloc] initWithFrame:CGRectMake(frame.origin.x+left, kMusicSliderTop, kMusicSliderWidth, kMusicSliderHeight)];
        [self setDefault];
        
        [self addSubview:_processSlider];
        [_processSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        UIImage *normal=[UIImage imageNamed:kMusicBtnBg];
        UIImage *highlight=[UIImage imageNamed:kMusicBtnBgHighlight];
        [normal stretchableImageWithLeftCapWidth:4 topCapHeight:4];
        [highlight stretchableImageWithLeftCapWidth:4 topCapHeight:4];
        
        CGFloat margin=(frame.size.width-3*kMusicBtnWidth)/4;
        CGRect rect=CGRectMake(0, kMusicBtnTop, kMusicBtnWidth, kMusicBtnHeight);
        rect.origin.x=frame.origin.x+margin;
        preMusic=[[UIButton alloc] initWithFrame:rect];
        [preMusic setBackgroundImage:normal forState:UIControlStateNormal];
        [preMusic setBackgroundImage:highlight forState:UIControlStateHighlighted];
        [preMusic setImage:[UIImage imageNamed:kMusicPreImage] forState:UIControlStateNormal];
        [preMusic addTarget:self action:@selector(previousButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:preMusic];
        
        rect.origin.x+=margin+kMusicBtnWidth;
        playMusic=[[UIButton alloc] initWithFrame:rect];
        [playMusic setBackgroundImage:normal forState:UIControlStateNormal];
        [playMusic setBackgroundImage:highlight forState:UIControlStateHighlighted];
        [playMusic setImage:[UIImage imageNamed:kMusicPlayImage] forState:UIControlStateNormal];
        [playMusic setImage:[UIImage imageNamed:kMusicPauseImage] forState:UIControlStateSelected];
        [playMusic addTarget:self action:@selector(playButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:playMusic];
        
        rect.origin.x+=margin+kMusicBtnWidth;
        nextMusic=[[UIButton alloc] initWithFrame:rect];
        [nextMusic setBackgroundImage:normal forState:UIControlStateNormal];
        [nextMusic setBackgroundImage:highlight forState:UIControlStateHighlighted];
        [nextMusic setImage:[UIImage imageNamed:kMusicNextImage] forState:UIControlStateNormal];
        [nextMusic addTarget:self action:@selector(nextButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:nextMusic];
        
        [self setEnableToUser:NO];
    }
    return self;
}

-(void)setSliderMax:(CGFloat)max
{
    _processSlider.maximumValue=max;
}

-(void)setSliderCurrent:(CGFloat)cur
{
//    if (cur>_processSlider.maximumValue) {
//        cur=_processSlider.maximumValue;
//    } else if (cur<_processSlider.minimumValue) {
//        cur=_processSlider.minimumValue;
//    }
    _processSlider.value=cur;
}

-(void)setStatus:(BOOL)isPlaying
{
    if (isPlaying) {
        playMusic.selected=YES;
    }else {
        playMusic.selected=NO;
    }
}

-(void)setEnableToUser:(BOOL)enable
{
    preMusic.enabled=enable;
    playMusic.enabled=enable;
    nextMusic.enabled=enable;
    _processSlider.enabled=enable;
    if (!enable) {
        [self setDefault];
    }
}

#pragma mark - Private methods

-(void)setDefault
{
    _processSlider.minimumValue=0;
    _processSlider.maximumValue=0.0;
    _processSlider.value=0;
}

-(void)sliderValueChanged:(id)sender
{
    if ([delegate respondsToSelector:@selector(sliderValueChanged:)]) {
        [delegate sliderValueChanged:sender];
    }
}
-(void)previousButton:(id)sender
{
    if ([delegate respondsToSelector:@selector(previousButton:)]) {
        [delegate previousButton:sender];
    }
}
-(void)playButton:(id)sender
{
    if ([delegate respondsToSelector:@selector(playButton:)]) {
        [delegate playButton:sender];
    }
}
-(void)nextButton:(id)sender
{
    if ([delegate respondsToSelector:@selector(nextButton:)]) {
        [delegate nextButton:sender];
    }
}
@end
