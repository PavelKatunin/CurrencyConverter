#import <Foundation/Foundation.h>

@protocol CCRatesParser <NSObject>

// TODO: nullability
- (NSDictionary *)parseRatesMap:(NSData *)data error:(NSError **)error;

@end
