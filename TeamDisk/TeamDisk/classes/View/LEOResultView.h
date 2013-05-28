//
//  LEOResultView.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-12-3.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LEOResultView : UIView
{
    UIImageView *_imageView;
    UILabel *_reasonLabel;
}
-(void)setImage:(UIImage*)image;
-(void)setText:(NSString *)string;
@end
