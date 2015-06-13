//
//  TWTValidationErrorsTests.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 6/2/2014.
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


@interface TWTValidationErrorsTests : TWTRandomizedTestCase

- (void)testValidationErrorWithCodeValueLocalizedDescription;
- (void)testValidationErrorWithCodeValueLocalizedDescriptionUnderlyingErrors;
- (void)testValidationErrorWithCodeFailingValidatorValueLocalizedDescription;
- (void)testValidationErrorWithCodeFailingValidatorValueLocalizedDescriptionUnderlyingErrors;

- (void)testValidatedValue;
- (void)testUnderlyingErrors;
- (void)testUnderlyingErrorsByKey;
- (void)testCountValidationError;
- (void)testElementValidationErrors;
- (void)testKeyValidationErrors;
- (void)testValueValidationErrors;
- (void)testKeyValuePairValidationErrors;

@end


@implementation TWTValidationErrorsTests

- (NSError *)randomErrorWithObject:(id)object forUserInfoKey:(id<NSCopying>)key
{
    NSParameterAssert(key);
    NSParameterAssert(object);
    return [NSError errorWithDomain:UMKRandomAlphanumericString() code:random() userInfo:@{ key : object }];
}


- (NSError *)randomErrorWithoutUserInfoKey:(id<NSCopying>)key
{
    NSError *error = nil;
    while (!(error = UMKRandomError()) || error.userInfo[key]);
    return error;
}


- (void)testValidationErrorWithCodeValueLocalizedDescription
{
    // It’s okay to ignore deprecation warnings on +twt_validationErrorWithCode:value:localizedDescription:
    // in this test, as that’s the method we’re testing
    NSInteger code = random();
    id value = [self randomNonNilObject];

    NSString *description = UMKRandomUnicodeString();

    NSDictionary *userInfo = @{ TWTValidationValidatedValueKey : value, NSLocalizedDescriptionKey : description };

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSError *error = [NSError twt_validationErrorWithCode:code value:value localizedDescription:description];
#pragma clang diagnostic pop

    XCTAssertNotNil(error, @"returns nil object");
    XCTAssertEqual(error.code, code, @"code is not set correctly");
    XCTAssertEqualObjects(error.userInfo, userInfo, @"userInfo is not set correctly");

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    error = [NSError twt_validationErrorWithCode:code value:nil localizedDescription:nil];
#pragma clang diagnostic pop
    XCTAssertEqualObjects(error.userInfo, @{ }, @"userInfo is not set correctly");
}


- (void)testValidationErrorWithCodeValueLocalizedDescriptionUnderlyingErrors
{
    // It’s okay to ignore deprecation warnings on +twt_validationErrorWithCode:value:localizedDescription:underlyingErrors:
    // in this test, as that’s the method we’re testing
    NSInteger code = random();
    id value = [self randomNonNilObject];

    NSString *description = UMKRandomUnicodeString();
    NSArray *errors = UMKGeneratedArrayWithElementCount(random() % 10 + 1, ^id(NSUInteger index) {
        return UMKRandomError();
    });

    NSDictionary *userInfo = @{ TWTValidationValidatedValueKey : value,
                                NSLocalizedDescriptionKey : description,
                                TWTValidationUnderlyingErrorsKey : errors };

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSError *error = [NSError twt_validationErrorWithCode:code value:value localizedDescription:description underlyingErrors:errors];
#pragma clang diagnostic pop
    XCTAssertNotNil(error, @"returns nil object");
    XCTAssertEqual(error.code, code, @"code is not set correctly");
    XCTAssertEqualObjects(error.userInfo, userInfo, @"userInfo is not set correctly");

    userInfo = @{ };
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    error = [NSError twt_validationErrorWithCode:code value:nil localizedDescription:nil underlyingErrors:nil];
#pragma clang diagnostic pop
    XCTAssertEqualObjects(error.userInfo, @{ }, @"userInfo is not set correctly");

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    error = [NSError twt_validationErrorWithCode:code value:nil localizedDescription:nil underlyingErrors:@[ ]];
#pragma clang diagnostic pop
    XCTAssertEqualObjects(error.userInfo, @{ }, @"userInfo is not set correctly");
}


- (void)testValidationErrorWithCodeFailingValidatorValueLocalizedDescription
{
    NSInteger code = random();
    id value = [self randomNonNilObject];

    NSString *description = UMKRandomUnicodeString();
    TWTValidator *validator = [self randomValidator];

    NSDictionary *userInfo = @{ TWTValidationFailingValidatorKey : validator,
                                TWTValidationValidatedValueKey : value,
                                NSLocalizedDescriptionKey : description };
    NSError *error = [NSError twt_validationErrorWithCode:code failingValidator:validator value:value localizedDescription:description];

    XCTAssertNotNil(error, @"returns nil object");
    XCTAssertEqual(error.code, code, @"code is not set correctly");
    XCTAssertEqualObjects(error.userInfo, userInfo, @"userInfo is not set correctly");

    error = [NSError twt_validationErrorWithCode:code failingValidator:nil value:nil localizedDescription:nil];
    XCTAssertEqualObjects(error.userInfo, @{ }, @"userInfo is not set correctly");
}


- (void)testValidationErrorWithCodeFailingValidatorValueLocalizedDescriptionUnderlyingErrors
{
    NSInteger code = random();
    id value = [self randomNonNilObject];

    NSString *description = UMKRandomUnicodeString();
    NSArray *errors = UMKGeneratedArrayWithElementCount(random() % 10 + 1, ^id(NSUInteger index) {
        return UMKRandomError();
    });

    TWTValidator *validator = [self randomValidator];

    NSDictionary *userInfo = @{ TWTValidationFailingValidatorKey : validator,
                                TWTValidationValidatedValueKey : value,
                                NSLocalizedDescriptionKey : description,
                                TWTValidationUnderlyingErrorsKey : errors };

    NSError *error = [NSError twt_validationErrorWithCode:code
                                         failingValidator:validator
                                                    value:value
                                     localizedDescription:description
                                         underlyingErrors:errors];
    XCTAssertNotNil(error, @"returns nil object");
    XCTAssertEqual(error.code, code, @"code is not set correctly");
    XCTAssertEqualObjects(error.userInfo, userInfo, @"userInfo is not set correctly");

    userInfo = @{ };
    error = [NSError twt_validationErrorWithCode:code failingValidator:nil value:nil localizedDescription:nil underlyingErrors:nil];
    XCTAssertEqualObjects(error.userInfo, @{ }, @"userInfo is not set correctly");

    error = [NSError twt_validationErrorWithCode:code failingValidator:nil value:nil localizedDescription:nil underlyingErrors:@[ ]];
    XCTAssertEqualObjects(error.userInfo, @{ }, @"userInfo is not set correctly");
}


- (void)testFailingValidator
{
    NSString *key = TWTValidationFailingValidatorKey;
    NSError *error = [self randomErrorWithoutUserInfoKey:key];
    XCTAssertNil(error.twt_failingValidator, @"failing validator returns non-nil object");

    id object = [self randomNonNilObject];
    error = [self randomErrorWithObject:object forUserInfoKey:key];
    XCTAssertEqualObjects(error.twt_failingValidator, object, @"failing validator is not set correctly");
}


- (void)testValidatedValue
{
    NSString *key = TWTValidationValidatedValueKey;
    NSError *error = [self randomErrorWithoutUserInfoKey:key];
    XCTAssertNil(error.twt_validatedValue, @"validated value returns non-nil object");

    id object = [self randomNonNilObject];
    error = [self randomErrorWithObject:object forUserInfoKey:key];
    XCTAssertEqualObjects(error.twt_validatedValue, object, @"validated value is not set correctly");
}


- (void)testUnderlyingErrors
{
    NSString *key = TWTValidationUnderlyingErrorsKey;
    NSError *error = [self randomErrorWithoutUserInfoKey:key];
    XCTAssertNil(error.twt_underlyingErrors, @"underlying errors returns non-nil object");

    id object = [self randomNonNilObject];
    error = [self randomErrorWithObject:object forUserInfoKey:key];
    XCTAssertEqualObjects(error.twt_underlyingErrors, object, @"underlying errors is not set correctly");
}

- (void)testUnderlyingErrorsByKey
{
    NSString *key = TWTValidationUnderlyingErrorsByKeyKey;
    NSError *error = [self randomErrorWithoutUserInfoKey:key];
    XCTAssertNil(error.twt_underlyingErrorsByKey, @"underlying errors by key returns non-nil object");
    
    id object = [self randomNonNilObject];
    error = [self randomErrorWithObject:object forUserInfoKey:key];
    XCTAssertEqualObjects(error.twt_underlyingErrorsByKey, object, @"underlying errors by key is not set correctly");
}


- (void)testCountValidationError
{
    NSString *key = TWTValidationCountValidationErrorKey;
    NSError *error = [self randomErrorWithoutUserInfoKey:key];
    XCTAssertNil(error.twt_countValidationError, @"count validation error returns non-nil object");

    id object = [self randomNonNilObject];
    error = [self randomErrorWithObject:object forUserInfoKey:key];
    XCTAssertEqualObjects(error.twt_countValidationError, object, @"count validation error is not set correctly");
}


- (void)testElementValidationErrors
{
    NSString *key = TWTValidationElementValidationErrorsKey;
    NSError *error = [self randomErrorWithoutUserInfoKey:key];
    XCTAssertNil(error.twt_elementValidationErrors, @"element validation errors returns non-nil object");

    id object = [self randomNonNilObject];
    error = [self randomErrorWithObject:object forUserInfoKey:key];
    XCTAssertEqualObjects(error.twt_elementValidationErrors, object, @"element validation errors is not set correctly");
}


- (void)testKeyValidationErrors
{
    NSString *key = TWTValidationKeyValidationErrorsKey;
    NSError *error = [self randomErrorWithoutUserInfoKey:key];
    XCTAssertNil(error.twt_keyValidationErrors, @"key validation errors returns non-nil object");

    id object = [self randomNonNilObject];
    error = [self randomErrorWithObject:object forUserInfoKey:key];
    XCTAssertEqualObjects(error.twt_keyValidationErrors, object, @"key validation errors is not set correctly");
}


- (void)testValueValidationErrors
{
    NSString *key = TWTValidationValueValidationErrorsKey;
    NSError *error = [self randomErrorWithoutUserInfoKey:key];
    XCTAssertNil(error.twt_valueValidationErrors, @"value validation errors returns non-nil object");

    id object = [self randomNonNilObject];
    error = [self randomErrorWithObject:object forUserInfoKey:key];
    XCTAssertEqualObjects(error.twt_valueValidationErrors, object, @"value validation errors is not set correctly");
}


- (void)testKeyValuePairValidationErrors
{
    NSString *key = TWTValidationKeyValuePairValidationErrorsKey;
    NSError *error = [self randomErrorWithoutUserInfoKey:key];
    XCTAssertNil(error.twt_keyValuePairValidationErrors, @"key-value pair validation errors returns non-nil object");

    id object = [self randomNonNilObject];
    error = [self randomErrorWithObject:object forUserInfoKey:key];
    XCTAssertEqualObjects(error.twt_keyValuePairValidationErrors, object, @"key-value pair validation errors is not set correctly");
}

@end
