//
//  NSValue+YiXiang.m
//  Pods
//
//  Created by jiaguoshang on 2017/12/17.
//
//

#import "NSValue+YiXiang.h"

@implementation NSValue (YiXiang)

+ (NSValue *)YiXiang_valueWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSValue *value = [NSValue valueWithBytes:&coordinate objCType:@encode(CLLocationCoordinate2D)];
    return value;
}

@end
