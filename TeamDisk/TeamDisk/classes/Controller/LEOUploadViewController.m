//
//  LEOUploadViewController.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-10-25.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOUploadViewController.h"
#import "LEODefines.h"
#import "LEOUploadListCell.h"
#import "LEOAppDelegate.h"
#import "ELCImagePickerController.h"
#import "LEOAlbumPickerController.h"
#import "LEOUploadInfo.h"
#import "LEOWebDAVUploadRequest.h"
#import "LEOWebDAVClient.h"
#import "LEOServerInfo.h"
#import "LEOUtility.h"

//#import "LEOCameraPickerController.h"

@interface LEOUploadViewController ()
{
    UIButton *editButtonView;
    
    LEOUploadView *_uploadView;
    UITableView *_uploadListView;
    LEOEditToolBar *_editToolBar;
    
    NSMutableArray *_uploadList;
    NSString *_uploadCollection;
    
    NSMutableArray *_requests;
    NSMutableArray *_deleteRequests;
    NSMutableArray *_deleteList;
    
    LEOCameraPickerController *camera;
    MBProgressHUD *_hub;
}
@end

@implementation LEOUploadViewController

- (id)init
{
    self=[super init];
    if(self){
        self.title=NSLocalizedString(@"Upload",@"");
        editButtonView=[UIButton buttonWithType:UIButtonTypeCustom];
        editButtonView.frame=CGRectMake(0,kLEONavBarBtnTopY,kDefalutNavItemWidth,kLEONavBarBtnHeight);
        [editButtonView setTitle:NSLocalizedString(@"Edit", @"") forState:UIControlStateNormal];
        [editButtonView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [editButtonView setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
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
    _uploadView = [[LEOUploadView alloc] initWithFrame:CGRectMake(frame.origin.x, 0, frame.size.width, kUploadViewHeight)];
    [_uploadView setBackgroundColor:[UIColor grayColor]];
    _uploadView.delegate=self;
    [self.view addSubview:_uploadView];
    
    _uploadListView = [[UITableView alloc] initWithFrame:CGRectMake(frame.origin.x, 0+kUploadViewHeight, frame.size.width, frame.size.height-kUploadViewHeight-kLEOTabBarHeight-kLEONavBarHeight) style:UITableViewStylePlain];
    [_uploadListView setDataSource:self];
    [_uploadListView setDelegate:self];
    [_uploadListView setBounces:NO];
    _uploadListView.allowsMultipleSelectionDuringEditing=YES;
    _uploadListView.backgroundColor=[UIColor colorWithRed:kBackgroundColorR green:kBackgroundColorG blue:kBackgroundColorB alpha:kBackgroundColorA];
    [self.view addSubview:_uploadListView];
    
    UIView *footer=[[UIView alloc]initWithFrame:CGRectZero];
    [_uploadListView setTableFooterView:footer];
    [footer release];
    
    NSArray *items=[NSArray arrayWithObjects:NSLocalizedString(@"Select All",@""),NSLocalizedString(@"Delete",@""),nil];
    _editToolBar=[[LEOEditToolBar alloc] initWithItems:items];
    _editToolBar.delegate=self;
    [_editToolBar setButtonStatus:NO AtIndex:1];
    [self.view addSubview:_editToolBar];
    
    _uploadList=[[NSMutableArray alloc] init];
    _requests=[[NSMutableArray alloc] init];
    _deleteRequests=[[NSMutableArray alloc] init];
    _deleteList=[[NSMutableArray alloc] init];
}

-(void)dealloc
{
    [self clearUploadController];
    [_uploadListView release];
    [_uploadView release];
    [_uploadList release];
    [_requests release];
    [_deleteRequests release];
    [_deleteList release];
    [super dealloc];
}

-(void)clearUploadController
{
    [_deleteRequests removeAllObjects];
    [_deleteList removeAllObjects];
    [_requests removeAllObjects];
    [_uploadList removeAllObjects];
    [_uploadListView reloadData];
    [self removeClient];
}

#pragma mark - Private method
-(void)editModeOfList {
    [_uploadListView setEditing:!_uploadListView.editing animated:YES];
    LEOAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    LEOTabBarViewController *root=(LEOTabBarViewController *)delegate.window.rootViewController;
    if(_uploadListView.editing){
        [editButtonView setTitle: NSLocalizedString(@"Done", @"") forState:UIControlStateNormal];
        if([root respondsToSelector:@selector(hideTabBar:)]){
            [root hideTabBar:YES];
        }
        if([_editToolBar respondsToSelector:@selector(hideEditTooBar:)]){
            [_editToolBar hideEditTooBar:NO];
        }
    }else{
        [editButtonView setTitle: NSLocalizedString(@"Edit", @"") forState:UIControlStateNormal];
        if([root respondsToSelector:@selector(hideTabBar:)]){
            [root hideTabBar:NO];
        }
        if([_editToolBar respondsToSelector:@selector(hideEditTooBar:)]){
            [_editToolBar hideEditTooBar:YES];
        }
    }
}

-(void)uploadToolBar:(BOOL)isChoose
{
    LEOAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
    LEOTabBarViewController *root=(LEOTabBarViewController *)delegate.window.rootViewController;
    if (isChoose) {
        // 显示上传目录选择视图
//        if ([root respondsToSelector:@selector(hideTabBarWithoutAnm:)]) {
//            [root hideTabBarWithoutAnm:YES];
//        }
        if([root respondsToSelector:@selector(hideTabBarFromBottom:)]){
            [root hideTabBarFromBottom:YES];
        }
    }else {
        // 隐藏目录选择视图
//        if ([root respondsToSelector:@selector(hideTabBarWithoutAnm:)]) {
//            [root hideTabBarWithoutAnm:NO];
//        }
        if([root respondsToSelector:@selector(hideTabBarFromBottom:)]){
            [root hideTabBarFromBottom:NO];
        }
    }
}

-(void)deleteSelected
{
    NSArray *selectedArray=[_uploadListView indexPathsForSelectedRows];
    for (NSIndexPath *index in selectedArray) {
        [_deleteRequests addObject:[_requests objectAtIndex:index.row]];
        [_deleteList addObject:[_uploadList objectAtIndex:index.row]];
    }
    for (LEOWebDAVUploadRequest *request in _deleteRequests) {
        request.delegate=nil;
        if ([request isExecuting]) {
            [request cancel];
        }
    }
    [_requests removeObjectsInArray:_deleteRequests];
    [_uploadList removeObjectsInArray:_deleteList];
    [_uploadListView reloadData];
    if ([_uploadList count]<1) {
        [self editModeOfList];
    }
}
#pragma mark - Request Methods
-(void)setupClient
{
    if (_currentClient!=nil) {
        [self removeClient];
    }
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

-(void)addNewRequestForUpload:(LEOUploadInfo *)one
{
    if (_currentClient==nil) {
        [self setupClient];
    }
    NSString *onePath=[_uploadCollection stringByAppendingPathComponent:one.displayName];
    onePath=[onePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    LEOWebDAVUploadRequest *uploadRequest=[[LEOWebDAVUploadRequest alloc] initWithPath:onePath];
    if ([[one.displayName pathExtension] isEqualToString:@"png"]) {
        uploadRequest.data=UIImagePNGRepresentation(one.originalImage);
    }else {
        uploadRequest.data=UIImageJPEGRepresentation(one.originalImage, 1.0);
    }
    one.contentLength=[uploadRequest.data length];
    [uploadRequest setDelegate:one];
    [_requests addObject:uploadRequest];
    [_currentClient enqueueRequest:uploadRequest];
}

#pragma mark - UploadView delegate
-(void)pictureButton:(id)sender
{
    NSLog(@"upload picture");
    
    LEOAlbumPickerController *albumController = [[LEOAlbumPickerController alloc] init];
    ELCImagePickerController *imagePicker=[[ELCImagePickerController alloc] initWithRootViewController:albumController];
    [albumController setParent:imagePicker];
    [imagePicker setRoot:albumController];
    imagePicker.delegate=self;
//    imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
//    [self presentModalViewController:imagePicker animated:YES];
    [self presentViewController:imagePicker animated:YES completion:nil];
    [imagePicker release];
    [albumController release];
    [self uploadToolBar:YES];
}

-(void)cameraButton:(id)sender
{
    UIImagePickerControllerSourceType sourceType=UIImagePickerControllerSourceTypeCamera;
    if (![UIImagePickerController isSourceTypeAvailable:sourceType]) {
        return;
    }
    LEOCameraPickerController *cameraPicker=[[LEOCameraPickerController alloc] init];
    cameraPicker.delegate=self;
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:cameraPicker];
    [self presentViewController:nav animated:NO completion:nil];
    [nav release];
    [cameraPicker release];

//    UIImagePickerController *cameraPicker=[[UIImagePickerController alloc] init];
//    cameraPicker.delegate=self;
//    cameraPicker.sourceType=sourceType;
//    
//    [self presentModalViewController:cameraPicker animated:YES];
//    [cameraPicker release];
    [self uploadToolBar:YES];
}

#pragma mark - LEOCameraPicker delegate
-(void)leoCameraPickerController:(LEOCameraPickerController *)picker didFinishPickingPictureWithInfo:(NSDictionary *)info andPath:(NSString *)path
{
    
    [self uploadToolBar:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
    if (_uploadCollection) {
        [_uploadCollection release];
        _uploadCollection=nil;
    }
    _uploadCollection=[[NSString alloc] initWithFormat:@"%@",picker.uploadPath];
    NSLog(@"path:%@",_uploadCollection);
    
    LEOUploadInfo *one=[[LEOUploadInfo alloc] initWithCameraInfo:info];
    [_uploadList addObject:one];
    [self addNewRequestForUpload:one];
    [one release];
    [_uploadListView reloadData];
}

-(void)leoCameraPickerControllerDidCancel:(LEOCameraPickerController *)picker
{
    [self uploadToolBar:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//#pragma mark - UIImagePickerControllerDelegate
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//{
//    [picker dismissModalViewControllerAnimated:NO];
//    [camera setPreviewImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
//    [self presentModalViewController:camera animated:YES];
//    [camera release];
//}
//
//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
//{
//    [self uploadToolBar:NO];
//    [picker dismissModalViewControllerAnimated:YES];
//}

#pragma mark - ELCImagePickerControllerDelegate
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self uploadToolBar:NO];
    [self dismissModalViewControllerAnimated:YES];
    if (_uploadCollection) {
        [_uploadCollection release];
        _uploadCollection=nil;
    }
    _uploadCollection=[[NSString alloc] initWithFormat:@"%@",picker.uploadPath];
    NSLog(@"total:%d; path:%@",[info count],_uploadCollection);
    
    for (NSDictionary *dic in info) {
        LEOUploadInfo *one=[[LEOUploadInfo alloc] initWithDictionary:dic];
        [_uploadList addObject:one];
        [self addNewRequestForUpload:one];
        [one release];
    }
    [_uploadListView reloadData];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self uploadToolBar:NO];
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count=[_uploadList count];
    if (count>0) {
//        [_editToolBar setButtonStatus:NO AtIndex:2];
        editButtonView.enabled=YES;
    }else {
//        [_editToolBar setButtonStatus:NO AtIndex:2];
        editButtonView.enabled=NO;
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UploadListCell";
    LEOUploadListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil){
        cell = [[[LEOUploadListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    // Configure the cell...
    LEOUploadInfo *info=[_uploadList objectAtIndex:indexPath.row];
    cell.fileNameLabel.text=info.displayName;
    cell.iconImageView.image=info.thumbnail;
    cell.detailLabel.text=info.date;
    [cell setStatus:info.status];
    info.delegate=cell;
    cell.info=info;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kContentListCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing) {
        [_editToolBar setButtonStatus:YES AtIndex:1];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing) {
        if ([[tableView indexPathsForSelectedRows] count]<1) {
            [_editToolBar setButtonStatus:NO AtIndex:1];
        }else{
        }
    }
}
#pragma mark - LEOEditToolBar delegate
-(void)didSelectedEditToolBarIndex:(NSInteger)index
{
    NSInteger count=[_uploadListView numberOfRowsInSection:0];
    if (index==-1) {
        // 全选
        for (NSInteger i=0; i<count; i++) {
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:i inSection:0];
            [_uploadListView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
        [_editToolBar setButtonStatus:YES AtIndex:1];
    } else if (index==1) {
        //全不选
        for (NSInteger i=0; i<count; i++) {
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:i inSection:0];
            [_uploadListView deselectRowAtIndexPath:indexPath animated:YES];
        }
        [_editToolBar setButtonStatus:NO AtIndex:1];
    }else if (index==2 || index==-2) {
        //删除
        [self deleteSelected];
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
@end
