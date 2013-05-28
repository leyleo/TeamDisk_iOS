//
//  LEOChooseCopyPathViewController.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-12-20.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOChooseCopyPathViewController.h"
#import "LEODoubleModeViewController.h"
#import "LEOAppDelegate.h"
#import "LEODefines.h"
#import "LEOWebDAVItem.h"
#import "LEOWebDAVPropertyRequest.h"
#import "LEOWebDAVClient.h"
#import "LEOServerInfo.h"
#import "LEOContentListCell.h"
#import "LEOServerListCell.h"
#import "LEONewFolderViewController.h"
#import "LEOUtility.h"
#import "SFHFKeychainUtils.h"

@interface LEOChooseCopyPathViewController ()
{
    UITableView *_contentListView;
    LEOEditToolBar *_editToolBar;
    UIBarButtonItem *leftButton;
    
    NSMutableArray *_contentArray;
    NSString *_currentPath;
    LEOWebDAVItem *_currentItem;
    LEOServerInfo *_info;
    
    MBProgressHUD *_hub;
    BOOL _isServer;
}
@end

@implementation LEOChooseCopyPathViewController
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
        
        _isServer=NO;
    }
    return self;
}

//-(id)initWithPath:(NSString *)path
//{
//    self=[self init];
//    if (self) {
//        _currentPath=[path==nil ? @"/":path copy];
//        _currentItem=nil;
//        if (![_currentPath isEqualToString:@"/"]) {
//            self.title=[_currentPath lastPathComponent];
//            self.navigationItem.leftBarButtonItem=leftButton;
//        }else {
//            self.navigationItem.leftBarButtonItem=leftButton;
//        }
//    }
//    return self;
//}
-(id)initWithPath:(NSString *)path
{
    self=[self init];
    if (self) {
        _currentPath=[path==nil ? @"/":path copy];
        _currentItem=nil;
        if (![_currentPath isEqualToString:@"/"]) {
            self.title=[_currentPath lastPathComponent];
            self.navigationItem.leftBarButtonItem=leftButton;
        }else {
            self.navigationItem.leftBarButtonItem=leftButton;
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

-(id)initWithServer
{
    self=[self init];
    if (self) {
        self.title=NSLocalizedString(@"Server List",@"");
        _isServer=YES;
        
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
    
    if (_info==nil) {
        [self setupClient:nil];
    }
    if (_isServer) {
        [self initListFromLocal];
        [_editToolBar setButtonStatus:NO AtIndex:0];
        [_editToolBar setButtonStatus:NO AtIndex:1];
    }else {
        [self loadCurrentPath];
    }
    
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
-(void)setupClient:(LEOServerInfo *)info
{
    if (info==nil) {
        LEOAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
        _info=[[LEOServerInfo alloc] initWithInfo:delegate.currentServer];
    } else {
        _info=[[LEOServerInfo alloc] initWithInfo:info];
    }
    _currentClient=[[LEOWebDAVClient alloc] initWithRootURL:[NSURL URLWithString:_info.url]
                                                andUserName:_info.userName
                                                andPassword:_info.password];
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
// 从本地plist取列表信息
-(void) initListFromLocal {
    NSString *serverListPath=[[LEOUtility documentPath] stringByAppendingFormat:@"%@",kServerListPlistFileName];
    NSMutableArray *serverList=[NSMutableArray arrayWithContentsOfFile:serverListPath];
    if (!_contentArray) {
        _contentArray=[[NSMutableArray alloc]init];
    }
    [_contentArray removeAllObjects];
    
    for (NSMutableDictionary *d in serverList) {
        [d setObject:[SFHFKeychainUtils getPasswordForUsername:[d valueForKey:@"userName"] andServiceName:[d valueForKey:@"url"] error:nil] forKey:@"password"];
        
        LEOServerInfo *add=[[LEOServerInfo alloc] initWithDictionary:d];
        [_contentArray addObject:add];
        [add release];
    }
}

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
    [self beforeBack];
    if ([_currentPath isEqualToString:@"/"]) {
//        NSString *previous=[_currentPath substringToIndex:_currentPath.length-_currentPath.lastPathComponent.length-1];
        LEOChooseCopyPathViewController *serverList=[[LEOChooseCopyPathViewController alloc] initWithServer];
        serverList.parent=self.parent;
        NSMutableArray *result=[NSMutableArray arrayWithArray:self.navigationController.viewControllers];
        [result insertObject:serverList atIndex:[result count]-1];
        [self.navigationController setViewControllers:result animated:NO];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)cancelChoose
{
    [self beforeBack];
    if ([self.parent respondsToSelector:@selector(beforeFinishChooseCopyPath)]) {
        [self.parent beforeFinishChooseCopyPath];
    }
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void)gotoNextSection:(LEOWebDAVItem *)item
{
    LEOChooseCopyPathViewController *subSectionVC=[[LEOChooseCopyPathViewController alloc] initWithItem:item];
    [subSectionVC setupClient:_info];
    subSectionVC.parent=self.parent;
    [self.navigationController pushViewController:subSectionVC animated:YES];
    [subSectionVC release];
}

-(void)gotoNewSection:(LEOServerInfo *)info
{
    LEOChooseCopyPathViewController *subSectionVC=[[LEOChooseCopyPathViewController alloc] initWithPath:nil];
    [subSectionVC setupClient:info];
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
            if ([self.parent respondsToSelector:@selector(setCopyPath:withServer:)]) {
                [self.parent setCopyPath:_currentPath withServer:_info];
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
    CGFloat result;
    if (_isServer) {
        result=kServerListCellHeight;
    } else {
        result=kContentListCellHeight;
    }
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isServer) {
        // 服务器
        static NSString *serverCellIdentifier = @"ServerListCell";
        LEOServerListCell *cell = [tableView dequeueReusableCellWithIdentifier:serverCellIdentifier];
        if(cell==nil){
            cell = [[[LEOServerListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:serverCellIdentifier] autorelease];
        }
        LEOServerInfo *info=[_contentArray objectAtIndex:indexPath.row];
        if ([info.description isEqualToString:@""]) {
            cell.descriptionLabel.text=NSLocalizedString(@"Default Name", @"");
        }else{
            cell.descriptionLabel.text=info.description;
        }
        cell.userNameLabel.text=info.userName;
        cell.urlLabel.text=info.url;
        [cell showAccessory:YES];
        return cell;
    }else {
        static NSString *contentCellIdentifier = @"ContentListCell";
        LEOContentListCell *cell = [tableView dequeueReusableCellWithIdentifier:contentCellIdentifier];
        if(cell==nil){
            cell = [[[LEOContentListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:contentCellIdentifier] autorelease];
        }
        LEOWebDAVItem *item=[_contentArray objectAtIndex:indexPath.row];
        cell.fileNameLabel.text=item.displayName;
        
        if (item.type==LEOWebDAVItemTypeCollection) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailLabel.text=item.modifiedDate;
        }
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_isServer) {
        [self gotoNewSection:[_contentArray objectAtIndex:indexPath.row]];
    } else {
        LEOWebDAVItem *item=[_contentArray objectAtIndex:indexPath.row];
        [self gotoNextSection:item];
    }
}
@end
