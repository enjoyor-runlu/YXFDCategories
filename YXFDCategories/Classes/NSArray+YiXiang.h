//
//  NSArray+YiXiang.h
//  Pods
//
//  Created by jiaguoshang on 2017/7/21.
//
//

#import <Foundation/Foundation.h>

@interface NSArray (YiXiang)

- (id)objectAtSafeIndex:(NSUInteger)index;

- (NSString*)jsonString;

@end
