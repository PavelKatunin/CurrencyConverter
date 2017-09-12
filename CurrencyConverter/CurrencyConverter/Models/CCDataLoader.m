#import "CCDataLoader.h"

@interface CCDataLoader ()

@property(copy) NSURL *url;

@end

@implementation CCDataLoader

#pragma mark - Initialization

- (instancetype)initWithURLString:(NSString *)urlString {
    self = [super init];
    if (self) {
        self.url = [NSURL URLWithString:urlString];
    }
    return self;
}

#pragma mark - Public methods

- (void)loadDataSuccess:(void (^)(NSData *data))success
                   fail:(void (^)(NSError *error))fail
            targetQueue:(dispatch_queue_t)queue {
    
    if ([self.url isFileURL]) {
        [self loadDataFromLocalSuccess:success
                                  fail:fail
                           targetQueue:queue];
    }
    else {
        [self loadDataFromRemoteSuccess:success
                                   fail:fail
                            targetQueue:queue];
    }
}

#pragma mark - Private methods

- (void)loadDataFromLocalSuccess:(void (^)(NSData *data))success
                            fail:(void (^)(NSError *error))fail
                     targetQueue:(dispatch_queue_t)queue{
    
    NSString * strNoURLScheme =
        [self.url.absoluteString stringByReplacingOccurrencesOfString:[self.url scheme] withString:@""];
    NSData *data = [NSData dataWithContentsOfFile:strNoURLScheme];
    
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

- (void)loadDataFromRemoteSuccess:(void (^)(NSData *data))success
                            fail:(void (^)(NSError *error))fail
                     targetQueue:(dispatch_queue_t)queue{
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:self.url
                                          completionHandler:^(NSData *data,
                                                              NSURLResponse *response,
                                                              NSError *error) {
                                              if (error) {
                                                  dispatch_async(queue, ^{
                                                      fail(error);
                                                  });
                                              }
                                              else {
                                                  dispatch_async(queue, ^{
                                                      success(data);
                                                  });
                                              }
                                              
                                          }];
    [downloadTask resume];
}

@end
