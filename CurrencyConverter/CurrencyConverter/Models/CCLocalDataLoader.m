#import "CCLocalDataLoader.h"

@interface CCLocalDataLoader ()

@property(copy) NSURL *url;

@end

@implementation CCLocalDataLoader

- (instancetype)initWithURLString:(NSString *)urlString {
    self = [super init];
    if (self) {
        self.url = [NSURL URLWithString:urlString];
    }
    return self;
}

- (void)loadDataSuccess:(void (^)(NSData *data))success
                   fail:(void (^)(NSError *error))fail
            targetQueue:(dispatch_queue_t)queue {
    
    NSData *data = [NSData dataWithContentsOfFile:[self.url absoluteString]];
    
    if (data) {
        dispatch_async(queue, ^{
            success(data);
        });
    }
    else {
        dispatch_async(queue, ^{
            NSError *error = [[NSError alloc] initWithDomain:@"NilData"
                                                        code:1
                                                    userInfo:@{}];
            fail(error);
        });
    }
}


@end
