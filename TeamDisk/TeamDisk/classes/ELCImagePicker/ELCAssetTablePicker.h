//
//  AssetTablePicker.h
//
//  Created by Matt Tuzzolo on 2/15/11.
//  Copyright 2011 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface ELCAssetTablePicker : UITableViewController
//@interface ELCAssetTablePicker : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
	ALAssetsGroup *assetGroup;
	
	NSMutableArray *elcAssets;
	int selectedAssets;
	
	id parent;
	
	NSOperationQueue *queue;
}

@property (nonatomic, assign) id parent;
@property (nonatomic, assign) ALAssetsGroup *assetGroup;
@property (nonatomic, retain) NSMutableArray *elcAssets;
@property (nonatomic, retain) IBOutlet UILabel *selectedAssetsLabel;
//@property (nonatomic, retain) UITableView *tableView;
-(int)totalSelectedAssets;
-(void)preparePhotos;
-(NSArray *)selectedAssets;
-(void)doneAction:(id)sender;

@end