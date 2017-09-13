#import "CCRemoteDataLoader.h"

@interface CCRemoteDataLoader ()

@property(copy) NSURL *url;

@end

@implementation CCRemoteDataLoader

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
    
    [self loadDataFromRemoteSuccess:success
                               fail:fail
                        targetQueue:queue];
}

#pragma mark - Private methods

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
