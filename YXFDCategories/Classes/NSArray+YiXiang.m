//
//  NSArray+YiXiang.m
//  Pods
//
//  Created by jiaguoshang on 2017/7/21.
//
//

#import "NSArray+YiXiang.h"

@implementation NSArray (YiXiang)


- (id)objectAtSafeIndex:(NSUInteger)index
{
    if (index >= self.count) {
        return nil;
    }
    return [self objectAtIndex:index];
}

- (NSString *)jsonString
{
    NSError* error = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:0
                                                         error:&error];
    
    if (error) {
        return nil;
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
