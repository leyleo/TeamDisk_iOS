//
//  LEOCameraUploadViewController.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-12-6.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOCameraPickerController.h"
#import "LEODefines.h"
#import "LEOChoosePathViewController.h"

@interface LEOCameraPickerController ()
{
    LEOUploadToolBar *_uploadToolBar;
    NSString *_uploadPath;
    UIImageView *_previewImageView;
    NSDictionary *_info;
    UIImageView *_navImage;
    
    BOOL isLoad;
    MBProgressHUD *_hub;
}
@end

@implementation LEOCameraPickerController
@synthesize delegate;
@synthesize uploadPath=_uploadPath;
//-(id)init
//{
//    self=[super init];
//    if (self) {
//        
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *stretchImage=[UIImage imageNamed:kNavigationBg];
    stretchImage=[stretchImage stretchableImageWithLeftCapWidth:1 topCapHeight:0];
	[self.navigationController.navigationBar setBackgroundImage:stretchImage forBarMetrics:UIBarMetricsDefault];
    
    self.view.backgroundColor=[UIColor colorWithRed:kBackgroundColorR green:kBackgroundColorG blue:kBackgroundColorB alpha:kBackgroundColorA];
    
    CGRect rect=self.view.frame;
//    UIImage *stretchImage=[UIImage imageNamed:kNavigationBg];
//    stretchImage=[stretchImage stretchableImageWithLeftCapWidth:1 topCapHeight:0];
//    rect.size.height=kLEONavBarHeight;
//    rect.origin.y=0;
//    _navImage=[[UIImageView alloc] initWithFrame:rect];
//    [_navImage setImage:stretchImage];
//    [self.view addSubview:_navImage];
    
    UIButton *cancelButtonView=[UIButton buttonWithType:UIButtonTypeCustom];
    cancelButtonView.frame=CGRectMake(0,kLEONavBarBtnTopY,kDefalutNavItemWidth,kLEONavBarBtnHeight);
    [cancelButtonView setTitle:NSLocalizedString(@"Cancel", @"") forState:UIControlStateNormal];
    [cancelButtonView setBackgroundImage:[UIImage imageNamed:kNavigationEditBg] forState:UIControlStateNormal];
    [cancelButtonView setBackgroundImage:[UIImage imageNamed:kNavigationEditBgHighlight] forState:UIControlStateHighlighted];
    [cancelButtonView.titleLabel setFont:[UIFont systemFontOfSize:kLEONavBarFontSz]];
    [cancelButtonView addTarget:self action:@selector(cancelChoose) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButton=[[[UIBarButtonItem alloc] initWithCustomView:cancelButtonView] autorelease];
    self.navigationItem.rightBarButtonItem=rightButton;
//    [self.view addSubview:cancelButtonView];
    
    rect.size.height-=kLEOTabBarHeight+kLEONavBarHeight;
    rect.origin.y=0;
    _previewImageView=[[UIImageView alloc] initWithFrame:rect];
    _previewImageView.contentMode=UIViewContentModeScaleAspectFit;
    [self.view addSubview:_previewImageView];
    
    _uploadToolBar=[[LEOUploadToolBar alloc] init];
    _uploadToolBar.delegate=self;
    rect=_uploadToolBar.frame;
    rect.origin.y-=kLEONavBarHeight+kLEOStatusBarHeight;
    _uploadToolBar.frame=rect;
    [self.view addSubview:_uploadToolBar];
    [self setUploadPath:@"/"];
    
    isLoad=NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    if (isLoad==NO) {
        // 载入
        [self showCameraPreview];
        isLoad=YES;
    }else{
        // do nothing
    }
}

-(void)dealloc
{
    [_uploadToolBar release];
    if (_uploadPath!=nil) {
        [_uploadPath release];
        _uploadPath=nil;
    }
    [super dealloc];
}

-(void)setPreviewImage:(UIImage *)image
{
    [_previewImageView setImage:image];
}

#pragma mark - Private
-(void)cancelChoose
{
    if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(leoCameraPickerControllerDidCancel:)]) {
        [self.delegate leoCameraPickerControllerDidCancel:self];
    }
}

-(void)showCameraPreview
{
    UIImagePickerController *picker=[[UIImagePickerController alloc] init];
    picker.delegate=self;
    picker.navigationBarHidden=YES;
    picker.wantsFullScreenLayout=NO;
    picker.sourceType=UIImagePickerControllerSourceTypeCamera;
    [self presentModalViewController:picker animated:YES];
    [picker release];
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

#pragma mark - UploadToolBar delegate
-(void)chooseButton:(id)sender
{
    LEOChoosePathViewController *chooseVC=[[LEOChoosePathViewController alloc] initWithPath:nil];
    chooseVC.parent=self;
    UINavigationController *navChooseVC=[[UINavigationController alloc] initWithRootViewController:chooseVC];
    [self presentViewController:navChooseVC animated:YES completion:nil];
    [chooseVC release];
    [navChooseVC release];
}

-(void)uploadButton:(id)sender
{
//    [self setupProgressHD:NSLocalizedString(@"Progressing...", @"") isDone:NO];
    if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(leoCameraPickerController:didFinishPickingPictureWithInfo:andPath:)]) {
//        [self.delegate performSelector:@selector(leoCameraPickerController:didFinishPickingPictureWithInfo:andPath:) withObject:_info withObject:_uploadPath];
        [self.delegate leoCameraPickerController:self didFinishPickingPictureWithInfo:_info andPath:_uploadPath];
    }
//    if(_hub!=nil) {
//        [_hub hide:NO];
//        [_hub release];
//        _hub=nil;
//    }
}

-(void)setUploadPath:(NSString *)path
{
    if (_uploadPath) {
        [_uploadPath release];
        _uploadPath=nil;
    }
    _uploadPath=[[NSString alloc] initWithFormat:@"%@",path];
    [_uploadToolBar setDisplayPath:_uploadPath];
    NSLog(@"_uploadPath:%@",_uploadPath);
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissModalViewControllerAnimated:NO];
    _info=[info copy];
    _previewImageView.image=[info objectForKey:UIImagePickerControllerOriginalImage];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:NO];
    if (self.delegate!=nil && [self.delegate respondsToSelector:@selector(leoCameraPickerControllerDidCancel:)]) {
        [self.delegate leoCameraPickerControllerDidCancel:self];
    }
}
@end
