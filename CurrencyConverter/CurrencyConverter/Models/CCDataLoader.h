#import <Foundation/Foundation.h>

@protocol CCDataLoader <NSObject>

- (instancetype)initWithURLString:(NSString *)urlString;

- (void)loadDataSuccess:(void (^)(NSData *data))success
                   fail:(void (^)(NSError *error))fail
            targetQueue:(dispatch_queue_t)queue;

@end
