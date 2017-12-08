//
//  NSDictionary+YiXiang.m
//  Pods
//
//  Created by jiaguoshang on 2017/7/21.
//
//

#import "NSDictionary+YiXiang.h"

@implementation NSDictionary (YiXiang)

- (id)safeObjectForKey:(NSString *)aKey
{
    if (![self containKey:aKey]) {
        return nil;
    }
    return [self objectForKey:aKey];
}

- (NSString *)jsonString
{
    NSError* error = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if (error) {
        return nil;
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (BOOL)containKey:(NSString *)key
{
    return [[self allKeys] containsObject:key];
}

- (NSDictionary *)deepCopy
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

@end
