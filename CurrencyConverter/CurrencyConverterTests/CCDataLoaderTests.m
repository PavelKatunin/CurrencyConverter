#import <XCTest/XCTest.h>
#import "CCDataLoader.h"

@interface CCDataLoaderTests : XCTestCase

@end

@implementation CCDataLoaderTests

- (void)testLoadingDataFromLocalFile {
    
    NSString *filePath =
        [[[NSBundle bundleForClass:[self class]] resourcePath]
         stringByAppendingPathComponent:@"CorrectCurrenciesRates.json"];
    XCTAssertNotNil(filePath);
    
    CCDataLoader *dataLoader = [[CCDataLoader alloc] initWithURLString:[@"file:/" stringByAppendingString:filePath]];

    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Async Data Loader"];
    
    [dataLoader loadDataSuccess:^(NSData *data) {
        XCTAssertNotNil(data);
        [expectation fulfill];
    } fail:^(NSError *error) {
        
    } targetQueue:dispatch_get_main_queue()];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        
        if(error) {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
        
    }];
}

@end
