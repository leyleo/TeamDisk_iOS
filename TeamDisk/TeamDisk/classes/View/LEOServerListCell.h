//
//  LEOServerListCell.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-10-25.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LEOServerListCell : UITableViewCell {
    UILabel *_descriptionLabel;
    UILabel *_userNameLabel;
    UILabel *_urlLabel;
    
    UIImageView *_accessoryImage;
}

@property(nonatomic, retain) UILabel *descriptionLabel;
@property(nonatomic, retain) UILabel *userNameLabel;
@property(nonatomic, retain) UILabel *urlLabel;
-(void)showAccessory:(BOOL)show;
@end
