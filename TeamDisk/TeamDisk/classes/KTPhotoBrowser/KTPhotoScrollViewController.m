//
//  KTPhotoScrollViewController.m
//  KTPhotoBrowser
//
//  Created by Kirby Turner on 2/4/10.
//  Copyright 2010 White Peak Software Inc. All rights reserved.
//
//  Modified by Liu Ley on 2012.11.16.

#import "KTPhotoScrollViewController.h"
#import "KTPhotoBrowserDataSource.h"
//#import "KTPhotoBrowserGlobal.h"
#import "KTPhotoView.h"
#import "LEOImageDataSource.h"
#import "LEOAppDelegate.h"
#import "LEODefines.h"
#import "LEOUtility.h"
#import "LEOWebDAVItem.h"
#import "LEOWebDAVClient.h"
#import "LEOWebDAVDefines.h"
#import "LEOWebDAVDeleteRequest.h"
#import "LEOWebDAVDownloadRequest.h"
#import "LEONetworkController.h"
#import "LEODoubleModeViewController.h"

const CGFloat ktkDefaultPortraitToolbarHeight   = 44;
const CGFloat ktkDefaultLandscapeToolbarHeight  = 33;
const CGFloat ktkDefaultToolbarHeight = 44;

#define BUTTON_DELETEPHOTO 0
#define BUTTON_CANCEL 1

@interface KTPhotoScrollViewController ()
{
    MBProgressHUD *_hub;
    NSMutableArray *_requestArray;
}
@end

@implementation KTPhotoScrollViewController

@synthesize statusBarStyle = statusBarStyle_;
@synthesize statusbarHidden = statusbarHidden_;


- (void)dealloc 
{
    if (_hub) {
        [_hub release];
    }
    [_requestArray release];
   [scrollView_ release], scrollView_ = nil;
   [photoViews_ release], photoViews_ = nil;
   [dataSource_ release], dataSource_ = nil;  
   
   [super dealloc];
}

- (id)initWithDataSource:(LEOImageDataSource *)dataSource andStartWithPhotoAtIndex:(NSUInteger)index
{
   if (self = [super init]) {
     startWithIndex_ = index;
     dataSource_ = [dataSource retain];
       _requestArray=[[NSMutableArray alloc] init];
     // Make sure to set wantsFullScreenLayout or the photo
     // will not display behind the status bar.
     [self setWantsFullScreenLayout:YES];

     BOOL isStatusbarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
     [self setStatusbarHidden:isStatusbarHidden];
     
     self.hidesBottomBarWhenPushed = YES;
   }
   return self;
}

- (void)prepareDetail
{  
    photoCount_ = [dataSource_ numberOfPhotos];
    [self setScrollViewContentSize];

    // Setup our photo view cache. We only keep 3 views in
    // memory. NSNull is used as a placeholder for the other
    // elements in the view cache array.
    photoViews_ = [[NSMutableArray alloc] initWithCapacity:photoCount_];
    for (int i=0; i < photoCount_; i++) {
      [photoViews_ addObject:[NSNull null]];
    }

    [self setupScrollView];
    
    NSArray *items=[NSArray arrayWithObjects:NSLocalizedString(@"Open In",@""), NSLocalizedString(@"Save to Photo Album",@""), NSLocalizedString(@"Delete",@""), nil];
    [_editToolBar setupItems:items];
}

-(void)prepareAction
{
    _item=[dataSource_ itemAtIndex:startWithIndex_];
}

-(void)backToList
{
    if (_hub!=nil) {
        [_hub hide:YES];
    }
    
    [super backToList];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [NSOperation cancelPreviousPerformRequestsWithTarget:self];
    
    if (self.parentInstance && [self.parentInstance respondsToSelector:@selector(reloadData)]) {
        [self.parentInstance reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated 
{
   [super viewWillAppear:animated];
   
   // The first time the view appears, store away the previous controller's values so we can reset on pop.
   UINavigationBar *navbar = [[self navigationController] navigationBar];
   if (!viewDidAppearOnce_) {
      viewDidAppearOnce_ = YES;
      navbarWasTranslucent_ = [navbar isTranslucent];
      statusBarStyle_ = [[UIApplication sharedApplication] statusBarStyle];
   }
   // Then ensure translucency. Without it, the view will appear below rather than under it.  
   [navbar setTranslucent:YES];
   [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:YES];

   // Set the scroll view's content size, auto-scroll to the stating photo,
   // and setup the other display elements.
   [self setScrollViewContentSize];
   [self setCurrentIndex:startWithIndex_];
   [self scrollToIndex:startWithIndex_];

   [self setTitleWithCurrentPhotoIndex];
//   [self toggleNavButtons];
   [self startChromeDisplayTimer];
}

- (void)viewWillDisappear:(BOOL)animated 
{
  // Reset nav bar translucency and status bar style to whatever it was before.
  UINavigationBar *navbar = [[self navigationController] navigationBar];
  [navbar setTranslucent:navbarWasTranslucent_];
  [[UIApplication sharedApplication] setStatusBarStyle:statusBarStyle_ animated:YES];
  [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated 
{
   [self cancelChromeDisplayTimer];
   [super viewDidDisappear:animated];
}

-(void)afterDelete
{
    if (dataSource_) {
        // TODO: Animate the deletion of the current photo.
        
        NSInteger photoIndexToDelete = currentIndex_;
        [self unloadPhoto:photoIndexToDelete];
        [dataSource_ deleteImageAtIndex:photoIndexToDelete];
        
        if (self.parentInstance!=nil && [self.parentInstance respondsToSelector:@selector(loadCurrentPath)]) {
            //            [self.parentInstance loadCurrentPath];
            [self.parentInstance performSelectorInBackground:@selector(loadCurrentPath) withObject:nil];
        }
        
        photoCount_ -= 1;
        if (photoCount_ == 0) {
            [self showChrome];
//            [[self navigationController] popViewControllerAnimated:YES];
            [self backToList];
        } else {
            NSInteger nextIndex = photoIndexToDelete;
            if (nextIndex == photoCount_) {
                nextIndex -= 1;
            }
            [self setScrollViewContentSize];
            [self unloadPhoto:nextIndex+1];
            [self setCurrentIndex:nextIndex];
            
        }
        
    }
}

- (void)deleteCurrentPhoto 
{
    [self addNewRequestForDelete];
}

#pragma mark - (Private)
- (void)setupScrollView
{
    CGRect scrollFrame = [self frameForPagingScrollView];
    UIScrollView *newView = [[UIScrollView alloc] initWithFrame:scrollFrame];
    [newView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    [newView setDelegate:self];
    
    UIColor *backgroundColor = [dataSource_ respondsToSelector:@selector(imageBackgroundColor)] ?
    [dataSource_ imageBackgroundColor] : [UIColor blackColor];
    [newView setBackgroundColor:backgroundColor];
    [newView setAutoresizesSubviews:YES];
    [newView setPagingEnabled:YES];
    [newView setShowsVerticalScrollIndicator:NO];
    [newView setShowsHorizontalScrollIndicator:NO];
    
    [_displayView addSubview:newView];
    
    scrollView_ = [newView retain];
    
    [newView release];
    
    CGRect editToolBarFrame=_editToolBar.frame;
    editToolBarFrame.origin.y=scrollFrame.size.height+scrollFrame.origin.y-kLEOTabBarHeight;
    _editToolBar.frame=editToolBarFrame;
}

- (void)setTitleWithCurrentPhotoIndex
{
    NSString *formatString = NSLocalizedString(@"%1$i of %2$i", @"Picture X out of Y total.");
    NSString *title = [NSString stringWithFormat:formatString, currentIndex_ + 1, photoCount_, nil];
    [self setTitle:title];
}

- (void)scrollToIndex:(NSInteger)index
{
    CGRect frame = scrollView_.frame;
    frame.origin.x = frame.size.width * index;
    frame.origin.y = 0;
    [scrollView_ scrollRectToVisible:frame animated:NO];
}

- (void)setScrollViewContentSize
{
    NSInteger pageCount = photoCount_;
    if (pageCount == 0) {
        pageCount = 1;
    }
    
    CGSize size = CGSizeMake(scrollView_.frame.size.width * pageCount,
                             scrollView_.frame.size.height / 2);   // Cut in half to prevent horizontal scrolling.
    [scrollView_ setContentSize:size];
}

//-(void)downloadItem:(LEOWebDAVItem *)_currentItem
//{
//    LEOAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
//    LEOWebDAVDownloadRequest *downRequest=[[LEOWebDAVDownloadRequest alloc] initWithPath:_item.href];
//    [downRequest setDelegate:self];
//    downRequest.item=_currentItem;
//    [delegate.client enqueueRequest:downRequest];
//}

//-(void)downloadItem:(LEOWebDAVItem *)_currentItem photoView:(KTPhotoView *)photoView
//{
//    LEOAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
//    LEOWebDAVDownloadRequest *downRequest=[[LEOWebDAVDownloadRequest alloc] initWithPath:_currentItem.href];
//    [downRequest setDelegate:self];
//    downRequest.item=_currentItem;
//    downRequest.view=photoView;
//    [delegate.client enqueueRequest:downRequest];
//}
-(void)downloadItem:(LEOWebDAVItem *)_currentItem photoView:(KTPhotoView *)photoView
{
    LEOWebDAVDownloadRequest *downRequest=[[LEOWebDAVDownloadRequest alloc] initWithPath:_currentItem.href];
    [downRequest setDelegate:self];
    downRequest.item=_currentItem;
    NSLog(@"enqueue:%@",_currentItem.href);
    downRequest.view=photoView;
    NSArray *array=[_currentClient currentArray];
    for (LEOWebDAVRequest *req in array) {
        if ([req isKindOfClass:[LEOWebDAVDownloadRequest class]]) {
            LEOWebDAVDownloadRequest *reqdown=(LEOWebDAVDownloadRequest*)req;
            if ([reqdown.item.href isEqualToString:downRequest.item.href]) {
                NSLog(@"return");
                return;
            }
        }
    }
    [_currentClient enqueueRequest:downRequest];
}

//-(void)downloadItem:(LEOWebDAVItem *)_currentItem photoView:(KTPhotoView *)photoView
//{
//    LEOAppDelegate *delegate=[[UIApplication sharedApplication] delegate];
//    LEOWebDAVRequest *downReq =[delegate.networkController addNewDownloadRequest:_currentItem withView:photoView forInstance:self failSEL:nil successSEL:@selector(downloadFinish:) receiveSEL:nil startSEL:nil];
//    [_requestArray addObject:downReq];
//    [downReq release];
//}

-(void)downloadFinish:(LEOWebDAVDownloadRequest *)request
{
    KTPhotoView *view=request.view;
    LEOWebDAVItem *_currentItem=request.item;
    NSString *cacheFolder=[[LEOUtility getInstance] cachePathWithName:@"download"];
    NSString *cacheUrl=[[cacheFolder stringByAppendingPathComponent:_currentItem.cacheName] stringByAppendingPathExtension:[_currentItem.displayName pathExtension]];
//    [self computeThumbnail:cacheUrl];
    if (view!=nil && [_item.href isEqualToString:_currentItem.href]) {
        [view setImage:[UIImage imageWithContentsOfFile:cacheUrl]];
    }
}

-(void)computeThumbnail:(NSString *)path
{
    NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
    NSString *url=[[NSString alloc] initWithString:path];
    NSString *cacheName=[url lastPathComponent];
    UIImage *icon=[LEOUtility generatePhotoThumbnail:[UIImage imageWithContentsOfFile:url]];
    NSString *cacheFolder=[[LEOUtility getInstance] cachePathWithName:@"thumbnail"];
    NSString *cacheUrl=[cacheFolder stringByAppendingPathComponent:cacheName];
    NSData *data=UIImageJPEGRepresentation(icon, 1.0);
    [data writeToFile:cacheUrl atomically:YES];
    [url release];
    [pool release];
}


#pragma mark -
#pragma mark Frame calculations
#define PADDING  20

- (CGRect)frameForPagingScrollView 
{
   CGRect frame = [[UIScreen mainScreen] bounds];
   frame.origin.x -= PADDING;
   frame.size.width += (2 * PADDING);
   return frame;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index 
{
   // We have to use our paging scroll view's bounds, not frame, to calculate the page placement. When the device is in
   // landscape orientation, the frame will still be in portrait because the pagingScrollView is the root view controller's
   // view, so its frame is in window coordinate space, which is never rotated. Its bounds, however, will be in landscape
   // because it has a rotation transform applied.
   CGRect bounds = [scrollView_ bounds];
   CGRect pageFrame = bounds;
   pageFrame.size.width -= (2 * PADDING);
   pageFrame.origin.x = (bounds.size.width * index) + PADDING;
   return pageFrame;
}

#pragma mark - Photo (Page) Management

- (void)loadPhoto:(NSInteger)index
{
   if (index < 0 || index >= photoCount_) {
      return;
   }
   
   id currentPhotoView = [photoViews_ objectAtIndex:index];
   if (NO == [currentPhotoView isKindOfClass:[KTPhotoView class]]) {
      // Load the photo view.
      CGRect frame = [self frameForPageAtIndex:index];
      KTPhotoView *photoView = [[KTPhotoView alloc] initWithFrame:frame];
      [photoView setScroller:self];
      [photoView setIndex:index];
      [photoView setBackgroundColor:[UIColor clearColor]];
      
      // Set the photo image.
      if (dataSource_) {
          UIImage *image=[dataSource_ imageAtIndex:index];
          if (image) {
              [photoView setImage:image];
          }else {
//              [self downloadItem:[dataSource_ itemAtIndex:index]];
              [photoView setDefaultImage];
              [self downloadItem:[dataSource_ itemAtIndex:index] photoView:photoView];
          }
      }
      
      [scrollView_ addSubview:photoView];
      [photoViews_ replaceObjectAtIndex:index withObject:photoView];
      [photoView release];
   } else {
      // Turn off zooming.
      [currentPhotoView turnOffZoom];
   }
}

- (void)unloadPhoto:(NSInteger)index
{
   if (index < 0 || index >= photoCount_) {
      return;
   }
   
   id currentPhotoView = [photoViews_ objectAtIndex:index];
   if ([currentPhotoView isKindOfClass:[KTPhotoView class]]) {
      [currentPhotoView removeFromSuperview];
      [photoViews_ replaceObjectAtIndex:index withObject:[NSNull null]];
   }
}

- (void)setCurrentIndex:(NSInteger)newIndex
{
   currentIndex_ = newIndex;
    NSLog(@"index:%d",currentIndex_);
    if (currentIndex_>-1 && currentIndex_<[dataSource_ numberOfPhotos]) {
        _item=[dataSource_ itemAtIndex:currentIndex_];
    }
    
   [self loadPhoto:currentIndex_];
   [self loadPhoto:currentIndex_ + 1];
   [self loadPhoto:currentIndex_ - 1];
   [self unloadPhoto:currentIndex_ + 2];
   [self unloadPhoto:currentIndex_ - 2];
   
   [self setTitleWithCurrentPhotoIndex];
}

#pragma mark - Chrome Helpers

- (void)toggleChromeDisplay 
{
   [self toggleChrome:!isChromeHidden_];
}

- (void)toggleChrome:(BOOL)hide 
{
   isChromeHidden_ = hide;
   if (hide) {
      [UIView beginAnimations:nil context:nil];
      [UIView setAnimationDuration:0.4];
   }
   
   if ( ! [self isStatusbarHidden] ) {     
     if ([[UIApplication sharedApplication] respondsToSelector:@selector(setStatusBarHidden:withAnimation:)]) {
       [[UIApplication sharedApplication] setStatusBarHidden:hide withAnimation:NO];
     } else {  // Deprecated in iOS 3.2+.
       id sharedApp = [UIApplication sharedApplication];  // Get around deprecation warnings.
       [sharedApp setStatusBarHidden:hide animated:NO];
     }
   }

   CGFloat alpha = hide ? 0.0 : 1.0;
   
   // Must set the navigation bar's alpha, otherwise the photo
   // view will be pushed until the navigation bar.
   UINavigationBar *navbar = [[self navigationController] navigationBar];
   [navbar setAlpha:alpha];
    [_editToolBar setAlpha:alpha];

   if (hide) {
      [UIView commitAnimations];
   }
   
   if ( ! isChromeHidden_ ) {
      [self startChromeDisplayTimer];
   }
}

- (void)hideChrome 
{
   if (chromeHideTimer_ && [chromeHideTimer_ isValid]) {
      [chromeHideTimer_ invalidate];
      chromeHideTimer_ = nil;
   }
   [self toggleChrome:YES];
}

- (void)showChrome 
{
   [self toggleChrome:NO];
}

- (void)startChromeDisplayTimer 
{
   [self cancelChromeDisplayTimer];
   chromeHideTimer_ = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                       target:self 
                                                     selector:@selector(hideChrome)
                                                     userInfo:nil
                                                      repeats:NO];
}

- (void)cancelChromeDisplayTimer 
{
   if (chromeHideTimer_) {
      [chromeHideTimer_ invalidate];
      chromeHideTimer_ = nil;
   }
}


#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView 
{
   CGFloat pageWidth = scrollView.frame.size.width;
   float fractionalPage = scrollView.contentOffset.x / pageWidth;
   NSInteger page = floor(fractionalPage);
	if (page != currentIndex_) {
		[self setCurrentIndex:page];
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView 
{
   [self hideChrome];
}


#pragma mark - LEOWebDAV delegate
- (void)request:(LEOWebDAVRequest *)aRequest didFailWithError:(NSError *)error
{
    NSLog(@"error:%@",[error description]);
    if ([aRequest isKindOfClass:[LEOWebDAVDeleteRequest class]]) {
    } else if ([aRequest isKindOfClass:[LEOWebDAVDownloadRequest class]]) {
        if ([error.domain isEqualToString:kWebDAVErrorDomain] && error.code==-1) {
            return;
        } else if ([error.domain isEqualToString:NSURLErrorDomain]) {
            [self setupProgressHDFailure:[error localizedDescription]];
        }
    }
}

- (void)request:(LEOWebDAVRequest *)aRequest didSucceedWithResult:(id)result
{
    NSLog(@"sucess");
    if ([aRequest isKindOfClass:[LEOWebDAVDownloadRequest class]]) {
        // 下载类请求
        LEOWebDAVDownloadRequest *req=(LEOWebDAVDownloadRequest *)aRequest;
        NSData *myDate=result;
        LEOWebDAVItem *_currentItem=[(LEOWebDAVDownloadRequest *)aRequest item];
        NSString *cacheFolder=[[LEOUtility getInstance] cachePathWithName:@"download"];
        NSString *cacheUrl=[[cacheFolder stringByAppendingPathComponent:_currentItem.cacheName] stringByAppendingPathExtension:[_currentItem.displayName pathExtension]];
        [myDate writeToFile:cacheUrl atomically:YES];
//        [self computeThumbnail:cacheUrl];
        [self performSelectorInBackground:@selector(computeThumbnail:) withObject:cacheUrl];
        KTPhotoView *view=nil;
        if (req.view!=nil) {
            view=req.view;
        }
//        if (view!=nil && [_item.href isEqualToString:_currentItem.href]) {
        if (view!=nil) {
//            [view performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageWithContentsOfFile:cacheUrl] waitUntilDone:NO];
            [view setImage:[UIImage imageWithContentsOfFile:cacheUrl]];
        }
    }
    else if ([aRequest isKindOfClass:[LEOWebDAVDeleteRequest class]]) {
        // 删除类请求
        [self afterDelete];
    }
}

#pragma mark - UIActionSheetDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
   if (buttonIndex == BUTTON_DELETEPHOTO) {
      [self deleteCurrentPhoto];
   }
   [self startChromeDisplayTimer];
}

#pragma mark - Edit Tool Bar Delegate
-(void)didSelectedEditToolBarIndex:(NSInteger)index
{
    if (index==-1 || index==1) {
        // 打开为
        [self openFileIn];
    } else if (index==2 || index==-2) {
        // 保存到相册
        [self saveImageToAlbum];
    } else if (index==3 || index==-3) {
        //删除
        [self showDeleteSheet:LEOContentSheetTagSingle];
    }
}

-(void)saveImageToAlbum
{
    LEOUtility *utility=[LEOUtility getInstance];
    NSString *path=[[utility cachePathWithName:@"download"] stringByAppendingPathComponent:_item.cacheName];
    path=[path stringByAppendingPathExtension:[_item.displayName pathExtension]];
    if ([utility isExistFile:path]) {
        UIImage *image=[UIImage imageWithContentsOfFile:path];
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    } else {
        // 需要先下载，再保存
    }
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    if (error) {
        // 有错误
        [self setupProgressHDFailure:NSLocalizedString(@"Save Image Faild", @"保存失败")];
    }
    else {
        [self setupProgressHD:NSLocalizedString(@"Save Image Success", @"保存成功") isDone:YES];
    }
}

-(void)setupProgressHD:(NSString *)text isDone:(BOOL)done
{
    if (_hub) {
        [_hub hide:YES];
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
    [_hub show:YES];
    if (done) {
        [_hub hide:YES afterDelay:2];
    }
}

-(void)setupProgressHDFailure:(NSString *)text
{
    if (_hub) {
        [_hub hide:YES];
        [_hub release];
        _hub=nil;
    }
    _hub=[[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_hub];
    _hub.delegate=self;
    _hub.labelText=text;
    _hub.mode=MBProgressHUDModeCustomView;
    _hub.removeFromSuperViewOnHide=YES;
    [_hub show:YES];
    [_hub hide:YES afterDelay:1.5];
}

@end
