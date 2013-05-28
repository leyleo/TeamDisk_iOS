//
//  LEOUploadInfo.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-8.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOUploadInfo.h"
#import "LEOUtility.h"
#import "LEOUploadListCell.h"

@interface LEOUploadInfo ()
{
    NSString *_type;
    NSDate *_date;
    NSString *_refUrl;
    UIImage *_originalImage;
    UIImage *_thumbnail;
    LEOUploadStatus _status;
    NSUInteger _uploadProgress;
    NSUInteger _contentLength;
    NSString *_displayName;
}
@end

@implementation LEOUploadInfo
@synthesize status=_status;
@synthesize thumbnail=_thumbnail;
@synthesize originalImage=_originalImage;
@synthesize delegate;

-(id)initWithDictionary:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        _type=[[NSString alloc] initWithFormat:@"%@",[[dic valueForKey:@"UIImagePickerControllerType"] pathExtension]];
        _originalImage=[[dic objectForKey:@"UIImagePickerControllerOriginalImage"] copy];
        _thumbnail=[[dic objectForKey:@"UIImagePickerControllerThumbnail"] copy];
        _status=LEOUploadStatusWait;
        
        [self setCurrentTime];
        [self setDisplayName];
    }
    return self;
}

-(id)initWithCameraInfo:(NSDictionary *)dic
{
    self=[super init];
    if (self) {
        _type=[[NSString alloc] initWithFormat:@"%@",@"jpeg"];
        _originalImage=[UIImage imageWithData:UIImageJPEGRepresentation([dic objectForKey:UIImagePickerControllerOriginalImage], 0.05)];
        NSLog(@"_original:%@",[LEOUtility formattedFileSize:UIImageJPEGRepresentation(_originalImage, 1.0).length]);
        _thumbnail=[[LEOUtility generatePhotoThumbnail:_originalImage] copy];
        _status=LEOUploadStatusWait;
        [self setCurrentTime];
        [self setDisplayName];
    }
    return self;
}

-(NSString *)displayName
{
    return _displayName;
}

-(void)setContentLength:(NSUInteger)contentLength
{
    _contentLength=2*contentLength;
};

-(NSUInteger)contentLength
{
    return _contentLength;
}

-(void)setCurrentTime
{
    NSDate * date = [NSDate date];
    NSTimeInterval sec = [date timeIntervalSinceNow];
    _date = [[NSDate alloc] initWithTimeIntervalSinceNow:sec];
}

-(NSString *)date
{
    return [LEOUtility generateTimeString:_date];
}

-(void)setDisplayName
{
    _displayName=[[NSString alloc] initWithFormat:@"%@.%@",[LEOUtility generateTimeName:_date],_type];
}

#pragma mark - LEOWebDAV delegate
- (void)request:(LEOWebDAVRequest *)aRequest didFailWithError:(NSError *)error
{
    NSLog(@"error:%@",[error description]);
    _status=LEOUploadStatusError;
    if (self.delegate!=nil && [self.delegate.info isEqual:self]) {
        [self.delegate setStatus:_status];
    }
}

- (void)request:(LEOWebDAVRequest *)aRequest didSucceedWithResult:(id)result
{
    NSLog(@"sucess");
    _status=LEOUploadStatusDone;
    if (self.delegate!=nil && [self.delegate.info isEqual:self]) {
        [self.delegate setStatus:_status];
    }
}

- (void)requestDidBegin:(LEOWebDAVRequest *)request
{
    _status=LEOUploadStatusUploading;
    _uploadProgress=0;
    if (self.delegate!=nil && [self.delegate.info isEqual:self] && [self.delegate respondsToSelector:@selector(setStatus:)]) {
        [self.delegate setStatus:_status];
    }
}

//- (void)request:(LEOWebDAVRequest *)request didReceivedProgress:(float)percent
//{
//    if (self.delegate!=nil && [self.delegate.info isEqual:self] && [self.delegate respondsToSelector:@selector(setProgress:)]) {
//        NSLog(@"percent from upload info:%f",percent);
//        [self.delegate setProgress:percent];
//    }
//}

- (void)request:(LEOWebDAVRequest *)request didSendBodyData:(NSUInteger)currentP
{
    _uploadProgress+=currentP;
    if (self.delegate!=nil && [self.delegate.info isEqual:self] && [self.delegate respondsToSelector:@selector(setProgress:)]) {
//        NSLog(@"percent from upload info:%ud / %ud",_uploadProgress,_contentLength);
        [self.delegate setProgress:_uploadProgress/(float)_contentLength];
    }
}
@end
