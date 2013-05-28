//
//  LEONetworkController.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-26.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEOWebDAVRequest.h"
#import "LEOWebDAVClient.h"
#import "LEOServerInfo.h"

@class LEOWebDAVItem;
@class KTPhotoView;
@interface LEONetworkController : NSObject<LEOWebDAVRequestDelegate>
{
    LEOWebDAVClient *_client;
}
-(id)initWithServerInfo:(LEOServerInfo *)info;
-(LEOWebDAVRequest *)addNewDownloadRequest:(LEOWebDAVItem *)info
                    withView:(KTPhotoView *)view
                 forInstance:(id)instance
                     failSEL:(SEL)fail
                  successSEL:(SEL)success
                  receiveSEL:(SEL)receive
                    startSEL:(SEL)start;
-(LEOWebDAVRequest *)addNewDeleteRequest:(LEOWebDAVItem *)one
               forInstance:(id)instance
                   failSEL:(SEL)fail
                successSEL:(SEL)success
                receiveSEL:(SEL)receive
                  startSEL:(SEL)start;
@end
