//
//  TWTKeyValuePairValidatorTests.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 6/1/2014.
//  Copyright (c) 2014 Two Toasters, LLC.
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


@interface TWTKeyValuePairValidatorTests : TWTRandomizedTestCase

- (void)testInit;
- (void)testCopy;
- (void)testHashAndIsEqual;

- (void)testValidateValueError;

@end


@implementation TWTKeyValuePairValidatorTests

- (void)testInit
{
    XCTAssertThrows([[TWTKeyValuePairValidator alloc] init], @"-init does not throw an exception");

    id key = [self randomNonNilObject];
    TWTValidator *valueValidator = [self randomValidator];
    TWTKeyValuePairValidator *validator = [[TWTKeyValuePairValidator alloc] initWithKey:key valueValidator:valueValidator];

    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertEqualObjects(validator.key, key, @"key is not set correctly");
    XCTAssertEqualObjects(validator.valueValidator, valueValidator, @"value validator is not set correctly");
}


- (void)testCopy
{
    id key = [self randomNonNilObject];
    TWTValidator *valueValidator = [self randomValidator];
    TWTKeyValuePairValidator *validator = [[TWTKeyValuePairValidator alloc] initWithKey:key valueValidator:valueValidator];
    TWTKeyValuePairValidator *copy = [validator copy];

    XCTAssertEqualObjects(validator, copy, @"copy is not equal to original");
    XCTAssertEqualObjects(copy.key, key, @"key is not set correctly");
    XCTAssertEqualObjects(copy.valueValidator, valueValidator, @"value validator is not set correctly");
}


- (void)testHashAndIsEqual
{
    id key1 = UMKRandomUnicodeString();
    id key2 = UMKRandomUnsignedNumber();

    TWTValidator *valueValidator1 = [self randomValidator];
    TWTValidator *valueValidator2 = [TWTCompoundValidator notValidatorWithSubvalidator:valueValidator1];
    
    TWTKeyValuePairValidator *equalValidator1 = [[TWTKeyValuePairValidator alloc] initWithKey:key1 valueValidator:valueValidator1];
    TWTKeyValuePairValidator *equalValidator2 = [[TWTKeyValuePairValidator alloc] initWithKey:key1 valueValidator:valueValidator1];
    TWTKeyValuePairValidator *unequalValidator1 = [[TWTKeyValuePairValidator alloc] initWithKey:key2 valueValidator:valueValidator1];
    TWTKeyValuePairValidator *unequalValidator2 = [[TWTKeyValuePairValidator alloc] initWithKey:key1 valueValidator:valueValidator2];

    XCTAssertEqual(equalValidator1.hash, equalValidator2.hash, @"hashes are different for equal objects");
    XCTAssertEqualObjects(equalValidator1, equalValidator2, @"equal objects are not equal");
    XCTAssertNotEqualObjects(equalValidator1, unequalValidator1, @"unequal objects are equal");
    XCTAssertNotEqualObjects(equalValidator1, unequalValidator2, @"unequal objects are equal");
}


- (void)testValidateValueError
{
    id key = [self randomNonNilObject];
    TWTKeyValuePairValidator *validator = [[TWTKeyValuePairValidator alloc] initWithKey:key valueValidator:[self passingValidator]];
    XCTAssertTrue([validator validateValue:[self randomObject] error:NULL], @"fails with passing value validator");

    NSError *expectedError = UMKRandomError();

    validator = [[TWTKeyValuePairValidator alloc] initWithKey:key valueValidator:[self failingValidatorWithError:expectedError]];
    XCTAssertFalse([validator validateValue:[self randomObject] error:NULL], @"passes with failing value validator");

    NSError *error = nil;
    XCTAssertFalse([validator validateValue:[self randomObject] error:&error], @"passes with failing value validator");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error, expectedError, @"error is not set correctly");
}

@end
