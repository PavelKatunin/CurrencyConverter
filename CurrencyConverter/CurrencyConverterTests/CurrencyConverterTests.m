#import <XCTest/XCTest.h>
#import "CCCurrencyConverter.h"

@interface CurrencyConverterTests : XCTestCase

@end

@implementation CurrencyConverterTests

- (NSString *)pathForLocalFile:(NSString *)localFile {
    NSString *filePath =
    [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:localFile];
    XCTAssertNotNil(filePath);
    return filePath;
}

- (NSData *)dataFromLocalFile:(NSString *)fileName {
    NSString *filePath = [self pathForLocalFile:fileName];
    return [NSData dataWithContentsOfFile:filePath];
}

- (NSDictionary *)testRatesMap {
    return [NSDictionary dictionaryWithContentsOfFile:[self pathForLocalFile:@"TestCurrencyRatesMap.plist"]];
}

- (void)testConverteCurrency {
    CCCurrencyConverter *converter = [[CCCurrencyConverter alloc] initWithCurrencyRatesMap:[self testRatesMap]];
    
    double resultAmount = [converter convertAmount:10
                                      fromCurrency:@"eur"
                                        toCurrency:@"usd"];

    XCTAssertEqual(resultAmount, 11.997);
}

- (void)testUpperCaseConverting {
    CCCurrencyConverter *converter = [[CCCurrencyConverter alloc] initWithCurrencyRatesMap:[self testRatesMap]];
    
    double resultAmount = [converter convertAmount:10
                                      fromCurrency:@"EUR"
                                        toCurrency:@"USD"];
    
    XCTAssertEqual(resultAmount, 11.997);
}

- (void)testRatesBetweenCurrencies {
    CCCurrencyConverter *converter = [[CCCurrencyConverter alloc] initWithCurrencyRatesMap:[self testRatesMap]];
    
    double resultRate = [converter rateBetweenCurrency:@"eur" andCurrency:@"usd"];
    
    XCTAssertEqual(resultRate, 1.1997);
}

- (void)testUpperCaseRatesBetweenCurrencies {
    CCCurrencyConverter *converter = [[CCCurrencyConverter alloc] initWithCurrencyRatesMap:[self testRatesMap]];
    
    double resultRate = [converter rateBetweenCurrency:@"eur" andCurrency:@"USD"];
    
    XCTAssertEqual(resultRate, 1.1997);
}


- (void)testCurrenciesArray {
    CCCurrencyConverter *converter = [[CCCurrencyConverter alloc] initWithCurrencyRatesMap:[self testRatesMap]];
    
    NSArray *expectedArray = @[@"rub", @"usd", @"eur"];
    NSArray *currenciesArray = [converter currencies];
    
    [expectedArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       XCTAssertTrue([currenciesArray containsObject:obj]);
    }];
}

@end
