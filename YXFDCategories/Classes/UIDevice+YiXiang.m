//
//  UIDevice+YiXiang.m
//  ArtEnjoymentRunLu
//
//  Created by jiaguoshang on 2017/11/29.
//  Copyright © 2016年 YiXiang. All rights reserved.
//

#import "UIDevice+YiXiang.h"
#import <SAMKeychain/SAMKeychain.h>
#import <AdSupport/AdSupport.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreTelephony/CTCarrier.h>
#import <sys/sysctl.h>
#include <ifaddrs.h>
#import <sys/sockio.h>
#import <sys/ioctl.h>
#import <arpa/inet.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <mach/mach.h>
#import <AddressBook/AddressBook.h>

#import "NSString+YiXiang.h"
#import "NSMutableArray+YiXiang.h"
#import "NSMutableDictionary+YiXiang.h"

#define ARRAY_SIZE(a) sizeof(a)/sizeof(a[0])

const char* jailbreak_tool_pathes[] = {
    "/Applications/Cydia.app",
    "/Library/MobileSubstrate/MobileSubstrate.dylib",
    "/bin/bash",
    "/usr/sbin/sshd",
    "/etc/apt"
};

@implementation UIDevice (YiXiang)

+ (NSString *)YiXiang_uniqueID
{
    
    static NSString *kUXUniqueIDAccountName = @"com.YiXiang.idfa";
    static NSString *kUXUniqueIDServiceName = @"YiXiang_unique_key";
    
    static dispatch_once_t onceToken;
    static NSString * uniqueId = nil;
    dispatch_once(&onceToken, ^{
        
        uniqueId = [SAMKeychain passwordForService:kUXUniqueIDServiceName account:kUXUniqueIDAccountName];
        
        if (uniqueId.length == 0) {
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
                uniqueId = [self YiXiang_IDFA];
                if ([[uniqueId stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByReplacingOccurrencesOfString:@"0" withString:@""].length == 0) {//不存在说明用户关闭了广告跟踪
                    NSString *timeString = [NSString stringWithFormat:@"%.5f",[[NSDate date] timeIntervalSince1970]];
                    NSString *randomString = [NSString stringWithFormat:@"%d", arc4random() % 10000/*0-9999*/];
                    uniqueId = [[timeString stringByAppendingString:randomString] yixiang_md5hashString];
                }
            }
            [SAMKeychain setPassword:uniqueId forService:kUXUniqueIDServiceName account:kUXUniqueIDAccountName];
        }
        
    });
    
    return uniqueId;

}

+ (NSString *)getSystemLangauge {
    NSString *localeLanguageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    return localeLanguageCode;
}

+ (NSString *)getScreenResolution {
    CGFloat scale = [UIScreen mainScreen].scale;
    CGRect rect = [UIScreen mainScreen].bounds;
    CGFloat resolutionX = rect.size.width * scale;
    CGFloat resolutionY = rect.size.height * scale;
    return [NSString stringWithFormat:@"%.0f*%.0f",resolutionX,resolutionY];
}

+ (CGFloat)getBatteryQuantity {
    return [[UIDevice currentDevice] batteryLevel];
}
    
+ (NSString *)getConnectedWIFIName {
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
    
    NSDictionary *SSIDInfo;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = CFBridgingRelease(
                                     CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
        
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty) {
            break;
        }
    }
    NSString *SSID = SSIDInfo[@"SSID"];
    return SSID;
}

+ (NSString *)ipAddressWithIfaName:(NSString *)name {
    if (name.length == 0) return nil;
    NSString *address = nil;
    struct ifaddrs *addrs = NULL;
    if (getifaddrs(&addrs) == 0) {
        struct ifaddrs *addr = addrs;
        while (addr) {
            if ([[NSString stringWithUTF8String:addr->ifa_name] isEqualToString:name]) {
                sa_family_t family = addr->ifa_addr->sa_family;
                switch (family) {
                    case AF_INET: { // IPv4
                        char str[INET_ADDRSTRLEN] = {0};
                        inet_ntop(family, &(((struct sockaddr_in *)addr->ifa_addr)->sin_addr), str, sizeof(str));
                        if (strlen(str) > 0) {
                            address = [NSString stringWithUTF8String:str];
                        }
                    } break;
                        
                    case AF_INET6: { // IPv6
                        char str[INET6_ADDRSTRLEN] = {0};
                        inet_ntop(family, &(((struct sockaddr_in6 *)addr->ifa_addr)->sin6_addr), str, sizeof(str));
                        if (strlen(str) > 0) {
                            address = [NSString stringWithUTF8String:str];
                        }
                    }
                        
                    default: break;
                }
                if (address) break;
            }
            addr = addr->ifa_next;
        }
    }
    freeifaddrs(addrs);
    return address ? address : nil;
}

+ (NSString *)getIpAddressWIFI {
    return [self ipAddressWithIfaName:@"en0"];
}

+ (NSString *)getIpAddressCell {
    return [self ipAddressWithIfaName:@"pdp_ip0"];
}

+ (NSString *)YiXiang_IDFA
{
    NSString *idfa = nil;
    if (NSClassFromString(@"ASIdentifierManager")) {
        if ([ASIdentifierManager sharedManager].isAdvertisingTrackingEnabled) {
            idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        }
    }
    return idfa;
}

+ (BOOL)isJailBreak
{
    for (int i=0; i<ARRAY_SIZE(jailbreak_tool_pathes); i++) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:jailbreak_tool_pathes[i]]]) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isSimulator
{
    if ([[UIDevice currentDevice].name hasSuffix:@"Simulator"]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isVPNConnected
{
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            NSString *string = [NSString stringWithFormat:@"%s" , temp_addr->ifa_name];
            if ([string rangeOfString:@"tap"].location != NSNotFound ||
                [string rangeOfString:@"tun"].location != NSNotFound ||
                [string rangeOfString:@"ppp"].location != NSNotFound ||
                [string rangeOfString:@"ipsec"].location != NSNotFound ){
                return YES;
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    return NO; 

}

+ (NSString *)YiXiang_appVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString *)YiXiang_buildVersion
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
}

+ (NSString *)YiXiang_fullVersion
{
    return [NSString stringWithFormat:@"%@.%@", [self YiXiang_appVersion], [self YiXiang_buildVersion]];
}

+ (NSString *)YiXiang_systemType
{
    static NSString *deviceName = nil;
    if (!deviceName) {
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *name = malloc(size);
        sysctlbyname("hw.machine", name, &size, NULL, 0);
        deviceName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        free(name);
        deviceName = [self trunToGeneralName:deviceName];
    }
    return deviceName;
}

+ (NSString *)YiXiang_systemVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *)trunToGeneralName:(NSString *)name
{
    if ([name isEqualToString:@"iPhone1,1"])    return @"iPhone1G";
    if ([name isEqualToString:@"iPhone1,2"])    return @"iPhone3G";
    if ([name isEqualToString:@"iPhone2,1"])    return @"iPhone3GS";
    if ([name isEqualToString:@"iPhone3,1"])    return @"iPhone4";
    if ([name isEqualToString:@"iPhone3,2"])    return @"VerizoniPhone4";
    if ([name isEqualToString:@"iPhone4,1"])    return @"iPhone4S";
    if ([name isEqualToString:@"iPhone5,2"])    return @"iPhone5";
    if ([name isEqualToString:@"iPhone5,1"]||[name isEqualToString:@"iPhone5,2"])    return @"iPhone5";
    if ([name isEqualToString:@"iPhone5,3"]||[name isEqualToString:@"iPhone5,4"])    return @"iPhone5C";
    if ([name isEqualToString:@"iPhone6,1"])    return @"iPhone5S";
    if ([name isEqualToString:@"iPhone6,2"])    return @"iPhone5S";
    if ([name isEqualToString:@"iPhone7,1"])    return @"iPhone6Plus";
    if ([name isEqualToString:@"iPhone7,2"])    return @"iPhone6";
    if ([name isEqualToString:@"iPhone8,1"])    return @"iPhone6s";
    if ([name isEqualToString:@"iPhone8,4"])    return @"iPhoneSE";
    if ([name isEqualToString:@"iPhone8,2"])    return @"iPhone6sPlus";
    if ([name isEqualToString:@"iPhone8,4"])    return @"iPhoneSE";
    if ([name isEqualToString:@"iPhone9,1"])    return @"iPhone7";
    if ([name isEqualToString:@"iPhone9,3"])    return @"iPhone7";
    if ([name isEqualToString:@"iPhone9,2"])    return @"iPhone7PLus";
    if ([name isEqualToString:@"iPhone9,4"])    return @"iPhone7PLus";
    
    if ([name isEqualToString:@"i386"])         return @"Simulator";
    if ([name isEqualToString:@"x86_64"])       return @"Simulator";
    return name;
}

+ (DeviceNetworkStatus)YiXiang_networkSatus
{
    UIApplication *application = [UIApplication sharedApplication];
    NSArray *subViews = [[[application valueForKeyPath:@"statusBar"]
                                       valueForKeyPath:@"foregroundView"]
                                       subviews];
    NSInteger networkType = 0;
    DeviceNetworkStatus networkStatus;
    //获取到网络返回码
    for (UIView *view in subViews) {
        if ([view isKindOfClass:NSClassFromString(@"UIStatusBarDataNetworkItemView")]) {
            //获取到状态栏
            networkType = [[view valueForKeyPath:@"dataNetworkType"] integerValue];
            switch (networkType) {
                case 0:
                    networkStatus = DeviceNetworkStatusNotReachable;
                    break;
                case 1:
                    networkStatus = DeviceNetworkStatusWWAN2G;
                    break;
                case 2:
                    networkStatus = DeviceNetworkStatusWWAN3G;
                    break;
                case 3:
                    networkStatus = DeviceNetworkStatusWWAN4G;
                    break;
                case 5:
                    networkStatus = DeviceNetworkStatusWiFi;
                    break;
                default:
                    networkStatus = DeviceNetworkStatusUnknown;
                    break;
            }
        }
    }
    return networkStatus;
}



+ (NSString *)YiXiang_cellularProvider
{
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = info.subscriberCellularProvider;
    NSString *carrierName = [carrier carrierName];
    return carrierName ? : @"";

}

+ (NSString *)YiXiang_ipAddress
{
    NSString *address = nil;
    NSString *wifiAddress = nil;
    NSString *wwanAddress = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                // Check if interface is pdp_ip0 which is the wwan connection on the iPhone
                NSString *ifaName = [NSString stringWithUTF8String:temp_addr->ifa_name];
                if ([ifaName isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    wifiAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                } else if ([ifaName isEqualToString:@"pdp_ip0"]) {
                    // Get NSString from C String
                    wwanAddress = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
            
        }
    }
    if (wifiAddress) {
        address = wifiAddress;
    } else if (wwanAddress) {
        address = wwanAddress;
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address ? : @"";
}

+ (CGSize)YiXiang_screenPixelSize
{
    CGSize size = [[UIScreen mainScreen] bounds].size;
    size = CGSizeMake(size.width * [UIScreen mainScreen].scale, size.height * [UIScreen mainScreen].scale);
    return size;

}

+ (CGFloat)YiXiang_availableMemory
{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    
    return ((vm_page_size *vmStats.free_count) / 1024.0) / 1024.0;
}

+ (CGFloat)YiXiang_usedMemory
{
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    
    if (kernReturn != KERN_SUCCESS
        ) {
        return NSNotFound;
    }
    
    return taskInfo.resident_size;
}

+ (CGFloat)YiXiang_cpuUsage
{
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
    stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    CGFloat tot_cpu = 0.f;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->user_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

//wifi名称
+ (NSString *)YiXiang_wifiName
{
    NSString *wifiName = nil;
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    if (!wifiInterfaces) {
        return nil;
    }
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            CFRelease(dictRef);
        }
    }
    CFRelease(wifiInterfaces);
    return wifiName;
}

//系统语言
+ (NSString *)YiXiang_language
{
    NSArray *appLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    return [appLanguages objectAtIndex:0];
}

//通讯录
+ (void)YiXiang_addressBookWithBlock:(void (^)(NSArray *phoneBook))block
{
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    if (status == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            //3.1 判断是否出错
            if (error) {
                CFRelease(addressBook);
                return;
            }
            //3.2 判断是否授权
            if (granted) {
                if (block) {
                    block([UIDevice YiXiang_addressBook]);
                }
                CFRelease(addressBook);
            } else {
                CFRelease(addressBook);
            }
        });
    } else if(status == kABAuthorizationStatusAuthorized) {
        if (block) {
            block([UIDevice YiXiang_addressBook]);
        }
    }
}

+ (NSArray *)YiXiang_addressBook {
    NSMutableArray *phoneBook = [NSMutableArray array];
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    if(status == kABAuthorizationStatusAuthorized) {
        //2. 创建通讯录
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        //3. 获取所有联系人
        CFArrayRef peosons = ABAddressBookCopyArrayOfAllPeople(addressBook);
        //4. 遍历所有联系人来获取数据(姓名和电话)
        CFIndex count = CFArrayGetCount(peosons);
        for (CFIndex i = 0 ; i < count; i++) {
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            //5. 获取单个联系人
            ABRecordRef person = CFArrayGetValueAtIndex(peosons, i);
            //6. 获取姓名
            NSString *lastName = CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty))?:@"";
            NSString *firstName  = CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty))?:@"";
            NSString *key = [NSString stringWithFormat:@"%@%@",lastName, firstName];
            //7. 获取电话
            ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
            //7.1 获取电话的count数
            CFIndex phoneCount = ABMultiValueGetCount(phones);
            NSMutableArray *valueArray = [[NSMutableArray alloc] init];
            //7.2 遍历所有电话号码
            for (CFIndex i = 0; i < phoneCount; i++) {
                NSString *label = CFBridgingRelease(ABMultiValueCopyLabelAtIndex(phones, i));
                NSString *value = CFBridgingRelease(ABMultiValueCopyValueAtIndex(phones, i));
                [valueArray addSafeObject:value];
            }
            [dic setSafeObject:valueArray forKey:key];
            [phoneBook addSafeObject:dic];
            //8.1 释放 CF 对象
            CFRelease(phones);
        }
        //8.1 释放 CF 对象
        CFRelease(peosons);
        CFRelease(addressBook);
    }
    return phoneBook;
}

+ (int)YiXiang_batteryQuantity {
    
    UIApplication *application = [UIApplication sharedApplication];
    if (application.applicationState == UIApplicationStateActive|| application.applicationState==UIApplicationStateInactive) {
        Ivar ivar = class_getInstanceVariable([application class],"_statusBar");
        id status = object_getIvar(application, ivar);
        for (id aview in [status subviews]) {
            int batteryLevel = 0;
            for (id bview in [aview subviews]) {
                if ([NSStringFromClass([bview class]) caseInsensitiveCompare:@"UIStatusBarBatteryItemView"] == NSOrderedSame &&[[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
                    Ivar ivar = class_getInstanceVariable([bview class],"_capacity");
                    if(ivar) {
                        batteryLevel = ((int (*)(id, Ivar))object_getIvar)(bview, ivar);
                        if (batteryLevel > 0 && batteryLevel <= 100) {
                            return batteryLevel;
                        } else {
                            return 0;
                        }
                    }
                }
            }
        }
    }
    return 0;
}

+ (NSString *)YiXiang_uid
{
    static NSString *kUIDAccountName = @"com.YiXiang.install.uid";
    NSString *uniqueId = [[NSUserDefaults standardUserDefaults] objectForKey:kUIDAccountName];
    if (!uniqueId || uniqueId.length < 1) {
        NSString *timeString = [NSString stringWithFormat:@"%.5f",[[NSDate date] timeIntervalSince1970]];
        NSString *randomString = [NSString stringWithFormat:@"%d", arc4random() % 10000/*0-9999*/];
        uniqueId = [[timeString stringByAppendingString:randomString] yixiang_md5hashString];
        [[NSUserDefaults standardUserDefaults] setObject:uniqueId forKey:kUIDAccountName];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return uniqueId;
}


@end
