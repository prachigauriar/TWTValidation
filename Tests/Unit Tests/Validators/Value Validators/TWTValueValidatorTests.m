//
//  TWTValueValidatorTests.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 4/3/2014.
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


@interface TWTValueValidatorTests : TWTRandomizedTestCase

- (void)testInit;
- (void)testCopy;
- (void)testHashAndIsEqual;

- (void)testValidateValueErrorValueClass;
- (void)testValidateValueErrorAllowsNil;
- (void)testValidateValueErrorAllowsNull;

@end


@implementation TWTValueValidatorTests

- (void)testInit
{
    TWTValueValidator *validator = [[TWTValueValidator alloc] init];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
    XCTAssertNil(validator.valueClass, @"non-nil value class");
    
    // Two arbitrary classes
    Class valueClass = [self randomClass];
    BOOL allowsNil = UMKRandomBoolean();
    BOOL allowsNull = UMKRandomBoolean();
    
    validator = [TWTValueValidator valueValidatorWithClass:valueClass allowsNil:allowsNil allowsNull:allowsNull];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertEqualObjects(validator.valueClass, valueClass, @"value class is not set correctly");
    XCTAssertEqual(validator.allowsNil, allowsNil, @"allowsNil is not set correctly");
    XCTAssertEqual(validator.allowsNull, allowsNull, @"allowsNull is not set correctly");
}


- (void)testCopy
{
    Class valueClass = [self randomClass];
    BOOL allowsNil = UMKRandomBoolean();
    BOOL allowsNull = UMKRandomBoolean();
    
    TWTValueValidator *validator = [TWTValueValidator valueValidatorWithClass:valueClass allowsNil:allowsNil allowsNull:allowsNull];
    TWTValueValidator *copy = [validator copy];
    XCTAssertEqualObjects(validator, copy, @"copy is not equal to original");
    XCTAssertEqualObjects(copy.valueClass, valueClass, @"value class is not set correctly");
    XCTAssertEqual(copy.allowsNil, allowsNil, @"allowsNil is not set correctly");
    XCTAssertEqual(copy.allowsNull, allowsNull, @"allowsNull is not set correctly");
}


- (void)testHashAndIsEqual
{
    Class valueClass = [self randomClass];
    BOOL allowsNil = UMKRandomBoolean();
    BOOL allowsNull = UMKRandomBoolean();

    TWTValueValidator *validator1 = [TWTValueValidator valueValidatorWithClass:valueClass allowsNil:allowsNil allowsNull:allowsNull];
    TWTValueValidator *validator2 = [TWTValueValidator valueValidatorWithClass:valueClass allowsNil:allowsNil allowsNull:allowsNull];

    XCTAssertEqual(validator1.hash, validator2.hash, @"hashes are not equal for equal objects");
    XCTAssertEqualObjects(validator1, validator2, @"equal objects are not equal");

    // Value class
    while (validator1.valueClass == validator2.valueClass) {
        validator1.valueClass = [self randomClass];
    }

    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");

    validator2.valueClass = validator1.valueClass;
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
}


- (void)testValidateValueErrorValueClass
{
    Class valueClass = [self randomClassWithMutableVariant];
    id value = [[valueClass alloc] init];
    
    // valueClass is nil
    TWTValueValidator *validator = [[TWTValueValidator alloc] init];
    XCTAssertTrue([validator validateValue:value error:NULL], @"fails when valueClass is nil");
    
    // valueClass is either [value class] or a superclass of it
    validator.valueClass = valueClass;
    XCTAssertTrue([validator validateValue:value error:NULL], @"fails when value is instance of valueClass");
    XCTAssertTrue([validator validateValue:[value mutableCopy] error:NULL], @"fails when value is an instance of a subclass of valueClass");
    
    // valueClass is different than [value class]
    validator.valueClass = [self class];
    XCTAssertFalse([validator validateValue:value error:NULL], @"passes when value is not an instance of valueClass");

    NSError *error = nil;
    XCTAssertFalse([validator validateValue:value error:&error], @"passes when value is not an instance of valueClass");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeValueHasIncorrectClass, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validated value");
    
    // valueClass is NSNull, but allowsNull = NO
    value = [NSNull null];
    validator.valueClass = [NSNull class];
    XCTAssertFalse([validator validateValue:value error:NULL]);

    error = nil;
    XCTAssertFalse([validator validateValue:value error:&error], @"passes when allowsNull is NO");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeValueNull, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validated value");
}


- (void)testValidateValueErrorAllowsNil
{
    TWTValueValidator *validator = [[TWTValueValidator alloc] init];
    XCTAssertFalse([validator validateValue:nil error:NULL], @"passes when value is nil");

    NSError *error = nil;
    XCTAssertFalse([validator validateValue:nil error:&error], @"passes when value is nil");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeValueNil, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, nil, @"incorrect validated value");

    validator.allowsNil = YES;
    XCTAssertTrue([validator validateValue:nil error:NULL], @"fails when value is nil");
}


- (void)testValidateValueErrorAllowsNull
{
    TWTValueValidator *validator = [[TWTValueValidator alloc] init];
    XCTAssertFalse([validator validateValue:[NSNull null] error:NULL], @"passes when value is null");
    
    NSError *error = nil;
    XCTAssertFalse([validator validateValue:[NSNull null] error:&error], @"passes when value is null");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeValueNull, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, [NSNull null], @"incorrect validated value");
    
    validator.allowsNull = YES;
    XCTAssertTrue([validator validateValue:[NSNull null] error:NULL], @"fails when value is null");
}

@end
