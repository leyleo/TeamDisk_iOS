//
//  LEOContentListCell.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-10-29.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOContentListCell.h"
#import "LEODefines.h"
#import "LEOUtility.h"

@interface LEOContentListCell ()
{
    UIImageView *_iconImageView;
    UILabel *_fileNameLabel;
    UILabel *_detailLabel;
    UILabel *_sizeLabel;
    UIImageView *_accessoryImage;
    
    LEOListExtendView *_extendView;
    
    LEOContentItemType _type;
}
@end

@implementation LEOContentListCell

@synthesize iconImageView=_iconImageView;
@synthesize fileNameLabel=_fileNameLabel;
@synthesize detailLabel=_detailLabel;
@synthesize delegate;

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
        [_iconImageView setImage:[UIImage imageNamed:kDefaultFolderImage]];
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
        
        if ([reuseIdentifier isEqualToString:@"music"]) {
            _type=LEOContentItemTypeMusic;
            _extendView=[[LEOListExtendView alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"Open In",@""),NSLocalizedString(@"Add to Music List",@""),NSLocalizedString(@"Rename",@""),NSLocalizedString(@"Move To",@""), NSLocalizedString(@"Copy To", @""),nil]];
        }
        else if ([reuseIdentifier isEqualToString:@"picture"]) {
            _type = LEOContentItemTypePicture;
            _extendView=[[LEOListExtendView alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"Open In",@""),NSLocalizedString(@"Save to Photo Album",@""),NSLocalizedString(@"Rename",@""),NSLocalizedString(@"Move To",@""),NSLocalizedString(@"Copy To", @""),nil]];
        } else if ([reuseIdentifier isEqualToString:@"collection"]){
            _type = LEOContentItemTypeCollection;
            _extendView=[[LEOListExtendView alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"Rename",@""),NSLocalizedString(@"Move To",@""),NSLocalizedString(@"Delete", @""), nil]];
        } else {
            _type = LEOContentItemTypeFile;
            _extendView=[[LEOListExtendView alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"Open In",@""),NSLocalizedString(@"Rename",@""),NSLocalizedString(@"Move To",@""), NSLocalizedString(@"Copy To", @""),nil]];
        }
        _extendView.delegate=self;
        
        _accessoryImage=[[UIImageView alloc] initWithImage:[UIImage imageNamed:kCellAccessory]];
        frame.origin.x=frame.size.width-kLEOCellAccessorySize-kDefaultListLeftX;
        frame.origin.y=(frame.size.height-kLEOCellAccessorySize)/2.0;
        frame.size.width=kLEOCellAccessorySize;
        frame.size.height=kLEOCellAccessorySize;
        _accessoryImage.frame=frame;
        [self addSubview:_accessoryImage];
        
        [self.contentView addSubview:_extendView];
        [self showExtend:NO];
    }
    return self;
}

-(void)showAccessory:(BOOL)show
{
    _accessoryImage.hidden=!show;
}

-(void)setAccessoryType:(UITableViewCellAccessoryType)accessoryType
{
    if (accessoryType==UITableViewCellAccessoryNone) {
        self.accessoryView.hidden=YES;
    } else {
        self.accessoryView.hidden=NO;
    }
}

-(void)setIconType:(NSString *)picName
{
    [_iconImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"res/%@",picName]]];
}

-(void)setThumbnail:(NSString *)cacheName
{
    if (cacheName!=nil) {
        NSString *url=[[LEOUtility getInstance] cachePathWithName:@"thumbnail"];
        url=[url stringByAppendingPathComponent:cacheName];
        if ([[LEOUtility getInstance] isExistFile:url]) {
            [_iconImageView setImage:[UIImage imageWithContentsOfFile:url]];
        }
    }
}

-(void)setExtendType:(LEOContentItemType)type
{
    _type=type;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)showExtend:(BOOL)isShow
{
    _extendView.hidden=!isShow;
}

-(void)didSelectedExtendIndex:(NSInteger)index
{
    if (_type==LEOContentItemTypeFile) {
        // 常规类型
        if (self.delegate) {
            switch (index) {
                case 1:
                    [self.delegate chooseButtonForOpenAS];
                    break;
                case 2:
                    [self.delegate chooseButtonForRename];
                    break;
                case 3:
//                    [self.delegate chooseButtonForDelete];
                    [self.delegate chooseButtonForMoveTo];
                    break;
                case 4:
                    
                    [self.delegate chooseButtonForCopyTo];
                    break;
                default:
                    break;
            }
        }
    } else if (_type==LEOContentItemTypeMusic || _type==LEOContentItemTypePicture) {
        if (self.delegate) {
            switch (index) {
                case 1:
                    [self.delegate chooseButtonForOpenAS];
                    break;
                case 2:
                    if (_type==LEOContentItemTypePicture) {
                        [self.delegate chooseButtonForSaveToAlbum];
                    } else if (_type==LEOContentItemTypeMusic) {
                        [self.delegate chooseButtonForAddToMusicList];
                    }
                    break;
                case 3:
                    [self.delegate chooseButtonForRename];
                    break;
                case 4:
//                    [self.delegate chooseButtonForDelete];
                    [self.delegate chooseButtonForMoveTo];
                    break;
                case 5:
                    
                    [self.delegate chooseButtonForCopyTo];
                    break;
                default:
                    break;
            }
        }
    } else if (_type==LEOContentItemTypeCollection) {
        if (self.delegate) {
            switch (index) {
                case 1:
                    [self.delegate chooseButtonForRename];
                    break;
                case 2:
                    [self.delegate chooseButtonForMoveTo];
                    break;
                case 3:
                    [self.delegate chooseButtonForDelete];
                    break;
                default:
                    break;
            }
        }
    }
}
@end
