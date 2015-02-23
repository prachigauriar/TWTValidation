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
    // TODO: make these relative
    NSString *directoryPath = @"/Users/jillcohen/Developer/TWTValidation/Tests/JSONSchemaTestSuite/tests/draft4/";
    NSError *error = nil;
    
    for (NSDictionary *test in [self testsInDirectory:directoryPath]) {
        TWTJSONObjectValidator *validator = [TWTJSONObjectValidator validatorWithJSONSchema:test[TWTTestKeywordSchema] error:nil warnings:nil];
        for (NSDictionary *testValue in test[TWTTestKeywordTests]) {

            if (![[self failingTests] containsObject:testValue[TWTTestKeywordDescription]]) {
                BOOL shouldPass = [testValue[TWTTestKeywordValid] boolValue];
                XCTAssertTrue([validator validateValue:testValue[TWTTestKeywordData] error:&error] == shouldPass,
                              @"\nValue: %@\nSchema: %@\nshould have %@ed because %@. (%@)",
                              testValue[TWTTestKeywordData], test[TWTTestKeywordSchema], shouldPass ? @"pass" : @"fail",
                              testValue[TWTTestKeywordDescription], test[TWTTestKeywordDescription]);
            }
        }
    }
}


- (void)testKnownFailingTests
{
    // TODO: make these relative
    NSString *directoryPath = @"/Users/jillcohen/Developer/TWTValidation/Tests/JSONSchemaTestSuite/tests/draft4/";
    NSError *error = nil;

    for (NSDictionary *test in [self testsInDirectory:directoryPath]) {
        TWTJSONObjectValidator *validator = [TWTJSONObjectValidator validatorWithJSONSchema:test[TWTTestKeywordSchema] error:nil warnings:nil];
        for (NSDictionary *testValue in test[TWTTestKeywordTests]) {
            error = nil;
            if ([[self failingTests] containsObject:testValue[TWTTestKeywordDescription]]) {
                BOOL shouldPass = [testValue[TWTTestKeywordValid] boolValue];
                XCTAssertTrue([validator validateValue:testValue[TWTTestKeywordData] error:&error] == shouldPass, @"\nValue: %@\nSchema: %@\nshould have %@ed because %@. (%@)",
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


- (NSArray *)testsInDirectory:(NSString *)directoryPath
{
    NSArray *testFilenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:nil];
    NSMutableArray *tests = [[NSMutableArray alloc] init];

    for (NSString *filename in testFilenames) {
        if ([filename hasSuffix:@".json"]) {
            NSError *error = nil;
            NSData *fileData = [NSData dataWithContentsOfFile:[directoryPath stringByAppendingPathComponent:filename] options:0 error:&error];
            if (error) {
                NSLog(@"%@", error.description);
                return nil;
            }
            id JSONObject = [NSJSONSerialization JSONObjectWithData:fileData options:0 error:&error];

            if (error) {
                NSLog(@"Error reading file: %@", error.description);
                return nil;
            }

            if (![JSONObject isKindOfClass:[NSArray class]]) {
                NSLog(@"Expected array of dictionaries with schema as value for ""schema"" key.");
                return nil;
            }
            
            [tests addObjectsFromArray:JSONObject];
        }
    }
    
    return [tests copy];
}


- (NSSet *)failingTests
{
    // TWTValidation does not support differentiating between booleans and NSNumbers when checking for unique items in an array,
    // because Objective-C treats 1/0 as equivalent to YES/NO.
    return [NSSet setWithObjects:@"1 and true are unique",
            @"0 and false are unique",
            @"unique heterogeneous types are valid",
            @"remote ref valid", @"remote ref invalid",
            @"slash", @"tilda", @"percent", nil];
}


@end
