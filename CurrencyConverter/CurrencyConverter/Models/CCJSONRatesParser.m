#import "CCJSONRatesParser.h"
#import "NSString+Currency.h"

@implementation CCJSONRatesParser

- (NSDictionary *)parseRatesMap:(NSData *)data error:(NSError **)errorPointer {
    
    NSError *error = nil;
    
    __block NSMutableDictionary *ratesMap = nil;
    
    if (!data) {
        // TODO: implement correct error
        *errorPointer = [[NSError alloc] initWithDomain:@"NilData"
                                                   code:1
                                               userInfo:@{}];
    }
    else {
        
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if (error != nil) {
            *errorPointer = error;
        }
        else {
            ratesMap = [[NSMutableDictionary alloc] init];
            
            ratesMap[[jsonDict[@"base"] normalizedCurrency]] = @(1);
            
            NSDictionary *rates = jsonDict[@"rates"];
            
            [rates enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                ratesMap[[key normalizedCurrency]] = obj;
            }];
        }
    }
    
    return ratesMap;
}

@end
