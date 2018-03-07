//
//  NSMutableArray+YiXiang.m
//  Pods
//
//  Created by jiaguoshang on 2017/7/21.
//
//

#import "NSMutableArray+YiXiang.h"

@implementation NSMutableArray (YiXiang)


- (void)addSafeObject:(id)anObject
{
    if (anObject) {
        [self addObject:anObject];
    }
}

- (void)insertSafeObject:(id)anObject atIndex:(NSUInteger)index
{
    if (anObject) {
        [self insertObject:anObject atIndex:index];
    }
}

- (void)addObjectsFromSafeArray:(NSArray *)otherArray
{
    if (otherArray && otherArray.count > 0) {
        [self addObjectsFromArray:otherArray];
    }
}

- (void)removeSafeObjectAtIndex:(NSUInteger)index
{
    if ((self.count > 0) && (self.count > index))
    {
        [self removeObjectAtIndex:index];
    }
}

@end
