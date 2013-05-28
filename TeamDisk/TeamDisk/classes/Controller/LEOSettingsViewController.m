//
//  LEOSettingsViewController.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-10-23.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOSettingsViewController.h"
#import "LEODefines.h"
#import "LEOUtility.h"


@interface LEOSettingsViewController ()
{
    UITableView *_settingsListView;
    MBProgressHUD *_hub;
}
@end

@implementation LEOSettingsViewController

- (id)init
{
    if (self) {
        self.title=NSLocalizedString(@"Settings",@"");
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
    _settingsListView = [[UITableView alloc] initWithFrame:frame
                                                   style:UITableViewStyleGrouped];
    _settingsListView.delegate=self;
    _settingsListView.dataSource=self;
    _settingsListView.bounces=NO;
    _settingsListView.allowsSelectionDuringEditing=YES;
    _settingsListView.backgroundColor=[UIColor colorWithRed:kBackgroundColorR green:kBackgroundColorG blue:kBackgroundColorB alpha:kBackgroundColorA];
    [self.view addSubview:_settingsListView];
    UIView *footer=[[UIView alloc]initWithFrame:CGRectZero];
    [_settingsListView setTableFooterView:footer];
    [footer release];
}

-(void)viewWillAppear:(BOOL)animated
{
    [_settingsListView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==1) {
        return 1;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell==nil){
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
    }
    if (indexPath.section==0) {
        cell.textLabel.text=[NSString stringWithFormat: @"%@: %@",NSLocalizedString(@"Clear Caches",@""),[LEOUtility formattedFileSize:[LEOUtility cacheFolderSize]]];
        cell.selectionStyle=UITableViewCellSelectionStyleGray;
    } else if (indexPath.section==1) {
        cell.textLabel.text=[NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"Version",@""),[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey]];;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.highlighted=NO;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return nil;
    } else if (section==1) {
        return NSLocalizedString(@"About",@"");
    } else
        return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==0 && indexPath.row==0) {
        [self clearCache];
    }
}

#pragma mark - Alert Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==0x401) {
        if (buttonIndex==1) {
            // 确定
            [self setupProgressHD:NSLocalizedString(@"Clearing...",@"") isDone:NO];
//            BOOL isSuccess=[LEOUtility clearCacheWithName:@"open"];
            BOOL isSuccess=[LEOUtility clearCache];
//            isSuccess = isSuccess && [LEOUtility clearCacheWithName:@"download"];
//            isSuccess = isSuccess && [LEOUtility clearCacheWithName:@"com.saemobile.ConnectDisk"];
            if (isSuccess) {
                [self setupProgressHD:NSLocalizedString(@"Clear Success",@"") isDone:YES];
            }else {
                [self setupProgressHD:NSLocalizedString(@"Clear Fail",@"") isDone:YES];
            }
            [_settingsListView reloadData];
            NSLog(@"clear :%@",isSuccess?@"成功":@"失败");
        } else if (buttonIndex==0) {
            // 取消
        }
    }
    
}

#pragma mark - Private
-(void)clearCache
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil
                                                  message:NSLocalizedString(@"Are you really want to clear?",@"")
                                                 delegate:self
                                        cancelButtonTitle:NSLocalizedString(@"Cancel",@"")
                                        otherButtonTitles:NSLocalizedString(@"Clear",@""),nil];
    alert.delegate=self;
    alert.tag=0x401;
    [alert show];
    [alert release];
}

-(void)setupProgressHD:(NSString *)text isDone:(BOOL)done
{
    if (_hub) {
        [_hub hide:YES];
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
    [_hub show:YES];
    if (done) {
        [_hub hide:YES afterDelay:2];
    }
}
@end
