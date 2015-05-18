//
//  AFHTTP.m
//  网络请求
//
//  Created by SuperDanny on 14/12/8.
//  Copyright (c) 2014年 SuperDanny. All rights reserved.
//

#import "AFHTTP.h"
#import "SVProgressHUD.h"
#import "NSString+Dir.h"

#import <SystemConfiguration/SCNetworkReachability.h>
#import <netdb.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>


@interface AFHTTP ()

@property (readonly, nonatomic) AFHTTPRequestOperationManager *operationManager;
@property (readonly, nonatomic) AFURLSessionManager           *sessionManager;
///存放请求信息字典（eg.@{@"AFNetWorking_UserInfoKey":@"xxxxxx"}）
@property (strong, nonatomic) NSDictionary   *userInfoDic;
@property (strong, nonatomic) NSMutableArray *downloadTaskArr;

@end

@implementation AFHTTP

- (instancetype)init
{
    self = [super init];
    if (self) {
        _operationManager = [AFHTTPRequestOperationManager manager];
        _operationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/txt",@"text/html", nil];
        //
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    }
    return self;
}

+ (AFHTTP *)shareInstanced {
    static AFHTTP *http = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        http = [[AFHTTP alloc] init];
    });
    return http;
}

#pragma mark - 检测网络状态可達性
+ (BOOL)checkNetWorkStatus {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    //    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        return NO;
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    
    return (isReachable && !needsConnection) ? YES : NO;
}

#pragma mark - 開啟网络状态監聽
+ (void)openNetWorkStatus{
    
    /**
     *  AFNetworkReachabilityStatusUnknown          = -1,  // 未知
     *  AFNetworkReachabilityStatusNotReachable     = 0,   // 无连接
     *  AFNetworkReachabilityStatusReachableViaWWAN = 1,   // 3G
     *  AFNetworkReachabilityStatusReachableViaWiFi = 2,   // 局域网络Wifi
     */
    
    // 如果要检测网络状态的变化, 必须要用检测管理器的单例startMoitoring
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    // 检测网络连接的单例,网络变化时的回调方法
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        /*
        if(status == AFNetworkReachabilityStatusNotReachable || status == AFNetworkReachabilityStatusUnknown){
            
            DLog(@"网络连接已断开，请检查您的网络！");
            
            return ;
        }
         */
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:{
                DLog(@"网络不通");
                [SVProgressHUD showErrorWithStatus:@"当前网络不可用"];
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi:{
                DLog(@"网络通过WIFI连接");
                break;
            }
                
            case AFNetworkReachabilityStatusReachableViaWWAN:{
                DLog(@"网络通过流量连接");
                //可以在這裡發出一個通知，提示用戶注意流量使用之類的話
                break;
            }
            default:
                break;
        }
    }];
}

#pragma mark - 为每一个请求添加用户信息（方便取消特定请求使用）
- (void)addUserInfo:(AFHTTPRequestOperation *)operation {
    //为每一个请求添加用户信息（方便取消特定请求使用）
    operation.userInfo = _userInfoDic;
}

- (void)addDownloadDescription:(NSURLSessionDownloadTask *)task {
    task.taskDescription = _userInfoDic[UserInfoKey_AFNetWorking];
}

#pragma mark - URL转码
/**
 *  URL转码
 *
 *  @param url 转码前URL *
 *  @return 返回转码后URL
 */
+ (NSString *)urlEncode:(NSString *)url {
    return [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - 识别图片格式
/**
 *  识别图片格式
 *
 *  @param image 图片
 *
 *  @return 图片的格式（@"png"/@"jpg"/...）
 */
+ (NSString *)imageType:(UIImage *)image {
    NSString *type = @"jpg";
    DLog(@"----->%@",UIImagePNGRepresentation(image));
    NSData *imageData = UIImagePNGRepresentation(image);
    // 文件头数据
    Byte pngHead[] = {0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a};
    if (imageData) {
        // 判断是否为png格式
        int cmpResult = memcmp(imageData.bytes, pngHead, 8);
        if (cmpResult == 0) {
            type = @"png";
        }
    }
    return type;
}

#pragma mark - ------------------------------------------------Request-----------------------------------------------
#pragma mark 取消特定请求
- (void)cancelRequestWithUserInfo:(NSDictionary *)dic {
    DLog(@"cancel operation dic == %@",dic);
    //队列里的所有操作
    NSArray *operationArray = _operationManager.operationQueue.operations;
    [operationArray enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop){
        
        AFHTTPRequestOperation *operation = (AFHTTPRequestOperation *)object;
        DLog(@"队列里的所有操作:%@",operation.userInfo);
        //判断对应的operation是否存在
        if ([operation.userInfo isEqualToDictionary:dic]) {
            DLog(@"cancel operation");
            [operation cancel];
        }
    }];
}

#pragma mark 取消所有请求
- (void)cancelAllRequest {
    [_operationManager.operationQueue cancelAllOperations];
}

#pragma mark 发送请求
- (void)sendRequest:(NSString *)url
         parameters:(NSDictionary *)parameters
     fileDictionary:(NSDictionary *)dataDic
           userInfo:(NSDictionary *)userInfo
           withType:(NSUInteger)requestType
          isShowHUD:(BOOL)isShow
       SuccessBlock:(RequestSuccess)success
       FailureBlock:(RequestFailure)failure {
    //判断网络状态
    if ([AFHTTP checkNetWorkStatus]) {
        _operationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/txt",@"text/html", nil];
        _userInfoDic = [NSDictionary dictionaryWithDictionary:userInfo];
        if (isShow) {
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
        }
        switch (requestType) {
            case request_Get:
                [self get:[[self class] urlEncode:url] parameters:parameters SuccessBlock:(RequestSuccess)success FailureBlock:(RequestFailure)failure];
                break;
            case request_Post:
                [self post:[[self class] urlEncode:url] parameters:parameters SuccessBlock:(RequestSuccess)success FailureBlock:(RequestFailure)failure];
                break;
            case request_Upload:
                [self upload:[[self class] urlEncode:url] parameters:parameters fileDictionary:dataDic SuccessBlock:(RequestSuccess)success FailureBlock:(RequestFailure)failure];
                break;
            case request_Download:
                [self download:[[self class] urlEncode:url] parameters:parameters SuccessBlock:(RequestSuccess)success FailureBlock:(RequestFailure)failure];
                break;
            default:
                break;
        }
    }
}

- (void)get:(NSString *)url
 parameters:(NSDictionary *)parameters
SuccessBlock:(RequestSuccess)success
FailureBlock:(RequestFailure)failure {
    AFHTTPRequestOperation *operation = nil;
    operation = [_operationManager GET:url
                   parameters:parameters
                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                          [SVProgressHUD dismiss];
                          if (success) {
                              success(responseObject);
                          }
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                          //请求被取消时不弹窗提示
                          if (!operation.cancelled) {
                              [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                              if (failure) {
                                  failure(operation, error);
                              }
                          }
                      }];
    [self addUserInfo:operation];
}

- (void)post:(NSString *)url
  parameters:(NSDictionary *)parameters
SuccessBlock:(RequestSuccess)success
FailureBlock:(RequestFailure)failure {
    AFHTTPRequestOperation *operation = nil;
    operation = [_operationManager POST:url
                    parameters:parameters
                       success:^(AFHTTPRequestOperation *operation, id responseObject) {
                           [SVProgressHUD dismiss];
                           if (success) {
                               success(responseObject);
                           }
                       }
                       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                           //请求被取消时不弹窗提示
                           if (!operation.cancelled) {
                               [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                               if (failure) {
                                   failure(operation, error);
                               }
                           }
                       }];
    [self addUserInfo:operation];
}

- (void)upload:(NSString *)url
    parameters:(NSDictionary *)parameters
fileDictionary:(NSDictionary *)dataDic
  SuccessBlock:(RequestSuccess)success
  FailureBlock:(RequestFailure)failure {
    
    // 可以在上传时使用当前的系统时间作为文件名
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置时间格式
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@", str];
    
    AFHTTPRequestOperation *operation = nil;
    operation = [_operationManager POST:url
                             parameters:parameters
              constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                  /*
                   此方法参数
                   1. 要上传的[二进制数据]
                   2. 上传文件字段（与后台约定好）
                   3. 要保存在服务器上的[文件名]
                   4. 上传文件的[mimeType]（不同的文件mimeType不同，詳情見http://www.iana.org/assignments/media-types/media-types.xhtml）
                   */
                  
                  //获取文件类型
                  NSMutableString *filePath = [NSMutableString stringWithString:[dataDic objectForKey:KK_File_PATH]];
                  CFStringRef UTI           = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[filePath pathExtension], NULL);
                  CFStringRef MIMEType      = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
                  
                  [formData appendPartWithFileData:[NSData dataWithContentsOfFile:filePath]
                                              name:[dataDic objectForKey:KK_UPLOAD_DATA_KEY]
                                          fileName:fileName
                                          mimeType:(__bridge NSString *)(MIMEType)];
              }
                                success:^(AFHTTPRequestOperation *operation,id responseObject) {
                                    [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"上传成功", nil)];
                                    if (success) {
                                        success(responseObject);
                                    }
                                }
                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    //请求被取消时不弹窗提示
                                    if (!operation.cancelled) {
                                        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
                                        if (failure) {
                                            failure(operation, error);
                                        }
                                    }
                                }];
    [self addUserInfo:operation];
    
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        DLog(@"Wrote %f", (CGFloat)totalBytesWritten/totalBytesExpectedToWrite);
        CGFloat progress = (CGFloat)totalBytesWritten/totalBytesExpectedToWrite;
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showProgress:progress maskType:SVProgressHUDMaskTypeBlack];
        });
        
    }];
    
//    [operation start];
    
}

- (void)download:(NSString *)url
      parameters:(NSDictionary *)parameters
    SuccessBlock:(RequestSuccess)success
    FailureBlock:(RequestFailure)failure {
    
    [_sessionManager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        DLog(@"Wrote %f", (CGFloat)totalBytesWritten/totalBytesExpectedToWrite);
        CGFloat progress = (CGFloat)totalBytesWritten/totalBytesExpectedToWrite;
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showProgress:progress maskType:SVProgressHUDMaskTypeNone];
        });
    }];
    
    //创建子文件夹
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *downloadPath     = [NSString stringWithFormat:@"%@/Download", [NSString documentDir]];
    if(![fileManager fileExistsAtPath:downloadPath]){//如果不存在,则说明是第一次运行这个程序，那么建立这个文件夹
        DLog(@"first run");
        NSError *error;
        [fileManager createDirectoryAtPath:downloadPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            DLog(@"%@",error.localizedDescription);
        }
        DLog(@"%@",downloadPath);
    }
    
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [_sessionManager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
//        NSURL *documentsDirectoryURL = [NSURL URLWithString:downloadPath];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        //此处已经在主线程了
        DLog(@"File downloaded to: %@", filePath);
        if (error) {
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
            if (failure) {
                failure(nil, error);
            }
        }
        else {
            [SVProgressHUD showSuccessWithStatus:@"下载完成"];
            if (success) {
                success(response);
            }
        }
    }];
    
    [self addDownloadDescription:downloadTask];
    
    [downloadTask resume];
}

#pragma mark - 暂停下载
- (void)suspendWithDescription:(NSDictionary *)dic {
    DLog(@"suspend task dic == %@",dic);
    //队列里的所有操作
    NSArray *taskArray = _sessionManager.downloadTasks;
    [taskArray enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop){
        
        NSURLSessionDownloadTask *task = (NSURLSessionDownloadTask *)object;
        DLog(@"队列里的所有操作:%@",task.taskDescription);
        //判断对应的task是否存在
        if ([task.taskDescription isEqualToString:dic[UserInfoKey_AFNetWorking]]) {
            DLog(@"suspend task");
            [task suspend];
        }
    }];
}

#pragma mark - 开始下载
- (void)resumeWithDescription:(NSDictionary *)dic {
    DLog(@"resume task dic == %@",dic);
    //队列里的所有操作
    NSArray *taskArray = _sessionManager.downloadTasks;
    [taskArray enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop){
        
        NSURLSessionDownloadTask *task = (NSURLSessionDownloadTask *)object;
        DLog(@"队列里的所有操作:%@",task.taskDescription);
        //判断对应的task是否存在
        if ([task.taskDescription isEqualToString:dic[UserInfoKey_AFNetWorking]]) {
            DLog(@"resume task");
            [task resume];
        }
    }];
}

@end
