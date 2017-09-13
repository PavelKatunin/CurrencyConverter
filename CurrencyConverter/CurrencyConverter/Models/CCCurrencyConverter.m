#import "CCCurrencyConverter.h"
#import "NSString+Currency.h"

@implementation CCCurrencyConverter

#pragma mark - Properties

- (NSArray *)currencies {
    return [[self.currencyRatesMap allKeys]
            sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];
}

#pragma mark - Initialization

- (instancetype)initWithCurrencyRatesMap:(NSDictionary *)currencyRatesMap {
    self = [super init];
    if (self) {
        self.currencyRatesMap = currencyRatesMap;
    }
    return self;
}

#pragma mark - Public methods

- (double)convertAmount:(double)amount
           fromCurrency:(NSString *)fromCurrency
             toCurrency:(NSString *)toCurrency {
    
    double rateFromCurrency = [self rateForCurrency:fromCurrency];
    double rateToCurrency = [self rateForCurrency:toCurrency];
    
    return (amount / rateFromCurrency) * rateToCurrency;
}

- (double)rateBetweenCurrency:(NSString *)currency1
                  andCurrency:(NSString *)currency2 {
    return [self rateForCurrency:currency2] / [self rateForCurrency:currency1];
}

#pragma mark - Private methods

- (double)rateForCurrency:(NSString *)currency {
    return ((NSNumber *)self.currencyRatesMap[[currency normalizedCurrency]]).doubleValue;
}

@end
