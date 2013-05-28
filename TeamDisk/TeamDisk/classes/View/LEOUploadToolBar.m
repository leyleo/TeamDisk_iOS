//
//  LEOUploadToolBar.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-7.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOUploadToolBar.h"
#import "LEODefines.h"

@implementation LEOUploadToolBar
@synthesize delegate;
- (id)init
{
    self = [super init];
    if (self) {
        CGRect appSize= [[UIScreen mainScreen] applicationFrame];
        
        appSize.origin.y+=appSize.size.height-kLEOUploadToolBarHeight;
        appSize.size.height=kLEOUploadToolBarHeight;
        self.frame=appSize;
//        self.backgroundColor=[UIColor grayColor];
        UIImage *stretchImage=[UIImage imageNamed:kTabbarBg];
        stretchImage=[stretchImage stretchableImageWithLeftCapWidth:1 topCapHeight:0];
        appSize.origin.y=0;
        _backgroundView=[[UIImageView alloc] initWithFrame:appSize];
        [_backgroundView setImage:stretchImage];
        [self addSubview:_backgroundView];
        
        CGFloat top=(kLEOUploadToolBarHeight-kUploadToolBarBtnHeight)/2.0;
        chooseBtn=[[UIButton alloc] initWithFrame:CGRectMake(kUploadToolBarBtnMargin, top, kUploadToolBarChooseBtnW, kUploadToolBarBtnHeight)];
        UIImage *stretchImage1=[UIImage imageNamed:kTabbarEditBtnBlueBg];
        stretchImage1=[stretchImage1 stretchableImageWithLeftCapWidth:5 topCapHeight:0];
        [chooseBtn setBackgroundImage:stretchImage1 forState:UIControlStateNormal];
        UIImage *stretchImage2=[UIImage imageNamed:kTabbarEditBtnBlueBgSelected];
        stretchImage2=[stretchImage2 stretchableImageWithLeftCapWidth:5 topCapHeight:0];
        [chooseBtn setBackgroundImage:stretchImage2 forState:UIControlStateHighlighted];
        [chooseBtn addTarget:self action:@selector(clickChooseBtn:) forControlEvents:UIControlEventTouchUpInside];
        [chooseBtn.titleLabel setTextAlignment:NSTextAlignmentLeft];
        [chooseBtn.titleLabel setLineBreakMode:NSLineBreakByTruncatingHead];
        [self setDisplayPath:nil];
        [self addSubview:chooseBtn];
        
        UIButton *uploadBtn=[[UIButton alloc] initWithFrame:CGRectMake(kUploadToolBarChooseBtnW+2*kUploadToolBarBtnMargin, top, kUploadToolBarUploadBtnW, kUploadToolBarBtnHeight)];
        [uploadBtn setTitle:NSLocalizedString(@"Upload", @"") forState:UIControlStateNormal];
        UIImage *stretchImage3=[UIImage imageNamed:kTabbarEditBtnBg];
        stretchImage3=[stretchImage3 stretchableImageWithLeftCapWidth:5 topCapHeight:0];
        [uploadBtn setBackgroundImage:stretchImage3 forState:UIControlStateNormal];
        UIImage *stretchImage4=[UIImage imageNamed:kTabbarEditBtnBgSelected];
        stretchImage4=[stretchImage4 stretchableImageWithLeftCapWidth:5 topCapHeight:0];
        [uploadBtn setBackgroundImage:stretchImage4 forState:UIControlStateHighlighted];
        [uploadBtn addTarget:self action:@selector(clickUploadBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:uploadBtn];
        [uploadBtn release];
    }
    return self;
}

-(void)hideUploadToolBar:(BOOL)hide
{
    [self setHidden:hide];
}

-(void)setDisplayPath:(NSString *)path
{
    if (path==nil || [path isEqualToString:@"/"]) {
        _path=NSLocalizedString(@"Root",@"");
    }else {
        _path=[path lastPathComponent];
    }
    
    [chooseBtn setTitle:[NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Upload to server", ),_path] forState:UIControlStateNormal];
}

-(void)clickChooseBtn:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(chooseButton:)]) {
        [self.delegate chooseButton:sender];
    }
}

-(void)clickUploadBtn:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(uploadButton:)]) {
        [self.delegate uploadButton:sender];
    }
}
@end
