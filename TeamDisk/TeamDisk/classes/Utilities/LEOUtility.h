//
//  LEOUtility.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-10-25.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LEOUtility : NSObject
+(LEOUtility *)getInstance;
+(NSString *)documentPath;
+(BOOL)isUrl:(NSString *)orgString;
+(BOOL)isEmptyString:(NSString *)string;
+(NSString *)generateTimeStamp;
+(NSString *)generateTimeName:(NSDate *)date;
+(NSString *)generateTimeString:(NSDate *)date;
+ (UIImage *)generatePhotoThumbnail:(UIImage *)image;
-(NSString *)cachePathWithName:(NSString *)name;
+(BOOL)clearCacheWithName:(NSString *)name;
+(BOOL)clearCache;
-(NSString *)md5ForData:(NSData *)data;
-(BOOL)isExistFile:(NSString *)filePath;
+ (NSString *)formattedFileSize:(unsigned long long)size;
+ (unsigned long long int) cacheFolderSize;
@end
