//
//  LEODetailDocViewController.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-5.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEODetailDocViewController.h"
#import "LEOUtility.h"
#import "LEOWebDAVItem.h"
#import "LEOResultView.h"


@interface LEODetailDocViewController ()
{
    UIWebView *previewView;
    NSURL *fileURL;
}
@end

@implementation LEODetailDocViewController

- (void)prepareDetail
{
    fileURL=nil;
    previewView=[[UIWebView alloc] initWithFrame:_displayView.frame];
    previewView.delegate=self;
    [_displayView addSubview:previewView];
    [previewView setScalesPageToFit:YES];
    previewView.hidden=YES;
    [super prepareDetail];
}

-(void)dealloc
{
    [previewView release];
    [fileURL release];
    [super dealloc];
}

-(void)detailTodo
{
    [super detailTodo];
    LEOUtility *utility=[LEOUtility getInstance];
    NSString *path=[[utility cachePathWithName:@"download"] stringByAppendingPathComponent:_item.cacheName];
    path=[path stringByAppendingPathExtension:[_item.displayName pathExtension]];
    fileURL=[[NSURL alloc] initFileURLWithPath:path];
    NSURLRequest *request=[NSURLRequest requestWithURL:fileURL];
    [previewView loadRequest:request];
}

-(void)detailTodo:(id)sender
{
    [super detailTodo];
    LEOUtility *utility=[LEOUtility getInstance];
    NSString *path=[[utility cachePathWithName:@"download"] stringByAppendingPathComponent:_item.cacheName];
    path=[path stringByAppendingPathExtension:[_item.displayName pathExtension]];
    fileURL=[[NSURL alloc] initFileURLWithPath:path];
    NSURLRequest *request=[NSURLRequest requestWithURL:fileURL];
    [previewView loadRequest:request];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"finish load");
    previewView.hidden=NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"fail to load:%d，%@",[error code],error);
    if ([error.domain isEqualToString:@"WebKitErrorDomain"]) {
        // webkit 解析域
        if (error.code==102) {
            // 无法显示 WebKitErrorFrameLoadInterruptedByPolicyChange
            [resultView setImage:[UIImage imageNamed:kDetailOpeninIcon]];
            [resultView setText:NSLocalizedString(@"Fail to Preview the file, Please 'open in' the 3rd party Apps.", @"")];
            resultView.hidden=NO;
        }
    }
}
@end
