//
//  LEOListExtendView.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-12.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOListExtendView.h"
#import "LEODefines.h"

@interface LEOListExtendView ()
{
//    UIImageView *_backgroundView;
    NSMutableArray *_buttons;
}
@end

@implementation LEOListExtendView
@synthesize delegate;

- (id)initWithOriginalHeight:(CGFloat)height
{
    self = [super init];
    if (self) {
        CGRect appSize= [[UIScreen mainScreen] applicationFrame];
        
        appSize.origin.y=height;
        appSize.size.height=kContentListCellExtend;
        self.frame=appSize;
        
//        [self addSubview:_backgroundView];
    }
    return self;
}

- (id)initWithItems:(NSArray *)items
{
    self = [self initWithOriginalHeight:kContentListCellHeight];
    if (self) {
        [self setupButtons:items];
    }
    return self;
}

- (id)initWithItems:(NSArray *)items withOriginalHeight:(CGFloat)height
{
    self = [self initWithOriginalHeight:height];
    if (self) {
        [self setupButtons:items];
    }
    return self;
}

-(void)setupButtons:(NSArray *)items{
    if([items count]<1)
        return;
    int count=[items count];
    _buttons=[[NSMutableArray alloc]initWithCapacity:count];
    CGFloat width=self.frame.size.width/count;
    UIButton *btn;
    for (int i=0; i<count; i++) {
        btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag=i+1;
        btn.titleLabel.numberOfLines=0;
        btn.titleLabel.textAlignment=UITextAlignmentCenter;
        btn.frame=CGRectMake(width*i,0,width,kContentListCellExtend);
        [btn setTitle:[items objectAtIndex:i] forState:UIControlStateNormal];
        [[btn titleLabel] setFont:[UIFont systemFontOfSize:kEditToolBarBtnFontSz]];
        UIImage *strech=[UIImage imageNamed:kExtendBgImage];
        strech=[strech stretchableImageWithLeftCapWidth:1 topCapHeight:2];
        [btn setBackgroundImage:strech forState:UIControlStateNormal];
        UIImage *highlight=[UIImage imageNamed:kExtendHighlightImage];
        highlight=[highlight stretchableImageWithLeftCapWidth:3 topCapHeight:3];
        [btn setBackgroundImage:highlight forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        [_buttons addObject:btn];
    }
}

-(void)touchUp:(UIButton *)button {
    if([self.delegate respondsToSelector:@selector(didSelectedExtendIndex:)]){
        [self.delegate didSelectedExtendIndex:button.tag];
    }
}

-(void)hideExtendView:(BOOL)hide
{
    self.hidden=hide;
}
@end
