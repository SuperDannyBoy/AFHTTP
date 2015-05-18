#import "NSString+Dir.h"

@implementation NSString (Dir)

+ (NSString *)cacheDir {
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    return [dir stringByAppendingPathComponent:[[[self alloc] init] lastPathComponent]];
}

+ (NSString *)documentDir {
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [dir stringByAppendingPathComponent:[[[self alloc] init] lastPathComponent]];
}

+ (NSString *)tmpDir {
    NSString *dir = NSTemporaryDirectory();
    return [dir stringByAppendingPathComponent:[[[self alloc] init] lastPathComponent]];
}

@end
