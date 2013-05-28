//
//  LEONewFolderViewController.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-8.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEONewFolderViewController.h"
#import "LEODefines.h"
#import "LEOAppDelegate.h"
#import "LEOWebDAVMakeCollectionRequest.h"
#import "LEOWebDAVClient.h"
#import "LEOServerInfo.h"

@interface LEONewFolderViewController ()
{
    UITextField *_newNameTextField;
    NSString *_currentPath;
    
    MBProgressHUD *_hub;
}
@end

@implementation LEONewFolderViewController
@synthesize parentInstance;

- (id)initWithCurrentPath:(NSString *)path
{
    self = [super init];
    if(self){
        self.title=NSLocalizedString(@"New Folder",@"");
        _currentPath=[path copy];
        UIButton *backButtonView=[UIButton buttonWithType:UIButtonTypeCustom];
        backButtonView.frame=CGRectMake(0,kLEONavBarBtnTopY,kDefalutNavItemWidth,kLEONavBarBtnHeight);
        [backButtonView.titleLabel setFont:[UIFont systemFontOfSize:kLEONavBarFontSz]];
        backButtonView.contentEdgeInsets=UIEdgeInsetsMake(0, kLEONavBarBackLeft, 0, 0);
        [backButtonView setTitle:NSLocalizedString(@"Back", @"") forState:UIControlStateNormal];
        [backButtonView setBackgroundImage:[UIImage imageNamed:kNavigationBackBg] forState:UIControlStateNormal];
        [backButtonView setBackgroundImage:[UIImage imageNamed:kNavigationBackBgHighlight] forState:UIControlStateHighlighted];
        [backButtonView addTarget:self action:@selector(cancelChoose) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftButton=[[[UIBarButtonItem alloc] initWithCustomView:backButtonView] autorelease];
        self.navigationItem.leftBarButtonItem=leftButton;
        
        UIButton *doneButtonView=[UIButton buttonWithType:UIButtonTypeCustom];
        doneButtonView.frame=CGRectMake(0,kLEONavBarBtnTopY,kDefalutNavItemWidth,kLEONavBarBtnHeight);
        [doneButtonView setTitle:NSLocalizedString(@"Done", @"") forState:UIControlStateNormal];
        [doneButtonView setBackgroundImage:[UIImage imageNamed:kNavigationEditBg] forState:UIControlStateNormal];
        [doneButtonView setBackgroundImage:[UIImage imageNamed:kNavigationEditBgHighlight] forState:UIControlStateHighlighted];
        [doneButtonView.titleLabel setFont:[UIFont systemFontOfSize:kLEONavBarFontSz]];
        [doneButtonView addTarget:self action:@selector(doneChoose) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *doneButton=[[[UIBarButtonItem alloc] initWithCustomView:doneButtonView] autorelease];
        self.navigationItem.rightBarButtonItem=doneButton;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UIImage *stretchImage=[UIImage imageNamed:kNavigationBg];
    stretchImage=[stretchImage stretchableImageWithLeftCapWidth:1 topCapHeight:0];
	[self.navigationController.navigationBar setBackgroundImage:stretchImage forBarMetrics:UIBarMetricsDefault];
    
    self.view.backgroundColor=[UIColor colorWithRed:kBackgroundColorR green:kBackgroundColorG blue:kBackgroundColorB alpha:kBackgroundColorA];
    CGRect frame=self.view.frame;
    frame.size.height=kUploadNewFolderTFHeight;
    frame.origin.y=kUploadNewFolderTFHeight/2.0;
    frame.origin.x=(frame.size.width-kUploadNewFolderTFWidth)/2.0;
    frame.size.width=kUploadNewFolderTFWidth;
    _newNameTextField=[[UITextField alloc] initWithFrame:frame];
    [_newNameTextField setDelegate:self];
    _newNameTextField.borderStyle=UITextBorderStyleRoundedRect;
    _newNameTextField.textAlignment=UITextAlignmentLeft;
    _newNameTextField.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    _newNameTextField.font=[UIFont systemFontOfSize:kUploadNewFolderFontSz];
    _newNameTextField.placeholder=NSLocalizedString(@"Please Input New Folder Name",@"");
    _newNameTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
    _newNameTextField.returnKeyType=UIReturnKeyDone;
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [self.view addSubview:_newNameTextField];
    
    [_newNameTextField becomeFirstResponder];
}

-(void)viewDidUnload
{
    [_newNameTextField resignFirstResponder];
    [_newNameTextField removeFromSuperview];
    [_newNameTextField release];
}

-(void)dealloc
{
    [_currentPath release];
    [super dealloc];
}
#pragma mark - Private methods
-(void) doneChoose
{    
    // 需要检查合法性
    if ([self checkName:_newNameTextField.text]) {
        NSString *newFolder=[_currentPath stringByAppendingPathComponent:_newNameTextField.text];
        [self addMakeCollectionRequest:newFolder];
        [self setupProgressHD:NSLocalizedString(@"Creating New Folder", @"") isDone:NO];
    }else {
        // 不合法
        [self setupProgressHDFail:NSLocalizedString(@"Illegally Name", @"")];
    }
    
}

-(void)setupProgressHD:(NSString *)text isDone:(BOOL)done
{
    if (_hub) {
        [_hub hide:NO];
        [_hub release];
        _hub=nil;
    }
    CGRect frame=self.view.frame;
    frame.size.height/=2.0;
    _hub=[[MBProgressHUD alloc] initWithFrame:frame];
    
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

-(void)setupProgressHDFail:(NSString *)text
{
    if (_hub) {
        [_hub hide:NO];
        [_hub release];
        _hub=nil;
    }
    CGRect frame=self.view.frame;
    frame.size.height/=2.0;
    _hub=[[MBProgressHUD alloc] initWithFrame:frame];
    
    [self.view addSubview:_hub];
    _hub.delegate=self;
    _hub.labelText=text;
    _hub.mode=MBProgressHUDModeCustomView;
    _hub.removeFromSuperViewOnHide=YES;
    [_hub show:NO];
    [_hub hide:NO afterDelay:1.5];
}

-(BOOL)checkName:(NSString *)oldName
{
    NSString *regex=@"^[^\\/\\<>\\*\?\\:\"\\|.#]{1,16}";
    NSPredicate *nameTest=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    BOOL result= [nameTest evaluateWithObject:oldName];
    return result;
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

-(void)cancelChoose
{
    [self beforeBack];
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self doneChoose];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text=textField.text;
    if (range.length==1 && text.length==1 && [string isEqualToString:@""]) {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    }else{
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    return YES;
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

-(void)addMakeCollectionRequest:(NSString *)newName
{
    if (_currentClient==nil) {
        [self setupClient];
    }
    LEOWebDAVMakeCollectionRequest *makeCollectionReq=[[LEOWebDAVMakeCollectionRequest alloc] initWithPath:newName];
    [makeCollectionReq setDelegate:self];
    [_currentClient enqueueRequest:makeCollectionReq];
}

#pragma mark - LEOWebDAV delegate
- (void)request:(LEOWebDAVRequest *)aRequest didFailWithError:(NSError *)error
{
    NSLog(@"error:%@",[error description]);
    [self setupProgressHDFail:NSLocalizedString(@"Create Failed", @"")];
}

- (void)request:(LEOWebDAVRequest *)aRequest didSucceedWithResult:(id)result
{
//    NSString *string=[[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
//    NSLog(@"make folder sucess:%@",string);
    [self setupProgressHD:NSLocalizedString(@"Create Success", @"") isDone:YES];
    if (self.parentInstance && [self.parentInstance respondsToSelector:@selector(loadCurrentPath)]) {
        [self.parentInstance performSelector:@selector(loadCurrentPath) withObject:nil];
    }
//    [self cancelChoose];
    [self performSelector:@selector(cancelChoose) withObject:nil afterDelay:1.5];
}
@end
