//
//  LEOUploadListCell.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-7.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEOUploadInfo.h"

@interface LEOUploadListCell : UITableViewCell
@property(nonatomic,readonly) UIImageView *iconImageView;
@property(nonatomic,readonly) UILabel *fileNameLabel;
@property(nonatomic,readonly) UILabel *detailLabel;
@property(nonatomic,assign) LEOUploadInfo *info;
@property(assign) id delegate;
-(void)setStatus:(NSInteger)status;
-(void)setProgress:(float)percent;
@end
