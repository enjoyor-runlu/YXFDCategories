//
//  UIDevice+YiXiang.h
//  ArtEnjoymentRunLu
//
//  Created by jiaguoshang on 2017/11/29.
//  Copyright © 2016年 YiXiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>


#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <ifaddrs.h>
#include <arpa/inet.h>


typedef NS_ENUM(NSInteger, DeviceNetworkStatus){
    DeviceNetworkStatusNotReachable = 1,
    DeviceNetworkStatusUnknown = 2,
    DeviceNetworkStatusWWAN2G = 3,
    DeviceNetworkStatusWWAN3G = 4,
    DeviceNetworkStatusWWAN4G = 5,
    DeviceNetworkStatusWiFi = 6,
};

@interface UIDevice (YiXiang)

//设备唯一标识符,取idfa,idfa取不到的时候使用时间戳加随机数
+ (NSString *)yixiang_uniqueID;

//判断设备是否越狱
+ (BOOL)isJailBreak;

//是否是模拟器
+ (BOOL)isSimulator;

//是否连接了VPN
+ (BOOL)isVPNConnected;

//版本号
+ (NSString *)yixiang_appVersion;

//build号
+ (NSString *)yixiang_buildVersion;

//完整版本号
+ (NSString *)yixiang_fullVersion;

//系统型号
+ (NSString *)yixiang_systemType;

//系统版本
+ (NSString *)yixiang_systemVersion;

//网络状态
+ (DeviceNetworkStatus)yixiang_networkSatus;

//运营商名称
+ (NSString *)yixiang_cellularProvider;

//ip地址
+ (NSString *)yixiang_ipAddress;

//分辨率
+ (CGSize)yixiang_screenPixelSize;

//可用内存
+ (CGFloat)yixiang_availableMemory;

//使用内存
+ (CGFloat)yixiang_usedMemory;

//cpu使用率
+ (CGFloat)yixiang_cpuUsage;

//wifi名称
+ (NSString *)yixiang_wifiName;

//系统语言
+ (NSString *)yixiang_language;

/**
 获取通讯录

 @return 格式为
 [
    {"key":["value"]},
    {"key":["value"]}
 ]
 */
+ (NSArray *)yixiang_addressBook;
/**
 获取系统电量
 
 @return 返回区间为0-1，如果没获取到，为-1
 */
+ (int)yixiang_batteryQuantity;

//存储uid----如果卸载会重新生成
+ (NSString *)yixiang_uid;

@end
