//
//  NSMutableArray+YiXiang.h
//  Pods
//
//  Created by luminary on 2017/7/21.
//
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (YiXiang)


- (void)addSafeObject:(id)object;

- (void)insertSafeObject:(id)anObject atIndex:(NSUInteger)index;

- (void)addObjectsFromSafeArray:(NSArray *)otherArray;


@end
