//
//  LEOChoosePathViewController.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-8.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOChoosePathViewController.h"
#import "LEOAppDelegate.h"
#import "LEODefines.h"
#import "LEOWebDAVItem.h"
#import "LEOWebDAVPropertyRequest.h"
#import "LEOWebDAVClient.h"
#import "LEOServerInfo.h"
#import "LEOContentListCell.h"
#import "LEONewFolderViewController.h"

@interface LEOChoosePathViewController ()
{
    UITableView *_contentListView;
    LEOEditToolBar *_editToolBar;
    UIBarButtonItem *leftButton;
    
    NSMutableArray *_contentArray;
    NSString *_currentPath;
    LEOWebDAVItem *_currentItem;
    
    MBProgressHUD *_hub;
}
@end

@implementation LEOChoosePathViewController
@synthesize parent;
- (id)init
{
    self = [super init];
    if(self){
        self.title=NSLocalizedString(@"Root",@"");
        UIButton *backButtonView=[UIButton buttonWithType:UIButtonTypeCustom];
        backButtonView.frame=CGRectMake(0,kLEONavBarBtnTopY,kDefalutNavItemWidth,kLEONavBarBtnHeight);
        [backButtonView setTitle:NSLocalizedString(@"Back", @"") forState:UIControlStateNormal];
        backButtonView.contentEdgeInsets=UIEdgeInsetsMake(0, kLEONavBarBackLeft, 0, 0);
        [backButtonView setBackgroundImage:[UIImage imageNamed:kNavigationBackBg] forState:UIControlStateNormal];
        [backButtonView setBackgroundImage:[UIImage imageNamed:kNavigationBackBgHighlight] forState:UIControlStateHighlighted];
        [backButtonView.titleLabel setFont:[UIFont systemFontOfSize:kLEONavBarFontSz]];
        [backButtonView addTarget:self action:@selector(backToPrevious:) forControlEvents:UIControlEventTouchUpInside];
        leftButton=[[UIBarButtonItem alloc] initWithCustomView:backButtonView];
        self.navigationItem.leftBarButtonItem=nil;
        
        UIButton *cancelButtonView=[UIButton buttonWithType:UIButtonTypeCustom];
        cancelButtonView.frame=CGRectMake(0,kLEONavBarBtnTopY,kDefalutNavItemWidth,kLEONavBarBtnHeight);
        [cancelButtonView setTitle:NSLocalizedString(@"Cancel", @"") forState:UIControlStateNormal];
        [cancelButtonView setBackgroundImage:[UIImage imageNamed:kNavigationEditBg] forState:UIControlStateNormal];
        [cancelButtonView setBackgroundImage:[UIImage imageNamed:kNavigationEditBgHighlight] forState:UIControlStateHighlighted];
        [cancelButtonView.titleLabel setFont:[UIFont systemFontOfSize:kLEONavBarFontSz]];
        [cancelButtonView addTarget:self action:@selector(cancelChoose) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *cancelButton=[[[UIBarButtonItem alloc] initWithCustomView:cancelButtonView] autorelease];
        self.navigationItem.rightBarButtonItem=cancelButton;
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
            self.navigationItem.leftBarButtonItem=leftButton;
        }else {
            
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
                self.navigationItem.leftBarButtonItem=leftButton;
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
    _contentListView.bounces=NO;
    _contentListView.allowsSelectionDuringEditing=YES;
    _contentListView.backgroundColor=[UIColor colorWithRed:kBackgroundColorR green:kBackgroundColorG blue:kBackgroundColorB alpha:kBackgroundColorA];
    [self.view addSubview:_contentListView];
    UIView *footer=[[UIView alloc]initWithFrame:CGRectZero];
    [_contentListView setTableFooterView:footer];
    [footer release];
    NSArray *items=[NSArray arrayWithObjects: NSLocalizedString(@"New Folder",@""), NSLocalizedString(@"OK",@""), nil];
    _editToolBar=[[LEOEditToolBar alloc] initWithItems:items];
    _editToolBar.delegate=self;
    [self.view addSubview:_editToolBar];
    
    [self setupClient];
    [self loadCurrentPath];
}

-(void)dealloc
{
    [self beforeBack];
    [leftButton release];
    [_currentPath release];
    [_editToolBar release];
    [_contentListView release];
    [_contentArray release];
    [super dealloc];
}

#pragma mark - Public methods
-(void)loadCurrentPath
{
    [self setupProgressHD:NSLocalizedString(@"Loading...",@"") isDone:NO];
    [self sendLoadRequest];
//    [self performSelectorInBackground:@selector(sendLoadRequest) withObject:nil];
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

-(void)sendLoadRequest
{
    LEOWebDAVPropertyRequest *request=[[LEOWebDAVPropertyRequest alloc] initWithPath:_currentPath];
    request.delegate=self;
    [_currentClient enqueueRequest:request];
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

#pragma mark - Private methods
// 显示Request Error
-(void)showRequestError:(NSString *)error
{
    [self setupProgressHDFailure:error];
}

-(void)beforeBack
{
    if (_hub) {
        [_hub hide:NO];
        _hub.delegate=nil;
    }
    if (_currentClient!=nil) {
        [_currentClient cancelRequest];
        [_currentClient release];
        _currentClient=nil;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [NSOperation cancelPreviousPerformRequestsWithTarget:self];
}

-(void) backToPrevious:(UIButton *)button {
    if ([_currentPath isEqualToString:@"/"]) {
        // do nothing
    }else {
        [self beforeBack];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)cancelChoose
{
    [self beforeBack];
    if ([self.parent respondsToSelector:@selector(beforeFinishChooseMovePath)]) {
        [self.parent beforeFinishChooseMovePath];
    }
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void)gotoNextSection:(LEOWebDAVItem *)item
{
    LEOChoosePathViewController *subSectionVC=[[LEOChoosePathViewController alloc] initWithItem:item];
    subSectionVC.parent=self.parent;
    [self.navigationController pushViewController:subSectionVC animated:YES];
    [subSectionVC release];
}

-(void)createNewFolder
{
    LEONewFolderViewController *newFolder=[[LEONewFolderViewController alloc] initWithCurrentPath:_currentPath];
    newFolder.parentInstance=self;
    UINavigationController *navNewFolder=[[UINavigationController alloc] initWithRootViewController:newFolder];
//    [self presentModalViewController:navNewFolder animated:YES];
    [self presentViewController:navNewFolder animated:YES completion:nil];
    [navNewFolder release];
    [newFolder release];
}

-(void)setContentArray:(NSMutableArray *)contents
{
    if (_hub) {
        [_hub hide:NO];
    }
    
    if (_contentArray!=nil) {
        [_contentArray release];
        _contentArray=nil;
    }
    _contentArray=[[NSMutableArray alloc] init];
    for (LEOWebDAVItem *item in contents) {
        if (item.type==LEOWebDAVItemTypeCollection) {
            [_contentArray addObject:item];
        }
    }
    
    if (_contentListView!=nil) {
        [_contentListView reloadData];
    }
}

#pragma mark - LEOEditToolBar delegate
-(void)didSelectedEditToolBarIndex:(NSInteger)index
{
    switch (index) {
        case -1:
        case 1:
            // 新建文件夹
            [self createNewFolder];
            break;
        case -2:
        case 2:
        default:
            // 确定
            if ([self.parent respondsToSelector:@selector(setUploadPath:)]) {
                [self.parent setUploadPath:_currentPath];
            }
            [self cancelChoose];
            break;
    }
}

#pragma mark - LEOWebDAV delegate
- (void)request:(LEOWebDAVRequest *)aRequest didFailWithError:(NSError *)error
{
    NSLog(@"error:%@",[error description]);
    if ([aRequest isKindOfClass:[LEOWebDAVPropertyRequest class]]) {
        [self performSelectorOnMainThread:@selector(showRequestError:) withObject:[error description] waitUntilDone:NO];
    }
}

- (void)request:(LEOWebDAVRequest *)aRequest didSucceedWithResult:(id)result
{
    if ([aRequest isKindOfClass:[LEOWebDAVPropertyRequest class]]) {
//        [self setContentArray:result];
        [self performSelectorOnMainThread:@selector(setContentArray:) withObject:result waitUntilDone:NO];
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
    return kContentListCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    LEOContentListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil){
        cell = [[[LEOContentListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    LEOWebDAVItem *item=[_contentArray objectAtIndex:indexPath.row];
    cell.fileNameLabel.text=item.displayName;
    
    if (item.type==LEOWebDAVItemTypeCollection) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailLabel.text=item.modifiedDate;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LEOWebDAVItem *item=[_contentArray objectAtIndex:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self gotoNextSection:item];
}
@end
