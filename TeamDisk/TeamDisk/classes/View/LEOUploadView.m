//
//  LEOUploadView.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-7.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOUploadView.h"
#import "LEODefines.h"

@interface LEOUploadView ()
{
    UIButton *_pictureButton;
    UIButton *_cameraButton;
    UILabel *_detailLabel;
    UIImageView *_detailImage;
}
@end

@implementation LEOUploadView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate=nil;
        CGRect btnFrame=frame;
        btnFrame.size.height=kUploadViewButtonHeight;
        btnFrame.size.width/=2.0;
        _pictureButton=[[UIButton alloc] initWithFrame:btnFrame];
        [_pictureButton setImage:[UIImage imageNamed:NSLocalizedString(@"upload_pic_normal", @"")] forState:UIControlStateNormal];
        [_pictureButton setImage:[UIImage imageNamed:NSLocalizedString(@"upload_pic_highlight", @"")] forState:UIControlStateHighlighted];
        [_pictureButton addTarget:self action:@selector(clickPictureButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_pictureButton];
        
        btnFrame.origin.x=btnFrame.size.width;
        _cameraButton=[[UIButton alloc] initWithFrame:btnFrame];
        [_cameraButton setImage:[UIImage imageNamed:NSLocalizedString(@"upload_cam_normal", @"")] forState:UIControlStateNormal];
        [_cameraButton setImage:[UIImage imageNamed:NSLocalizedString(@"upload_cam_highlight", @"")] forState:UIControlStateHighlighted];
        [_cameraButton addTarget:self action:@selector(clickCameraButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cameraButton];
        
//        btnFrame.origin.y+=kUploadViewButtonHeight;
//        btnFrame.size.height=kUploadViewHeight-kUploadViewButtonHeight;
//        
//        _detailImage=[[UIImageView alloc] initWithFrame:btnFrame];
//        [_detailImage setImage:[UIImage imageNamed:kUploadViewDetail]];
//        [self addSubview:_detailImage];
//        
//        btnFrame.origin.x=kDefaultListLeftX;
//        btnFrame.size.width-=kDefaultListLeftX;
//        _detailLabel=[[UILabel alloc] initWithFrame:btnFrame];
//        _detailLabel.textColor=[UIColor colorWithRed:0.212 green:0.212 blue:0.212 alpha:1];
//        [_detailLabel setFont:[UIFont systemFontOfSize:kUploadDetailFontSz]];
//        [_detailLabel setBackgroundColor:[UIColor clearColor]];
//        _detailLabel.text=NSLocalizedString(@"Upload Queues", @"");
//        [self addSubview:_detailLabel];
    }
    return self;
}

-(void)clickPictureButton:(id)sender
{
    if ([delegate respondsToSelector:@selector(pictureButton:)]) {
        [delegate pictureButton:sender];
    }
}

-(void)clickCameraButton:(id)sender
{
    if ([delegate respondsToSelector:@selector(cameraButton:)]) {
        [delegate cameraButton:sender];
    }
}

@end
