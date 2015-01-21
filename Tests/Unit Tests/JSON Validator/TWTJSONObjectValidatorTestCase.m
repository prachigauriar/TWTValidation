//
//  TWTJSONObjectValidatorTestCase.m
//  TWTValidation
//
//  Created by Jill Cohen on 1/16/15.
//  Copyright (c) 2015 Two Toasters, LLC.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "TWTRandomizedTestCase.h"


static NSString *const TWTTestKeywordSchema = @"schema";
static NSString *const TWTTestKeywordDescription = @"description";
static NSString *const TWTTestKeywordData = @"data";
static NSString *const TWTTestKeywordTests = @"tests";
static NSString *const TWTTestKeywordValid = @"valid";


@interface TWTJSONObjectValidatorTestCase : TWTRandomizedTestCase

@end


@implementation TWTJSONObjectValidatorTestCase

- (void)testSuite
{
    NSString *directoryPath = @"/Users/jillcohen/Developer/TWTValidation/Tests/JSONSchemaTestSuite/tests/draft4/";
    
    for (NSDictionary *test in [self testsInDirectory:directoryPath]) {
        TWTJSONObjectValidator *validator = [TWTJSONObjectValidator validatorWithJSONSchema:test[TWTTestKeywordSchema] error:nil warnings:nil];
        for (NSDictionary *testValue in test[TWTTestKeywordTests]) {

            if (![[self failingTests] containsObject:testValue[TWTTestKeywordDescription]]) {
                BOOL shouldPass = [testValue[TWTTestKeywordValid] boolValue];
                XCTAssertTrue([validator validateValue:testValue[TWTTestKeywordData] error:nil] == shouldPass,
                              @"\nValue: %@\nSchema: %@\nshould have %@ed because %@. (%@)",
                              testValue[TWTTestKeywordData], test[TWTTestKeywordSchema], shouldPass ? @"pass" : @"fail",
                              testValue[TWTTestKeywordDescription], test[TWTTestKeywordDescription]);
            }
        }
    }
}


- (void)testKnownFailingTests
{
    NSString *directoryPath = @"/Users/jillcohen/Developer/TWTValidation/Tests/JSONSchemaTestSuite/tests/draft4/";
    for (NSDictionary *test in [self testsInDirectory:directoryPath]) {
        TWTJSONObjectValidator *validator = [TWTJSONObjectValidator validatorWithJSONSchema:test[TWTTestKeywordSchema] error:nil warnings:nil];
        for (NSDictionary *testValue in test[TWTTestKeywordTests]) {
            if ([[self failingTests] containsObject:testValue[TWTTestKeywordDescription]]) {
                BOOL shouldPass = [testValue[TWTTestKeywordValid] boolValue];
                XCTAssertTrue([validator validateValue:testValue[TWTTestKeywordData] error:nil] == shouldPass, @"\nValue: %@\nSchema: %@\nshould have %@ed because %@. (%@)",
                              testValue[TWTTestKeywordData], test[TWTTestKeywordSchema], shouldPass ? @"pass" : @"fail", testValue[TWTTestKeywordDescription], test[TWTTestKeywordDescription]);
            }
        }
    }
}



- (void)testCustom
{
    NSString *directoryPath = @"/Users/jillcohen/Developer/TWTValidation/Tests/JSONSchemaCustom/";
    for (NSDictionary *test in [self testsInDirectory:directoryPath]) {
        TWTJSONObjectValidator *validator = [TWTJSONObjectValidator validatorWithJSONSchema:test[TWTTestKeywordSchema] error:nil warnings:nil];
        for (NSDictionary *testValue in test[TWTTestKeywordTests]) {
            BOOL shouldPass = [testValue[TWTTestKeywordValid] boolValue];
            XCTAssertTrue([validator validateValue:testValue[TWTTestKeywordData] error:nil] == shouldPass, @"\nValue: %@\nSchema: %@\nshould have %@ed because %@. (%@)",
                          testValue[TWTTestKeywordData], test[TWTTestKeywordSchema], shouldPass ? @"pass" : @"fail", testValue[TWTTestKeywordDescription], test[TWTTestKeywordDescription]);
        }
    }
}


- (void)testIndividual
{

//    schema = @{ @"maxLength" : @2 };
//    NSString *passString = @"💩💩";
//    XCTAssertTrue([validator validateValue:passString error:nil]);


}


- (NSArray *)testsInDirectory:(NSString *)directoryPath
{
    NSArray *testFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:nil];
    NSMutableArray *tests = [[NSMutableArray alloc] init];

    for (NSString *file in testFiles) {
        if ([file containsString:@".json"]) {
            NSError *error = nil;
            NSData *fileData = [NSData dataWithContentsOfFile:[directoryPath stringByAppendingString:file]];
            id JSONObject = [NSJSONSerialization JSONObjectWithData:fileData options:0 error:&error];

            if (error) {
                fprintf(stderr, "Error reading file: %s\n", [error.description UTF8String]);
                return nil;
            }

            if (![JSONObject isKindOfClass:[NSArray class]]) {
                fprintf(stderr, "Expected array of dictionaries with schema as value for ""schema"" key.\n");
                return nil;
            }
            
            [tests addObjectsFromArray:JSONObject];
        }
    }
    
    return [tests copy];
}


- (NSSet *)failingTests
{
    return [NSSet setWithObjects:@"two supplementary Unicode code points is long enough",
            @"one supplementary Unicode code point is not long enough",
            @"1 and true are unique",
            @"0 and false are unique",
            @"unique heterogeneous types are valid", nil];
}


@end
