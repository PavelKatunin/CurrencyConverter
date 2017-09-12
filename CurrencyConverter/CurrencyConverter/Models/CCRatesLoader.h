#import <Foundation/Foundation.h>
#import "CCRatesParser.h"

@interface CCRatesLoader : NSObject

- (instancetype)initWithUrlString:(NSString *)urlString
                           parser:(id <CCRatesParser>)ratesParser;

- (void)loadRatesSuccess:(void (^)(NSDictionary *ratesMap))success
                    fail:(void (^)(NSError *error))fail
             targetQueue:(dispatch_queue_t)queue;

@end
