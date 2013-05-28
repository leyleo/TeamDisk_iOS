//
//  LEOUploadInfo.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-8.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEOWebDAVRequest.h"
@class LEOUploadListCell;

typedef enum {
    LEOUploadStatusWait,
    LEOUploadStatusDone,
    LEOUploadStatusUploading,
    LEOUploadStatusError
} LEOUploadStatus;

@interface LEOUploadInfo : NSObject<LEOWebDAVRequestDelegate>
@property (readonly) NSString *displayName;
@property (assign) LEOUploadStatus status;
@property (assign) NSUInteger contentLength;
@property (readonly) UIImage *thumbnail;
@property (readonly) UIImage *originalImage;
@property (readonly) NSString *date;
@property (assign) LEOUploadListCell *delegate;
-(id)initWithDictionary:(NSDictionary *)dic;
-(id)initWithCameraInfo:(NSDictionary *)dic;
@end
