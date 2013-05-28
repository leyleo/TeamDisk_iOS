//
//  LEODetailViewController.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-10-29.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEOEditToolBar.h"
#import "LEOWebDAVRequest.h"
#import "LEODefines.h"
#import "LEOWebDAVClient.h"

@class LEOWebDAVItem;
@class LEODoubleModeViewController;
@class LEOResultView;

@interface LEODetailViewController : UIViewController<LEOEditToolBarDelegate,
LEOWebDAVRequestDelegate,UIDocumentInteractionControllerDelegate,UIActionSheetDelegate>
{
    UIView *_displayView;
    LEOResultView *resultView;
    LEOWebDAVItem *_item;
    LEOEditToolBar *_editToolBar;
    
    LEOWebDAVClient *_currentClient;
}
@property (assign) LEODoubleModeViewController *parentInstance;
-(id)initWithItem:(LEOWebDAVItem *)item;
-(void)downloadItem;

-(void)detailTodo;
-(void)prepareDetail;
-(void)prepareAction;
-(void)openFileIn;
-(void)showDeleteSheet:(LEOContentSheetTag)tag;
-(void)addNewRequestForDelete;
-(void)backToList;
-(void)changeToolBar:(BOOL)isDetail;
@end
