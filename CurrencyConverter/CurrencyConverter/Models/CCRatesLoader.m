#import "CCRatesLoader.h"
#import "CCDataLoader.h"
#import "CCJSONRatesParser.h"

@interface CCRatesLoader ()

@property(strong) CCDataLoader *dataLoader;
@property(strong) id <CCRatesParser> ratesParser;

@end

@implementation CCRatesLoader

#pragma mark - Initialization

- (instancetype)initWithUrlString:(NSString *)urlString
                           parser:(id <CCRatesParser>)ratesParser {
    self = [super init];
    
    if (self) {
        self.dataLoader = [[CCDataLoader alloc] initWithURLString:urlString];
        self.ratesParser = [[CCJSONRatesParser alloc] init];
    }
    
    return self;
}

#pragma mark - Public methods

- (void)loadRatesSuccess:(void (^)(NSDictionary *ratesMap))success
                    fail:(void (^)(NSError *error))fail
             targetQueue:(dispatch_queue_t)queue {
    [self.dataLoader loadDataSuccess:^(NSData *data) {
        NSError *parserError = nil;
        // TODO: handle error
        success([self.ratesParser parseRatesMap:data error:&parserError]);
        
    }
                                fail:fail
                         targetQueue:queue];
}

@end
