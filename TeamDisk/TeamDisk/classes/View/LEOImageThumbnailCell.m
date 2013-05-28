//
//  LEOImageThumbnailCell.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-14.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOImageThumbnailCell.h"
#import "LEOThumbnailItem.h"
#import "LEOUtility.h"
#import "LEOWebDAVItem.h"
#import "LEODefines.h"

@interface LEOImageThumbnailCell ()
{
    NSArray *items;
    NSMutableArray *buttons;
    LEOListExtendView *_extendView;
    BOOL isEdit;
}
@end
@implementation LEOImageThumbnailCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect rect=CGRectMake(kImageThumbnailMargin, kImageThumbnailMargin/2.0, kImageThumbnailSz, kImageThumbnailSz);
        buttons=[[NSMutableArray alloc] initWithCapacity:4];
        for (int i=0; i<4; i++) {
            rect.origin.x=i*(kImageThumbnailSz+kImageThumbnailMargin)+kImageThumbnailMargin;
            LEOThumbnailItem *btn=[[LEOThumbnailItem alloc] init];
            btn.frame=rect;
            [btn setFrontImage:[UIImage imageNamed:kImageDefalut]];
            btn.tag=i;
            UITapGestureRecognizer *singleTap = [[[UITapGestureRecognizer alloc]initWithTarget:self                 action:@selector(handleTap:)] autorelease];
            singleTap.numberOfTapsRequired=1;
            singleTap.numberOfTouchesRequired=1;
            btn.userInteractionEnabled=YES;
            [btn addGestureRecognizer:singleTap];
            UILongPressGestureRecognizer *longPressRecognizer = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)] autorelease];
            [btn addGestureRecognizer:longPressRecognizer];
            [self.contentView addSubview:btn];
            [buttons addObject:btn];
            btn.hidden=YES;
        }
//        _extendView=[[LEOListExtendView alloc] initWithItems:[NSArray arrayWithObjects:@"打开为",@"保存到相册",@"重命名",@"删除", nil] ];
        _extendView=[[LEOListExtendView alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"Open In",@""),NSLocalizedString(@"Save to Photo Album",@""),NSLocalizedString(@"Rename",@""),NSLocalizedString(@"Move To",@""),NSLocalizedString(@"Copy To",@""), nil] withOriginalHeight:kImageThumbnailSz+kImageThumbnailMargin];
        _extendView.delegate=self;
        [self.contentView addSubview:_extendView];
        [self showExtend:NO];
    }
    return self;
}

-(void)setThumbnails:(NSArray *)array
{
    items=[array retain];
    int i=0;
    NSString *thumbnail=[[LEOUtility getInstance] cachePathWithName:@"thumbnail"];
    LEOWebDAVItem *item;
    for (i=0; i<items.count; i++) {
        LEOThumbnailItem *btn=[buttons objectAtIndex:i];
        item=[items objectAtIndex:i];
        btn.hidden=NO;
        NSString *iconName=[thumbnail stringByAppendingPathComponent:[item.cacheName stringByAppendingPathExtension:[item.displayName pathExtension]]];
        if ([[LEOUtility getInstance] isExistFile:iconName]) {
            [btn setFrontImage:[UIImage imageWithContentsOfFile:iconName]];
        }
    }
    for (int j=i; j<4; j++) {
        LEOThumbnailItem *btn=[buttons objectAtIndex:j];
        btn.hidden=YES;
    }
}

-(void)setEdit:(BOOL)_isEdit
{
    isEdit=_isEdit;
}

-(void)setAllSelected:(BOOL)selected
{
    for (int i=0; i<4; i++) {
        LEOThumbnailItem *btn=[buttons objectAtIndex:i];
        if (btn.hidden==NO) {
            [btn setSelected:selected];
        }
    }
}

-(void)setIndex:(NSInteger)index Selected:(BOOL)selected
{
    LEOThumbnailItem *btn=[buttons objectAtIndex:index];
    [btn setSelected:selected];
}

-(void)chooseButtonIndex:(LEOThumbnailItem *)btn
{
    if (self.isEditing) {
        // 编辑界面
        [btn setSelected:!btn.isSelected];
    } else {
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelected:)]) {
        [self.delegate didSelected:[items objectAtIndex:btn.tag]];
    }
}

-(void)handleTap:(UITapGestureRecognizer *)sender
{
    LEOThumbnailItem *btn=(LEOThumbnailItem *)sender.view;
    if (self.isEditing) {
        // 编辑界面
        [btn setSelected:!btn.isSelected];
    } else {
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelected:)]) {
        [self.delegate didSelected:[items objectAtIndex:btn.tag]];
    }
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(thumbnailLongPress:)]) {
            [self.delegate thumbnailLongPress:[items objectAtIndex:sender.view.tag]];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    // Configure the view for the selected state
}

-(void)showExtend:(BOOL)isShow
{
    _extendView.hidden=!isShow;
}

-(void)didSelectedExtendIndex:(NSInteger)index
{
    if (self.delegate) {
        switch (index) {
            case 1:
                [self.delegate chooseButtonForOpenAS];
                break;
            case 2:
                [self.delegate chooseButtonForSaveToAlbum];
                break;
            case 3:
                [self.delegate chooseButtonForRename];
                break;
            case 4:
                [self.delegate chooseButtonForMoveTo];
                break;
            case 5:
                [self.delegate chooseButtonForCopyTo];
                break;
            default:
                break;
        }
    }
}

@end
