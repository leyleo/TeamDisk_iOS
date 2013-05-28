//
//  LEOContentListViewController.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-10-25.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOContentListViewController.h"
#import "LEOAppDelegate.h"
#import "LEODefines.h"
#import "LEOUtility.h"
#import "LEOContentTypeConvert.h"
#import "LEOContentListCell.h"
#import "LEOWebDAVItem.h"
#import "LEOContentTypeConvert.h"
#import "LEODetailViewController.h"
#import "LEODetailPictureViewController.h"
#import "LEODetailVideoViewController.h"
#import "LEODetailDocViewController.h"
#import "LEOMusicViewController.h"
#import "LEOWebDAVPropertyRequest.h"
#import "LEOWebDAVDeleteRequest.h"
#import "LEOWebDAVMakeCollectionRequest.h"
#import "LEOWebDAVClient.h"
#import "LEONewFolderViewController.h"
#import "LEORenameViewController.h"

@interface LEOContentListViewController ()
{
    UITableView *_contentListView;
    LEOEditToolBar *_editToolBar;
    MBProgressHUD *_hub;
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _loading;
    
    NSMutableArray *_contentArray; // 属性队列
    NSString *_currentPath;
    LEOWebDAVItem *_currentItem;
    
    NSMutableArray *_deleteArray; // 即将被删除的队列
    
    NSIndexPath *longPressIndexPath; // 长按后选中的元素
}
@end

@implementation LEOContentListViewController

- (id)init
{
    self = [super init];
    if(self){
        self.title=NSLocalizedString(@"Root",@"");
        UIButton *backButtonView=[UIButton buttonWithType:UIButtonTypeCustom];
        backButtonView.frame=CGRectMake(0,0,kDefalutNavItemWidth,kLEONavBarHeight);
        [backButtonView setBackgroundColor:[UIColor clearColor]];
        [backButtonView setImage:[UIImage imageNamed:kTestNormal] forState:UIControlStateNormal];
        [backButtonView setImage:[UIImage imageNamed:kTestSelected] forState:UIControlStateHighlighted];
        [backButtonView addTarget:self action:@selector(backToServerList:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftButton=[[[UIBarButtonItem alloc] initWithCustomView:backButtonView] autorelease];
        self.navigationItem.leftBarButtonItem=leftButton;
        
        UIButton *editButtonView=[UIButton buttonWithType:UIButtonTypeCustom];
        editButtonView.frame=CGRectMake(0,0,kDefalutNavItemWidth,kLEONavBarHeight);
        [editButtonView setBackgroundColor:[UIColor clearColor]];
        [editButtonView setImage:[UIImage imageNamed:kTestNormal] forState:UIControlStateNormal];
        [editButtonView setImage:[UIImage imageNamed:kTestSelected] forState:UIControlStateHighlighted];
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
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:kNavigationBg] forBarMetrics:UIBarMetricsDefault];
    
    // 初始化TabelView
    CGRect frame=self.view.frame;
    frame.size.height-=kLEOTabBarHeight+kLEONavBarHeight;
    frame.origin.y=0;
    _contentListView = [[UITableView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height) style:UITableViewStylePlain];
    _contentListView.delegate=self;
    _contentListView.dataSource=self;
//    _contentListView.bounces=NO;
    _contentListView.allowsMultipleSelectionDuringEditing=YES;
    _contentListView.allowsSelectionDuringEditing=YES;
    [self.view addSubview:_contentListView];
    UIView *footer=[[UIView alloc]initWithFrame:CGRectZero];
    [_contentListView setTableFooterView:footer];
    [footer release];
    
    EGORefreshTableHeaderView *view=[[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0-frame.size.height, frame.size.width, frame.size.height)];
    view.delegate=self;
    [_contentListView addSubview: view];
    _refreshHeaderView=view;
    [view release];
    
    NSArray *items=[NSArray arrayWithObjects:NSLocalizedString(@"Select All",@""), NSLocalizedString(@"New Folder",@""), NSLocalizedString(@"Delete",@""), nil];
    _editToolBar=[[LEOEditToolBar alloc] initWithItems:items];
    _editToolBar.delegate=self;
    [_editToolBar setButtonStatus:NO AtIndex:2];
    [self.view addSubview:_editToolBar];
    
    [self loadCurrentPath];
}

-(void)dealloc
{
    [super dealloc];
    [_currentPath release];
    [_editToolBar release];
    [_contentListView release];
    [_contentArray release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - Public methods
-(void)loadCurrentPath
{
    [self setupProgressHD:NSLocalizedString(@"Loading...",@"")];
    _loading = YES;
    [self performSelectorInBackground:@selector(sendLoadRequest) withObject:nil];
}

#pragma mark - Private methods
-(void)setupProgressHD:(NSString *)text
{
    if (_hub) {
        [_hub release];
        _hub=nil;
    }
    _hub=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_hub];
    _hub.delegate=self;
    _hub.labelText=text;
    _hub.removeFromSuperViewOnHide=YES;
    [_hub show:YES];
}

-(void)sendLoadRequest
{
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
    LEOAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    LEOWebDAVPropertyRequest *request=[[LEOWebDAVPropertyRequest alloc] initWithPath:_currentPath];
    request.delegate=self;
    [delegate.client enqueueRequest:request];
    [pool release];
}

-(void)resetUI:(BOOL)isEditing
{
    if (isEditing) {
        [_editToolBar setButtonStatus:NO AtIndex:2];
        if ([_contentArray count]<1) {
            [_editToolBar setButtonStatus:NO AtIndex:0];
        }
    }
}

-(void) backToServerList:(UIButton *)button {
    if (_contentListView.editing) {
        [self editModeOfList];
    }
    if ([_currentPath isEqualToString:@"/"]) {
        LEOAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
        [delegate.window setRootViewController:delegate.rootTabBarController];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)editModeOfList {
    [_contentListView setEditing:!_contentListView.editing animated:YES];
    LEOAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    if(_contentListView.editing){
        if([delegate.window.rootViewController respondsToSelector:@selector(hideTabBar:)]){
            [delegate.window.rootViewController hideTabBar:YES];
        }
        if([_editToolBar respondsToSelector:@selector(hideEditTooBar:)]){
            [_editToolBar hideEditTooBar:NO];
        }
    }else{
        if([delegate.window.rootViewController respondsToSelector:@selector(hideTabBar:)]){
            [delegate.window.rootViewController hideTabBar:NO];
        }
        if([_editToolBar respondsToSelector:@selector(hideEditTooBar:)]){
            [_editToolBar hideEditTooBar:YES];
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
                LEOContentListCell *cell=[_contentListView cellForRowAtIndexPath:pressedIndexPath];
                [cell showExtend:YES];
                
//                [_contentListView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionBottom animated:YES];
                [_contentListView scrollToRowAtIndexPath:longPressIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }
        }
    }
}

-(void)gotoNextSection:(LEOWebDAVItem *)item
{
    LEOContentListViewController *subSectionVC=[[LEOContentListViewController alloc] initWithItem:item];
    [self.navigationController pushViewController:subSectionVC animated:YES];
    [subSectionVC release];
}

-(void)setContentArray:(NSMutableArray *)contents
{
    if (_hub) {
        [_hub hide:YES];
    }
    
    _loading = NO;
    [_refreshHeaderView refreshLastUpdatedDate];
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_contentListView];
    
    if (_contentArray!=nil) {
        [_contentArray release];
        _contentArray=nil;
    }
    _contentArray=[[NSMutableArray alloc] initWithArray:contents];
    NSLog(@"set content");
    
    if (_contentListView!=nil) {
        [_contentListView reloadData];
    }
}

-(void)addNewRequestForDelete:(LEOWebDAVItem *)one
{
    LEOAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    LEOWebDAVDeleteRequest *uploadRequest=[[LEOWebDAVDeleteRequest alloc] initWithPath:one.href];
    [uploadRequest setDelegate:self];
    uploadRequest.info=one;
    [delegate.client enqueueRequest:uploadRequest];
}

// 删除元素队列
-(void)getDeleteList
{
    NSArray *selectedArray=[_contentListView indexPathsForSelectedRows];
    if (_deleteArray==nil) {
        _deleteArray=[[NSMutableArray alloc] init];
    }
    for (NSIndexPath *selectedIndex in selectedArray) {
        [_deleteArray addObject:[_contentArray objectAtIndex:selectedIndex.row]];
    }
//    [self prepareDelete];
    [self setupProgressHD:NSLocalizedString(@"Deleting...",@"")];
    [self performSelectorInBackground:@selector(prepareDelete) withObject:nil];
}

// 删除单个元素
-(void)getDeleteItem
{
    LEOWebDAVItem *item=[_contentArray objectAtIndex:longPressIndexPath.row];
    if (_deleteArray==nil) {
        _deleteArray=[[NSMutableArray alloc] init];
    }
    [_deleteArray addObject:item];
//    [self prepareDelete];
    [self setupProgressHD:NSLocalizedString(@"Deleting...",@"")];
    [self performSelectorInBackground:@selector(prepareDelete) withObject:nil];
    [self resetExtendCellView];
}

-(void)finishDeleteList
{
    if (_hub) {
        [_hub hide:YES];
    }
    [self resetUI:[_contentListView isEditing]];
    [self loadCurrentPath]; //重新刷新当前列表
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
    if (_hub) {
        _hub.labelText=error;
    }
    [_hub performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:3000];
}

-(void)openFileIn:(LEOWebDAVItem *)_item
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
            
        }
    }
    
    UIDocumentInteractionController *documentIC=[UIDocumentInteractionController interactionControllerWithURL:url];
    documentIC.name=_item.displayName;
    documentIC.delegate=self;
    documentIC.UTI=[self currentItemUTI:_item];
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
    }
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    if (error) {
        // 有错误
        [self setupProgressHD:NSLocalizedString(@"Save Image Faild", @"保存失败")];
    }
    else {
        [self setupProgressHD:NSLocalizedString(@"Save Image Success", @"保存成功")];
    }
    [_hub performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:2];
}
#pragma mark - LEOEditToolBar delegate
-(void)didSelectedEditToolBarIndex:(NSInteger)index
{
    NSInteger count=[_contentListView numberOfRowsInSection:0];
    if (index==-1) {
        // 全选
        for (NSInteger i=0; i<count; i++) {
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:i inSection:0];
            [_contentListView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
        [_editToolBar setButtonStatus:YES AtIndex:2];
    } else if (index==1) {
        //全不选
        for (NSInteger i=0; i<count; i++) {
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:i inSection:0];
            [_contentListView deselectRowAtIndexPath:indexPath animated:YES];
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

-(void)didClickToggleButton:(UIButton *)button
{
    if (button.tag==1) {
        [button setTitle:NSLocalizedString(@"Select All",@"") forState:UIControlStateNormal];
    }else if (button.tag==-1) {
        [button setTitle:NSLocalizedString(@"Select None",@"") forState:UIControlStateNormal];
    }
}

#pragma mark - LEOWebDAV delegate
- (void)request:(LEOWebDAVRequest *)aRequest didFailWithError:(NSError *)error
{
    if ([aRequest isKindOfClass:[LEOWebDAVPropertyRequest class]]) {
        [self performSelectorOnMainThread:@selector(showRequestError:) withObject:[error description] waitUntilDone:NO];
    }else if ([aRequest isKindOfClass:[LEOWebDAVDeleteRequest class]]) {
        LEOWebDAVDeleteRequest *req=(LEOWebDAVDeleteRequest *)aRequest;
        if (req.info) {
            [_deleteArray removeObject:req.info];
        }
        if ([_deleteArray count]<1) {
            [self performSelectorOnMainThread:@selector(finishDeleteList) withObject:nil waitUntilDone:NO];
        }
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
    }
}

#pragma mark - Table view data source & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSLog(@"count:%d",[_contentArray count]);
    return [_contentArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (longPressIndexPath!=nil && [longPressIndexPath compare:indexPath]==NSOrderedSame) {
        return kContentListCellHeight+kContentListCellExtend;
    }
    return kContentListCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellNormal = @"normal";
    static NSString *CellMusic = @"music";
    static NSString *CellPicture = @"picture";
    static NSString *CellCollection = @"collection";
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
    if (item.type==LEOWebDAVItemTypeCollection) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailLabel.text=item.modifiedDate;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailLabel.text=[NSString stringWithFormat:@"%@   %@",[item.creationDate description],item.contentSize];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LEOWebDAVItem *item=[_contentArray objectAtIndex:indexPath.row];
    if (_contentListView.editing) {
        [_editToolBar setButtonStatus:YES AtIndex:2];
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (longPressIndexPath!=nil) {
            [[tableView cellForRowAtIndexPath:longPressIndexPath] showExtend:NO];
            longPressIndexPath=nil;
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
            return;
        }
        if (item.type==LEOWebDAVItemTypeFile) {
            if ([item.contentType rangeOfString:@"image"].location!=NSNotFound) {
                LEODetailDocViewController *details=[[LEODetailDocViewController alloc] initWithItem:item];
                details.parentInstance=self;
                [self.navigationController pushViewController:details animated:YES];
                [details release];
            }else if([item.contentType rangeOfString:@"video"].location!=NSNotFound){
                LEODetailVideoViewController *details=[[LEODetailVideoViewController alloc] initWithItem:item];
                details.parentInstance=self;
                [self.navigationController pushViewController:details animated:YES];
                [details release];
            }else if([item.contentType rangeOfString:@"audio"].location!=NSNotFound){
                LEOAppDelegate *delegate=[[UIApplication sharedApplication]delegate];
                [delegate.serverTabBarController.tabBar setSelectedIndex:kLEOTabBarMusicIndex];
                [delegate.musicVC playMusic:item];
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

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_contentListView.editing) {
        if ([[tableView indexPathsForSelectedRows] count]<1) {
            [_editToolBar setButtonStatus:NO AtIndex:2];
        }else{
        }
    }
}

#pragma mark - Extend cell delegate
-(void)chooseButtonForRename
{
    // 跳转到重命名视图页面
    
    LEOWebDAVItem *item=[_contentArray objectAtIndex:longPressIndexPath.row];
    LEORenameViewController *renameVC=[[LEORenameViewController alloc] initWithCurrentItem:item];
    renameVC.parentInstance=self;
    UINavigationController *navRenameVC=[[UINavigationController alloc] initWithRootViewController:renameVC];
    [self resetExtendCellView];
    [self presentViewController:navRenameVC animated:YES completion:nil];
}
-(void)chooseButtonForDelete
{
    // 显示删除对话框
    
    [self showDeleteSheet:LEOContentSheetTagSingle];
}
-(void)chooseButtonForOpenAS
{
    // 显示打开为对话页
    LEOWebDAVItem *item=[_contentArray objectAtIndex:longPressIndexPath.row];
    [self openFileIn:item];
    
    [self resetExtendCellView];
}
-(void)chooseButtonForAddToMusicList
{
    // 将音乐添加到列表中
    
    LEOWebDAVItem *item=[_contentArray objectAtIndex:longPressIndexPath.row];
    [self resetExtendCellView];
    LEOAppDelegate *delegate=[[UIApplication sharedApplication]delegate];
    [delegate.musicVC addMusic:item];
}
-(void)chooseButtonForSaveToAlbum
{
    // 将图片保存到相册
    // ToDo
    LEOWebDAVItem *item=[_contentArray objectAtIndex:longPressIndexPath.row];
    [self saveImageToAlbum:item];
    [self resetExtendCellView];
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
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    // 触发下拉事件
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
