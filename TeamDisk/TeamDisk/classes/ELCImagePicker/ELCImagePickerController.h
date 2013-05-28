//
//  ELCImagePickerController.h
//  ELCImagePickerDemo
//
//  Created by Collin Ruffenach on 9/9/10.
//  Copyright 2010 ELC Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LEOUploadToolBar.h"

@interface ELCImagePickerController : UINavigationController<LEOUploadToolBarDelegate> {

	id delegate;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) id root;
@property (readonly) NSString *uploadPath;
-(void)selectedAssets:(NSArray*)_assets;
-(void)cancelImagePicker;
-(void)setRoot:(id)controller;
-(void)setUploadPath:(NSString *)path;
@end

@protocol ELCImagePickerControllerDelegate

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info;
- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker;

@end

