#import "NSString+Currency.h"

@implementation NSString (Currency)

- (NSString *)normalizedCurrency {
    return [self.lowercaseString stringByReplacingOccurrencesOfString:@" " withString:@""];
}

@end
