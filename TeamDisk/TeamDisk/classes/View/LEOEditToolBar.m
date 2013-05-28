//
//  LEOEditToolBar.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-10-26.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOEditToolBar.h"
#import "LEODefines.h"

@interface LEOEditToolBar()
{
    UIImageView *_backgroundView;
    NSMutableArray *_buttons;
    NSMutableDictionary *_titles;
}
@end

@implementation LEOEditToolBar
@synthesize delegate;

- (id)initWithItems:(NSArray *)items
{
    self = [super init];
    if (self) {
        CGRect appSize= [[UIScreen mainScreen] applicationFrame];
        
        appSize.origin.y=appSize.size.height-kLEOTabBarHeight-kLEONavBarHeight;
        appSize.size.height=kLEOTabBarHeight;
        self.frame=appSize;
//        self.backgroundColor=[UIColor greenColor];
        appSize.origin.y=0;
        UIImage *stretchImage=[UIImage imageNamed:kTabbarBg];
        stretchImage=[stretchImage stretchableImageWithLeftCapWidth:5 topCapHeight:0];
        _backgroundView=[[UIImageView alloc] initWithFrame:appSize];
        [_backgroundView setImage:stretchImage];
        [self addSubview:_backgroundView];
        [self setupButtons:items];
    }
    return self;
}

-(void)setBackgroudImage:(NSString *)resPath
{
    UIImage *stretchImage=[UIImage imageNamed:resPath];
    stretchImage=[stretchImage stretchableImageWithLeftCapWidth:5 topCapHeight:0];
    [_backgroundView setImage:stretchImage];
}

-(void)dealloc
{
    [_buttons release];
    [_titles release];
    [_backgroundView release];
    [super dealloc];
}

-(void)setupButtons:(NSArray *)items{
    if([items count]<1)
        return;
    int count=[items count];
    _buttons=[[NSMutableArray alloc]initWithCapacity:count];
    _titles=[[NSMutableDictionary alloc] init];
    CGFloat topX=(kLEOTabBarHeight-kEditToolBarBtnHeight)/2;
    UIButton *btn;
    for (int i=0; i<count; i++) {
        btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag=i+1;
        btn.frame=CGRectMake(kEditToolBarBtnMargin*(i+1)+kEditToolBarBtnWidth*i,topX,kEditToolBarBtnWidth,kEditToolBarBtnHeight);
        if (i==count-1) {
            CGRect rect=btn.frame;
            rect.origin.x=self.frame.size.width-kEditToolBarBtnWidth-kEditToolBarBtnMargin;
            btn.frame=rect;
        }
        [btn setTitle:[items objectAtIndex:i] forState:UIControlStateNormal];
        btn.titleEdgeInsets=UIEdgeInsetsMake(kEditToolBarBtnLabelMargin, kEditToolBarBtnLabelMargin, kEditToolBarBtnLabelMargin, kEditToolBarBtnLabelMargin);
        btn.titleLabel.textAlignment=UITextAlignmentCenter;
        btn.titleLabel.numberOfLines=2;
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
        [_titles setObject:[items objectAtIndex:i] forKey:[NSString stringWithFormat:@"%d",i+1]];
        [_titles setObject:[items objectAtIndex:i] forKey:[NSString stringWithFormat:@"%d",-i-1]];
        [[btn titleLabel] setFont:[UIFont systemFontOfSize:kEditToolBarBtnFontSz]];
        if (i==0) {
            UIImage *stretchImage1=[UIImage imageNamed:kTabbarEditBtnBlueBg];
            stretchImage1=[stretchImage1 stretchableImageWithLeftCapWidth:5 topCapHeight:0];
            [btn setBackgroundImage:stretchImage1 forState:UIControlStateNormal];
            UIImage *stretchImage2=[UIImage imageNamed:kTabbarEditBtnBlueBgSelected];
            stretchImage2=[stretchImage2 stretchableImageWithLeftCapWidth:5 topCapHeight:0];
            [btn setBackgroundImage:stretchImage2 forState:UIControlStateHighlighted];
        }else {
            UIImage *stretchImage1=[UIImage imageNamed:kTabbarEditBtnBg];
            stretchImage1=[stretchImage1 stretchableImageWithLeftCapWidth:5 topCapHeight:0];
            [btn setBackgroundImage:stretchImage1 forState:UIControlStateNormal];
            UIImage *stretchImage2=[UIImage imageNamed:kTabbarEditBtnBgSelected];
            stretchImage2=[stretchImage2 stretchableImageWithLeftCapWidth:5 topCapHeight:0];
            [btn setBackgroundImage:stretchImage2 forState:UIControlStateHighlighted];
        }
        
        [btn addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        [_buttons addObject:btn];
    }
}

-(void)setupItems:(NSArray *)items
{
    for (UIButton *btn in _buttons) {
        [btn removeFromSuperview];
    }
    if (_buttons) {
        [_buttons removeAllObjects];
        [_buttons release];
        _buttons=nil;
    }
    if (_titles) {
        [_titles removeAllObjects];
        [_titles release];
        _titles=nil;
    }
    [self setupButtons:items];
}

-(void)resetButtons
{
    int count=[_buttons count];
    for (int i=0; i<count; i++) {
        UIButton *btn=[_buttons objectAtIndex:i];
        if (btn.tag<0) {
            btn.tag=-btn.tag;
            [btn setTitle:[_titles objectForKey:[NSString stringWithFormat:@"%d",btn.tag]] forState:UIControlStateNormal];
        }
    }
}

-(void)touchUp:(UIButton *)button {
    button.tag=-button.tag;
    [button setTitle:[_titles objectForKey:[NSString stringWithFormat:@"%d",button.tag]] forState:UIControlStateNormal];
    if([self.delegate respondsToSelector:@selector(didSelectedEditToolBarIndex:)]){
        [self.delegate didSelectedEditToolBarIndex:button.tag];
    }
    [self toggleButton:button];
}

-(void)toggleButton:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(didClickToggleButton:)]) {
        [self.delegate didClickToggleButton:button];
    }
}

-(void)setButtonStatus:(BOOL)enabled AtIndex:(NSInteger)index
{
    UIButton *selected=[_buttons objectAtIndex:index];
    [selected setEnabled:enabled];
}

-(void)setToggleTextMore:(NSString *)string1 AtIndex:(NSInteger)index
{
    [_titles setObject:string1 forKey:[NSString stringWithFormat:@"%d",-index-1]];
}

-(void)hideEditTooBar:(BOOL)hide {
    if(hide){
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.transform = CGAffineTransformMakeTranslation(-320, 0);
                         }
                         completion:^(BOOL finished){
                             [self resetButtons];
                         }];
    }else{
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.transform = CGAffineTransformMakeTranslation(0, 0);
                         }
                         completion:nil];
    }
}

-(void)hideEditTooBar:(BOOL)hide fromLeft:(BOOL)left{
    if(hide){
        NSInteger weight=left?-1:1;
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.transform = CGAffineTransformMakeTranslation(320*weight, 0);
                         }
                         completion:^(BOOL finished){
                             [self resetButtons];
                         }];
    }else{
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.transform = CGAffineTransformMakeTranslation(0, 0);
                         }
                         completion:nil];
    }
}

-(void)hideEditToolBarWithoutAnim:(BOOL)hide
{
    self.hidden=hide;
    if (hide==NO) {
        self.transform = CGAffineTransformMakeTranslation(0, 0);
    } else {
        self.transform = CGAffineTransformMakeTranslation(320, 0);
    }
}
@end
