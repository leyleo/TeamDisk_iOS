//
//  LEOMusicListCell.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-10-26.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOMusicListCell.h"
#import "LEODefines.h"

@interface LEOMusicListCell ()
{
    UIImageView *_iconImageView;
    UILabel *_fileNameLabel;
    UILabel *_detailLabel;
}
@end

@implementation LEOMusicListCell
@synthesize fileNameLabel=_fileNameLabel;
@synthesize detailLabel=_detailLabel;

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
        [_iconImageView setImage:[UIImage imageNamed:kMusicIconImageGray]];
        [self.contentView addSubview:_iconImageView];
        
        _fileNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kDefaultListLeftX *2+kContentListCellIconSz, 0, frame.size.width-3*kDefaultListLeftX-kContentListCellIconSz, kContentListCellDesLbHeight)];
        _fileNameLabel.backgroundColor = [UIColor clearColor];
        _fileNameLabel.font = [UIFont systemFontOfSize:kContentListCellDesLbFontSz];
        _fileNameLabel.textColor = [UIColor blackColor];
        _fileNameLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:_fileNameLabel];
        
        CGRect desFrame=_fileNameLabel.frame;
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(desFrame.origin.x, desFrame.origin.y+desFrame.size.height, desFrame.size.width, kContentListCellHeight-kContentListCellDesLbHeight-desFrame.origin.y-kContentListCellMargin)];
        _detailLabel.backgroundColor = [UIColor clearColor];
        _detailLabel.font = [UIFont systemFontOfSize:kContentListCellDetLbFontSz];
        _detailLabel.textColor = [UIColor blackColor];
        _detailLabel.textAlignment = UITextAlignmentLeft;
        _detailLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:_detailLabel];
        
        UIImageView *bg=[[UIImageView alloc] initWithFrame:self.frame];
        bg.backgroundColor=[UIColor colorWithRed:kHighlightColorR green:kHighlightColorG blue:kHighlightColorB alpha:kHighlightColorA];
        self.selectedBackgroundView=bg;
        [bg release];
    }
    return self;
}

-(void)isPlaying:(BOOL)isPlay
{
    if (isPlay) {
        [_iconImageView setImage:[UIImage imageNamed:kMusicIconImage]];
    } else {
        [_iconImageView setImage:[UIImage imageNamed:kMusicIconImageGray]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
