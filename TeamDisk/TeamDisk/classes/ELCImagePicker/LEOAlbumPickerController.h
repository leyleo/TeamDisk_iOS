//
//  LEOAlbumPickerController.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-12-18.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface LEOAlbumPickerController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *assetGroups;
	NSOperationQueue *queue;
	id parent;
    
    ALAssetsLibrary *library;
    
    UITableView *_tableView;
}

@property (nonatomic, assign) id parent;
@property (nonatomic, assign) id child;
@property (nonatomic, retain) NSMutableArray *assetGroups;

-(void)selectedAssets:(NSArray*)_assets;
-(NSArray *)selectedAssets;
-(void)cancelImagePicker;
@end
