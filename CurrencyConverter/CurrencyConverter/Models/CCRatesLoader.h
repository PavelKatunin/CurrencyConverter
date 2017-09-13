#import <Foundation/Foundation.h>
#import "CCRatesParser.h"
#import "CCDataLoader.h"

@interface CCRatesLoader : NSObject

- (instancetype)initWithDataLoader:(id <CCDataLoader>)dataLoader
                            parser:(id <CCRatesParser>)ratesParser;

- (void)loadRatesSuccess:(void (^)(NSDictionary *ratesMap))success
                    fail:(void (^)(NSError *error))fail
             targetQueue:(dispatch_queue_t)queue;

@end
