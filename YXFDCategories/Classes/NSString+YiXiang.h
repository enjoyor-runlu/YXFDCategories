//
//  NSString+YiXiang.h
//  ArtEnjoymentRunLu
//
//  Created by jiaguoshang on 2017/11/29.
//  Copyright © 2016年 YiXiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (YiXiang)

- (NSString *)yixiang_md5hashString;

- (NSString *)yixiang_base64encode;

- (NSString *)yixiang_urlencode;

- (NSString *)yixiang_urldecode;

+ (NSString *)yixiang_UUID;

+ (NSString *)combineURLWithBaseURL:(NSString *)baseURL parameters:(NSDictionary *)parameters;

- (id)jsonObject;

- (id)jsonFragment;

@end
