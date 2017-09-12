#import <XCTest/XCTest.h>
#import "CCJSONRatesParser.h"

@interface CCRatesParserTests : XCTestCase

@end

@implementation CCRatesParserTests

- (NSData *)dataFromLocalFile:(NSString *)fileName {
    NSString *filePath =
    [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:fileName];
    XCTAssertNotNil(filePath);
    
    return [NSData dataWithContentsOfFile:filePath];
}

- (void)testCorrectTravelsJSON {
    
    CCJSONRatesParser *parser = [[CCJSONRatesParser alloc] init];
    
    NSError *error = nil;
    NSDictionary *ratesMap = [parser parseRatesMap:[self dataFromLocalFile:@"CorrectCurrenciesRates.json"]
                                       error:&error];
    
    XCTAssertEqual(32, ratesMap.count);
    XCTAssertNil(error);
}

- (void)testIncorrectJSONFormat {
    
    CCJSONRatesParser *parser = [[CCJSONRatesParser alloc] init];
    
    NSError *error = nil;
    NSDictionary *ratesMap = [parser parseRatesMap:[self dataFromLocalFile:@"IncorrectJsonFormat.json"]
                                             error:&error];
    
    XCTAssertNotNil(error);
    XCTAssertNil(ratesMap);
}

- (void)testIncorrectAPIFormat {
    
    CCJSONRatesParser *parser = [[CCJSONRatesParser alloc] init];
    
    NSError *error = nil;
    NSDictionary *ratesMap = [parser parseRatesMap:[self dataFromLocalFile:@"incorrectAPIRates.json"]
                                             error:&error];
    
    XCTAssertNotNil(error);
    XCTAssertNil(ratesMap);
}

- (void)testParseNilValueAttempt {
    
    CCJSONRatesParser *parser = [[CCJSONRatesParser alloc] init];
    
    NSError *error = nil;
    NSDictionary *ratesMap = [parser parseRatesMap:nil
                                             error:&error];
    
    XCTAssertNotNil(error);
    XCTAssertNil(ratesMap);
}

@end
