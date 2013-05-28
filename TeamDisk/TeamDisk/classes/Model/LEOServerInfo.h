//
//  LEOServerInfo.h
//  ConnectDisk
//
//  Created by Liu Ley on 12-10-25.
//  Copyright (c) 2012年 SAE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LEOServerInfo : NSObject {
    NSString *_description;
    NSString *_userName;
    NSString *_password;
    NSString *_url;
}
@property(nonatomic,readonly) NSString *description;
@property(nonatomic,readonly) NSString *userName;
@property(nonatomic,readonly) NSString *password;
@property(nonatomic,readonly) NSString *url;

-(id) initWithDictionary:(NSDictionary *)dic;
-(id) modifyData:(NSDictionary *)dic;
-(id)initWithInfo:(LEOServerInfo *)info;
-(BOOL)isEqual:(LEOServerInfo *)_one;
@end
