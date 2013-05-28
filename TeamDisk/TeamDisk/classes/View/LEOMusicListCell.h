//
//  LEOMusicListCell.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-10-26.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LEOMusicListCell : UITableViewCell
@property(nonatomic,retain) UILabel *fileNameLabel;
@property(nonatomic,retain) UILabel *detailLabel;
-(void)isPlaying:(BOOL)isPlay;
@end
