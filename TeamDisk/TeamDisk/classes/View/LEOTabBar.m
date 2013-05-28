//
//  LEOTabBar.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-10-23.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOTabBar.h"
#import "LEODefines.h"

@implementation LEOTabBar
@synthesize delegate;

- (id)init {
    self=[super init];
    if(self){
        CGRect appSize= [[UIScreen mainScreen] applicationFrame];
        
        appSize.origin.y=appSize.size.height-kLEOTabBarHeight;
//        appSize.origin.y=0;
        appSize.size.height=kLEOTabBarHeight;
//        NSLog(@"tabbar:%f,%f,%f,%f",appSize.origin.x,appSize.origin.y,appSize.size.width,appSize.size.height);
        self.frame=appSize;
//        self.backgroundColor=[UIColor whiteColor];
        UIImage *stretchImage=[UIImage imageNamed:kTabbarBg];
        stretchImage=[stretchImage stretchableImageWithLeftCapWidth:1 topCapHeight:0];
        _backgroundView=[[UIImageView alloc] initWithFrame:appSize];
        [_backgroundView setImage:stretchImage];
        [self addSubview:_backgroundView];
    }
    return self;
}

-(void)dealloc
{
    [_backgroundView release];
    [_buttons release];
    [super dealloc];
}

- (id)initWithItems:(NSArray *)items {
    self = [self init];
    if (self) {
        [self setupButtons:items];
    }
    return self;
}

- (void)setSelectedIndex:(NSInteger)index {
    UIButton *btn=[_buttons objectAtIndex:index];
    for (int i = 0; i < [_buttons count]; i++)
	{
		UIButton *b = [_buttons objectAtIndex:i];
		b.selected = NO;
	}
    btn.selected=YES;
    if([self.delegate respondsToSelector:@selector(tabBar:didSelectedIndex:)]){
        [self.delegate tabBar:self didSelectedIndex:index];
    }
}

-(void)setupButtons:(NSArray *)items {
    if([items count]<1)
        return;
    int count=[items count]/2;
    _buttons=[[NSMutableArray alloc]initWithCapacity:count];
    CGFloat width=self.frame.size.width/count;
    UIButton *btn;
    for (int i=0; i<count; i++) {
        btn=[UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag=i;
        btn.frame=CGRectMake(width*i,0,width,kLEOTabBarHeight);
        [btn setBackgroundColor:[UIColor clearColor]];
        [btn setBackgroundImage:[UIImage imageNamed:kTabbarBtnBg] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:kTabbarBtnBg] forState:UIControlStateHighlighted];
        [btn setBackgroundImage:[UIImage imageNamed:kTabbarBtnBgSelected] forState:UIControlStateSelected];
        [btn setImage:[UIImage imageNamed:[items objectAtIndex:i*2]] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:[items objectAtIndex:i*2]] forState:UIControlStateHighlighted];
        [btn setImage:[UIImage imageNamed:[items objectAtIndex:(i*2+1)]] forState:UIControlStateSelected];
        [btn setTintColor:[UIColor clearColor]];
        [btn setHighlighted:NO];
        
        [btn addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        [_buttons addObject:btn];
    }
}

-(void)touchUp:(UIButton *)button {
    [self setSelectedIndex:button.tag];
}
@end
