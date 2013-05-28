            //
//  LEODetailViewController.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-10-29.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEODetailViewController.h"
#import "LEOWebDAVItem.h"
#import "LEOAppDelegate.h"
#import "LEOWebDAVDownloadRequest.h"
#import "LEOWebDAVClient.h"
#import "LEONetworkController.h"
#import "LEOUtility.h"
#import "LEOWebDAVDeleteRequest.h"
#import "LEOContentTypeConvert.h"
#import "LEOResultView.h"

@interface LEODetailViewController ()
{
    UIProgressView *_progressView;
    LEOWebDAVRequest *downloadReq;
    LEOWebDAVRequest *deleteReq;
    
}

@end

@implementation LEODetailViewController
@synthesize parentInstance;
- (id)init
{
    self = [super init];
    if(self){
        UIButton *backButtonView=[UIButton buttonWithType:UIButtonTypeCustom];
        backButtonView.frame=CGRectMake(0,kLEONavBarBtnTopY,kDefalutNavItemWidth,kLEONavBarBtnHeight);
        [backButtonView.titleLabel setFont:[UIFont systemFontOfSize:kLEONavBarFontSz]];
        backButtonView.contentEdgeInsets=UIEdgeInsetsMake(0, kLEONavBarBackLeft, 0, 0);
        [backButtonView setTitle:NSLocalizedString(@"Back", @"") forState:UIControlStateNormal];
        [backButtonView setBackgroundImage:[UIImage imageNamed:kDetailNavigationBackBg] forState:UIControlStateNormal];
        [backButtonView setBackgroundImage:[UIImage imageNamed:kDetailNavigationBackBgHighlight] forState:UIControlStateHighlighted];
        [backButtonView addTarget:self action:@selector(backToList) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftButton=[[[UIBarButtonItem alloc] initWithCustomView:backButtonView] autorelease];
        self.navigationItem.leftBarButtonItem=leftButton;
    }
    return self;
}

-(id)initWithItem:(LEOWebDAVItem *)item
{
    self=[self init];
    if(self){
        _item=[[LEOWebDAVItem alloc] initWithItem:item];
        self.title=_item.displayName;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
//    UIImage *stretchImage=[UIImage imageNamed:kDetailNavigationBg];
//    stretchImage=[stretchImage stretchableImageWithLeftCapWidth:1 topCapHeight:0];
//	[self.navigationController.navigationBar setBackgroundImage:stretchImage forBarMetrics:UIBarMetricsDefault];
    
    CGRect frame=[[UIScreen mainScreen] bounds];
    frame.size.height-=kLEONavBarHeight+kLEOTabBarHeight+kLEOStatusBarHeight;
    _displayView=[[UIView alloc] initWithFrame:frame];
    _displayView.backgroundColor=[UIColor colorWithRed:kDetailBackgroundColorR green:kDetailBackgroundColorG blue:kDetailBackgroundColorB alpha:kDetailBackgroundColorA];
    [self.view addSubview:_displayView];
    NSArray *items=[NSArray arrayWithObjects:NSLocalizedString(@"Open In",@""), NSLocalizedString(@"Delete",@""), nil];
    _editToolBar=[[LEOEditToolBar alloc] initWithItems:items];
    [_editToolBar setBackgroudImage:kDetailTabbarBg];
    _editToolBar.delegate=self;
    [_editToolBar setButtonStatus:NO AtIndex:0]; //初始将“打开为”设置为不可用
    [self.view addSubview:_editToolBar];
    [self changeToolBar:YES];
    
    [self prepareDetail];
    [self setupClient];
    [self prepareAction];
}

-(void)viewWillAppear:(BOOL)animated
{
    UIImage *stretchImage=[UIImage imageNamed:kDetailNavigationBg];
    stretchImage=[stretchImage stretchableImageWithLeftCapWidth:1 topCapHeight:0];
	[self.navigationController.navigationBar setBackgroundImage:stretchImage forBarMetrics:UIBarMetricsDefault];
}

-(void)dealloc
{
    [_displayView release];
    [_item release];
    [_editToolBar release];
    [_progressView release];
    [super dealloc];
}

#pragma mark - Request Methods
-(void)setupClient
{
    LEOAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    LEOServerInfo *info=delegate.currentServer;
    _currentClient=[[LEOWebDAVClient alloc] initWithRootURL:[NSURL URLWithString:info.url]
                                                andUserName:info.userName
                                                andPassword:info.password];
}

// 删除
-(void)addNewRequestForDelete
{
    LEOWebDAVDeleteRequest *deleteRequest=[[LEOWebDAVDeleteRequest alloc] initWithPath:_item.href];
    [deleteRequest setDelegate:self];
    deleteRequest.info=_item;
    [_currentClient enqueueRequest:deleteRequest];
}

// 下载
-(void)downloadItem
{
    LEOWebDAVDownloadRequest *downRequest=[[LEOWebDAVDownloadRequest alloc] initWithPath:_item.href];
    downRequest.delegate=self;
    [_currentClient enqueueRequest:downRequest];
}

//-(void)addNewRequestForDelete
//{
//    LEOAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
//    deleteReq=[delegate.networkController addNewDownloadRequest:_item withView:nil forInstance:self failSEL:@selector(requestFailure:) successSEL:@selector(deleteSuccess:) receiveSEL:nil startSEL:nil];
//}
//
//-(void)downloadItem
//{
//    LEOAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
//    downloadReq=[delegate.networkController addNewDownloadRequest:_item withView:nil forInstance:self failSEL:@selector(requestFailure:) successSEL:@selector(detailTodo:) receiveSEL:@selector(receivePercent:) startSEL:nil];
//}

//-(void)addNewRequestForDelete
//{
//    LEOAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
//    LEOWebDAVDeleteRequest *deleteRequest=[[LEOWebDAVDeleteRequest alloc] initWithPath:_item.href];
//    [deleteRequest setDelegate:self];
//    deleteRequest.info=_item;
//    [delegate.client enqueueRequest:deleteRequest];
//}

//-(void)downloadItem
//{
//    LEOAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
//    LEOWebDAVDownloadRequest *downRequest=[[LEOWebDAVDownloadRequest alloc] initWithPath:_item.href];
//    downRequest.delegate=self;
//    [delegate.client enqueueRequest:downRequest];
//}

#pragma mark - Private methods
-(void)prepareDetail
{
    _progressView=[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    [_displayView addSubview:_progressView];
    _progressView.center=_displayView.center;
    [_progressView setHidden:NO];
    [_progressView setProgress:0];
    
    resultView=[[LEOResultView alloc] initWithFrame:_displayView.frame];
    [_displayView addSubview: resultView];
    resultView.hidden=YES;
}

-(void)prepareAction
{
    LEOUtility *utility=[LEOUtility getInstance];
    NSString *path=[[utility cachePathWithName:@"download"] stringByAppendingPathComponent:_item.cacheName];
    path=[path stringByAppendingPathExtension:[_item.displayName pathExtension]];
    if ([utility isExistFile:path]) {
        [self detailTodo];
    }else {
        [self downloadItem];
    }
}

-(void)detailTodo
{
    [_editToolBar setButtonStatus:YES AtIndex:0];
    [_progressView setHidden: YES];
}

-(void)detailTodo:(id)sender
{
    [_editToolBar setButtonStatus:YES AtIndex:0];
    [_progressView setHidden: YES];
}

-(void)backToList
{
//    if (downloadReq!=nil) {
//        downloadReq.instance=nil;
//        if ([downloadReq isExecuting]) {
//            [downloadReq cancel];
//        }
//    }
//    if (deleteReq!=nil) {
//        deleteReq.instance=nil;
//        if ([deleteReq isExecuting]) {
//            [deleteReq cancel];
//        }
//    }
    [_currentClient cancelDelegate];
    [_currentClient cancelRequest];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [NSOperation cancelPreviousPerformRequestsWithTarget:self];
    
    [self.navigationController popViewControllerAnimated:YES];
    [self changeToolBar:NO];
}

-(void)changeToolBar:(BOOL)isDetail
{
    LEOAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    if (isDetail) {
        if([delegate.window.rootViewController respondsToSelector:@selector(hideTabBar:fromLeft:)]){
            [delegate.window.rootViewController hideTabBar:YES fromLeft:NO];
        }
        if([_editToolBar respondsToSelector:@selector(hideEditTooBar:fromLeft:)]){
            [_editToolBar hideEditTooBar:NO fromLeft:NO];
        }
    }else {
        if([delegate.window.rootViewController respondsToSelector:@selector(hideTabBar:fromLeft:)]){
            [delegate.window.rootViewController hideTabBar:NO fromLeft:NO];
        }
        if([_editToolBar respondsToSelector:@selector(hideEditTooBar:fromLeft:)]){
            [_editToolBar hideEditTooBar:YES fromLeft:NO];
        }
    }
}



-(void)showDeleteSheet:(LEOContentSheetTag)tag
{
    //弹出提示是否真的需要删除
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you really want to delete?",@"")
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel",@"")
                                               destructiveButtonTitle:NSLocalizedString(@"Delete",@"")
                                                    otherButtonTitles:nil];
    actionSheet.tag=tag;
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showInView:self.view];
}


-(void)openFileIn
{
    LEOUtility *utility=[LEOUtility getInstance];
    NSString *openPath=[[utility cachePathWithName:@"open"] stringByAppendingPathComponent:_item.displayName];
    NSURL *url;
    if ([utility isExistFile:openPath]) {
        url=[NSURL fileURLWithPath:openPath];
    } else {
        NSError *error;
        NSString *path=[[utility cachePathWithName:@"download"] stringByAppendingPathComponent:_item.cacheName];
        path=[path stringByAppendingPathExtension:[_item.displayName pathExtension]];
        BOOL isSuccess=[[NSFileManager defaultManager] copyItemAtPath:path toPath:openPath error:&error];
        if (isSuccess && error==nil) {
            url=[NSURL fileURLWithPath:openPath];
        } else {
            url=[NSURL fileURLWithPath:path];
        }
    }
    
    UIDocumentInteractionController *documentIC=[UIDocumentInteractionController interactionControllerWithURL:url];
    documentIC.name=_item.displayName;
    documentIC.delegate=self;
//    documentIC.UTI=[self currentItemUTI];
    [documentIC retain];
    [documentIC presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
}

-(NSString *)currentItemUTI
{
    NSString *result=[[LEOExtendUTIConvert getInstance] searchForUTI:_item.contentType];
    return result;
}
#pragma mark - LEOEditToolBar delegate
-(void)didSelectedEditToolBarIndex:(NSInteger)index
{
    if (index==-1 || index==1) {
        // 打开为
        [self openFileIn];
    } else if (index==2 || index==-2) {
        //删除
        [self showDeleteSheet:LEOContentSheetTagSingle];
    } 
}

#pragma mark - LEOWebDAV delegate
- (void)request:(LEOWebDAVRequest *)aRequest didFailWithError:(NSError *)error
{
    NSLog(@"error:%@",error);
    if (error.code==404) {
        //        errorReason=NSLocalizedString(@"Can't find relative file", @"");
        [resultView setImage:[UIImage imageNamed:kDetailUnfoundIcon]];
        [resultView setText:NSLocalizedString(@"Fail to find the file, maybe already be deleted.", @"")];
        resultView.hidden=NO;
        _progressView.hidden=YES;
        return;
    }
    if ([error.domain isEqualToString:NSURLErrorDomain]) {
        [resultView setImage:[UIImage imageNamed:kDetailDownloadFailIcon]];
        [resultView setText:[error localizedDescription]];
        resultView.hidden=NO;
        _progressView.hidden=YES;
        return;
    }
//    NSString *errorReason=nil;
    if ([aRequest isKindOfClass:[LEOWebDAVDownloadRequest class]]) {
        // 下载错误
    } else if ([aRequest isKindOfClass:[LEOWebDAVDeleteRequest class]]) {
    }
    
    
}

-(void)requestFailure:(LEOWebDAVItem *)request
{
    NSLog(@"error");
}

- (void)request:(LEOWebDAVRequest *)aRequest didSucceedWithResult:(id)result
{
    NSLog(@"sucess");
    if ([aRequest isKindOfClass:[LEOWebDAVDownloadRequest class]]) {
        // 下载类请求
        NSData *myDate=result;
        NSString *cacheFolder=[[LEOUtility getInstance] cachePathWithName:@"download"];
        NSString *cacheUrl=[[cacheFolder stringByAppendingPathComponent:_item.cacheName] stringByAppendingPathExtension:[_item.displayName pathExtension]];
        [myDate writeToFile:cacheUrl atomically:YES];
//        [self detailTodo];
        [self performSelectorOnMainThread:@selector(detailTodo) withObject:nil waitUntilDone:NO];
    }
    else if ([aRequest isKindOfClass:[LEOWebDAVDeleteRequest class]]) {
        // 删除类请求
        if (self.parentInstance!=nil && [self.parentInstance respondsToSelector:@selector(loadCurrentPath)]) {
//            [self.parentInstance loadCurrentPath];
            [self.parentInstance performSelectorInBackground:@selector(loadCurrentPath) withObject:nil];
        }
        [self performSelectorOnMainThread:@selector(backToList) withObject:nil waitUntilDone:NO];
//        [self backToList];
    }
}

-(void)deleteSuccess:(id)result
{
    if (self.parentInstance && [self.parentInstance respondsToSelector:@selector(loadCurrentPath)]) {
//        [self.parentInstance loadCurrentPath];
        [self.parentInstance performSelectorInBackground:@selector(loadCurrentPath) withObject:nil];
    }
    [self backToList];
}

- (void)requestDidBegin:(LEOWebDAVRequest *)request
{
}

- (void)request:(LEOWebDAVRequest *)request didReceivedProgress:(float)percent
{
    [_progressView setProgress:percent];
}

-(void)receivePercent:(NSNumber*)percent
{
    [_progressView setProgress:percent.floatValue];
}
#pragma mark - Action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 0 && actionSheet.tag==LEOContentSheetTagSingle)
	{
        // 删除
        [self addNewRequestForDelete];
	} else if (buttonIndex==1) {
        // 取消
    }
    [actionSheet release];
}
@end
