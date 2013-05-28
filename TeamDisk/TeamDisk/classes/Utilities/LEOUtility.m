//
//  LEOUtility.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-10-25.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOUtility.h"
#import <CommonCrypto/CommonDigest.h>

#define LEO_MD5_DIGEST_LENGTH 16

@implementation LEOUtility

+(LEOUtility *)getInstance
{
    static LEOUtility *_instance;
    @synchronized(self)
    {
        if(!_instance){
            _instance=[[LEOUtility alloc] init];
        }
    }
    return _instance;
}

+(NSString *)documentPath
{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    return documentsDir;
}

+(BOOL)clearCacheWithName:(NSString *)name
{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath =[[[NSString alloc] initWithString:[[paths objectAtIndex:0] stringByAppendingPathComponent:name]] autorelease];
    NSLog(@"Clear cache for: %@",cachePath);
    if([[NSFileManager defaultManager] fileExistsAtPath:cachePath])
    {
        NSArray *myArray=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:cachePath error:nil];
        for(NSString *each in myArray)
        {
            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@",cachePath,each] error:nil];
        }
        return YES;
    }
    return NO;
}

+(BOOL)clearCache
{
    NSFileManager  *_manager = [NSFileManager defaultManager];
    NSArray *_cachePaths =  NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                                NSUserDomainMask, YES);
    NSString  *_cacheDirectory = [_cachePaths objectAtIndex:0];
    NSArray  *_cacheFileList;
    NSEnumerator *_cacheEnumerator;
    NSString *_cacheFilePath;
    _cacheFileList = [ _manager subpathsAtPath:_cacheDirectory];
    _cacheEnumerator = [_cacheFileList objectEnumerator];
    NSError *error=nil;
    while (_cacheFilePath = [_cacheEnumerator nextObject])
    {
        [_manager removeItemAtPath:[_cacheDirectory stringByAppendingPathComponent:_cacheFilePath] error:&error];
        
    }
    return YES;
}

+ (unsigned long long int) cacheFolderSize
{
    NSFileManager  *_manager = [NSFileManager defaultManager];
    NSArray *_cachePaths =  NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                                NSUserDomainMask, YES);
    NSString  *_cacheDirectory = [_cachePaths objectAtIndex:0];
    NSArray  *_cacheFileList;
    NSEnumerator *_cacheEnumerator;
    NSString *_cacheFilePath;
    unsigned long long int _cacheFolderSize = 0;
    _cacheFileList = [ _manager subpathsAtPath:_cacheDirectory];
    _cacheEnumerator = [_cacheFileList objectEnumerator];
    NSError *error=nil;
    while (_cacheFilePath = [_cacheEnumerator nextObject])
    {
        if (error) {
            break;
        }
        NSDictionary *_cacheFileAttributes = [_manager attributesOfItemAtPath:[_cacheDirectory   stringByAppendingPathComponent:_cacheFilePath] error:&error];
        _cacheFolderSize += [_cacheFileAttributes fileSize];
    }
    // 单位是字节
    return _cacheFolderSize;
}

+ (NSString *)formattedFileSize:(unsigned long long)size
{
	NSString *formattedStr = nil;
    if (size == 0)
		formattedStr = NSLocalizedString(@"Empty",@"");
	else
		if (size > 0 && size < 1024)
			formattedStr = [NSString stringWithFormat:@"%qu bytes", size];
        else
            if (size >= 1024 && size < pow(1024, 2))
                formattedStr = [NSString stringWithFormat:@"%.1f KB", (size / 1024.)];
            else
                if (size >= pow(1024, 2) && size < pow(1024, 3))
                    formattedStr = [NSString stringWithFormat:@"%.2f MB", (size / pow(1024, 2))];
                else
                    if (size >= pow(1024, 3))
                        formattedStr = [NSString stringWithFormat:@"%.3f GB", (size / pow(1024, 3))];
	
	return formattedStr;
}

+ (NSString *) generateTimeStamp
{
    return [NSString stringWithFormat:@"%ld", time(NULL)];
}

+(NSString *)generateTimeString:(NSDate *)date
{
    static NSDateFormatter *dateFormatter;
    if (dateFormatter==nil) {
        dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    }
    return [dateFormatter stringFromDate:date];
}

+(NSString *)generateTimeName:(NSDate *)date
{
    static NSDateFormatter *nameFormatter;
    if (nameFormatter==nil) {
        nameFormatter=[[NSDateFormatter alloc] init];
        [nameFormatter setDateFormat:@"yyyy-MM-dd HHmmssSSSS"];
    }
    return [nameFormatter stringFromDate:date];
}

+ (UIImage *)generatePhotoThumbnail:(UIImage *)image
{
    // Create a thumbnail version of the image for the event object.
    CGSize size = image.size;
    CGSize croppedSize;
    CGFloat ratio = 64.0;
    CGFloat offsetX = 0.0;
    CGFloat offsetY = 0.0;
    
    // check the size of the image, we want to make it
    // a square with sides the size of the smallest dimension
    if (size.width > size.height) {
        offsetX = (size.height - size.width) / 2;
        croppedSize = CGSizeMake(size.height, size.height);
    } else {
        offsetY = (size.width - size.height) / 2;
        croppedSize = CGSizeMake(size.width, size.width);
    }
    
    // Crop the image before resize
    CGRect clippedRect = CGRectMake(offsetX * -1, offsetY * -1, croppedSize.width, croppedSize.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
    // Done cropping
    
    // Resize the image
    CGRect rect = CGRectMake(0.0, 0.0, ratio, ratio);
    
    UIGraphicsBeginImageContext(rect.size);
    [[UIImage imageWithCGImage:imageRef] drawInRect:rect];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(imageRef);
    // Done Resizing
    
    return thumbnail;
}

-(NSString *) cachePathWithName:(NSString *)name
{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath =[[[NSString alloc] initWithString:[[paths objectAtIndex:0] stringByAppendingPathComponent:name]] autorelease];
    if(![[NSFileManager defaultManager] fileExistsAtPath:cachePath])
    {
        NSLog(@"create cache folder:%@",cachePath);
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    return cachePath;
}

-(BOOL)isExistFile:(NSString *)filePath
{
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

+(BOOL)isUrl:(NSString *)orgString
{
    NSString *myregex = @"\\bhttps?://[a-zA-Z0-9\\-.]+(?::(\\d+))?(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";
    NSPredicate *pred=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",myregex];
    BOOL isMatch=[pred evaluateWithObject:orgString];
    return isMatch;
}

+(BOOL)isEmptyString:(NSString *)string
{
    if(!string)
    { //string is empty or nil
        return YES;
    }
    else if([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        //string is all whitespace
        return YES;
    }
    return NO;
}

-(NSString *)md5ForData:(NSData *)data
{
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(data.bytes, data.length, md5Buffer);

    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}
@end
