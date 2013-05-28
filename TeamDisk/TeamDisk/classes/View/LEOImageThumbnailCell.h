//
//  LEOImageThumbnailCell.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-14.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEODefines.h"
#import "LEOListExtendView.h"
@class LEOWebDAVItem;
@protocol LEOImageThumbnailCellDelegate;
@interface LEOImageThumbnailCell : UITableViewCell<LEOListExtendViewDelegate>
@property(assign) id<LEOImageThumbnailCellDelegate> delegate;
-(void)setThumbnails:(NSArray *)array;
-(void)showExtend:(BOOL)isShow;
-(void)setEdit:(BOOL)isEdit;
-(void)setAllSelected:(BOOL)selected;
-(void)setIndex:(NSInteger)index Selected:(BOOL)selected;
@end

@protocol LEOImageThumbnailCellDelegate <NSObject>

@required
-(void)didSelected:(LEOWebDAVItem *)index;
-(void)thumbnailLongPress:(LEOWebDAVItem *)index;
-(void)chooseButtonForRename;
-(void)chooseButtonForDelete;
-(void)chooseButtonForOpenAS;
-(void)chooseButtonForSaveToAlbum;
-(void)chooseButtonForMoveTo;
-(void)chooseButtonForCopyTo;
@end