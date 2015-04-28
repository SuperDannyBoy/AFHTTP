//
//  AFHTTP.m
//  网络请求
//
//  Created by SuperDanny on 14/12/8.
//  Copyright (c) 2014年 SuperDanny. All rights reserved.
//

#import "AFHTTP.h"
#import "SVProgressHUD.h"

#define KK_IMAGE_DATA @"data"
#define KK_IMAGE_TYPE @"type"
#define KK_UPLOAD_DATA_KEY @"key"

@interface AFHTTP ()

@property (readonly, nonatomic) AFHTTPRequestOperationManager *manager;
///存放请求信息字典（eg.@{@"AFNetWorking_UserInfoKey":@"http://1.gkgm.sinaapp.com/?s=/Home/Ypages/index"}）
@property (strong, nonatomic) NSDictionary *userInfoDic;

@end

@implementation AFHTTP

- (instancetype)init
{
    self = [super init];
    if (self) {
        _manager = [AFHTTPRequestOperationManager manager];
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/txt",@"text/html", nil];
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

#pragma mark - 检测网络状态
+ (BOOL)checkNetWorkStatus{
    
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
        if(status == AFNetworkReachabilityStatusNotReachable || status == AFNetworkReachabilityStatusUnknown){
            
            DLog(@"网络连接已断开，请检查您的网络！");
            
            return ;
        }
    }];
    if ([AFNetworkReachabilityManager sharedManager].isReachable) {
        return YES;
    }
    [SVProgressHUD showErrorWithStatus:@"当前网络不可用"];
    return NO;
}

#pragma mark - 为每一个请求添加用户信息（方便取消特定请求使用）
- (void)addUserInfo:(AFHTTPRequestOperation *)operation {
    //为每一个请求添加用户信息（方便取消特定请求使用）
    operation.userInfo = _userInfoDic;
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
    NSArray *operationArray = _manager.operationQueue.operations;
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
    [_manager.operationQueue cancelAllOperations];
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
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/txt",@"text/html", nil];
        _userInfoDic = [NSDictionary dictionaryWithDictionary:userInfo];
        if (isShow) {
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
        }
        switch (requestType) {
            case GET:
                [self get:[[self class] urlEncode:url] parameters:parameters SuccessBlock:(RequestSuccess)success FailureBlock:(RequestFailure)failure];
                break;
            case POST:
                [self post:[[self class] urlEncode:url] parameters:parameters SuccessBlock:(RequestSuccess)success FailureBlock:(RequestFailure)failure];
                break;
            case UPLOAD:
                [self upload:[[self class] urlEncode:url] parameters:parameters fileDictionary:dataDic SuccessBlock:(RequestSuccess)success FailureBlock:(RequestFailure)failure];
                break;
            case DOWNLOAD:
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
    operation = [_manager GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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
    operation = [_manager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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
    NSString *fileName = [NSString stringWithFormat:@"%@.%@", str, [dataDic objectForKey:KK_IMAGE_TYPE]];
    
    AFHTTPRequestOperation *operation = nil;
    operation = [_manager POST:url parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        /*
         此方法参数
         1. 要上传的[二进制数据]
         2. 上传文件字段（与后台约定好）
         3. 要保存在服务器上的[文件名]
         4. 上传文件的[mimeType]
         */
        [formData appendPartWithFileData:[dataDic objectForKey:KK_IMAGE_DATA] name:[dataDic objectForKey:KK_UPLOAD_DATA_KEY] fileName:fileName mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation,id responseObject) {
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"上传成功", nil)];
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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

- (void)download:(NSString *)url
      parameters:(NSDictionary *)parameters
    SuccessBlock:(RequestSuccess)success
    FailureBlock:(RequestFailure)failure {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:@"http://example.com/download.zip"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        NSLog(@"File downloaded to: %@", filePath);
    }];
    [downloadTask resume];
}

@end
