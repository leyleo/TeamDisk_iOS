//
//  LEONetworkController.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-26.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEONetworkController.h"
#import "LEOWebDAVDeleteRequest.h"
#import "LEOWebDAVDownloadRequest.h"
#import "LEOWebDAVMakeCollectionRequest.h"
#import "LEOWebDAVCopyRequest.h"
#import "LEOWebDAVMoveRequest.h"
#import "LEOWebDAVPropertyRequest.h"
#import "LEOWebDAVUploadRequest.h"
#import "LEOUtility.h"
#import "LEOWebDAVItem.h"
#import "KTPhotoView.h"

@implementation LEONetworkController
-(id)initWithServerInfo:(LEOServerInfo *)info
{
    self=[super init];
    if (self) {
        _client=[[LEOWebDAVClient alloc] initWithRootURL:[NSURL URLWithString:info.url]
                                            andUserName:info.userName
                                            andPassword:info.password];
    }
    return self;
}

-(LEOWebDAVRequest *)addNewDownloadRequest:(LEOWebDAVItem *)info
                    withView:(KTPhotoView *)view
                 forInstance:(id)instance
                     failSEL:(SEL)fail
                  successSEL:(SEL)success
                  receiveSEL:(SEL)receive
                    startSEL:(SEL)start
{
    LEOWebDAVDownloadRequest *downRequest=[[LEOWebDAVDownloadRequest alloc] initWithPath:info.href];
    [downRequest setDelegate:self];
    downRequest.item=info;
    downRequest.instance=instance;
    downRequest.view=view;
    downRequest.errorAction=fail;
    downRequest.successAction=success;
    downRequest.receiveAction=receive;
    downRequest.startAction=start;
    [_client enqueueRequest:downRequest];
    return downRequest;
}

-(LEOWebDAVRequest *)addNewDeleteRequest:(LEOWebDAVItem *)one
               forInstance:(id)instance
                   failSEL:(SEL)fail
                successSEL:(SEL)success
                receiveSEL:(SEL)receive
                  startSEL:(SEL)start
{
    LEOWebDAVDeleteRequest *uploadRequest=[[LEOWebDAVDeleteRequest alloc] initWithPath:one.href];
    [uploadRequest setDelegate:self];
    uploadRequest.info=one;
    uploadRequest.instance=instance;
    uploadRequest.errorAction=fail;
    uploadRequest.successAction=success;
    uploadRequest.receiveAction=receive;
    uploadRequest.startAction=start;
    [_client enqueueRequest:uploadRequest];
    return uploadRequest;
}

-(void)dealloc
{
    [_client cancelRequest];
    [_client release];
    [super dealloc];
}

//#ifdef YES
//-(BOOL) respondsToSelector:(SEL)aSelector {
//    printf("SELECTOR: %s\n", [NSStringFromSelector(aSelector) UTF8String]);
//    return [super respondsToSelector:aSelector];
//}
//#endif

#pragma mark - WebDav delegate
- (void)request:(LEOWebDAVRequest *)aRequest didFailWithError:(NSError *)error
{
    NSLog(@"error:%@",[error description]);
}

- (void)request:(LEOWebDAVRequest *)aRequest didSucceedWithResult:(id)result
{
    NSLog(@"sucess");
    if ([aRequest isKindOfClass:[LEOWebDAVDownloadRequest class]]) {
        // 下载类请求
        LEOWebDAVDownloadRequest *req=(LEOWebDAVDownloadRequest *)aRequest;
        NSData *myDate=result;
        NSString *cacheFolder=[[LEOUtility getInstance] cachePathWithName:@"download"];
        NSString *cacheUrl=[[cacheFolder stringByAppendingPathComponent:req.item.cacheName] stringByAppendingPathExtension:[req.item.displayName pathExtension]];
        [myDate writeToFile:cacheUrl atomically:YES];
        if (req==nil || req.instance==nil || req.successAction==nil) {
            return;
        }
        [req.instance performSelectorOnMainThread:req.successAction withObject:req waitUntilDone:NO];
    }
    else if ([aRequest isKindOfClass:[LEOWebDAVDeleteRequest class]]) {
        // 删除类请求
        LEOWebDAVDeleteRequest *req=(LEOWebDAVDeleteRequest *)aRequest;
        if (req==nil || req.instance==nil || req.successAction==nil) {
            return;
        }
        if (req.instance && [req.instance respondsToSelector:req.successAction]) {
            [req.instance performSelectorOnMainThread:req.successAction withObject:req.info waitUntilDone:NO];
        }
    }
}
- (void)requestDidBegin:(LEOWebDAVRequest *)request
{
    if (request==nil || request.instance==nil || request.startAction==nil) {
        return;
    }
    if (request.instance && [request.instance respondsToSelector:request.startAction]) {
        [request.instance performSelectorOnMainThread:request.receiveAction withObject:request waitUntilDone:NO];
    }
}
- (void)request:(LEOWebDAVRequest *)request didReceivedProgress:(float)percent
{
    if (request==nil || request.instance==nil || request.receiveAction==nil) {
        return;
    }
    if (request.instance && [request.instance respondsToSelector:request.receiveAction]) {
        [request.instance performSelectorOnMainThread:request.receiveAction withObject:[NSNumber numberWithFloat:percent] waitUntilDone:NO];
    }
}
@end
