#import <XCTest/XCTest.h>
#import "NSString+Currency.h"

@interface CCCurrencyStringTests : XCTestCase

@end

@implementation CCCurrencyStringTests

- (void)testCurrencyNormalization {
    XCTAssertEqualObjects([@"USD" normalizedCurrency], @"usd");
    XCTAssertEqualObjects([@"EuR" normalizedCurrency], @"eur");
    XCTAssertEqualObjects([@" GbP " normalizedCurrency], @"gbp");
}

@end
