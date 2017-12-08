//
//  NSMutableDictionary+YiXiang.h
//  Pods
//
//  Created by jiaguoshang on 2017/7/21.
//
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (YiXiang)

- (void)setSafeObject:(id)anObject forKey:(id<NSCopying>)aKey;

@end
