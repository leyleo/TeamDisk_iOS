//
//  ELCImagePickerController.m
//  ELCImagePickerDemo
//
//  Created by Collin Ruffenach on 9/9/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import "ELCImagePickerController.h"
#import "ELCAsset.h"
#import "ELCAssetCell.h"
#import "ELCAssetTablePicker.h"
#import "LEODefines.h"
#import "LEOChoosePathViewController.h"

@interface ELCImagePickerController ()
{
    LEOUploadToolBar *_uploadToolBar;
    NSString *_uploadPath;
}
@end

@implementation ELCImagePickerController

@synthesize delegate;
@synthesize uploadPath=_uploadPath;

-(void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *stretchImage=[UIImage imageNamed:kNavigationBg];
    stretchImage=[stretchImage stretchableImageWithLeftCapWidth:1 topCapHeight:0];
	[self.navigationController.navigationBar setBackgroundImage:stretchImage forBarMetrics:UIBarMetricsDefault];
    
	_uploadToolBar=[[LEOUploadToolBar alloc] init];
    _uploadToolBar.delegate=self;
    [self.view addSubview:_uploadToolBar];
    
    [self setUploadPath:@"/"];
}

-(void)cancelImagePicker {
	if([delegate respondsToSelector:@selector(elcImagePickerControllerDidCancel:)]) {
		[delegate performSelector:@selector(elcImagePickerControllerDidCancel:) withObject:self];
	}
}

-(void)selectedAssets:(NSArray*)_assets {

	NSMutableArray *returnArray = [[[NSMutableArray alloc] init] autorelease];
	
	for(ALAsset *asset in _assets) {

		NSMutableDictionary *workingDictionary = [[NSMutableDictionary alloc] init];
        [workingDictionary setObject:[UIImage imageWithCGImage:[asset thumbnail]] forKey:@"UIImagePickerControllerThumbnail"];
        [workingDictionary setObject:[asset valueForProperty:ALAssetPropertyDate] forKey:@"UIImagePickerControllerDate"];
        [workingDictionary setObject:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]] forKey:@"UIImagePickerControllerOriginalImage"];
        [workingDictionary setObject:[[asset valueForProperty:ALAssetPropertyRepresentations] objectAtIndex:0] forKey:@"UIImagePickerControllerType"];
		
		[returnArray addObject:workingDictionary];
		
		[workingDictionary release];	
	}
	
    [self popToRootViewControllerAnimated:NO];
//    [[self parentViewController] dismissModalViewControllerAnimated:YES];
    [[self parentViewController] dismissViewControllerAnimated:YES completion:nil];
    
	if([delegate respondsToSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:)]) {
		[delegate performSelector:@selector(elcImagePickerController:didFinishPickingMediaWithInfo:) withObject:self withObject:[NSArray arrayWithArray:returnArray]];
	}
}

#pragma mark -
-(void)chooseButton:(id)sender
{
    LEOChoosePathViewController *chooseVC=[[LEOChoosePathViewController alloc] initWithPath:nil];
    chooseVC.parent=self;
    UINavigationController *navChooseVC=[[UINavigationController alloc] initWithRootViewController:chooseVC];
//    [self presentModalViewController:navChooseVC animated:YES];
    [self presentViewController:navChooseVC animated:YES completion:nil];
    [chooseVC release];
    [navChooseVC release];
}

-(void)uploadButton:(id)sender
{
    [self selectedAssets:[self.root selectedAssets]];
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

#pragma mark - Memory management

- (void)didReceiveMemoryWarning {    
    NSLog(@"ELC Image Picker received memory warning.");
    
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [_uploadToolBar release];
    [super viewDidUnload];
}


- (void)dealloc {
    NSLog(@"deallocing ELCImagePickerController");
    [super dealloc];
}

@end
