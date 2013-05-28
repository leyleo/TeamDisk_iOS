//
//  LEOContentListCell.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-10-29.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEODefines.h"
#import "LEOListExtendView.h"
@protocol LEOContentListCellDelegate;
@interface LEOContentListCell : UITableViewCell<LEOListExtendViewDelegate>
{
}
@property(nonatomic,retain) UIImageView *iconImageView;
@property(nonatomic,retain) UILabel *fileNameLabel;
@property(nonatomic,retain) UILabel *detailLabel;
@property(assign) id<LEOContentListCellDelegate> delegate;
-(void)setIconType:(NSString *)picName;
-(void)setThumbnail:(NSString *)path;
-(void)setExtendType:(LEOContentItemType)type;
-(void)showExtend:(BOOL)isShow;
-(void)showAccessory:(BOOL)show;
@end

@protocol LEOContentListCellDelegate <NSObject>
@required
-(void)chooseButtonForRename;
-(void)chooseButtonForDelete;
-(void)chooseButtonForOpenAS;
-(void)chooseButtonForMoveTo;
-(void)chooseButtonForCopyTo;
@optional
-(void)chooseButtonForAddToMusicList;
-(void)chooseButtonForSaveToAlbum;
@end