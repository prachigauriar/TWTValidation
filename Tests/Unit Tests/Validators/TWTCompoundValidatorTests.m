//
//  TWTCompoundValidatorTests.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/30/2014.
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


@interface TWTCompoundValidatorTests : TWTRandomizedTestCase

- (void)testInit;
- (void)testCopy;
- (void)testHashAndIsEqual;

- (void)testValidateValueErrorForNotWithPassingValidator;
- (void)testValidateValueErrorForNotWithFailingValidator;

- (void)testValidateValueErrorForAndWithNoValidators;
- (void)testValidateValueErrorForAndWithOnePassingValidator;
- (void)testValidateValueErrorForAndWithMultiplePassingValidators;
- (void)testValidateValueErrorForAndWithOneFailingValidator;
- (void)testValidateValueErrorForAndWithMultipleFailingValidators;

- (void)testValidateValueErrorForOrWithNoValidators;
- (void)testValidateValueErrorForOrWithOnePassingValidator;
- (void)testValidateValueErrorForOrWithMultiplePassingValidators;
- (void)testValidateValueErrorForOrWithOneFailingValidator;
- (void)testValidateValueErrorForOrWithMultipleFailingValidators;

- (void)testValidateValueErrorForMutualExclusionWithNoValidators;
- (void)testValidateValueErrorForMutualExclusionWithOnePassingValidator;
- (void)testValidateValueErrorForMutualExclusionWithMultiplePassingValidators;
- (void)testValidateValueErrorForMutualExclusionWithOneFailingValidator;
- (void)testValidateValueErrorForMutualExclusionWithMultipleFailingValidators;

@end


#pragma mark

@implementation TWTCompoundValidatorTests

- (TWTCompoundValidatorType)randomCompoundValidatorType
{
    TWTCompoundValidatorType types[3] = { TWTCompoundValidatorTypeAnd, TWTCompoundValidatorTypeOr, TWTCompoundValidatorTypeMutualExclusion };
    return types[random() % 3];
}


- (void)testInit
{
    TWTCompoundValidator *validator = [[TWTCompoundValidator alloc] init];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertEqual(validator.compoundValidatorType, TWTCompoundValidatorTypeAnd, @"type is not TWTCompoundValidatorTypeAnd");
    XCTAssertNil(validator.subvalidators, @"subvalidators is non-nil");

    TWTCompoundValidatorType randomType = [self randomCompoundValidatorType];
    NSArray *randomSubvalidators = UMKGeneratedArrayWithElementCount(1 + random() % 5, ^id(NSUInteger index) {
        return [self randomValidator];
    });

    // Test all types but not
    validator = [[TWTCompoundValidator alloc] initWithType:randomType subvalidators:randomSubvalidators];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertEqual(validator.compoundValidatorType, randomType, @"type set incorrectly");
    XCTAssertEqualObjects(validator.subvalidators, randomSubvalidators, @"subvalidators set incorrectly");

    // Test not type
    NSArray *notSubvalidators = @[ [self randomValidator] ];
    validator = [[TWTCompoundValidator alloc] initWithType:TWTCompoundValidatorTypeNot subvalidators:notSubvalidators];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertEqual(validator.compoundValidatorType, TWTCompoundValidatorTypeNot, @"type set incorrectly");
    XCTAssertEqualObjects(validator.subvalidators, notSubvalidators, @"subvalidators set incorrectly");

    XCTAssertThrows([[TWTCompoundValidator alloc] initWithType:TWTCompoundValidatorTypeNot subvalidators:nil], @"does not throw with nil subvalidators");
    XCTAssertThrows([[TWTCompoundValidator alloc] initWithType:TWTCompoundValidatorTypeNot subvalidators:@[ ]], @"does not throw with empty subvalidators");

    notSubvalidators = UMKGeneratedArrayWithElementCount(random() % 5 + 2, ^id(NSUInteger index) {
        return [self randomValidator];
    });

    XCTAssertThrows([[TWTCompoundValidator alloc] initWithType:TWTCompoundValidatorTypeNot subvalidators:notSubvalidators],
                    @"does not throw with more than 1 subvalidators");

    // Test factory methods
    validator = [TWTCompoundValidator andValidatorWithSubvalidators:randomSubvalidators];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertEqual(validator.compoundValidatorType, TWTCompoundValidatorTypeAnd, @"type is not TWTCompoundValidatorTypeAnd");
    XCTAssertEqualObjects(validator.subvalidators, randomSubvalidators, @"subvalidators set incorrectly");

    validator = [TWTCompoundValidator orValidatorWithSubvalidators:randomSubvalidators];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertEqual(validator.compoundValidatorType, TWTCompoundValidatorTypeOr, @"type is not TWTCompoundValidatorTypeOr");
    XCTAssertEqualObjects(validator.subvalidators, randomSubvalidators, @"subvalidators set incorrectly");

    validator = [TWTCompoundValidator mutualExclusionValidatorWithSubvalidators:randomSubvalidators];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertEqual(validator.compoundValidatorType, TWTCompoundValidatorTypeMutualExclusion, @"type is not TWTCompoundValidatorTypeMutualExclusion");
    XCTAssertEqualObjects(validator.subvalidators, randomSubvalidators, @"subvalidators set incorrectly");
}


- (void)testCopy
{
    TWTCompoundValidatorType randomType = [self randomCompoundValidatorType];
    NSArray *randomSubvalidators = UMKGeneratedArrayWithElementCount(1 + random() % 5, ^id(NSUInteger index) {
        return [self randomValidator];
    });

    TWTCompoundValidator *validator = [[TWTCompoundValidator alloc] initWithType:randomType subvalidators:randomSubvalidators];
    TWTCompoundValidator *copy = [validator copy];
    XCTAssertEqual(copy, validator, @"copy returns different object");
    XCTAssertEqual(randomType, copy.compoundValidatorType, @"type is not set correctly");
    XCTAssertEqualObjects(randomSubvalidators, copy.subvalidators, @"subvalidators is not set correctly");
}


- (void)testHashAndIsEqual
{
    TWTCompoundValidatorType randomType1 = [self randomCompoundValidatorType];
    NSArray *randomSubvalidators1 = UMKGeneratedArrayWithElementCount(1 + random() % 5, ^id(NSUInteger index) {
        return [self randomValidator];
    });
    
    TWTCompoundValidatorType randomType2 = [self randomCompoundValidatorType];
    while (randomType2 == randomType1) {
        randomType2 = [self randomCompoundValidatorType];
    }
    
    NSArray *randomSubvalidators2 = UMKGeneratedArrayWithElementCount(1 + randomSubvalidators1.count, ^id(NSUInteger index) {
        return [self randomValidator];
    });
    
    TWTCompoundValidator *equalValidator1 = [[TWTCompoundValidator alloc] initWithType:randomType1 subvalidators:randomSubvalidators1];
    TWTCompoundValidator *equalValidator2 = [[TWTCompoundValidator alloc] initWithType:randomType1 subvalidators:randomSubvalidators1];
    TWTCompoundValidator *unequalValidator1 = [[TWTCompoundValidator alloc] initWithType:randomType2 subvalidators:randomSubvalidators1];
    TWTCompoundValidator *unequalValidator2 = [[TWTCompoundValidator alloc] initWithType:randomType1 subvalidators:randomSubvalidators2];
    
    XCTAssertEqual(equalValidator1.hash, equalValidator2.hash, @"hashes are different for equal objects");
    XCTAssertEqualObjects(equalValidator1, equalValidator2, @"equal objects are not equal");
    XCTAssertNotEqualObjects(equalValidator1, unequalValidator1, @"unequal objects are equal");
    XCTAssertNotEqualObjects(equalValidator1, unequalValidator2, @"unequal objects are equal");
}


#pragma mark - Not Validation Tests

- (void)testValidateValueErrorForNotWithPassingValidator
{
    TWTValidator *subvalidator = [self passingValidator];
    TWTCompoundValidator *validator = [TWTCompoundValidator notValidatorWithSubvalidator:subvalidator];
    XCTAssertFalse([validator validateValue:[self randomObject] error:NULL], @"passes with passing validator");

    NSError *error = nil;
    subvalidator = [self passingValidator];
    validator = [TWTCompoundValidator notValidatorWithSubvalidator:subvalidator];

    id value = [self randomObject];
    XCTAssertFalse([validator validateValue:value error:&error], @"passes with passing validator");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeCompoundValidatorError, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validated value");
}


- (void)testValidateValueErrorForNotWithFailingValidator
{
    TWTValidator *subvalidator = [self failingValidatorWithError:UMKRandomError()];
    TWTCompoundValidator *validator = [TWTCompoundValidator notValidatorWithSubvalidator:subvalidator];
    XCTAssertTrue([validator validateValue:[self randomObject] error:NULL], @"fails with passing validator");

    NSError *error = nil;
    subvalidator = [self failingValidatorWithError:UMKRandomError()];
    validator = [TWTCompoundValidator notValidatorWithSubvalidator:subvalidator];
    XCTAssertTrue([validator validateValue:[self randomObject] error:&error], @"fails with passing validator");
}


#pragma mark - And Validation Tests

- (void)testValidateValueErrorForAndWithNoValidators
{
    TWTCompoundValidator *validator = [TWTCompoundValidator andValidatorWithSubvalidators:nil];
    XCTAssertTrue([validator validateValue:[self randomObject] error:NULL], @"fails with nil validators");

    validator = [TWTCompoundValidator andValidatorWithSubvalidators:@[ ]];
    XCTAssertTrue([validator validateValue:[self randomObject] error:NULL], @"fails with no validators");
}


- (void)testValidateValueErrorForAndWithOnePassingValidator
{
    NSArray *subvalidators = @[ [self passingValidator] ];
    TWTCompoundValidator *validator = [TWTCompoundValidator andValidatorWithSubvalidators:subvalidators];
    XCTAssertTrue([validator validateValue:[self randomObject] error:NULL], @"fails with one passing validator");
    
    NSError *error = nil;
    validator = [TWTCompoundValidator andValidatorWithSubvalidators:subvalidators];
    XCTAssertTrue([validator validateValue:[self randomObject] error:&error], @"fails with one passing validator");
}


- (void)testValidateValueErrorForAndWithMultiplePassingValidators
{
    NSArray *subvalidators = UMKGeneratedArrayWithElementCount(2 + random() % 8, ^id(NSUInteger index) {
        return [self passingValidator];
    });

    TWTCompoundValidator *validator = [TWTCompoundValidator andValidatorWithSubvalidators:subvalidators];
    XCTAssertTrue([validator validateValue:[self randomObject] error:nil], @"fails with multiple passing validators");

    NSError *error = nil;
    validator = [TWTCompoundValidator andValidatorWithSubvalidators:subvalidators];
    XCTAssertTrue([validator validateValue:[self randomObject] error:&error], @"fails with multiple passing validators");
}


- (void)testValidateValueErrorForAndWithOneFailingValidator
{
    NSArray *subvalidators = @[ [self failingValidatorWithError:UMKRandomError()] ];
    TWTCompoundValidator *validator = [TWTCompoundValidator andValidatorWithSubvalidators:subvalidators];
    XCTAssertFalse([validator validateValue:[self randomObject] error:NULL]);

    NSError *error = nil;
    NSError *expectedError = UMKRandomError();
    subvalidators = @[ [self failingValidatorWithError:expectedError] ];
    validator = [TWTCompoundValidator andValidatorWithSubvalidators:subvalidators];

    id value = [self randomObject];
    XCTAssertFalse([validator validateValue:value error:&error], @"passes with one failing validator");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeCompoundValidatorError, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validated value");
    XCTAssertEqualObjects(error.twt_underlyingErrors, @[ expectedError ], @"incorrect underlying errors");

}


- (void)testValidateValueErrorForAndWithMultipleFailingValidators
{
    NSArray *subvalidators = UMKGeneratedArrayWithElementCount(4 + random() % 6, ^id(NSUInteger index) {
        return index % 2 == 0 ? [self passingValidator] : [self failingValidatorWithError:UMKRandomError()];
    });

    TWTCompoundValidator *validator = [TWTCompoundValidator andValidatorWithSubvalidators:subvalidators];
    XCTAssertFalse([validator validateValue:[self randomObject] error:NULL], @"passes with multiple failing validators");

    NSArray *expectedErrors = UMKGeneratedArrayWithElementCount(3, ^id(NSUInteger index) {
        return UMKRandomError();
    });

    subvalidators = @[ [self passingValidator],
                       [self failingValidatorWithError:expectedErrors[0]],
                       [self failingValidatorWithError:expectedErrors[1]],
                       [self passingValidator],
                       [self failingValidatorWithError:expectedErrors[2]],
                       [self passingValidator] ];

    NSError *error = nil;
    id value = [self randomObject];
    validator = [TWTCompoundValidator andValidatorWithSubvalidators:subvalidators];
    XCTAssertFalse([validator validateValue:value error:&error], @"passes with multiple failing validators");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeCompoundValidatorError, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validated value");
    XCTAssertEqualObjects(error.twt_underlyingErrors, expectedErrors, @"incorrect underlying errors");
}


#pragma mark - Or Validation Tests

- (void)testValidateValueErrorForOrWithNoValidators
{
    TWTCompoundValidator *validator = [TWTCompoundValidator orValidatorWithSubvalidators:nil];
    XCTAssertFalse([validator validateValue:[self randomObject] error:NULL], @"passes with nil validators");

    NSError *error = nil;
    id value = [self randomObject];
    XCTAssertFalse([validator validateValue:value error:&error], @"passes with nil validators");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeCompoundValidatorError, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validatedValue");
    XCTAssertNil(error.twt_underlyingErrors, @"non-nil underlying errors");

    validator = [TWTCompoundValidator orValidatorWithSubvalidators:@[ ]];
    XCTAssertFalse([validator validateValue:[self randomObject] error:NULL], @"passes with nil validators");

    error = nil;
    value = [self randomObject];
    XCTAssertFalse([validator validateValue:value error:&error], @"passes with nil validators");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeCompoundValidatorError, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validatedValue");
    XCTAssertNil(error.twt_underlyingErrors, @"non-nil underlying errors");
}


- (void)testValidateValueErrorForOrWithOnePassingValidator
{
    NSArray *subvalidators = @[ [self passingValidator] ];
    TWTCompoundValidator *validator = [TWTCompoundValidator orValidatorWithSubvalidators:subvalidators];
    XCTAssertTrue([validator validateValue:[self randomObject] error:NULL], @"fails with one passing validator");

    NSError *error = nil;
    validator = [TWTCompoundValidator orValidatorWithSubvalidators:subvalidators];
    XCTAssertTrue([validator validateValue:[self randomObject] error:&error], @"fails with one passing validator");
}


- (void)testValidateValueErrorForOrWithMultiplePassingValidators
{
    NSArray *subvalidators = UMKGeneratedArrayWithElementCount(2 + random() % 8, ^id(NSUInteger index) {
        return index % 2 == 0 ? [self passingValidator] : [self failingValidatorWithError:UMKRandomError()];
    });

    TWTCompoundValidator *validator = [TWTCompoundValidator orValidatorWithSubvalidators:subvalidators];
    XCTAssertTrue([validator validateValue:[self randomObject] error:NULL], @"fails with multiple passing validators");

    NSArray *expectedErrors = UMKGeneratedArrayWithElementCount(3, ^id(NSUInteger index) {
        return UMKRandomError();
    });

    NSError *error = nil;
    subvalidators = @[ [self passingValidator],
                       [self failingValidatorWithError:expectedErrors[0]],
                       [self failingValidatorWithError:expectedErrors[1]],
                       [self passingValidator],
                       [self failingValidatorWithError:expectedErrors[2]],
                       [self passingValidator] ];

    error = nil;
    validator = [TWTCompoundValidator orValidatorWithSubvalidators:subvalidators];
    XCTAssertTrue([validator validateValue:[self randomObject] error:&error], @"fails with multiple passing validators");
}


- (void)testValidateValueErrorForOrWithOneFailingValidator
{
    NSError *expectedError = UMKRandomError();
    NSArray *subvalidators = @[ [self failingValidatorWithError:expectedError] ];
    TWTCompoundValidator *validator = [TWTCompoundValidator orValidatorWithSubvalidators:subvalidators];
    XCTAssertFalse([validator validateValue:[self randomObject] error:NULL]);

    NSError *error = nil;
    id value = [self randomObject];
    XCTAssertFalse([validator validateValue:value error:&error], @"passes with one failing validator");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeCompoundValidatorError, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validatedValue");
    XCTAssertEqualObjects(error.twt_underlyingErrors, @[ expectedError ], @"incorrect underlying errors");
}


- (void)testValidateValueErrorForOrWithMultipleFailingValidators
{
    NSArray *subvalidators = UMKGeneratedArrayWithElementCount(2 + random() % 8, ^id(NSUInteger index) {
        return [self failingValidatorWithError:UMKRandomError()];
    });

    TWTCompoundValidator *validator = [TWTCompoundValidator orValidatorWithSubvalidators:subvalidators];
    XCTAssertFalse([validator validateValue:[self randomObject] error:nil], @"passes with multiple failing validators");

    NSArray *expectedErrors = UMKGeneratedArrayWithElementCount(3, ^id(NSUInteger index) {
        return UMKRandomError();
    });

    NSError *error = nil;
    subvalidators = @[ [self failingValidatorWithError:expectedErrors[0]],
                       [self failingValidatorWithError:expectedErrors[1]],
                       [self failingValidatorWithError:expectedErrors[2]] ];

    validator = [TWTCompoundValidator orValidatorWithSubvalidators:subvalidators];
    id value = [self randomObject];
    XCTAssertFalse([validator validateValue:value error:&error], @"passes with multiple failing validators");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeCompoundValidatorError, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validatedValue");
    XCTAssertEqualObjects(error.twt_underlyingErrors, expectedErrors, @"incorrect underlying errors");
}


#pragma mark - Mutual Exclusion Validation Tests

- (void)testValidateValueErrorForMutualExclusionWithNoValidators
{
    TWTCompoundValidator *validator = [TWTCompoundValidator mutualExclusionValidatorWithSubvalidators:nil];
    XCTAssertFalse([validator validateValue:[self randomObject] error:NULL], @"passes with nil validators");

    NSError *error = nil;
    id value = [self randomObject];
    XCTAssertFalse([validator validateValue:value error:&error], @"passes with nil validators");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeCompoundValidatorError, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validatedValue");
    XCTAssertNil(error.twt_underlyingErrors, @"non-nil underlying errors");

    validator = [TWTCompoundValidator mutualExclusionValidatorWithSubvalidators:@[ ]];
    XCTAssertFalse([validator validateValue:[self randomObject] error:NULL], @"passes with nil validators");

    error = nil;
    value = [self randomObject];
    XCTAssertFalse([validator validateValue:value error:&error], @"passes with nil validators");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeCompoundValidatorError, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validatedValue");
    XCTAssertNil(error.twt_underlyingErrors, @"non-nil underlying errors");
}


- (void)testValidateValueErrorForMutualExclusionWithOnePassingValidator
{
    NSArray *subvalidators = @[ [self passingValidator] ];
    TWTCompoundValidator *validator = [TWTCompoundValidator mutualExclusionValidatorWithSubvalidators:subvalidators];
    XCTAssertTrue([validator validateValue:[self randomObject] error:NULL], @"fails with one passing validator");

    NSError *error = nil;
    XCTAssertTrue([validator validateValue:[self randomObject] error:&error], @"fails with one passing validator");
}


- (void)testValidateValueErrorForMutualExclusionWithMultiplePassingValidators
{
    NSArray *subvalidators = UMKGeneratedArrayWithElementCount(3 + random() % 8, ^id(NSUInteger index) {
        return index % 2 == 0 ? [self passingValidator] : [self failingValidatorWithError:UMKRandomError()];
    });

    TWTCompoundValidator *validator = [TWTCompoundValidator mutualExclusionValidatorWithSubvalidators:subvalidators];
    XCTAssertFalse([validator validateValue:[self randomObject] error:NULL], @"passes with multiple passing validators");

    NSArray *expectedErrors = UMKGeneratedArrayWithElementCount(3, ^id(NSUInteger index) {
        return UMKRandomError();
    });

    NSError *error = nil;
    subvalidators = @[ [self passingValidator],
                       [self failingValidatorWithError:expectedErrors[0]],
                       [self failingValidatorWithError:expectedErrors[1]],
                       [self failingValidatorWithError:expectedErrors[2]],
                       [self passingValidator] ];

    error = nil;
    validator = [TWTCompoundValidator mutualExclusionValidatorWithSubvalidators:subvalidators];
    id value = [self randomObject];
    XCTAssertFalse([validator validateValue:value error:&error], @"passes with nil validators");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeCompoundValidatorError, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validatedValue");
    XCTAssertEqualObjects(error.twt_underlyingErrors, expectedErrors, @"incorrect underlying errors");
}


- (void)testValidateValueErrorForMutualExclusionWithOneFailingValidator
{
    NSError *expectedError = UMKRandomError();
    NSArray *subvalidators = @[ [self failingValidatorWithError:expectedError] ];
    TWTCompoundValidator *validator = [TWTCompoundValidator mutualExclusionValidatorWithSubvalidators:subvalidators];
    XCTAssertFalse([validator validateValue:[self randomObject] error:NULL]);

    NSError *error = nil;
    id value = [self randomObject];
    XCTAssertFalse([validator validateValue:value error:&error], @"passes with one failing validator");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeCompoundValidatorError, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validated value");
    XCTAssertEqualObjects(error.twt_underlyingErrors, @[ expectedError ], @"incorrect underlying errors");
}


- (void)testValidateValueErrorForMutualExclusionWithMultipleFailingValidators
{
    NSArray *subvalidators = UMKGeneratedArrayWithElementCount(2 + random() % 8, ^id(NSUInteger index) {
        return [self failingValidatorWithError:UMKRandomError()];
    });

    TWTCompoundValidator *validator = [TWTCompoundValidator orValidatorWithSubvalidators:subvalidators];
    XCTAssertFalse([validator validateValue:[self randomObject] error:nil], @"passes with multiple failing validators");

    NSArray *expectedErrors = UMKGeneratedArrayWithElementCount(3, ^id(NSUInteger index) {
        return UMKRandomError();
    });

    NSError *error = nil;
    subvalidators = @[ [self failingValidatorWithError:expectedErrors[0]],
                       [self failingValidatorWithError:expectedErrors[1]],
                       [self failingValidatorWithError:expectedErrors[2]] ];

    validator = [TWTCompoundValidator orValidatorWithSubvalidators:subvalidators];
    id value = [self randomObject];
    XCTAssertFalse([validator validateValue:value error:&error], @"passes with multiple failing validators");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeCompoundValidatorError, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validated value");
    XCTAssertEqualObjects(error.twt_underlyingErrors, expectedErrors, @"incorrect underlying errors");
}

@end
