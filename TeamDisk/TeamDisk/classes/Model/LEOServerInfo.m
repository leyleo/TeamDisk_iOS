//
//  LEOServerInfo.m
//  ConnectDisk
//
//  Created by Liu Ley on 12-10-25.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import "LEOServerInfo.h"
#import "SFHFKeychainUtils.h"

@implementation LEOServerInfo

@synthesize description=_description;
@synthesize userName=_userName;
@synthesize password=_password;
@synthesize url=_url;

-(id) initWithDictionary:(NSDictionary *)dic {
    self=[super init];
    if(self){
//        _description=nil;
//        _userName=nil;
//        _password=nil;
//        _url=nil;
        
//        if([dic valueForKey:@"description"])
            _description=[[NSString alloc] initWithFormat:@"%@",[dic valueForKey:@"description"]];
//        if([dic valueForKey:@"userName"])
            _userName=[[NSString alloc] initWithFormat:@"%@",[dic valueForKey:@"userName"]];
//        if([dic valueForKey:@"password"])
            _password=[[NSString alloc] initWithFormat:@"%@",[dic valueForKey:@"password"]];
//        if([dic valueForKey:@"url"])
            _url=[[NSString alloc] initWithFormat:@"%@",[dic valueForKey:@"url"]];
    }
    return self;
}

-(id)initWithInfo:(LEOServerInfo *)info
{
    self=[super init];
    if (self) {
        _description=[[NSString alloc] initWithFormat:@"%@",info.description];
        _userName=[[NSString alloc] initWithFormat:@"%@",info.userName];
        _password=[[NSString alloc] initWithFormat:@"%@",info.password];
        _url=[[NSString alloc] initWithFormat:@"%@",info.url];
    }
    return self;
}

-(BOOL)isEqual:(LEOServerInfo *)_one
{
    if (![_url isEqualToString:_one.url]) {
        return NO;
    }
    if (![_userName isEqualToString:_one.userName]) {
        return NO;
    }
    if (![_password isEqualToString:_one.password]) {
        return NO;
    }
    return YES;
}

-(id) modifyData:(NSDictionary *)dic {
    [_description release];
    [_userName release];
    [_password release];
    [_url release];
    
    _description=[[NSString alloc] initWithFormat:@"%@",[dic valueForKey:@"description"]];
    _userName=[[NSString alloc] initWithFormat:@"%@",[dic valueForKey:@"userName"]];
    _password=[[NSString alloc] initWithFormat:@"%@",[dic valueForKey:@"password"]];
    _url=[[NSString alloc] initWithFormat:@"%@",[dic valueForKey:@"url"]];
    
    return self;
}

-(void)dealloc {
    [_description release];
    [_userName release];
    [_password release];
    [_url release];
    [super dealloc];
}
@end
