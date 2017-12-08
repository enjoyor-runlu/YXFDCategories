//
//  NSDictionary+YiXiang.h
//  Pods
//
//  Created by jiaguoshang on 2017/7/21.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (YiXiang)


- (id)safeObjectForKey:(NSString *)aKey;

- (NSString *)jsonString;

- (BOOL)containKey:(NSString *)key;

- (NSDictionary *)deepCopy;

@end
