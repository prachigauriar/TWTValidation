//
//  TWTNumberValidatorTests.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 4/5/2014.
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


@interface TWTNumberValidatorTests : TWTRandomizedTestCase

- (void)testInit;
- (void)testCopy;
- (void)testHashAndIsEqual;

- (void)testValidateValueErrorNoMinimum;
- (void)testValidateValueErrorMinimum;
- (void)testValidateValueErrorNoMaximum;
- (void)testValidateValueErrorMaximum;
- (void)testValidateValueErrorRequiresIntegralValue;

@end


@implementation TWTNumberValidatorTests

- (NSNumber *)randomFloatingPointNumber
{
    double signCoefficient = UMKRandomBoolean() ? 1.0 : -1.0;
    double integer = (double)random();
    double fraction = (random() + 1.0) / (double)INT32_MAX;
    return @(signCoefficient * integer + fraction);
}


- (NSNumber *)randomNumberLessThanNumber:(NSNumber *)number
{
    return @([number doubleValue] - random() - 1.0);
}


- (NSNumber *)randomNumberGreaterThanNumber:(NSNumber *)number
{
    return @([number doubleValue] + random() + 1.0);
}


- (void)testInit
{
    TWTNumberValidator *validator = [[TWTNumberValidator alloc] init];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
    XCTAssertEqualObjects(validator.valueClass, [NSNumber class], @"value class is not NSNumber");
    XCTAssertNil(validator.minimum, @"non-nil minimum");
    XCTAssertNil(validator.maximum, @"non-nil maximum");
    XCTAssertFalse(validator.requiresIntegralValue, @"requiresIntegralValue is YES");

    NSNumber *minimum = [self randomFloatingPointNumber];
    NSNumber *maximum = [self randomNumberGreaterThanNumber:minimum];
    
    validator = [[TWTNumberValidator alloc] initWithMinimum:minimum maximum:maximum];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
    XCTAssertEqualObjects(validator.valueClass, [NSNumber class], @"value class is not NSNumber");
    XCTAssertEqualObjects(validator.minimum, minimum, @"minimum is not set correctly");
    XCTAssertEqualObjects(validator.maximum, maximum, @"maximum is not set correctly");
    XCTAssertFalse(validator.requiresIntegralValue, @"requiresIntegralValue is YES");
    
    XCTAssertThrows([[TWTNumberValidator alloc] initWithMinimum:maximum maximum:minimum], @"does not throw when maximum < minimum");
}


- (void)testCopy
{
    NSNumber *minimum = [self randomFloatingPointNumber];
    NSNumber *maximum = [self randomNumberGreaterThanNumber:minimum];
    BOOL allowsNil = UMKRandomBoolean();
    BOOL allowsNull = UMKRandomBoolean();
    BOOL requiresIntegralValue = UMKRandomBoolean();
    
    TWTNumberValidator *validator = [[TWTNumberValidator alloc] initWithMinimum:minimum maximum:maximum];
    validator.allowsNil = allowsNil;
    validator.allowsNull = allowsNull;
    validator.requiresIntegralValue = requiresIntegralValue;
    
    TWTNumberValidator *copy = [validator copy];
    
    XCTAssertEqualObjects(validator, copy, @"copy is not equal to original");
    XCTAssertEqualObjects(copy.valueClass, [NSNumber class], @"value class is not set correctly");
    XCTAssertEqual(copy.allowsNil, allowsNil, @"allowsNil is not set correctly");
    XCTAssertEqual(copy.allowsNull, allowsNull, @"allowsNull is not set correctly");
    XCTAssertEqual(copy.requiresIntegralValue, requiresIntegralValue, @"requiresIntegralValue is not set correctly");
    XCTAssertEqualObjects(copy.minimum, minimum, @"minimum is not set correctly");
    XCTAssertEqualObjects(copy.maximum, maximum, @"maximum is not set correctly");
}


- (void)testHashAndIsEqual
{
    NSNumber *minimum = nil;
    NSNumber *maximum = [self randomNumberGreaterThanNumber:minimum];
    
    TWTNumberValidator *validator1 = [[TWTNumberValidator alloc] initWithMinimum:minimum maximum:maximum];
    TWTNumberValidator *validator2 = [[TWTNumberValidator alloc] initWithMinimum:minimum maximum:maximum];
    
    XCTAssertEqual(validator1.hash, validator2.hash, @"hashes are not equal for equal objects");
    XCTAssertEqualObjects(validator1, validator2, @"equal objects are not equal");

    // Allows nil
    validator1.allowsNil = !validator2.allowsNil;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");
    
    validator2.allowsNil = validator1.allowsNil;
    XCTAssertEqual(validator1.hash, validator2.hash, @"hashes are not equal for equal objects");
    XCTAssertEqualObjects(validator1, validator2, @"equal objects are not equal");
    
    // Allows null
    validator1.allowsNull = !validator2.allowsNull;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");
    
    validator2.allowsNull = validator1.allowsNull;
    XCTAssertEqual(validator1.hash, validator2.hash, @"hashes are not equal for equal objects");
    XCTAssertEqualObjects(validator1, validator2, @"equal objects are not equal");

    // Requires integral value
    validator1.requiresIntegralValue = !validator2.requiresIntegralValue;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");
    
    validator2.requiresIntegralValue = validator1.requiresIntegralValue;
    XCTAssertEqual(validator1.hash, validator2.hash, @"hashes are not equal for equal objects");
    XCTAssertEqualObjects(validator1, validator2, @"equal objects are not equal");

    // minimum
    validator2 = [[TWTNumberValidator alloc] initWithMinimum:[self randomNumberLessThanNumber:minimum] maximum:maximum];
    validator2.allowsNil = validator1.allowsNil;
    validator2.allowsNull = validator1.allowsNull;
    validator2.requiresIntegralValue = validator1.requiresIntegralValue;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");

    // maximum
    validator2 = [[TWTNumberValidator alloc] initWithMinimum:minimum maximum:[self randomNumberGreaterThanNumber:maximum]];
    validator2.allowsNil = validator1.allowsNil;
    validator2.allowsNull = validator1.allowsNull;
    validator2.requiresIntegralValue = validator1.requiresIntegralValue;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");
}


- (void)testValidateValueErrorNoMinimum
{
    TWTNumberValidator *validator = [[TWTNumberValidator alloc] initWithMinimum:nil maximum:@(INFINITY)];

    XCTAssertTrue([validator validateValue:@(-INFINITY) error:NULL], @"fails with -∞");
    XCTAssertTrue([validator validateValue:@(NSIntegerMin) error:NULL], @"fails with NSIntegerMin");
    XCTAssertTrue([validator validateValue:@(INT64_MIN) error:NULL], @"fails with INT64_MIN");
}


- (void)testValidateValueErrorMinimum
{
    NSNumber *minimum = [self randomFloatingPointNumber];
    TWTNumberValidator *validator = [[TWTNumberValidator alloc] initWithMinimum:minimum maximum:nil];

    XCTAssertTrue([validator validateValue:minimum error:NULL], @"fails with minimum number");

    NSNumber *value = [self randomNumberGreaterThanNumber:minimum];
    XCTAssertTrue([validator validateValue:value error:NULL], @"fails with larger number");
    
    value = [self randomNumberLessThanNumber:minimum];
    XCTAssertFalse([validator validateValue:value error:NULL], @"passes with smaller number");

    NSError *error = nil;
    XCTAssertFalse([validator validateValue:value error:&error], @"passes with smaller number");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeValueLessThanMinimum, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validated value");
}


- (void)testValidateValueErrorNoMaximum
{
    TWTNumberValidator *validator = [[TWTNumberValidator alloc] initWithMinimum:@(-INFINITY) maximum:nil];
    
    XCTAssertTrue([validator validateValue:@(INFINITY) error:NULL], @"fails with ∞");
    XCTAssertTrue([validator validateValue:@(NSUIntegerMax) error:NULL], @"fails with NSUIntegerMax");
    XCTAssertTrue([validator validateValue:@(UINT64_MAX) error:NULL], @"fails with UINT64_MAX");
}


- (void)testValidateValueErrorMaximum
{
    NSNumber *maximum = [self randomFloatingPointNumber];
    TWTNumberValidator *validator = [[TWTNumberValidator alloc] initWithMinimum:nil maximum:maximum];

    XCTAssertTrue([validator validateValue:maximum error:NULL], @"fails with minimum number");

    NSNumber *value = [self randomNumberLessThanNumber:maximum];
    XCTAssertTrue([validator validateValue:value error:NULL], @"fails with smaller number");
    
    value = [self randomNumberGreaterThanNumber:maximum];
    XCTAssertFalse([validator validateValue:value error:NULL], @"passes with larger number");
    
    NSError *error = nil;
    XCTAssertFalse([validator validateValue:value error:&error], @"passes with smaller number");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeValueGreaterThanMaximum, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validated value");
}


- (void)testValidateValueErrorRequiresIntegralValue
{
    TWTNumberValidator *validator = [[TWTNumberValidator alloc] init];
    validator.requiresIntegralValue = YES;
    
    XCTAssertTrue([validator validateValue:UMKRandomUnsignedNumber() error:NULL], @"fails with integer value");

    id value = [self randomFloatingPointNumber];
    XCTAssertFalse([validator validateValue:value error:NULL], @"passes with non-integral value");

    NSError *error = nil;
    XCTAssertFalse([validator validateValue:value error:&error], @"passes with non-integral value");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeValueIsNotIntegral, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validated value");
}

@end
