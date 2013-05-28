//
//  LEOServerListCell.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-10-25.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOServerListCell.h"
#import "../Utilities/LEODefines.h"

@implementation LEOServerListCell

@synthesize descriptionLabel=_descriptionLabel;
@synthesize userNameLabel=_userNameLabel;
@synthesize urlLabel=_urlLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect frame=self.frame;
        frame.size.height=kServerListCellHeight;
        self.frame=frame;
        _descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(kDefaultListLeftX, 0, frame.size.width-2*kDefaultListLeftX, kServerListCellDesLbHeight)];
        _descriptionLabel.backgroundColor = [UIColor clearColor];
        _descriptionLabel.font = [UIFont systemFontOfSize:kServerListCellDesLbFontSz];
        _descriptionLabel.textColor = [UIColor blackColor];
        _descriptionLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:_descriptionLabel];
        
        CGRect desFrame=_descriptionLabel.frame;
        _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kDefaultListLeftX, desFrame.origin.y+desFrame.size.height, desFrame.size.width*kServerListCellDetLbWidthP, kServerListCellHeight-kServerListCellDesLbHeight-desFrame.origin.y)];
        _userNameLabel.backgroundColor = [UIColor clearColor];
        _userNameLabel.font = [UIFont systemFontOfSize:kServerListCellDetLbFontSz];
        _userNameLabel.textColor = [UIColor blackColor];
        _userNameLabel.textAlignment = UITextAlignmentLeft;
        _userNameLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:_userNameLabel];
        
        CGRect userFrame=_userNameLabel.frame;
        _urlLabel = [[UILabel alloc] initWithFrame:CGRectMake(userFrame.origin.x+userFrame.size.width+kDefaultListLeftX, desFrame.origin.y+desFrame.size.height, desFrame.size.width-userFrame.origin.x-userFrame.size.width, kServerListCellHeight-kServerListCellDesLbHeight-desFrame.origin.y)];
        _urlLabel.backgroundColor = [UIColor clearColor];
        _urlLabel.font = [UIFont systemFontOfSize:kServerListCellDetLbFontSz];
        _urlLabel.textColor = [UIColor blackColor];
        _urlLabel.textAlignment = UITextAlignmentLeft;
        _urlLabel.lineBreakMode = UILineBreakModeTailTruncation;
        [self.contentView addSubview:_urlLabel];
        
        _accessoryImage=[[UIImageView alloc] initWithImage:[UIImage imageNamed:kCellAccessory]];
        frame.origin.x=frame.size.width-kLEOCellAccessorySize-kDefaultListLeftX;
        frame.origin.y=(frame.size.height-kLEOCellAccessorySize)/2.0;
        frame.size.width=kLEOCellAccessorySize;
        frame.size.height=kLEOCellAccessorySize;
        _accessoryImage.frame=frame;
        [self addSubview:_accessoryImage];
        
        UIImageView *bg=[[UIImageView alloc] initWithFrame:self.frame];
        bg.backgroundColor=[UIColor colorWithRed:kHighlightColorR green:kHighlightColorG blue:kHighlightColorB alpha:kHighlightColorA];
        self.selectedBackgroundView=bg;
        [bg release];
    }
    return self;
}

-(void)showAccessory:(BOOL)show
{
    _accessoryImage.hidden=!show;
}

-(void)dealloc {
    [_descriptionLabel release];
    [_userNameLabel release];
    [_urlLabel release];
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
