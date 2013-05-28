//
//  LEOContentTypeConvert.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-1.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEODefines.h"

@interface LEOContentTypeConvert : NSObject
{
    NSMutableDictionary *_folderDic;
    NSMutableDictionary *_fileDic;
}
+(LEOContentTypeConvert *)getInstance;
-(NSString *)searchForResourceType:(NSString *)type isFile:(BOOL)isFile;
@end


@interface LEOExtendUTIConvert : NSObject
{
    NSMutableDictionary *_covertDic;
}
+(LEOExtendUTIConvert *)getInstance;
-(NSString *)searchForUTI:(NSString *)type;
@end

@interface LEOExtensionToMIME : NSObject
{
    NSMutableDictionary *_convertDic;
}
+(LEOExtensionToMIME *)getInstance;
-(NSString *)searchMimeFromExtension:(NSString *)extension;
@end