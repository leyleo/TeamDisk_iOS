//
//  LEORenameViewController.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-12.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEORenameViewController.h"
#import "LEODefines.h"
#import "LEOAppDelegate.h"
#import "LEOWebDAVItem.h"
#import "LEOWebDAVMoveRequest.h"
#import "LEOWebDAVClient.h"
#import "LEOServerInfo.h"

@interface LEORenameViewController ()
{
    UITextField *_newNameTextField;
    LEOWebDAVItem *_currentItem;
    
    MBProgressHUD *_hub;
}
@end

@implementation LEORenameViewController
@synthesize parentInstance;

- (id)initWithCurrentItem:(LEOWebDAVItem *)item
{
    self = [super init];
    if(self){
        self.title=NSLocalizedString(@"New Name",@"");
        _currentItem=[[LEOWebDAVItem alloc] initWithItem:item];
        UIButton *backButtonView=[UIButton buttonWithType:UIButtonTypeCustom];
        backButtonView.frame=CGRectMake(0,kLEONavBarBtnTopY,kDefalutNavItemWidth,kLEONavBarBtnHeight);
        backButtonView.contentEdgeInsets=UIEdgeInsetsMake(0, kLEONavBarBackLeft, 0, 0);
        [backButtonView.titleLabel setFont:[UIFont systemFontOfSize:kLEONavBarFontSz]];
        [backButtonView setTitle:NSLocalizedString(@"Back", @"") forState:UIControlStateNormal];
        [backButtonView setBackgroundImage:[UIImage imageNamed:kNavigationBackBg] forState:UIControlStateNormal];
        [backButtonView setBackgroundImage:[UIImage imageNamed:kNavigationBackBgHighlight] forState:UIControlStateHighlighted];
        [backButtonView addTarget:self action:@selector(cancelChoose) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftButton=[[[UIBarButtonItem alloc] initWithCustomView:backButtonView] autorelease];
        self.navigationItem.leftBarButtonItem=leftButton;
        
        UIButton *doneButtonView=[UIButton buttonWithType:UIButtonTypeCustom];
        doneButtonView.frame=CGRectMake(0,kLEONavBarBtnTopY,kDefalutNavItemWidth,kLEONavBarBtnHeight);
        [doneButtonView.titleLabel setFont:[UIFont systemFontOfSize:kLEONavBarFontSz]];
        [doneButtonView setTitle:NSLocalizedString(@"Done", @"") forState:UIControlStateNormal];
        [doneButtonView setBackgroundImage:[UIImage imageNamed:kNavigationEditBg] forState:UIControlStateNormal];
        [doneButtonView setBackgroundImage:[UIImage imageNamed:kNavigationEditBgHighlight] forState:UIControlStateHighlighted];
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
    _newNameTextField.placeholder=NSLocalizedString(@"Please Input New Name",@"");
    
    _newNameTextField.text=[self generateDisplayOldName];
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
    if (_hub!=nil) {
        [_hub release];
    }
    
    [_currentItem release];
    [super dealloc];
}

#pragma mark - Private methods
-(NSString *)generateDisplayOldName
{
    NSString *display=_currentItem.displayName;
    if (_currentItem.type==LEOContentItemTypeCollection) {
        if ([display hasSuffix:@"/"]) {
            display=[display substringToIndex:display.length-1];
        }
    }
    else {
        if ([display pathExtension].length>0) {
            display=[display substringToIndex:display.length-1-[display pathExtension].length];
        }
    }
    return display;
}

-(void) doneChoose
{
    // 创建新目录
    NSString *parentHref=_currentItem.href;
	if([parentHref hasSuffix:@"/"]) {
		parentHref = [parentHref substringToIndex:parentHref.length-1];
	}
	parentHref = [parentHref substringToIndex:parentHref.length-[parentHref lastPathComponent].length];
	if([parentHref rangeOfString:@"://"].length > 0) {
		parentHref = [[NSURL URLWithString:parentHref] relativePath];
	}
    
    if (![self checkName:_newNameTextField.text]) {
        [self setupProgressHDFail:NSLocalizedString(@"Illegally Name", @"")];
        return;
    }
    
    NSString *newFolder=[parentHref stringByAppendingPathComponent:[self generateNewPath]];

    [self addMoveRequest:newFolder];
    [self setupProgressHD:NSLocalizedString(@"Renaming...", @"") isDone:NO];
}

-(BOOL)checkName:(NSString *)oldName
{
    NSString *regex=@"^[^\\/\\<>\\*\?\\:\"\\|.#]{1,16}";
    NSPredicate *nameTest=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    BOOL result= [nameTest evaluateWithObject:oldName];
    return result;
}

-(NSString *)generateNewPath
{
    NSString *result=_newNameTextField.text;
    if (_currentItem.type==LEOWebDAVItemTypeCollection) {
        return [result stringByAppendingString:@"/"];
    }
    else{
        return [result stringByAppendingPathExtension:[_currentItem.displayName pathExtension]];
    }
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

#pragma mark - TextField Delegate

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

-(void)addMoveRequest:(NSString *)newName
{
    if (_currentClient==nil) {
        [self setupClient];
    }
    LEOWebDAVMoveRequest *moveRequest=[[LEOWebDAVMoveRequest alloc] initWithPath:_currentItem.href];
    [moveRequest setDestinationPath:newName];
    moveRequest.overwrite=YES;
    [moveRequest setDelegate:self];
    [_currentClient enqueueRequest:moveRequest];
}

#pragma mark - LEOWebDAV delegate
- (void)request:(LEOWebDAVRequest *)aRequest didFailWithError:(NSError *)error
{
    NSLog(@"error:%@",[error description]);
    [self setupProgressHDFail:NSLocalizedString(@"Rename Failed", @"")];
}

- (void)request:(LEOWebDAVRequest *)aRequest didSucceedWithResult:(id)result
{
//    NSString *string=[[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
//    NSLog(@"make folder sucess:%@",string);
    [self setupProgressHD:NSLocalizedString(@"Rename Success", @"") isDone:YES];
    if (self.parentInstance && [self.parentInstance respondsToSelector:@selector(loadCurrentPath)]) {
        [self.parentInstance performSelector:@selector(loadCurrentPath) withObject:nil];
    }
//    [self cancelChoose];
    [self performSelector:@selector(cancelChoose) withObject:nil afterDelay:1.5];
}
@end
