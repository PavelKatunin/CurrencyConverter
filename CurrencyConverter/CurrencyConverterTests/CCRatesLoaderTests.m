#import <XCTest/XCTest.h>
#import "CCJSONRatesParser.h"
#import "CCLocalDataLoader.h"
#import "CCRatesLoader.h"

@interface CCRatesLoaderTests : XCTestCase

@end

@implementation CCRatesLoaderTests

- (void)testReachableLocalFileForDownload {
    
    NSString *filePath =
        [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"CorrectCurrenciesRates.json"];
    XCTAssertNotNil(filePath);
    
    CCJSONRatesParser *parser = [[CCJSONRatesParser alloc] init];
    CCLocalDataLoader *localDataLoader = [[CCLocalDataLoader alloc] initWithURLString:filePath];
    
    CCRatesLoader *ratesLoader = [[CCRatesLoader alloc] initWithDataLoader:localDataLoader
                                                                            parser:parser];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Rates Loader"];
    
    [ratesLoader loadRatesSuccess:^(NSDictionary *ratesMap) {
        XCTAssertNotNil(ratesMap);
        XCTAssertEqual(32, ratesMap.count);
        [expectation fulfill];
    } fail:^(NSError *error) {
        
    } targetQueue:dispatch_get_main_queue()];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        
        if(error)
        {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
        
    }];
}

- (void)testErrorCases {
    
    NSString *filePath =
    [[[NSBundle bundleForClass:[self class]] resourcePath] stringByAppendingPathComponent:@"000"];
    XCTAssertNotNil(filePath);
    
    CCJSONRatesParser *parser = [[CCJSONRatesParser alloc] init];
    CCLocalDataLoader *localDataLoader = [[CCLocalDataLoader alloc] initWithURLString:filePath];
    
    CCRatesLoader *ratesLoader = [[CCRatesLoader alloc] initWithDataLoader:localDataLoader
                                                                    parser:parser];
    
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Rates Loader"];
    
    [ratesLoader loadRatesSuccess:^(NSDictionary *ratesMap) {
        
    } fail:^(NSError *error) {
        XCTAssertNotNil(error);
        [expectation fulfill];
    } targetQueue:dispatch_get_main_queue()];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        
        if(error)
        {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
        
    }];
}

@end
