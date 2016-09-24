//
//  AFHTTP.h
//  网络请求
//
//  Created by SuperDanny on 14/12/8.
//  Copyright (c) 2014年 SuperDanny ( http://SuperDanny.link/ ). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
/**
 *  上传文件字典
 */

#define KK_File_PATH       @"path"
#define KK_UPLOAD_DATA_KEY @"key"
#define AFHTTP_FileDic(a,b)       @{KK_File_PATH:a, KK_UPLOAD_DATA_KEY:b}


/**
 *  生成请求所带的userInfo
 */
#define UserInfoKey_AFNetWorking        @"AFNetWorking_UserInfoKey"
#define AFHTTP_UserInfo(a)              [NSDictionary dictionaryWithObjectsAndKeys:a,UserInfoKey_AFNetWorking,nil]

typedef NS_ENUM(NSUInteger, HTTPRequestType) {
    request_Get,
    request_Post,
    request_Upload,
    request_Download,
};

typedef void(^RequestSuccess)(id responseObject);
typedef void(^RequestFailure)(NSURLSessionDataTask *task, NSError *error);

@class AFHTTP;

@interface AFHTTP : NSObject

- (instancetype)init;
+ (AFHTTP *)shareInstanced;

///检测网络可达性
+ (BOOL)checkNetWorkStatus;

///開啟网络状态監聽
+ (void)openNetWorkStatus;

/**
 *  发送请求（POST/GET/UPLOAD/...）
 *
 *  @param url         baseURL
 *  @param parameters  参数
 *  @param dataDic     默认传nil; 如果是上传文件，则传包括文件路径在内的字典（eg:@{@"path":@"xxxxxxx", @"key":@"file"}）
 *  @param userInfo    要取消的请求信息（eg.@{@"AFNetWorking_UserInfoKey":@"xxxxx"}）
 *  @param requestType 请求类型
 *  @param isShow      是否显示网络提示框
 *  @param success     成功Block
 *  @param failure     失败Block
 */
- (void)sendRequest:(NSString *)url
         parameters:(NSDictionary *)parameters
     fileDictionary:(NSDictionary *)dataDic
           userInfo:(NSDictionary *)userInfo
           withType:(HTTPRequestType)requestType
          isShowHUD:(BOOL)isShow
       SuccessBlock:(RequestSuccess)success
       FailureBlock:(RequestFailure)failure;

/**
 *  取消特定请求
 *
 *  @param dic 要取消的请求信息（eg.@{@"AFNetWorking_UserInfoKey":@"xxxxx"}）
 */
- (void)cancelRequestWithUserInfo:(NSDictionary *)dic;

///取消所有请求
- (void)cancelAllRequest;

/**
 *  暂停下载
 *
 *  @param dic 要暂停下载的请求信息（eg.@{@"AFNetWorking_UserInfoKey":@"xxxxx"}）
 */
- (void)suspendWithDescription:(NSDictionary *)dic;

/**
 *  继续下载
 *
 *  @param dic 要继续下载的请求信息（eg.@{@"AFNetWorking_UserInfoKey":@"xxxxx"}）
 */
- (void)resumeWithDescription:(NSDictionary *)dic;

/**
 *  URL转码
 *
 *  @param url 转码前URL
 *
 *  @return 返回转码后URL
 */
+ (NSString *)urlEncode:(NSString *)url;

@end
