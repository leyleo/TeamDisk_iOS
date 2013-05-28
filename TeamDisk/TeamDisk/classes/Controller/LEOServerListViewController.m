//
//  LEOServerListViewController.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-10-22.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOServerListViewController.h"
#import "LEOContentListViewController.h"
#import "LEOServerListCell.h"
#import "LEODefines.h"
#import "LEOUtility.h"
#import "LEOAppDelegate.h"
#import "LEONewServerViewController.h"
#import "LEOWebDAVPropertyRequest.h"
#import "LEOWebDAVClient.h"
#import "LEODoubleModeViewController.h"

#import "SFHFKeychainUtils.h"

@interface LEOServerListViewController ()
{
    UIButton *editButtonView;
    UITableView *_serverListView;
    NSMutableArray *_serverListArray;
    LEOEditToolBar *_editToolBar;
    
    UILabel *labelFooter;
    UIView *footer;
}
@end

@implementation LEOServerListViewController

#pragma mark - Life Cycle
- (id)init
{
    self = [super init];
    if (self) {
        self.title=NSLocalizedString(@"Server List",@"");
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *stretchImage=[UIImage imageNamed:kNavigationBg];
    stretchImage=[stretchImage stretchableImageWithLeftCapWidth:1 topCapHeight:0];
	[self.navigationController.navigationBar setBackgroundImage:stretchImage forBarMetrics:UIBarMetricsDefault];
    
    CGRect frame=self.view.frame;
    frame.size.height-=kLEOTabBarHeight+kLEONavBarHeight;
    frame.origin.y=0;
//    NSLog(@"serverList:%f,%f,%f,%f",frame.origin.x,frame.origin.y,frame.size.width,frame.size.height);
    _serverListView = [[UITableView alloc] initWithFrame:frame
                                                   style:UITableViewStylePlain];
    _serverListView.delegate=self;
    _serverListView.dataSource=self;
//    _serverListView.bounces=NO;
    _serverListView.allowsSelectionDuringEditing=YES;
    _serverListView.backgroundColor=[UIColor colorWithRed:kBackgroundColorR green:kBackgroundColorG blue:kBackgroundColorB alpha:kBackgroundColorA];
    [self.view addSubview:_serverListView];
    
    footer=[[UIView alloc]initWithFrame:CGRectZero];
    frame.size.height=kServerListCellHeight;
    labelFooter=[[UILabel alloc] initWithFrame:frame];
    labelFooter.textAlignment=UITextAlignmentCenter;
    labelFooter.text=NSLocalizedString(@"Press 'Edit' to Add New Server", @"");
    labelFooter.textColor=[UIColor grayColor];
    labelFooter.backgroundColor=[UIColor clearColor];

    NSArray *items=[NSArray arrayWithObjects:NSLocalizedString(@"Add",@""), nil];
    _editToolBar=[[LEOEditToolBar alloc] initWithItems:items];
    _editToolBar.delegate=self;
    [self.view addSubview:_editToolBar];
    _serverListArray=[[NSMutableArray alloc] init];
    [self initListFromLocal];
    [self refreshView];
}

-(void)dealloc
{
    [super dealloc];
    [_editToolBar removeFromSuperview];
    [_editToolBar release];
    [_serverListView removeFromSuperview];
    [_serverListView release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public method
-(BOOL)updateNewServerInfo:(LEOServerInfo *)info atIndex:(NSInteger)index
{
    if(index<0){
//        if ([SFHFKeychainUtils getPasswordForUsername:info.userName andServiceName:info.url error:nil]) {
//            // already exsit
//            
//            return NO;
//        }
        [_serverListArray addObject:info];
    }else{
//        [_serverListArray setObject:info atIndexedSubscript:index];
    }
    [_serverListView reloadData];
    [self refreshView];
    [self performSelectorInBackground:@selector(saveListToLocal) withObject:nil];
    return YES;
}

#pragma mark - Private method
// 从本地plist取列表信息
-(void) initListFromLocal {
    NSString *serverListPath=[[LEOUtility documentPath] stringByAppendingFormat:@"%@",kServerListPlistFileName];
    NSMutableArray *serverList=[NSMutableArray arrayWithContentsOfFile:serverListPath];
    if (!_serverListArray) {
        _serverListArray=[[NSMutableArray alloc]init];
    }
    [_serverListArray removeAllObjects];
    
//    for(NSDictionary *d in serverList){
    for (NSMutableDictionary *d in serverList) {
        [d setObject:[SFHFKeychainUtils getPasswordForUsername:[d valueForKey:@"userName"] andServiceName:[d valueForKey:@"url"] error:nil] forKey:@"password"];
        
        LEOServerInfo *add=[[LEOServerInfo alloc] initWithDictionary:d];
        [_serverListArray addObject:add];
        [add release];
    }
}

// 将列表信息存储到本地plist
-(void)saveListToLocal {
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
    NSMutableArray *list=[[NSMutableArray alloc] init];
    for(LEOServerInfo *info in _serverListArray){
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] initWithCapacity:4];
        [dic setObject:info.description forKey:@"description"];
        [dic setObject:info.userName forKey:@"userName"];
//        [dic setObject:info.password forKey:@"password"];
        [dic setObject:info.url forKey:@"url"];
        BOOL isSuccess=[SFHFKeychainUtils storeUsername:info.userName andPassword:info.password forServiceName:info.url updateExisting:YES error:nil];
        NSLog(@"store success:%@",isSuccess?@"Yes":@"No");
        [list addObject:dic];
        [dic release];
    }
    NSString *serverListPath=[[LEOUtility documentPath] stringByAppendingFormat:@"%@",kServerListPlistFileName];
    [list writeToFile:serverListPath atomically:YES];
    [list release];
    [pool release];
}

// 切换编辑模式
-(void)editModeOfList {
    [_serverListView setEditing:!_serverListView.editing animated:YES];
    LEOAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    if(_serverListView.editing){
        [editButtonView setTitle: NSLocalizedString(@"Done", @"") forState:UIControlStateNormal];
        labelFooter.text=NSLocalizedString(@"Press 'Add' to Create New Server Info", @"");
        if([delegate.window.rootViewController respondsToSelector:@selector(hideTabBar:)])
        {
            [delegate.window.rootViewController hideTabBar:YES];
        }
        if([_editToolBar respondsToSelector:@selector(hideEditTooBar:)]){
            [_editToolBar hideEditTooBar:NO];
        }
    }else{
        [editButtonView setTitle: NSLocalizedString(@"Edit", @"") forState:UIControlStateNormal];
        labelFooter.text=NSLocalizedString(@"Press 'Edit' to Add New Server", @"");
        if([delegate.window.rootViewController respondsToSelector:@selector(hideTabBar:)])
        {
            [delegate.window.rootViewController hideTabBar:NO];
        }
        if([_editToolBar respondsToSelector:@selector(hideEditTooBar:)]){
            [_editToolBar hideEditTooBar:YES];
        }
    }
    [_serverListView reloadData];
}

-(void)refreshView
{
    if ([_serverListArray count]>0) {
        [_serverListView setTableFooterView:footer];
    }else{
        [_serverListView setTableFooterView:labelFooter];
    }
}

-(void)loginServer:(LEOServerInfo *)server
{
    LEOAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
//    [delegate setupClient:server];
//    [delegate setupNetwork:server];
    [delegate setupCurrentServer:server];
//    [delegate.window setRootViewController:delegate.serverTabBarController];
}

#pragma mark - LEOWebDAV delegate
- (void)request:(LEOWebDAVRequest *)aRequest didFailWithError:(NSError *)error
{
    NSLog(@"error:%@",[error description]);
}

- (void)request:(LEOWebDAVRequest *)aRequest didSucceedWithResult:(id)result
{
    if ([aRequest isKindOfClass:[LEOWebDAVPropertyRequest class]]) {
//        NSLog(@"success:%@",result);
        LEOAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
        [delegate.window setRootViewController:delegate.serverTabBarController];
    }
}

#pragma mark - LEOEditToolBar delegate
// 新建一个server信息
-(void)didSelectedEditToolBarIndex:(NSInteger)index
{
    LEONewServerViewController *newServer=[[LEONewServerViewController alloc] init];
    [newServer setServerListVCInstance:self];
    [self.navigationController pushViewController:newServer animated:YES];
    [newServer release];
}

#pragma mark - Table view data source & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_serverListArray count];
//    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ServerListCell";
    LEOServerListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil){
        cell = [[[LEOServerListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    LEOServerInfo *info=[_serverListArray objectAtIndex:indexPath.row];
    if ([info.description isEqualToString:@""]) {
        cell.descriptionLabel.text=NSLocalizedString(@"Default Name", @"");
    }else{
        cell.descriptionLabel.text=info.description;
    }
    cell.userNameLabel.text=info.userName;
    cell.urlLabel.text=info.url;
    [cell showAccessory:YES];
    cell.userInteractionEnabled=YES;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kServerListCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_serverListView.editing) {
        // 编辑已有的信息
        LEONewServerViewController *newServer=[[LEONewServerViewController alloc] initWithServerInfo:[_serverListArray objectAtIndex:indexPath.row]
                                                                                             atIndex:indexPath.row];
        [newServer setServerListVCInstance:self];
        [self.navigationController pushViewController:newServer animated:YES];
        [newServer release];
    }else{
        [self loginServer:[_serverListArray objectAtIndex:indexPath.row]];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 圆圈
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    LEOServerInfo *info=[_serverListArray objectAtIndex:indexPath.row];
    [SFHFKeychainUtils deleteItemForUsername:info.userName andServiceName:info.url error:nil];
    [_serverListArray removeObjectAtIndex:[indexPath row]];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
    [self performSelectorInBackground:@selector(saveListToLocal) withObject:nil];
    [self performSelector:@selector(refreshView) withObject:nil afterDelay:0.4];
}
@end
