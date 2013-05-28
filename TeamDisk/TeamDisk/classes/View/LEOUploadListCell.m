//
//  LEOUploadListCell.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-7.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOUploadListCell.h"
#import "LEODefines.h"

@interface LEOUploadListCell ()
{
    UIImageView *_iconImageView;
    UILabel *_fileNameLabel;
    UILabel *_detailLabel;
    UIImageView *_statusView;
    
    UIProgressView *_progressView;
}
@end

@implementation LEOUploadListCell

@synthesize iconImageView=_iconImageView;
@synthesize fileNameLabel=_fileNameLabel,detailLabel=_detailLabel;
@synthesize delegate;
@synthesize info;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect frame=self.frame;
        frame.size.height=kContentListCellHeight;
        self.frame=frame;
        
        CGFloat iconTopY=(kContentListCellHeight-kContentListCellIconSz)/2.0;
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kDefaultListLeftX, iconTopY, kContentListCellIconSz, kContentListCellIconSz)];
        _iconImageView.backgroundColor=[UIColor clearColor];
        [_iconImageView setImage:[UIImage imageNamed:kMusicIconImage]];
        [self.contentView addSubview:_iconImageView];
        
        _fileNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kDefaultListLeftX *2+kContentListCellIconSz, 0, frame.size.width-3*kDefaultListLeftX-kContentListCellIconSz, kContentListCellDesLbHeight)];
        _fileNameLabel.backgroundColor = [UIColor clearColor];
        _fileNameLabel.font = [UIFont systemFontOfSize:kUploadCellDesLbFontSz];
        _fileNameLabel.textColor = [UIColor blackColor];
        _fileNameLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:_fileNameLabel];
        
        CGRect desFrame=_fileNameLabel.frame;
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(desFrame.origin.x, desFrame.origin.y+desFrame.size.height, desFrame.size.width, kContentListCellHeight-kContentListCellDesLbHeight-desFrame.origin.y-kContentListCellMargin)];
        _detailLabel.backgroundColor = [UIColor clearColor];
        _detailLabel.font = [UIFont systemFontOfSize:kUploadCellDetLbFontSz];
        _detailLabel.textColor = [UIColor blackColor];
        _detailLabel.textAlignment = UITextAlignmentLeft;
        _detailLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:_detailLabel];
        
        CGRect contentFrame=self.contentView.frame;
//        self.contentView.backgroundColor=[UIColor greenColor];
        contentFrame.origin.x=contentFrame.size.width-kUploadCellStatusSize-kDefaultListLeftX;
        contentFrame.origin.y=(kUploadCellHeight-kUploadCellStatusSize)/2.0;
        contentFrame.size.width=kUploadCellStatusSize;
        contentFrame.size.height=kUploadCellStatusSize;
        _statusView=[[UIImageView alloc] initWithFrame:contentFrame];
        [self addSubview:_statusView];
        
        UIImageView *bg=[[UIImageView alloc] initWithFrame:self.frame];
        bg.backgroundColor=[UIColor colorWithRed:kHighlightColorR green:kHighlightColorG blue:kHighlightColorB alpha:kHighlightColorA];
        self.selectedBackgroundView=bg;
        [bg release];
        
        desFrame=_detailLabel.frame;
        desFrame.size.width/=2.0;
        _progressView=[[UIProgressView alloc] initWithFrame:desFrame];
        _progressView.progressViewStyle=UIProgressViewStyleBar;
        _progressView.progress=0.0;
        _progressView.hidden=YES;
        [self.contentView addSubview:_progressView];
    }
    return self;
}

-(void)setStatus:(NSInteger)status
{
    switch (status) {
        case LEOUploadStatusDone:
            [_statusView setImage:[UIImage imageNamed:@"/res/upload_success.png"]];
            _statusView.hidden=NO;
            _detailLabel.hidden=NO;
            _progressView.hidden=YES;
            break;
        case LEOUploadStatusError:
            [_statusView setImage:[UIImage imageNamed:@"/res/upload_failure.png"]];
            _statusView.hidden=NO;
            _detailLabel.hidden=YES;
            _progressView.hidden=YES;
            break;
        case LEOUploadStatusUploading:
            _statusView.hidden=YES;
            _detailLabel.hidden=YES;
            _progressView.hidden=NO;
            break;
        case LEOUploadStatusWait:
        default:
            [_statusView setImage:[UIImage imageNamed:@"/res/upload_wait.png"]];
            _statusView.hidden=NO;
            _detailLabel.hidden=YES;
            _progressView.hidden=YES;
            break;
    }
}

-(void)setProgress:(float)percent
{
//    NSLog(@"percent:%f",percent);
    _progressView.progress=percent;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
