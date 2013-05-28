//
//  LEOAssetTablePicker.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-12-18.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface LEOAssetTablePicker : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    ALAssetsGroup *assetGroup;
	
	NSMutableArray *elcAssets;
	int selectedAssets;
	
	id parent;
	
	NSOperationQueue *queue;
    
    UITableView *_tableView;
}

@property (nonatomic, assign) id parent;
@property (nonatomic, assign) ALAssetsGroup *assetGroup;
@property (nonatomic, retain) NSMutableArray *elcAssets;
@property (nonatomic, retain) IBOutlet UILabel *selectedAssetsLabel;

-(int)totalSelectedAssets;
-(void)preparePhotos;
-(NSArray *)selectedAssets;
-(void)doneAction:(id)sender;
@end
