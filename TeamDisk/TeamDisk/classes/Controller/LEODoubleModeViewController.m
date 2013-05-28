//
//  LEODoubleModeViewController.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-14.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEODoubleModeViewController.h"
#import "LEOAppDelegate.h"
#import "LEOMusicViewController.h"
#import "LEODefines.h"
#import "LEOUtility.h"
#import "LEOContentTypeConvert.h"
#import "LEOContentListCell.h"
#import "LEOWebDAVItem.h"
#import "LEOWebDAVDefines.h"
#import "LEOContentTypeConvert.h"
#import "LEODetailViewController.h"
#import "LEODetailPictureViewController.h"
#import "LEODetailVideoViewController.h"
#import "LEODetailMusicViewController.h"
#import "LEODetailDocViewController.h"
#import "LEOWebDAVPropertyRequest.h"
#import "LEOWebDAVDeleteRequest.h"
#import "LEOWebDAVDownloadRequest.h"
#import "LEOWebDAVMoveRequest.h"
#import "LEOWebDAVUploadRequest.h"
#import "LEONewFolderViewController.h"
#import "LEORenameViewController.h"
#import "LEOImageDataSource.h"
#import "KTPhotoBrowserDataSource.h"
#import "KTPhotoScrollViewController.h"
#import "LEOImageThumbnailCell.h"
#import "LEOSwitchView.h"
#import "LEOServerInfo.h"

@interface LEODoubleModeViewController ()
{
    UIButton *editButtonView;
    UITableView *_contentListView;
    LEOSwitchView *_titleView;
//    UIButton *titleButtonView;
    LEOEditToolBar *_editToolBar;
    MBProgressHUD *_hub;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _loading;
    
    NSMutableArray *_contentArray; // 属性队列
    NSString *_currentPath;
    LEOWebDAVItem *_currentItem;
    
    NSMutableArray *_deleteArray; // 即将被删除的队列
    NSMutableSet *_thumbnailDeleteSet;
    
    NSIndexPath *longPressIndexPath; // 长按后选中的元素行
    LEOWebDAVItem *_longPressItem; // 长按选中的元素
    
    LEOImageDataSource *_imageDataSource;
    
    BOOL isThumbnail;
}
@end

@implementation LEODoubleModeViewController
- (id)init
{
    self = [super init];
    if(self){
        UIButton *backButtonView=[UIButton buttonWithType:UIButtonTypeCustom];
        backButtonView.frame=CGRectMake(0,kLEONavBarBtnTopY,kDefalutNavItemWidth,kLEONavBarBtnHeight);
        [backButtonView.titleLabel setFont:[UIFont systemFontOfSize:kLEONavBarFontSz]];
        [backButtonView setTitle:NSLocalizedString(@"Back", @"") forState:UIControlStateNormal];
        backButtonView.contentEdgeInsets=UIEdgeInsetsMake(0, kLEONavBarBackLeft, 0, 0);
        [backButtonView setBackgroundImage:[UIImage imageNamed:kNavigationBackBg] forState:UIControlStateNormal];
        [backButtonView setBackgroundImage:[UIImage imageNamed:kNavigationBackBgHighlight] forState:UIControlStateHighlighted];
        [backButtonView addTarget:self action:@selector(backToServerList:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftButton=[[[UIBarButtonItem alloc] initWithCustomView:backButtonView] autorelease];
        self.navigationItem.leftBarButtonItem=leftButton;
        
        CGRect frame=CGRectMake(0,0,kDefalutNavItemWidth*2,kLEONavBarBtnHeight);
        _titleView=[[LEOSwitchView alloc] initWithFrame:frame];
        _titleView.delegate=self;
        self.navigationItem.titleView=_titleView;
        [_titleView setEnabled:NO];
        [_titleView setTitle:NSLocalizedString(@"Root",@"")];
        
        
        editButtonView=[UIButton buttonWithType:UIButtonTypeCustom];
        editButtonView.frame=CGRectMake(0,kLEONavBarBtnTopY,kDefalutNavItemWidth,kLEONavBarBtnHeight);
        [editButtonView setTitle:NSLocalizedString(@"Edit", @"") forState:UIControlStateNormal];
        [editButtonView setBackgroundImage:[UIImage imageNamed:kNavigationEditBg] forState:UIControlStateNormal];
        [editButtonView setBackgroundImage:[UIImage imageNamed:kNavigationEditBgHighlight] forState:UIControlStateHighlighted];
        [editButtonView.titleLabel setFont:[UIFont systemFontOfSize:kLEONavBarFontSz]];
        [editButtonView addTarget:self action:@selector(editModeOfList) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *editButton=[[[UIBarButtonItem alloc] initWithCustomView:editButtonView] autorelease];
        self.navigationItem.rightBarButtonItem=editButton;
    }
    return self;
}

-(id)initWithPath:(NSString *)path
{
    self=[self init];
    if (self) {
        _currentPath=[path==nil ? @"/":path copy];
        if (![_currentPath isEqualToString:@"/"]) {
            self.title=[_currentPath lastPathComponent];
            [_titleView setTitle:self.title];
        }
    }
    return self;
}

-(id)initWithItem:(LEOWebDAVItem *)_item
{
    self=[self init];
    if (self) {
        if (_item) {
            _currentItem=[[LEOWebDAVItem alloc] initWithItem:_item];
            _currentPath=_currentItem.href;
            if (![_currentPath isEqualToString:@"/"]) {
                self.title=[_currentPath lastPathComponent];
                [_titleView setTitle:self.title];
            }
        }else {
            _currentItem=nil;
            _currentPath=@"/";
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *stretchImage=[UIImage imageNamed:kNavigationBg];
    stretchImage=[stretchImage stretchableImageWithLeftCapWidth:1 topCapHeight:0];
	[self.navigationController.navigationBar setBackgroundImage:stretchImage forBarMetrics:UIBarMetricsDefault];
    
    // 初始化TabelView
    CGRect frame=self.view.frame;
    frame.size.height-=kLEOTabBarHeight+kLEONavBarHeight;
    frame.origin.y=0;
    _contentListView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    _contentListView.delegate=self;
    _contentListView.dataSource=self;
    _contentListView.backgroundColor=[UIColor colorWithRed:kBackgroundColorR green:kBackgroundColorG blue:kBackgroundColorB alpha:kBackgroundColorA];
    _contentListView.allowsMultipleSelectionDuringEditing=YES;
    _contentListView.allowsSelectionDuringEditing=YES;
    [self.view addSubview:_contentListView];
    UIView *footer=[[UIView alloc]initWithFrame:CGRectZero];
    [_contentListView setTableFooterView:footer];
    [footer release];
    
    _imageDataSource=[[LEOImageDataSource alloc] init];
    isThumbnail=NO;
    
    EGORefreshTableHeaderView *view=[[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0-frame.size.height, frame.size.width, frame.size.height)];
    view.delegate=self;
    [_contentListView addSubview: view];
    _refreshHeaderView=view;
    [view release];
    
    NSArray *items=[NSArray arrayWithObjects:NSLocalizedString(@"Select All",@""), NSLocalizedString(@"New Folder",@""), NSLocalizedString(@"Delete",@""), nil];
    _editToolBar=[[LEOEditToolBar alloc] initWithItems:items];
    [_editToolBar setToggleTextMore:NSLocalizedString(@"Select None",@"") AtIndex:0];
    _editToolBar.delegate=self;
    [_editToolBar setButtonStatus:NO AtIndex:2];
    [self.view addSubview:_editToolBar];
    
    [self loadCurrentPath];
}

// 从详情页面返回时，更新导航背景颜色
-(void)viewWillAppear:(BOOL)animated
{
    UIImage *stretchImage=[UIImage imageNamed:kNavigationBg];
    stretchImage=[stretchImage stretchableImageWithLeftCapWidth:1 topCapHeight:0];
	[self.navigationController.navigationBar setBackgroundImage:stretchImage forBarMetrics:UIBarMetricsDefault];
}

-(void)dealloc
{
    [_currentPath release];
    if(_currentItem!=nil) {
        [_currentItem release];
    }
    if (_currentClient!=nil) {
        [_currentClient cancelRequest];
        [_currentClient release];
    }
    if (_hub!=nil) {
        [_hub release];
    }
    [_editToolBar release];
    [_imageDataSource release];
    [_contentListView release];
    [_contentArray release];
    [_titleView release];
    [super dealloc];
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - Public methods
-(void)loadCurrentPath
{
    [self setupProgressHD:NSLocalizedString(@"Loading...",@"") isDone:NO];
    _loading = YES;
    [self sendLoadRequest];
}

#pragma mark - MBProgressHUD (Private)
-(void)setupProgressHDFailure:(NSString *)text
{
    if (_hub) {
        [_hub hide:NO];
        [_hub release];
        _hub=nil;
    }
    _hub=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_hub];
    _hub.delegate=self;
    _hub.mode=MBProgressHUDModeText;
    _hub.customView=nil;
    _hub.labelText=text;
    _hub.removeFromSuperViewOnHide=YES;
    [_hub show:NO];
    [_hub hide:NO afterDelay:1.5];
}

-(void)setupProgressHD:(NSString *)text isDone:(BOOL)done
{
    if (_hub) {
        [_hub hide:NO];
        [_hub release];
        _hub=nil;
    }
    _hub=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_hub];
    _hub.delegate=self;
    _hub.labelText=text;
    _hub.customView=[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"/res/Checkmark.png"]] autorelease];
    _hub.mode=done?MBProgressHUDModeCustomView:MBProgressHUDModeIndeterminate;
    _hub.removeFromSuperViewOnHide=YES;
    [_hub show:NO];
    if (done) {
        [_hub hide:NO afterDelay:1.5];
    }
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

-(void)removeClient
{
    if (_currentClient!=nil) {
        [_currentClient cancelRequest];
        [_currentClient release];
        _currentClient=nil;
    }
}

// 属性请求
-(void)sendLoadRequest
{
    if (_currentClient==nil) {
        [self setupClient];
    }
    LEOWebDAVPropertyRequest *request=[[LEOWebDAVPropertyRequest alloc] initWithPath:_currentPath];
    request.delegate=self;
    [_currentClient enqueueRequest:request];
    [request release];
}

// 下载
//-(void)downloadItem:(LEOWebDAVItem *)downloadItem withCallback:(SEL)call
//{
//    if (_currentClient==nil) {
//        [self setupClient];
//    }
//    LEOWebDAVDownloadRequest *downRequest=[[LEOWebDAVDownloadRequest alloc] initWithPath:downloadItem.href];
//    [downRequest setDelegate:self];
//    downRequest.item=downloadItem;
//    downRequest.callback=call;
//    [_currentClient enqueueRequest:downRequest];
//    [downRequest release];
//}

-(void)downloadItem:(NSDictionary *)downloadItems withCallback:(SEL)call
{
    if (_currentClient==nil) {
        [self setupClient];
    }
    LEOWebDAVItem *downloadItem=[downloadItems objectForKey:@"item"];
    if (downloadItem==nil) {
        return;
    }
    LEOWebDAVDownloadRequest *downRequest=[[LEOWebDAVDownloadRequest alloc] initWithPath:downloadItem.href];
    [downRequest setDelegate:self];
    downRequest.dictionary=downloadItems;
    downRequest.callback=call;
    [_currentClient enqueueRequest:downRequest];
    [downRequest release];
}

// 添加新的删除请求
-(void)addNewRequestForDelete:(LEOWebDAVItem *)one
{
    if (_currentClient==nil) {
        [self setupClient];
    }
    LEOWebDAVDeleteRequest *uploadRequest=[[LEOWebDAVDeleteRequest alloc] initWithPath:one.href];
    [uploadRequest setDelegate:self];
    uploadRequest.info=one;
    [_currentClient enqueueRequest:uploadRequest];
    [uploadRequest release];
}

// 移动
-(void)addNewRequestForMove:(LEOWebDAVItem *)one withNewPath:(NSString *)newPath
{
    if (_currentClient==nil) {
        [self setupClient];
    }
    LEOWebDAVMoveRequest *moveRequest=[[LEOWebDAVMoveRequest alloc] initWithPath:one.href];
    moveRequest.destinationPath=[newPath stringByAppendingPathComponent:one.displayName];
    moveRequest.overwrite=YES;
    [moveRequest setDelegate:self];
    [_currentClient enqueueRequest:moveRequest];
    [moveRequest release];
}

// 复制
-(void)addNewRequestForCopy:(LEOWebDAVItem *)one withNewPath:(NSString *)newPath
{
    if (_currentClient==nil) {
        [self setupClient];
    }
    LEOWebDAVCopyRequest *moveRequest=[[LEOWebDAVCopyRequest alloc] initWithPath:one.href];
    moveRequest.destinationPath=[newPath stringByAppendingPathComponent:one.displayName];
    moveRequest.overwrite=YES;
    [moveRequest setDelegate:self];
    [_currentClient enqueueRequest:moveRequest];
    [moveRequest release];
}

-(void)addNewRequestForUpload:(LEOWebDAVItem *)one withServerInfo:(LEOServerInfo *)info andUploadPath:(NSString *)path
{
    LEOWebDAVClient *uploadClient=[[[LEOWebDAVClient alloc] initWithRootURL:[NSURL URLWithString:info.url]
                                                               andUserName:info.userName
                                                               andPassword:info.password] autorelease];
    NSString *uploadPath=[path stringByAppendingPathComponent:one.displayName];
    uploadPath=[uploadPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    LEOWebDAVUploadRequest *uploadRequest=[[LEOWebDAVUploadRequest alloc] initWithPath:uploadPath];
    NSString *cachePath=[[[LEOUtility getInstance] cachePathWithName:@"download"] stringByAppendingPathComponent:one.cacheName];
    cachePath=[cachePath stringByAppendingPathExtension:[one.displayName pathExtension]];
    uploadRequest.data=[NSData dataWithContentsOfFile:cachePath];
    one.contentLength=[uploadRequest.data length];
    [uploadRequest setDelegate:self];
    [uploadClient enqueueRequest:uploadRequest];
    
}

#pragma mark - Private
-(void)resetUI:(BOOL)isEditing
{
    if (isEditing) {
        [_editToolBar setButtonStatus:NO AtIndex:2];
        if ([_contentArray count]<1) {
            [_editToolBar setButtonStatus:NO AtIndex:0];
        } else {
            [_editToolBar setButtonStatus:YES AtIndex:0];
        }
    }
}

-(void)reloadData
{
    [_contentListView reloadData];
}

-(void) backToServerList:(UIButton *)button {
    if (_contentListView.editing) {
        [self editModeOfList];
    }
    
    [_currentClient cancelRequest];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [NSOperation cancelPreviousPerformRequestsWithTarget:self];
    
    if (_hub!=nil) {
        [_hub hide:NO];
        _hub.delegate=nil;
        [_hub release];
        _hub=nil;
    }

    if ([_currentPath isEqualToString:@"/"]) {
        if (_loading) {
            _loading = NO;
            [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_contentListView];
        }
        LEOAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
//        [delegate.window setRootViewController:delegate.rootTabBarController];
        [delegate clearCurrentServer];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)editModeOfList {
    [self resetExtendCellView];
    [_contentListView setEditing:!_contentListView.editing animated:YES];
    LEOAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    if(_contentListView.editing){
        //编辑状态
        [self resetUI:YES];
        [editButtonView setTitle: NSLocalizedString(@"Done", @"") forState:UIControlStateNormal];
        if([delegate.window.rootViewController respondsToSelector:@selector(hideTabBar:)]){
            [delegate.window.rootViewController hideTabBar:YES];
        }
        if([_editToolBar respondsToSelector:@selector(hideEditTooBar:)]){
            [_editToolBar hideEditTooBar:NO];
        }
        if (_thumbnailDeleteSet) {
            [_thumbnailDeleteSet removeAllObjects];
        }
        if (isThumbnail) {
            [_contentListView reloadData];
        }
    }else{
        [editButtonView setTitle: NSLocalizedString(@"Edit", @"") forState:UIControlStateNormal];
        if([delegate.window.rootViewController respondsToSelector:@selector(hideTabBar:)]){
            [delegate.window.rootViewController hideTabBar:NO];
        }
        if([_editToolBar respondsToSelector:@selector(hideEditTooBar:)]){
            [_editToolBar hideEditTooBar:YES];
        }
        if (_thumbnailDeleteSet) {
            [_thumbnailDeleteSet removeAllObjects];
        }
        if (isThumbnail) {
            [_contentListView reloadData];
        }
    }
}

-(void)handleLongPress:(UILongPressGestureRecognizer*)longPressRecognizer {
    if (_contentListView.editing) {
        return;
    }
    if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *pressedIndexPath = [_contentListView indexPathForRowAtPoint:[longPressRecognizer locationInView:_contentListView]];
        
        if (pressedIndexPath && (pressedIndexPath.row != NSNotFound) && (pressedIndexPath.section != NSNotFound)) {
            //            NSLog(@"long press:%d",pressedIndexPath.row);
            if (longPressIndexPath==nil) {
                longPressIndexPath=[pressedIndexPath copy];
                [_contentListView reloadRowsAtIndexPaths:[NSArray arrayWithObject:pressedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                LEOContentListCell *cell=(LEOContentListCell *)[_contentListView cellForRowAtIndexPath:pressedIndexPath];
                [cell showExtend:YES];
                
                //                [_contentListView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionBottom animated:YES];
                [_contentListView scrollToRowAtIndexPath:longPressIndexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
            }
        }
    }
}

-(void)uploadToolBar:(BOOL)isChoose
{
    LEOAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    LEOTabBarViewController *root=(LEOTabBarViewController *)delegate.window.rootViewController;
    if (isChoose) {
        // 显示上传目录选择视图
        if([root respondsToSelector:@selector(hideTabBarFromBottom:)]){
            [root hideTabBarFromBottom:YES];
        }
    }else {
        // 隐藏目录选择视图
        if([root respondsToSelector:@selector(hideTabBarFromBottom:)]){
            [root hideTabBarFromBottom:NO];
        }
    }
}

-(void)gotoNextSection:(LEOWebDAVItem *)item
{
    LEODoubleModeViewController *subSectionVC=[[LEODoubleModeViewController alloc] initWithItem:item];
    [self.navigationController pushViewController:subSectionVC animated:YES];
    [subSectionVC release];
}

-(void)finishLoad
{
    _loading = NO;
    [_refreshHeaderView refreshLastUpdatedDate];
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_contentListView];
}

-(void)setContentArray:(NSMutableArray *)contents
{
    if (_hub) {
        [_hub hide:NO];
    }
    
    [self finishLoad];
    
    if (_contentArray!=nil) {
        [_contentArray release];
        _contentArray=nil;
    }
    _contentArray=[[NSMutableArray alloc] initWithArray:contents];
    if (_imageDataSource) {
        [_imageDataSource removeAllObjects];
    }
    for (LEOWebDAVItem *it in contents) {
        if ([it.contentType rangeOfString:@"image"].location!=NSNotFound) {
            [_imageDataSource addObject:it];
        }
    }
    NSLog(@"set content");
    if ([_contentArray count]>0&&[_contentArray count]==[_imageDataSource numberOfPhotos]) {
        // 全部为图片
//        if ([_titleView enabled]==NO) {
//            // 当第一次转变为全图片文件夹时，转换成缩略图视图，否则保持不变
//            isThumbnail=YES;
//        }
        [_titleView setEnabled:YES];
        [_titleView setLeftOn:isThumbnail];
    }else {
        [_titleView setEnabled:NO];
        isThumbnail=NO;
    }
    
    if ([_contentArray count]>0) {
        [_editToolBar setButtonStatus:YES AtIndex:0];
    } else {
        [_editToolBar setButtonStatus:NO AtIndex:0];
    }
    
    [self prepareViewToggle];
    
    if (_contentListView!=nil) {
        [_contentListView reloadData];
    }
}



// 将所多选项添加到删除队列里
-(void)addSeletedItemsToDeleteArray
{
    if (_deleteArray==nil) {
        _deleteArray=[[NSMutableArray alloc] init];
    }
    
    if (isThumbnail) {
        // 缩略图模式，从暂存里取出待删除项
        for (LEOWebDAVItem *item in _thumbnailDeleteSet) {
            [_deleteArray addObject:item];
        }
    } else {
        // 列表模式，从队列里取出待删除项
        NSArray *selectedArray=[_contentListView indexPathsForSelectedRows];
        for (NSIndexPath *selectedIndex in selectedArray) {
            [_deleteArray addObject:[_contentArray objectAtIndex:selectedIndex.row]];
        }
    }
}

// 删除元素队列
-(void)getDeleteList
{
    [self addSeletedItemsToDeleteArray];
    
    [self setupProgressHD:NSLocalizedString(@"Deleting...",@"") isDone:NO];
    [self performSelectorInBackground:@selector(prepareDelete) withObject:nil];
}

// 删除单个元素
-(void)getDeleteItem
{
    LEOWebDAVItem *item;
    if (isThumbnail) {
        item=_longPressItem;
    } else {
        item=[_contentArray objectAtIndex:longPressIndexPath.row];
    }
    
    if (_deleteArray==nil) {
        _deleteArray=[[NSMutableArray alloc] init];
    }
    [_deleteArray addObject:item];
    //    [self prepareDelete];
    [self setupProgressHD:NSLocalizedString(@"Deleting...",@"") isDone:NO];
    [self performSelectorInBackground:@selector(prepareDelete) withObject:nil];
    [self resetExtendCellView];
}

-(void)finishDeleteList
{
    if (_hub) {
        [_hub hide:NO];
    }
    [self setupProgressHD:NSLocalizedString(@"Delete Success",@"") isDone:YES];

    [self resetUI:[_contentListView isEditing]];
    [self loadCurrentPath]; //重新刷新当前列表
}

-(void)finishUpload
{
    if (_hub) {
        [_hub hide:NO];
    }
    [self setupProgressHD:NSLocalizedString(@"Done",@"") isDone:YES];
    
    [self resetUI:[_contentListView isEditing]];
}

// 将_deleteArray中的元素添加到删除队列里
-(void)prepareDelete
{
    for (LEOWebDAVItem *item in _deleteArray) {
        [self addNewRequestForDelete:item];
    }
}

// 删除操作的提示
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

// 跳转到新建文件夹视图
-(void)createNewFolder
{
    LEONewFolderViewController *newFolder=[[LEONewFolderViewController alloc] initWithCurrentPath:_currentPath];
    newFolder.parentInstance=self;
    UINavigationController *navNewFolder=[[UINavigationController alloc] initWithRootViewController:newFolder];
    [self presentViewController:navNewFolder animated:YES completion:nil];
    [navNewFolder release];
    [newFolder release];
}

// 还原Extend Cell View 视图
-(void)resetExtendCellView
{
    if (longPressIndexPath!=nil) {
        [[_contentListView cellForRowAtIndexPath:longPressIndexPath] showExtend:NO];
        NSArray *need2Reload=[NSArray arrayWithObject:longPressIndexPath];
        longPressIndexPath=nil;
        [_contentListView reloadRowsAtIndexPaths:need2Reload withRowAnimation:UITableViewRowAnimationNone];
    }
}

// 显示Request Error
-(void)showRequestError:(NSString *)error
{
    [self finishLoad];
    [self setupProgressHDFailure:error];
}



-(void)openFileIn:(LEOWebDAVItem *)_item
{
    if (_hub) {
        [_hub hide:NO];
        [_hub release];
        _hub=nil;
    }
    LEOUtility *utility=[LEOUtility getInstance];
    NSString *openPath=[[utility cachePathWithName:@"open"] stringByAppendingPathComponent:_item.displayName];
    NSURL *url;
    if ([utility isExistFile:openPath]) {
        url=[NSURL fileURLWithPath:openPath];
    } else {
        NSError *error;
        NSString *path=[[utility cachePathWithName:@"download"] stringByAppendingPathComponent:_item.cacheName];
        path=[path stringByAppendingPathExtension:[_item.displayName pathExtension]];
        if ([utility isExistFile:path]) {
            // 在cache download中存在
            BOOL isSuccess=[[NSFileManager defaultManager] copyItemAtPath:path toPath:openPath error:&error];
            if (isSuccess && error==nil) {
                url=[NSURL fileURLWithPath:openPath];
            } else {
                url=[NSURL fileURLWithPath:path];
            }
        }
        else {
            // 需要先下载，再打开
//            [self downloadItem:_item withCallback:@selector(openFileIn:)];
            [self downloadItem:[NSDictionary dictionaryWithObject:_item forKey:@"item"] withCallback:@selector(openFileIn:)];
            [self setupProgressHD:NSLocalizedString(@"Loading...", @"") isDone:NO];
            return;
        }
    }
    
    UIDocumentInteractionController *documentIC=[UIDocumentInteractionController interactionControllerWithURL:url];
    documentIC.name=_item.displayName;
    documentIC.delegate=self;
//    documentIC.UTI=[self currentItemUTI:_item];
    [documentIC retain];
    [documentIC presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
}

// 取当前文件的UTI，用来执行不同的“打开为”
-(NSString *)currentItemUTI:(LEOWebDAVItem *)_item
{
    NSString *result=[[LEOExtendUTIConvert getInstance] searchForUTI:_item.contentType];
    return result;
}

-(void)saveImageToAlbum:(LEOWebDAVItem *)_item
{
    LEOUtility *utility=[LEOUtility getInstance];
    NSString *path=[[utility cachePathWithName:@"download"] stringByAppendingPathComponent:_item.cacheName];
    path=[path stringByAppendingPathExtension:[_item.displayName pathExtension]];
    if ([utility isExistFile:path]) {
        UIImage *image=[UIImage imageWithContentsOfFile:path];
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    } else {
        // 需要先下载，再保存
//        [self downloadItem:_item withCallback:@selector(saveImageToAlbum:)];
        [self downloadItem:[NSDictionary dictionaryWithObject:_item forKey:@"item"] withCallback:@selector(saveImageToAlbum:)];
        [self setupProgressHD:NSLocalizedString(@"Loading...", @"") isDone:NO];
        return;
    }
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    if (error) {
        // 有错误
        [self setupProgressHDFailure:NSLocalizedString(@"Save Image Faild", @"保存失败")];
    }
    else {
        [self setupProgressHD:NSLocalizedString(@"Save Image Success", @"保存成功") isDone:YES];
    }
}

#pragma mark - Toggle View (Private)

-(void)toggleViewMode
{
    // 切换模式
    isThumbnail=!isThumbnail;
    [_titleView setLeftOn:isThumbnail];
}

-(void)prepareViewToggle
{
    if (longPressIndexPath!=nil) {
        [[_contentListView cellForRowAtIndexPath:longPressIndexPath] showExtend:NO];
        longPressIndexPath=nil;
    }
    
    if (isThumbnail) {
        [_contentListView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }else {
        [_contentListView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    }
}

-(void)convertEditToggleView
{
    if (isThumbnail) {
        // 从列表-》缩略图
        if (_thumbnailDeleteSet==nil) {
            _thumbnailDeleteSet=[[NSMutableSet alloc] init];
        }
        [_thumbnailDeleteSet removeAllObjects];
        NSArray *selectedArray=[_contentListView indexPathsForSelectedRows];
        for (NSIndexPath *selectedIndex in selectedArray) {
            [_thumbnailDeleteSet addObject:[_contentArray objectAtIndex:selectedIndex.row]];
        }
        [_contentListView reloadData];
    } else {
        // 从缩略图-》列表
        [_contentListView reloadData];
        for (LEOWebDAVItem *item in _thumbnailDeleteSet) {
            NSIndexPath *index=[NSIndexPath indexPathForRow:[_contentArray indexOfObject:item] inSection:0];
            [_contentListView selectRowAtIndexPath:index animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

-(void)changeMode
{
    [self toggleViewMode];
    
    // 载入之前模式已选内容
    [self prepareViewToggle];
    
    if (_contentListView.isEditing) {
        // 正在编辑状态
        [self convertEditToggleView];
    } else {
        [_contentListView reloadData];
    }
}
#pragma mark - LEOSwitchView Delegate
-(void)toggleAction:(UIButton *)button
{
    [self changeMode];
}

#pragma mark - LEOEditToolBar delegate
-(void)didSelectedEditToolBarIndex:(NSInteger)index
{
    NSInteger count=[_contentListView numberOfRowsInSection:0];
    if (index==-1) {
        // 全选
        if (isThumbnail) {
            // 缩略图状态
            for (NSInteger i=0; i<count; i++) {
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:i inSection:0];
                LEOImageThumbnailCell *cell=(LEOImageThumbnailCell *)[_contentListView cellForRowAtIndexPath:indexPath];
                [cell setAllSelected:YES];
            }
            if (_thumbnailDeleteSet==nil) {
                _thumbnailDeleteSet=[[NSMutableSet alloc] init];
            }
            [_thumbnailDeleteSet addObjectsFromArray:_contentArray];
        } else {
            for (NSInteger i=0; i<count; i++) {
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:i inSection:0];
                [_contentListView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
        }
        [_editToolBar setButtonStatus:YES AtIndex:2];
    } else if (index==1) {
        //全不选
        if (isThumbnail) {
            // 缩略图状态
            for (NSInteger i=0; i<count; i++) {
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:i inSection:0];
                LEOImageThumbnailCell *cell=(LEOImageThumbnailCell *)[_contentListView cellForRowAtIndexPath:indexPath];
                [cell setAllSelected:NO];
            }
            if (_thumbnailDeleteSet) {
                [_thumbnailDeleteSet removeAllObjects];
            }
        } else {
            for (NSInteger i=0; i<count; i++) {
                NSIndexPath *indexPath=[NSIndexPath indexPathForRow:i inSection:0];
                [_contentListView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }
        
        [_editToolBar setButtonStatus:NO AtIndex:2];
    } else if (index==2 || index==-2) {
        //新建文件夹
        [self createNewFolder];
    } else if (index==3 || index==-3) {
        //删除
        [self showDeleteSheet:LEOContentSheetTagList];
    }
}
#pragma mark - Move delegate
-(void)setUploadPath:(NSString *)path
{
    LEOWebDAVItem *item;
    if (isThumbnail) {
        item=_longPressItem;
    } else {
        item=[_contentArray objectAtIndex:longPressIndexPath.row];
    }
    [self addNewRequestForMove:item withNewPath:path];
    [self resetExtendCellView];
}

-(void)beforeFinishChooseMovePath
{
    [self uploadToolBar:NO];
    [self resetExtendCellView];
}

#pragma mark - Copy delegate
-(void)setCopyPath:(NSString *)path withServer:(LEOServerInfo *)serverInfo
{
    LEOWebDAVItem *item;
    if (isThumbnail) {
        item=_longPressItem;
    } else {
        item=[_contentArray objectAtIndex:longPressIndexPath.row];
    }
    // 需要判断，如果跨server,需要单独处理
    LEOAppDelegate *delegate=[[UIApplication sharedApplication]delegate];
    LEOServerInfo *currentServer=delegate.currentServer;
    if ([serverInfo isEqual:currentServer]) {
        // 当前server, 使用copy方法
        [self addNewRequestForCopy:item withNewPath:path];
    } else {
        // 不是同一个server，需要先下载再上传
        NSMutableDictionary *dictionary=[[NSMutableDictionary alloc] init];
        [dictionary setObject:item forKey:@"item"];
        [dictionary setObject:serverInfo forKey:@"serverInfo"];
        [dictionary setObject:path forKey:@"desPath"];
        [self downloadItem:dictionary withCallback:@selector(remoteUpload:)];
        [self setupProgressHD:NSLocalizedString(@"Loading...", @"") isDone:NO];
    }
    
    [self resetExtendCellView];
}

-(void)beforeFinishChooseCopyPath
{
    [self uploadToolBar:NO];
    [self resetExtendCellView];
}

-(void)remoteUpload:(NSDictionary *)dictionary
{
    [self setupProgressHD:@"uploading..." isDone:NO];
    LEOServerInfo *server=[dictionary objectForKey:@"serverInfo"];
    LEOWebDAVItem *item=[dictionary objectForKey:@"item"];
    NSString *desPath=[dictionary objectForKey:@"desPath"];
    [self addNewRequestForUpload:item withServerInfo:server andUploadPath:desPath];
    [self setupProgressHD:NSLocalizedString(@"Loading...", @"") isDone:NO];
}
#pragma mark - LEOWebDAV delegate
- (void)request:(LEOWebDAVRequest *)aRequest didFailWithError:(NSError *)error
{
    NSLog(@"error:%@",error);
    if ([aRequest isKindOfClass:[LEOWebDAVPropertyRequest class]]) {
        if ([error.domain isEqualToString:kWebDAVErrorDomain] && error.code==-1) {
            // 如果是手动取消载入请求，不进行提示
            return;
        }
        [self performSelectorOnMainThread:@selector(showRequestError:) withObject:[error localizedDescription] waitUntilDone:NO];
    }else if ([aRequest isKindOfClass:[LEOWebDAVDeleteRequest class]]) {
        LEOWebDAVDeleteRequest *req=(LEOWebDAVDeleteRequest *)aRequest;
        if (req.info) {
            [_deleteArray removeObject:req.info];
        }
        if ([_deleteArray count]<1) {
            [self performSelectorOnMainThread:@selector(finishDeleteList) withObject:nil waitUntilDone:NO];
        }
    }else if ([aRequest isKindOfClass:[LEOWebDAVDownloadRequest class]]) {
        if ([error.domain isEqualToString:kWebDAVErrorDomain] && error.code==-1) {
            // 如果是手动取消载入请求，不进行提示
            return;
        }
        [self performSelectorOnMainThread:@selector(showRequestError:) withObject:[error localizedDescription] waitUntilDone:NO];
    }else if ([aRequest isKindOfClass:[LEOWebDAVMoveRequest class]]) {
        if ([error.domain isEqualToString:kWebDAVErrorDomain] && error.code==-1) {
            // 如果是手动取消载入请求，不进行提示
            return;
        }
        [self performSelectorOnMainThread:@selector(showRequestError:) withObject:[error localizedDescription] waitUntilDone:NO];
    }else if ([aRequest isKindOfClass:[LEOWebDAVUploadRequest class]]) {
        if ([error.domain isEqualToString:kWebDAVErrorDomain] && error.code==-1) {
            // 如果是手动取消载入请求，不进行提示
            return;
        }
        [self performSelectorOnMainThread:@selector(showRequestError:) withObject:[error localizedDescription] waitUntilDone:NO];
    }
}

- (void)request:(LEOWebDAVRequest *)aRequest didSucceedWithResult:(id)result
{
    if ([aRequest isKindOfClass:[LEOWebDAVPropertyRequest class]]) {
        //        [self setContentArray:result];
        [self performSelectorOnMainThread:@selector(setContentArray:) withObject:result waitUntilDone:NO];
    }else if ([aRequest isKindOfClass:[LEOWebDAVDeleteRequest class]]) {
        LEOWebDAVDeleteRequest *req=(LEOWebDAVDeleteRequest *)aRequest;
        if (req.info) {
            [_deleteArray removeObject:req.info];
        }
        if ([_deleteArray count]<1) {
            [self performSelectorOnMainThread:@selector(finishDeleteList) withObject:nil waitUntilDone:NO];
        }
    }else if ([aRequest isKindOfClass:[LEOWebDAVDownloadRequest class]]) {
        // 下载类请求
        NSData *myDate=result;
        LEOWebDAVDownloadRequest *req=(LEOWebDAVDownloadRequest *)aRequest;
//        LEOWebDAVItem *downloadItem=req.item;
        NSDictionary *dictionary=req.dictionary;
        LEOWebDAVItem *downloadItem=dictionary==nil?nil:[dictionary objectForKey:@"item"];
        NSString *cacheFolder=[[LEOUtility getInstance] cachePathWithName:@"download"];
        NSString *cacheUrl=[[cacheFolder stringByAppendingPathComponent:downloadItem.cacheName] stringByAppendingPathExtension:[downloadItem.displayName pathExtension]];
        [myDate writeToFile:cacheUrl atomically:YES];
        if (downloadItem!=nil && [downloadItem.contentType rangeOfString:@"image"].location!=NSNotFound) {
            [self performSelectorInBackground:@selector(computeThumbnail:) withObject:cacheUrl];
        }
        if (req.callback) {
//            [self performSelectorOnMainThread:req.callback withObject:downloadItem waitUntilDone:NO];
            [self performSelectorOnMainThread:req.callback withObject:dictionary waitUntilDone:NO];
        }
    }else if ([aRequest isKindOfClass:[LEOWebDAVMoveRequest class]]) {
        [self performSelectorInBackground:@selector(loadCurrentPath) withObject:nil];
    } else if ([aRequest isKindOfClass:[LEOWebDAVUploadRequest class]]) {
        [self performSelectorOnMainThread:@selector(finishUpload) withObject:nil waitUntilDone:NO];
    }
}

#pragma mark - Table view data source & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return [_contentArray count];
    if (isThumbnail) {
        NSInteger count=ceil([_contentArray count]/4.0);
        NSLog(@"count:%d/%d",count,[_contentArray count]);
        return count;
    }else{
        return [_contentArray count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isThumbnail) {
        if (longPressIndexPath!=nil && [longPressIndexPath compare:indexPath]==NSOrderedSame) {
            return kImageThumbnailSz+kImageThumbnailMargin+kContentListCellExtend;
        }
        return kImageThumbnailSz+kImageThumbnailMargin;
    }else {
        if (longPressIndexPath!=nil && [longPressIndexPath compare:indexPath]==NSOrderedSame) {
            return kContentListCellHeight+kContentListCellExtend;
        }
        return kContentListCellHeight;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isThumbnail) {
        // 缩略图模式
        LEOImageThumbnailCell *cell=[tableView dequeueReusableCellWithIdentifier:CellThumbnail];
        if (cell==nil) {
            cell=[[[LEOImageThumbnailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellThumbnail] autorelease];
            cell.delegate=self;
        }
        NSInteger length=_contentArray.count-indexPath.row*4;
        length=length<4?length:4;
        NSRange range=NSMakeRange(indexPath.row*4, length);
        NSArray *array=[_contentArray subarrayWithRange:range];
        [cell setThumbnails:array];
        for (int i=0; i<length; i++) {
            if ([_thumbnailDeleteSet containsObject:[array objectAtIndex:i]]) {
                [cell setIndex:i Selected:YES];
            }else {
                [cell setIndex:i Selected:NO];
            }
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone ;
        return cell;
    } else {
        // 列表模式
        NSString *dynimicCell;
        LEOWebDAVItem *item=[_contentArray objectAtIndex:indexPath.row];
        if (item.type==LEOWebDAVItemTypeCollection) {
            dynimicCell=CellCollection;
        }
        else if ([item.contentType rangeOfString:@"audio"].location!=NSNotFound) {
            dynimicCell=CellMusic;
        } else if ([item.contentType rangeOfString:@"image"].location!=NSNotFound) {
            dynimicCell=CellPicture;
        } else {
            dynimicCell=CellNormal;
        }
        LEOContentListCell *cell = [tableView dequeueReusableCellWithIdentifier:dynimicCell];
        if(cell==nil){
            cell = [[[LEOContentListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:dynimicCell] autorelease];
            UILongPressGestureRecognizer *longPressRecognizer = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)] autorelease];
            [cell addGestureRecognizer:longPressRecognizer];
            cell.delegate=self;
        }
        
        cell.fileNameLabel.text=item.displayName;
        NSString *iconName=[[LEOContentTypeConvert getInstance] searchForResourceType:item.contentType isFile:item.type==LEOWebDAVItemTypeFile];
        [cell setIconType:iconName];
        if ([item.contentType rangeOfString:@"image"].location!=NSNotFound) {
            [cell setThumbnail:[item.cacheName stringByAppendingPathExtension:[item.displayName pathExtension]]];
        }
        if (item.type==LEOWebDAVItemTypeCollection) {
            [cell showAccessory:YES];
            cell.detailLabel.text=item.modifiedDate;
        }else{
            [cell showAccessory:NO];
            cell.detailLabel.text=[NSString stringWithFormat:@"%@   %@",[item.modifiedDate description],item.contentSize];
        }
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isThumbnail) {
        //
    } else {
        LEOWebDAVItem *item=[_contentArray objectAtIndex:indexPath.row];
        if (_contentListView.editing) {
            [_editToolBar setButtonStatus:YES AtIndex:2];
        }else{
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            if (longPressIndexPath!=nil) {
                [self resetExtendCellView];
                return;
            }
            if (item.type==LEOWebDAVItemTypeFile) {
                if ([item.contentType rangeOfString:@"image"].location!=NSNotFound) {
                    NSInteger index=[_imageDataSource indexOfObject:item];
                    KTPhotoScrollViewController *newController = [[KTPhotoScrollViewController alloc]
                                                                  initWithDataSource:_imageDataSource
                                                                  andStartWithPhotoAtIndex:index];
                    newController.parentInstance=self;
                    [[self navigationController] pushViewController:newController animated:YES];
                    [newController release];
                }else if([item.contentType rangeOfString:@"video"].location!=NSNotFound){
                    LEODetailVideoViewController *details=[[LEODetailVideoViewController alloc] initWithItem:item];
                    details.parentInstance=self;
                    [self.navigationController pushViewController:details animated:YES];
                    [details release];
                }else if([item.contentType rangeOfString:@"audio"].location!=NSNotFound){
                    LEODetailMusicViewController *details=[[LEODetailMusicViewController alloc] initWithItem:item];
                    details.parentInstance=self;
                    [self.navigationController pushViewController:details animated:YES];
                    [details release];
                }else{
                    LEODetailDocViewController *details=[[LEODetailDocViewController alloc] initWithItem:item];
                    details.parentInstance=self;
                    [self.navigationController pushViewController:details animated:YES];
                    [details release];
                }
            }else {
                [self gotoNextSection:item];
            }
        }
    }
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isThumbnail) {
        return;
    }
    if (_contentListView.editing) {
        if ([[tableView indexPathsForSelectedRows] count]<1) {
            [_editToolBar setButtonStatus:NO AtIndex:2];
        }else{
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isThumbnail) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark Thumbnail Mode
-(void)didSelected:(LEOWebDAVItem *)index
{
    NSLog(@"selected:%@",index.displayName);
    if (_contentListView.editing) {
        // 编辑状态
        if (_thumbnailDeleteSet==nil) {
            _thumbnailDeleteSet=[[NSMutableSet alloc] init];
        }
        if ([_thumbnailDeleteSet containsObject:index]) {
            [_thumbnailDeleteSet removeObject:index];
        }else {
            [_thumbnailDeleteSet addObject:index];
        }
        if ([_thumbnailDeleteSet count]>0) {
            [_editToolBar setButtonStatus:YES AtIndex:2];
        }else {
            [_editToolBar setButtonStatus:NO AtIndex:2];
        }
        NSLog(@"thumbnaildeleteset:%d",[_thumbnailDeleteSet count]);
    } else {
        // 查看状态
        if (longPressIndexPath!=nil) {
            [self resetExtendCellView];
            return;
        }
        NSInteger _index=[_imageDataSource indexOfObject:index];
        [self didSelectThumbAtIndex:_index];
    }
}
-(void)thumbnailLongPress:(LEOWebDAVItem *)item
{
    
    if (_contentListView.editing) {
        // 编辑状态, do nothing
    } else {
        //
        NSLog(@"long press:%@",item.displayName);
        NSInteger _index=[_contentArray indexOfObject:item];
        _longPressItem=item;
        NSIndexPath *index=[NSIndexPath indexPathForRow:floor(_index/4.0) inSection:0];
        if (longPressIndexPath==nil) {
            longPressIndexPath=[index copy];
            [_contentListView reloadRowsAtIndexPaths:[NSArray arrayWithObject:longPressIndexPath] withRowAnimation:UITableViewRowAnimationNone];
            LEOImageThumbnailCell *cell=(LEOImageThumbnailCell *)[_contentListView cellForRowAtIndexPath:longPressIndexPath];
            [cell showExtend:YES];

            [_contentListView scrollToRowAtIndexPath:longPressIndexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
        }
    }
}

- (void)didSelectThumbAtIndex:(NSUInteger)index {
    KTPhotoScrollViewController *newController = [[KTPhotoScrollViewController alloc]
                                                  initWithDataSource:_imageDataSource
                                                  andStartWithPhotoAtIndex:index];
    newController.parentInstance=self;
    [[self navigationController] pushViewController:newController animated:YES];
    [newController release];
}
#pragma mark - Extend cell delegate
-(void)chooseButtonForRename
{
    // 跳转到重命名视图页面
    LEOWebDAVItem *item;
    if (isThumbnail) {
        // 缩略图
        item=_longPressItem;
    } else {
        // 列表视图
        item=[_contentArray objectAtIndex:longPressIndexPath.row];
    }
    
    LEORenameViewController *renameVC=[[LEORenameViewController alloc] initWithCurrentItem:item];
    renameVC.parentInstance=self;
    UINavigationController *navRenameVC=[[UINavigationController alloc] initWithRootViewController:renameVC];
    [self resetExtendCellView];
    [self presentViewController:navRenameVC animated:YES completion:nil];
    [renameVC release];
    [navRenameVC release];
}
-(void)chooseButtonForDelete
{
    // 显示删除对话框
    [self showDeleteSheet:LEOContentSheetTagSingle];
}
-(void)chooseButtonForOpenAS
{
    // 显示打开为对话页
    LEOWebDAVItem *item;
    if (isThumbnail) {
        // 缩略图
        item=_longPressItem;
    } else {
        // 列表视图
        item=[_contentArray objectAtIndex:longPressIndexPath.row];
    }
    
    [self openFileIn:item];
    
    [self resetExtendCellView];
}
-(void)chooseButtonForAddToMusicList
{
    // 将音乐添加到列表中
    LEOWebDAVItem *item;
    if (isThumbnail) {
        // 缩略图
        item=_longPressItem;
    } else {
        // 列表视图
        item=[_contentArray objectAtIndex:longPressIndexPath.row];
    }
    LEOAppDelegate *delegate=[[UIApplication sharedApplication]delegate];
    [delegate.musicVC addMusic:item];
    [self resetExtendCellView];
}
-(void)chooseButtonForSaveToAlbum
{
    // 将图片保存到相册
    LEOWebDAVItem *item;
    if (isThumbnail) {
        // 缩略图
        item=_longPressItem;
    } else {
        // 列表视图
        item=[_contentArray objectAtIndex:longPressIndexPath.row];
    }
    [self saveImageToAlbum:item];
    [self resetExtendCellView];
}

-(void)chooseButtonForMoveTo
{
    // 移动
    LEOWebDAVItem *item;
    if (isThumbnail) {
        // 缩略图
        item=_longPressItem;
    } else {
        // 列表视图
        item=[_contentArray objectAtIndex:longPressIndexPath.row];
    }
    LEOChoosePathViewController *chooseVC=[[LEOChoosePathViewController alloc] initWithPath:nil];
    
    chooseVC.parent=self;
    UINavigationController *navChooseVC=[[UINavigationController alloc] initWithRootViewController:chooseVC];
    [self presentViewController:navChooseVC animated:YES completion:nil];
    [chooseVC release];
    [navChooseVC release];
    
    [self uploadToolBar:YES];
}

// 复制到
-(void)chooseButtonForCopyTo
{
    LEOWebDAVItem *item;
    if (isThumbnail) {
        // 缩略图
        item=_longPressItem;
    } else {
        // 列表视图
        item=[_contentArray objectAtIndex:longPressIndexPath.row];
    }
    LEOChooseCopyPathViewController *chooseVC=[[LEOChooseCopyPathViewController alloc] initWithPath:nil];
    chooseVC.parent=self;
    UINavigationController *navChooseVC=[[UINavigationController alloc] initWithRootViewController:chooseVC];
    [self presentViewController:navChooseVC animated:YES completion:nil];
    [chooseVC release];
    [navChooseVC release];
    
    [self uploadToolBar:YES];
}

-(void)computeThumbnail:(NSString *)path
{
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
    NSString *url=[[NSString alloc] initWithString:path];
    NSString *cacheName=[url lastPathComponent];
    UIImage *icon=[LEOUtility generatePhotoThumbnail:[UIImage imageWithContentsOfFile:url]];
    NSString *cacheFolder=[[LEOUtility getInstance] cachePathWithName:@"thumbnail"];
    NSString *cacheUrl=[cacheFolder stringByAppendingPathComponent:cacheName];
    NSData *data=UIImageJPEGRepresentation(icon, 1.0);
    [data writeToFile:cacheUrl atomically:YES];
    [url release];
    [pool release];
}

#pragma mark - Action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 0)
	{
        if (actionSheet.tag==LEOContentSheetTagList) {
            [self getDeleteList];
        }
		else if (actionSheet.tag==LEOContentSheetTagSingle) {
            [self getDeleteItem];
        }
	} else if (buttonIndex==1) {
        if (actionSheet.tag==LEOContentSheetTagSingle) {
            [self resetExtendCellView];
        }
    }
    [actionSheet release];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    // 触发下拉事件
    [self resetExtendCellView];
    [self loadCurrentPath];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return _loading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return [NSDate date];
}

#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}
@end
