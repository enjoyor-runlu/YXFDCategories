//
//  NSMutableDictionary+YiXiang.m
//  Pods
//
//  Created by jiaguoshang on 2017/7/21.
//
//

#import "NSMutableDictionary+YiXiang.h"

@implementation NSMutableDictionary (YiXiang)


- (void)setSafeObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    if (anObject && aKey) {
        [self setObject:anObject forKey:aKey];
    }
}

@end
