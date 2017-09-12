#import <Foundation/Foundation.h>

@interface CCCurrencyConverter : NSObject

@property(nonatomic, copy) NSDictionary<NSString *, NSNumber *> *currencyRatesMap;
@property(nonatomic, readonly) NSArray *currencies;

- (instancetype)initWithCurrencyRatesMap:(NSDictionary *)currencyRatesMap;

- (double)convertAmount:(double)amount
           fromCurrency:(NSString *)fromCurrency
             toCurrency:(NSString *)toCurrency;

- (double)rateBetweenCurrency:(NSString *)currency1
                  andCurrency:(NSString *)currency2;

@end
