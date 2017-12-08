//
//  NSString+YiXiang.m
//  ArtEnjoymentRunLu
//
//  Created by jiaguoshang on 2017/11/29.
//  Copyright © 2016年 YiXiang. All rights reserved.
//

#import "NSString+YiXiang.h"
#import <sys/xattr.h>
#import <CommonCrypto/CommonDigest.h>

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

@implementation NSString (YiXiang)

- (NSString *)yixiang_urldecode
{
    return[self stringByRemovingPercentEncoding];
}

- (NSString *)yixiang_urlencode
{
    NSString *charactersToEscape = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
    NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
    NSString *encodedUrl = [self stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
    return encodedUrl;
}

- (NSString *)yixiang_base64encode
{
    if ([self length] == 0)
        return @"";
    
    const char *source = [self UTF8String];
    long strlength  = strlen(source);
    
    char *characters = malloc(((strlength + 2) / 3) * 4);
    if (characters == NULL)
        return nil;
    
    NSUInteger length = 0;
    NSUInteger i = 0;
    
    while (i < strlength) {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < strlength)
            buffer[bufferLength++] = source[i++];
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = encodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';
    }
    
    return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

- (NSString *)yixiang_md5hashString
{
    // Create pointer to the string as UTF8
    const char* ptr = [self UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, (int)strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x",md5Buffer[i]];
    }
    
    return output;
}

+ (NSString *)yixiang_UUID
{
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return uuidString;
}


+ (NSString *)combineURLWithBaseURL:(NSString *)baseURL parameters:(NSDictionary *)parameters
{
    NSMutableString *combinedURL = [[NSMutableString alloc] initWithString:@""];
    if (baseURL) {
        combinedURL = [baseURL mutableCopy];
        
        if (parameters.count > 0) {
            
            NSMutableString *queryString = [[NSMutableString alloc] init];
            
            NSArray *sortedKeys =[parameters.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
                return [obj1 compare:obj2];
            }];
            
            
            NSUInteger questionMarkLocation = [combinedURL rangeOfString:@"?"].location;
            if (questionMarkLocation != NSNotFound) {
                [queryString appendString:@"&"];
            }
            else
            {
                [queryString appendString:@"?"];
            }
            
            for (id key in sortedKeys) {
                [queryString appendFormat:@"%@=%@&", [key description], [[parameters[key] description] yixiang_urlencode]];
            }
            
            if ([queryString hasSuffix:@"&"]) {
                [queryString deleteCharactersInRange:NSMakeRange(queryString.length - 1, 1)];
            }
            
            //处理前端 URL 中的 hash
            NSInteger insertPosition = [combinedURL rangeOfString:@"#"].location;
            if (insertPosition == NSNotFound) {
                insertPosition = combinedURL.length;
            }
            else {
                // 存在问号，并且问号在 hash 之后时，直接把 URL 拼到最后
                if (questionMarkLocation != NSNotFound && questionMarkLocation > insertPosition) {
                    insertPosition = combinedURL.length;
                }
            }
            
            [combinedURL insertString:queryString atIndex:insertPosition];
        }
    }
    return combinedURL;
    
}



- (id)jsonObject
{
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding]
                                                options:NSJSONReadingMutableContainers
                                                  error:&error];
    
    return object;
}

- (id)jsonFragment
{
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding]
                                                options:NSJSONReadingAllowFragments
                                                  error:&error];
    return object;
}


@end
