//
//  LEOContentTypeConvert.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-11-1.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOContentTypeConvert.h"
#import "LEOUtility.h"

@interface LEOContentTypeConvert ()
{
    NSString *_fileDefault;
    NSString *_folderDefault;
}
-(id)init;
@end

@implementation LEOContentTypeConvert
-(id)init
{
    self=[super init];
    if (self) {
        NSString *filePath=[[[NSBundle mainBundle] bundlePath] stringByAppendingFormat:@"%@",kContentTypesPlistFileName];
        NSDictionary *_table=[NSDictionary dictionaryWithContentsOfFile:filePath];
//        _fileDic=[_table objectForKey:@"file"];
        _fileDic=[[NSMutableDictionary alloc] initWithDictionary:[_table objectForKey:@"file"]];
        _folderDic=[[NSMutableDictionary alloc] initWithDictionary:[_table objectForKey:@"folder"]];
        _fileDefault=[[NSString alloc] initWithString:[_fileDic valueForKey:@"default"]];
        _folderDefault=[[NSString alloc] initWithString:[_folderDic valueForKey:@"default"]];
    }
    return self;
}
-(void)dealloc
{
    [_fileDic release];
    [_folderDic release];
    [_fileDefault release];
    [_folderDefault release];
    [super dealloc];
}

+(LEOContentTypeConvert *)getInstance
{
    static LEOContentTypeConvert *_instance;
    @synchronized(self)
    {
        if(!_instance){
            _instance=[[LEOContentTypeConvert alloc] init];
        }
    }
    return _instance;
}

-(NSString *)searchForResourceType:(NSString *)type isFile:(BOOL)isFile
{
    if (isFile) {
        NSString *result=[_fileDic valueForKey:type];
        return result==nil?_fileDefault:result;
    }else{
        NSString *result=[_folderDic valueForKey:type];
        return result==nil?_folderDefault:result;
    }
}

@end

@interface LEOExtendUTIConvert ()
{
    NSString *_default;
}
-(id)init;
@end

@implementation LEOExtendUTIConvert

-(id)init
{
    self=[super init];
    if (self) {
        NSString *filePath=[[[NSBundle mainBundle] bundlePath] stringByAppendingFormat:@"%@",kExtendUTIPlistFileName];
        _covertDic=[[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        _default=[[NSString alloc] initWithString:[_covertDic valueForKey:@"default"]];
    }
    return self;
}
-(void)dealloc
{
    [_default release];
    [_covertDic release];
    [super dealloc];
}

+(LEOExtendUTIConvert *)getInstance
{
    static LEOExtendUTIConvert *_instance;
    @synchronized(self)
    {
        if(!_instance){
            _instance=[[LEOExtendUTIConvert alloc] init];
        }
    }
    return _instance;
}

-(NSString *)searchForUTI:(NSString *)type
{
    NSString *result=[_covertDic valueForKey:type];
    return result==nil?_default:result;
}

@end

@interface LEOExtensionToMIME ()
-(id)init;
@end

@implementation LEOExtensionToMIME
-(id)init
{
    self=[super init];
    if (self) {
        NSString *filePath=[[[NSBundle mainBundle] bundlePath] stringByAppendingFormat:@"%@",kExtentToMIMEPlistFileName];
        _convertDic=[[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
    }
    return self;
}
-(void)dealloc
{
    [_convertDic release];
    [super dealloc];
}

+(LEOExtensionToMIME *)getInstance
{
    static LEOExtensionToMIME *_instance;
    @synchronized(self)
    {
        if(!_instance){
            _instance=[[LEOExtensionToMIME alloc] init];
        }
    }
    return _instance;
}

-(NSString *)searchMimeFromExtension:(NSString *)extension
{
    NSString *result=[_convertDic valueForKey:extension];
    return result;
}
@end