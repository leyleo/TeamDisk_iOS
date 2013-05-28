//
//  LEOAssetTablePicker.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-12-18.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOAssetTablePicker.h"
#import "ELCAssetCell.h"
#import "ELCAsset.h"
#import "LEOAlbumPickerController.h"
#import "LEODefines.h"

@implementation LEOAssetTablePicker
@synthesize parent;
@synthesize selectedAssetsLabel;
@synthesize assetGroup, elcAssets;

-(void)viewDidLoad {
    CGRect frame=self.view.frame;
    frame.size.height-=kLEONavBarHeight+kLEOTabBarHeight;
    frame.origin.y=0;
    _tableView=[[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [self.view addSubview:_tableView];
	[_tableView setSeparatorColor:[UIColor clearColor]];
	[_tableView setAllowsSelection:NO];
    
    _tableView.backgroundColor=[UIColor colorWithRed:kBackgroundColorR green:kBackgroundColorG blue:kBackgroundColorB alpha:kBackgroundColorA];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    self.elcAssets = tempArray;
    [tempArray release];
	
    UIButton *backButtonView=[UIButton buttonWithType:UIButtonTypeCustom];
    backButtonView.frame=CGRectMake(0,kLEONavBarBtnTopY,kDefalutNavItemWidth,kLEONavBarBtnHeight);
    [backButtonView.titleLabel setFont:[UIFont systemFontOfSize:kLEONavBarFontSz]];
    backButtonView.contentEdgeInsets=UIEdgeInsetsMake(0, kLEONavBarBackLeft, 0, 0);
    [backButtonView setTitle:NSLocalizedString(@"Back", @"") forState:UIControlStateNormal];
    [backButtonView setBackgroundImage:[UIImage imageNamed:kNavigationBackBg] forState:UIControlStateNormal];
    [backButtonView setBackgroundImage:[UIImage imageNamed:kNavigationBackBgHighlight] forState:UIControlStateHighlighted];
    [backButtonView addTarget:self action:@selector(backToList:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButton=[[[UIBarButtonItem alloc] initWithCustomView:backButtonView] autorelease];
    self.navigationItem.leftBarButtonItem=leftButton;
    
    UIButton *cancelButtonView=[UIButton buttonWithType:UIButtonTypeCustom];
    cancelButtonView.frame=CGRectMake(0,kLEONavBarBtnTopY,kDefalutNavItemWidth,kLEONavBarBtnHeight);
    [cancelButtonView.titleLabel setFont:[UIFont systemFontOfSize:kLEONavBarFontSz]];
    [cancelButtonView setTitle:NSLocalizedString(@"Cancel", @"") forState:UIControlStateNormal];
    [cancelButtonView setBackgroundImage:[UIImage imageNamed:kNavigationEditBg] forState:UIControlStateNormal];
    [cancelButtonView setBackgroundImage:[UIImage imageNamed:kNavigationEditBgHighlight] forState:UIControlStateHighlighted];
    [cancelButtonView addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *cancelButton=[[[UIBarButtonItem alloc] initWithCustomView:cancelButtonView] autorelease];
    self.navigationItem.rightBarButtonItem=cancelButton;
    
	[self.navigationItem setTitle:NSLocalizedString(@"Loading...",@"")];
    
    
    
	[self performSelectorInBackground:@selector(preparePhotos) withObject:nil];
    
    // Show partial while full list loads
//	[_tableView performSelector:@selector(reloadData) withObject:nil afterDelay:.5];
}

-(void)preparePhotos {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	
    NSLog(@"enumerating photos");
    [self.assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop)
     {
         if(result == nil)
         {
             return;
         }
         
         ELCAsset *elcAsset = [[[ELCAsset alloc] initWithAsset:result] autorelease];
         [elcAsset setParent:self];
         [self.elcAssets addObject:elcAsset];
     }];
    NSLog(@"done enumerating photos");
	
//	[_tableView reloadData];
    [self performSelectorOnMainThread:@selector(preparedPhotos) withObject:nil waitUntilDone:NO];
    //    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    //	[self.navigationItem setTitle:@"Pick Photos"];
    [pool release];
}

-(void)preparedPhotos
{
    NSLog(@"count:%d",[self.elcAssets count]);
    [_tableView reloadData];
    [self.navigationItem setTitle:NSLocalizedString(@"Pick Photos",@"")];
}

-(void) backToList:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(NSArray *)selectedAssets {
	NSMutableArray *selectedAssetsImages = [[[NSMutableArray alloc] init] autorelease];
    
	for(ELCAsset *elcAsset in self.elcAssets)
    {
		if([elcAsset selected]) {
            
			[selectedAssetsImages addObject:[elcAsset asset]];
		}
	}
    return selectedAssetsImages;
}

- (void) doneAction:(id)sender {
    if ([self.parent respondsToSelector:@selector(cancelImagePicker)]) {
        [self.parent cancelImagePicker];
    }
}

#pragma mark UITableViewDataSource Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger result=ceil([self.assetGroup numberOfAssets] / 4.0);
//    NSLog(@"result count:%d",result);
    return result;
}

- (NSArray*)assetsForIndexPath:(NSIndexPath*)_indexPath {
    
	int index = (_indexPath.row*4);
	int maxIndex = (_indexPath.row*4+3);
    
	// NSLog(@"Getting assets for %d to %d with array count %d", index, maxIndex, [assets count]);
    
	if(maxIndex < [self.elcAssets count]) {
        
		return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
				[self.elcAssets objectAtIndex:index+1],
				[self.elcAssets objectAtIndex:index+2],
				[self.elcAssets objectAtIndex:index+3],
				nil];
	}
    
	else if(maxIndex-1 < [self.elcAssets count]) {
        
		return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
				[self.elcAssets objectAtIndex:index+1],
				[self.elcAssets objectAtIndex:index+2],
				nil];
	}
    
	else if(maxIndex-2 < [self.elcAssets count]) {
        
		return [NSArray arrayWithObjects:[self.elcAssets objectAtIndex:index],
				[self.elcAssets objectAtIndex:index+1],
				nil];
	}
    
	else if(maxIndex-3 < [self.elcAssets count]) {
        
		return [NSArray arrayWithObject:[self.elcAssets objectAtIndex:index]];
	}
    
	return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellForAsset";
    
    ELCAssetCell *cell = (ELCAssetCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[[ELCAssetCell alloc] initWithAssets:[self assetsForIndexPath:indexPath] reuseIdentifier:CellIdentifier] autorelease];
    }
	else
    {
		[cell setAssets:[self assetsForIndexPath:indexPath]];
	}
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	return 79;
}

- (int)totalSelectedAssets {
    
    int count = 0;
    
    for(ELCAsset *asset in self.elcAssets)
    {
		if([asset selected])
        {
            count++;
		}
	}
    
    return count;
}

- (void)dealloc
{
    [elcAssets release];
    [selectedAssetsLabel release];
    [_tableView release];
    [super dealloc];    
}
@end
