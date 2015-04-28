AFHTTP
===================


感谢开源精神，感谢我姐OMI，感谢我的队友。不足之处望大家见谅，当然，你可以[Fork](https://github.com/boy736809040/AFHTTP/fork)一个分支来完善我的工程，我将无比的荣欣。

----------


方法说明
-------------
#### 发送一个请求

```objective-c
- (void)sendRequest:(NSString *)url
         parameters:(NSDictionary *)parameters
     fileDictionary:(NSDictionary *)dataDic
           userInfo:(NSDictionary *)userInfo
           withType:(NSUInteger)requestType
          isShowHUD:(BOOL)isShow
       SuccessBlock:(RequestSuccess)success
       FailureBlock:(RequestFailure)failure
```

> **参数说明:**

> - **@param url**
> baseURL
> - **@param parameters**
> 字典形式参数
> - **@param dataDic**
>  默认传nil; 如果是上传文件，则传包括二进制数据在内的字典eg.@{@"data":@"xxxxxxx", @"key":@"file", @"type":@"png"}
> - **@param userInfo** 
>  要取消的请求信息 eg.@{@"AFNetWorking_UserInfoKey":@"requestUrl"}
> - **@param requestType**
> 请求类型
> - **@param isShow**
> 是否显示网络提示框
> - **@param success**
> 成功Block
> - **@param failure**
> 失败Block


#### 取消特定请求

```objective-c
- (void)cancelRequestWithUserInfo:(NSDictionary *)dic
```

> **参数说明:**

> - **@param dic**
> 要取消的请求信息 eg.@{@"AFNetWorking_UserInfoKey":@"xxxxx"}


#### 取消所有请求

```objective-c
- (void)cancelAllRequest
```
