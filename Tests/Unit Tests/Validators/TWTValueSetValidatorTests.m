//
//  TWTValueSetValidatorTests.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 8/13/2014.
//  Copyright (c) 2015 Ticketmaster. All rights reserved.
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


@interface TWTValueSetValidatorTests : TWTRandomizedTestCase

- (void)testInit;
- (void)testCopy;
- (void)testHashAndIsEqual;
- (void)testValidateValueError;

@end


@implementation TWTValueSetValidatorTests

- (NSSet *)randomObjectSet
{
    return UMKGeneratedSetWithElementCount(random() % 5 + 5, ^id{
        return [self randomObject];
    });
}


- (void)testInit
{
    TWTValueSetValidator *validator = [[TWTValueSetValidator alloc] init];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertNil(validator.validValues, @"valid values is non-nil");

    NSSet *validValues = [self randomObjectSet];
    validator = [TWTValueSetValidator valueSetValidatorWithValidValues:validValues];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertEqualObjects(validator.validValues, validValues, @"valid values is not set correctly");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");

    BOOL allowsNil = UMKRandomBoolean();
    validator = [TWTValueSetValidator  valueSetValidatorWithValidValues:validValues allowsNil:allowsNil];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertEqualObjects(validator.validValues, validValues, @"valid values is not set correctly");
    XCTAssertEqual(validator.allowsNil, allowsNil, @"allowsNil is not set correctly");
}


- (void)testCopy
{
    NSSet *validValues = [self randomObjectSet];
    BOOL allowsNil = UMKRandomBoolean();

    TWTValueSetValidator *validator = [[TWTValueSetValidator alloc] initWithValidValues:validValues allowsNil:allowsNil];
    TWTValueSetValidator *copy = [validator copy];

    XCTAssertEqualObjects(validator, copy, @"copy is not equal to original");
    XCTAssertEqual(copy.allowsNil, allowsNil, @"allowsNil is not set correctly");
    XCTAssertEqualObjects(copy.validValues, validValues, @"valid values is not set correctly");
}


- (void)testHashAndIsEqual
{
    NSSet *validValues1 = [self randomObjectSet];
    NSSet *validValues2 = [self randomObjectSet];
    while ([validValues1 isEqualToSet:validValues2]) {
        validValues2 = [self randomObjectSet];
    }

    BOOL allowsNil = UMKRandomBoolean();

    TWTValueSetValidator *equalValidator1 = [[TWTValueSetValidator alloc] initWithValidValues:validValues1 allowsNil:allowsNil];
    TWTValueSetValidator *equalValidator2 = [[TWTValueSetValidator alloc] initWithValidValues:validValues1 allowsNil:allowsNil];
    TWTValueSetValidator *unequalValidator1 = [[TWTValueSetValidator alloc] initWithValidValues:validValues2 allowsNil:allowsNil];
    TWTValueSetValidator *unequalValidator2 = [[TWTValueSetValidator alloc] initWithValidValues:validValues1 allowsNil:!allowsNil];

    XCTAssertEqual(equalValidator1.hash, equalValidator2.hash, @"hashes are not equal for equal objects");
    XCTAssertEqualObjects(equalValidator1, equalValidator2, @"equal objects are not equal");

    XCTAssertNotEqualObjects(equalValidator1, unequalValidator1, @"unequal objects are equal");
    XCTAssertNotEqualObjects(equalValidator1, unequalValidator2, @"unequal objects are equal");
}


- (void)testValidateValueError
{
    NSSet *validValues = UMKGeneratedSetWithElementCount(random() % 10 + 1, ^id{
        return UMKRandomUnicodeString();
    });

    id value = [validValues anyObject];

    // validValues
    TWTValueSetValidator *validator = [[TWTValueSetValidator alloc] initWithValidValues:validValues allowsNil:NO];
    XCTAssertTrue([validator validateValue:value error:NULL], @"fails when value is in validValues");

    value = self;
    NSError *error = nil;
    XCTAssertFalse([validator validateValue:value error:&error], @"passes when value is not in validValues");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeValueNotInSet, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validated value");

    // allowsNil
    error = nil;
    XCTAssertFalse([validator validateValue:nil error:&error], @"passes with nil value");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeValueNil, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertNil(error.twt_validatedValue, @"validated value is not nil");

    validator = [[TWTValueSetValidator alloc] initWithValidValues:validValues allowsNil:YES];
    XCTAssertTrue([validator validateValue:nil error:NULL], @"fails with nil value");
}

@end
