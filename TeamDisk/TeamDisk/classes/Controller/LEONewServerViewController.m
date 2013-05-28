//
//  LEONewServerViewController.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-10-29.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEONewServerViewController.h"
#import "../Utilities/LEODefines.h"
#import "LEOUtility.h"
#import "LEOServerInfo.h"
#import "LEOServerListViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface LEONewServerViewController ()
{
    UILabel *_serverUrl;
    UILabel *_userName;
    UILabel *_password;
    UILabel *_desName;
    UITextField *_serverUrlText;
    UITextField *_userNameText;
    UITextField *_passwordText;
    UITextField *_desNameText;
    LEOServerInfo *_serverInfo;
    
    LEOServerListViewController *instance;
    NSInteger indexInfo;
    MBProgressHUD *_hub;
}
@end

@implementation LEONewServerViewController

-(id)init
{
    self=[super init];
    if(self){
        self.title=NSLocalizedString(@"New Server",@"");
        UIButton *backButtonView=[UIButton buttonWithType:UIButtonTypeCustom];
        backButtonView.frame=CGRectMake(0,kLEONavBarBtnTopY,kDefalutNavItemWidth,kLEONavBarBtnHeight);
        backButtonView.contentEdgeInsets=UIEdgeInsetsMake(0, kLEONavBarBackLeft, 0, 0);
        [backButtonView setTitle:NSLocalizedString(@"Back", @"") forState:UIControlStateNormal];
        [backButtonView setBackgroundImage:[UIImage imageNamed:kNavigationBackBg] forState:UIControlStateNormal];
        [backButtonView setBackgroundImage:[UIImage imageNamed:kNavigationBackBgHighlight] forState:UIControlStateHighlighted];
        [backButtonView.titleLabel setFont:[UIFont systemFontOfSize:kLEONavBarFontSz]];
        [backButtonView addTarget:self action:@selector(returnToServerList) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *leftButton=[[[UIBarButtonItem alloc] initWithCustomView:backButtonView] autorelease];
        self.navigationItem.leftBarButtonItem=leftButton;
        
        UIButton *doneButtonView=[UIButton buttonWithType:UIButtonTypeCustom];
        doneButtonView.frame=CGRectMake(0,kLEONavBarBtnTopY,kDefalutNavItemWidth,kLEONavBarBtnHeight);
        [doneButtonView.titleLabel setFont:[UIFont systemFontOfSize:kLEONavBarFontSz]];
        [doneButtonView setTitle:NSLocalizedString(@"Done", @"") forState:UIControlStateNormal];
        [doneButtonView setBackgroundImage:[UIImage imageNamed:kNavigationEditBg] forState:UIControlStateNormal];
        [doneButtonView setBackgroundImage:[UIImage imageNamed:kNavigationEditBgHighlight] forState:UIControlStateHighlighted];
        [doneButtonView addTarget:self action:@selector(finishEditServer) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *doneButton=[[[UIBarButtonItem alloc] initWithCustomView:doneButtonView] autorelease];
        self.navigationItem.rightBarButtonItem=doneButton;
        
        _serverInfo=nil;
        indexInfo=-1;
    }
    return self;
}

-(id)initWithServerInfo:(LEOServerInfo *)info atIndex:(NSInteger)index
{
    self=[self init];
    if(self){
        self.title=NSLocalizedString(@"Modify Server Info",@"");
        _serverInfo=info;
        indexInfo=index;
        [_serverInfo retain];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor=[UIColor colorWithRed:kBackgroundColorR green:kBackgroundColorG blue:kBackgroundColorB alpha:kBackgroundColorA];;
    
    CGRect frame=self.view.frame;
    frame.size.width-=kNewServerMargin*2;
    frame.origin.x=kNewServerMargin;
    frame.size.height=4*kNewServerCellHeight+5*kNewServerMargin;
    frame.origin.y=kNewServerMargin;
    UIView *background=[[UIView alloc] initWithFrame:frame];
    CALayer *bgLayer=[background layer];
    [bgLayer setMasksToBounds:YES];
    [bgLayer setCornerRadius:5];
    [bgLayer setBorderWidth:1];
    [bgLayer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [self.view addSubview:background];
    [background release];
    
    // 左侧的Label
    _serverUrl = [[UILabel alloc] initWithFrame:CGRectMake(kNewServerMargin, kNewServerMargin*2, kNewServerLabelWidth, kNewServerCellHeight)];
    _serverUrl.backgroundColor=[UIColor clearColor];
    _serverUrl.font=[UIFont systemFontOfSize:kNewServerFontSz];
    _serverUrl.textAlignment=UITextAlignmentRight;
    _serverUrl.text=NSLocalizedString(@"Server URL",@"");
    [self.view addSubview:_serverUrl];
    _userName = [[UILabel alloc] initWithFrame:CGRectMake(kNewServerMargin, kNewServerMargin*3+kNewServerCellHeight, kNewServerLabelWidth, kNewServerCellHeight)];
    _userName.backgroundColor=[UIColor clearColor];
    _userName.font=[UIFont systemFontOfSize:kNewServerFontSz];
    _userName.textAlignment=UITextAlignmentRight;
    _userName.text=NSLocalizedString(@"User Name",@"");
    [self.view addSubview:_userName];
    _password = [[UILabel alloc] initWithFrame:CGRectMake(kNewServerMargin, kNewServerMargin*4+2*kNewServerCellHeight, kNewServerLabelWidth, kNewServerCellHeight)];
    _password.backgroundColor=[UIColor clearColor];
    _password.font=[UIFont systemFontOfSize:kNewServerFontSz];
    _password.textAlignment=UITextAlignmentRight;
    _password.text=NSLocalizedString(@"Password",@"");
    [self.view addSubview:_password];
    _desName = [[UILabel alloc] initWithFrame:CGRectMake(kNewServerMargin, kNewServerMargin*5+3*kNewServerCellHeight, kNewServerLabelWidth, kNewServerCellHeight)];
    _desName.backgroundColor=[UIColor clearColor];
    _desName.font=[UIFont systemFontOfSize:kNewServerFontSz];
    _desName.textAlignment=UITextAlignmentRight;
    _desName.text=NSLocalizedString(@"Description",@"");
    [self.view addSubview:_desName];
    
    // 右侧的TextField
    CGSize size=self.view.frame.size;
    CGFloat textWidth=size.width-kNewServerLabelWidth-5*kNewServerMargin;
    _serverUrlText = [[UITextField alloc] initWithFrame:CGRectMake(kNewServerMargin*2+kNewServerLabelWidth, kNewServerMargin*2, textWidth, kNewServerCellHeight)];
    _serverUrlText.borderStyle=UITextBorderStyleRoundedRect;
    _serverUrlText.textAlignment=UITextAlignmentLeft;
    _serverUrlText.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    _serverUrlText.font=[UIFont systemFontOfSize:kNewServerFontSz];
    _serverUrlText.keyboardType=UIKeyboardTypeURL;
    _serverUrlText.autocapitalizationType=UITextAutocapitalizationTypeNone;
    _serverUrlText.placeholder=NSLocalizedString(@"(Required)Please Input Server URL",@"");
    _serverUrlText.clearButtonMode=UITextFieldViewModeWhileEditing;
    _serverUrlText.returnKeyType=UIReturnKeyNext;
    _serverUrlText.tag=kTagServerURL;
    _serverUrlText.delegate=self;
    [self.view addSubview:_serverUrlText];
    
    _userNameText = [[UITextField alloc] initWithFrame:CGRectMake(kNewServerMargin*2+kNewServerLabelWidth, kNewServerMargin*3+kNewServerCellHeight, textWidth, kNewServerCellHeight)];
    _userNameText.borderStyle=UITextBorderStyleRoundedRect;
    _userNameText.textAlignment=UITextAlignmentLeft;
    _userNameText.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    _userNameText.font=[UIFont systemFontOfSize:kNewServerFontSz];
    _userNameText.keyboardType=UIKeyboardTypeDefault;
    _userNameText.autocapitalizationType=UITextAutocapitalizationTypeNone;
    _userNameText.placeholder=NSLocalizedString(@"(Required)Please Input User Name",@"");
    _userNameText.clearButtonMode=UITextFieldViewModeWhileEditing;
    _userNameText.returnKeyType=UIReturnKeyNext;
    _userNameText.tag=kTagUserName;
    _userNameText.delegate=self;
    [self.view addSubview:_userNameText];
    
    _passwordText = [[UITextField alloc] initWithFrame:CGRectMake(kNewServerMargin*2+kNewServerLabelWidth, kNewServerMargin*4+kNewServerCellHeight*2, textWidth, kNewServerCellHeight)];
    _passwordText.borderStyle=UITextBorderStyleRoundedRect;
    _passwordText.textAlignment=UITextAlignmentLeft;
    _passwordText.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    _passwordText.font=[UIFont systemFontOfSize:kNewServerFontSz];
    _passwordText.keyboardType=UIKeyboardTypeAlphabet;
    _passwordText.autocapitalizationType=UITextAutocapitalizationTypeNone;
    _passwordText.secureTextEntry=YES;
    _passwordText.placeholder=NSLocalizedString(@"Please Input Password",@"");
    _passwordText.clearButtonMode=UITextFieldViewModeWhileEditing;
    _passwordText.returnKeyType=UIReturnKeyNext;
    _passwordText.tag=kTagPassword;
    _passwordText.delegate=self;
    [self.view addSubview:_passwordText];
    
    _desNameText = [[UITextField alloc] initWithFrame:CGRectMake(kNewServerMargin*2+kNewServerLabelWidth, kNewServerMargin*5+kNewServerCellHeight*3, textWidth, kNewServerCellHeight)];
    _desNameText.borderStyle=UITextBorderStyleRoundedRect;
    _desNameText.textAlignment=UITextAlignmentLeft;
    _desNameText.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
    _desNameText.font=[UIFont systemFontOfSize:kNewServerFontSz];
    _desNameText.keyboardType=UIKeyboardTypeDefault;
    _desNameText.placeholder=NSLocalizedString(@"Please Input Description Name",@"");
    _desNameText.clearButtonMode=UITextFieldViewModeWhileEditing;
    _desNameText.returnKeyType=UIReturnKeyDone;
    _desNameText.tag=kTagDescription;
    _desNameText.delegate=self;
    [self.view addSubview:_desNameText];
    
    if(_serverInfo){
        _serverUrlText.text=_serverInfo.url;
        _userNameText.text=_serverInfo.userName;
        _passwordText.text=_serverInfo.password? _serverInfo.password:@"";
        _desNameText.text=_serverInfo.description?_serverInfo.description:@"";
    }else{
        _serverUrlText.text=@"";//kTestURl;
        _userNameText.text=@"";//kTestUserName;
        _passwordText.text=@"";//kTestPassword;
        _desNameText.text=@"";//@"Test";
    }
    [_serverUrlText becomeFirstResponder];
}

-(void)dealloc
{
    [super dealloc];
    [_serverInfo release];
    [_serverUrl release];
    [_userName release];
    [_password release];
    [_desName release];
    [_serverUrlText release];
    [_userNameText release];
    [_passwordText release];
    [_desNameText release];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Public methods
-(void)setServerListVCInstance:(LEOServerListViewController *)one
{
    instance=one;
}

#pragma mark - Private methods
-(void)finishEditServer{
    // 判断必填项是否存在
    NSString *_serverUrlString=_serverUrlText.text;
    if (![LEOUtility isUrl:_serverUrlString])
    {
        [self setupProgressHD:NSLocalizedString(@"Please Input Server URL", @"")];
        return;
    }

    NSString *_userNameString=_userNameText.text;
    if([LEOUtility isEmptyString:_userNameString])
    {
        [self setupProgressHD:NSLocalizedString(@"Please Input User Name", @"")];
        return;
    }
    
    NSString *_passwordString=_passwordText.text;
    NSString *_descriptionString=_desNameText.text;
    
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    [dic setObject:_serverUrlString forKey:@"url"];
    [dic setObject:_userNameString forKey:@"userName"];
    if(_passwordString && ![LEOUtility isEmptyString:_passwordString])
        [dic setObject:_passwordString forKey:@"password"];
    else
        [dic setObject:@"" forKey:@"password"];
    if(_descriptionString && ![LEOUtility isEmptyString:_descriptionString])
        [dic setObject:_descriptionString forKey:@"description"];
    else
        [dic setObject:@"" forKey:@"description"];
    
    // 分类型处理
    if(_serverInfo==nil){
        // 创建htt
        _serverInfo=[[LEOServerInfo alloc] initWithDictionary:dic];
    }else{
        // 修改
        _serverInfo=[_serverInfo modifyData:dic];
    }
    [dic release];
    // 更新数据
    BOOL isSuccess=[instance updateNewServerInfo:_serverInfo atIndex:indexInfo];
    if (isSuccess) {
        [self returnToServerList];
    }else {
        // 已经存在
        [self setupProgressHD:NSLocalizedString(@"Server info already exsit", @"")];
    }
    
}

-(void)returnToServerList{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setupProgressHD:(NSString *)text
{
    if (_hub!=nil) {
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
    _hub.mode=MBProgressHUDModeText;
    _hub.removeFromSuperViewOnHide=YES;
    [_hub show:NO];
    [_hub hide:NO afterDelay:1.5];
}
#pragma mark - TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    switch (textField.tag) {
        case kTagServerURL:
            [_userNameText becomeFirstResponder];
            break;
        case kTagUserName:
            [_passwordText becomeFirstResponder];
            break;
        case kTagPassword:
            [_desNameText becomeFirstResponder];
            break;
        case kTagDescription:
            [_desNameText resignFirstResponder];
            [self finishEditServer];
        default:
            break;
    }
    return YES;
}
@end
