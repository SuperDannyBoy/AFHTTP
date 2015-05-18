#import <Foundation/Foundation.h>

@interface NSString (Dir)

/**
 *  返回缓存路径的完整路径名
 */
+ (NSString *)cacheDir;
/**
 *  返回文档路径的完整路径名
 */
+ (NSString *)documentDir;
/**
 *  返回临时路径的完整路径名
 */
+ (NSString *)tmpDir;

@end
