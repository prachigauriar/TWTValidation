//
//  TWTCompoundValidatorTests.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/30/2014.
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

#import <TWTValidation/TWTCompoundValidator.h>
#import <TWTValidation/TWTValidationErrors.h>

@interface TWTCompoundValidatorTests : TWTRandomizedTestCase

- (void)testInit;
- (void)testCopy;
- (void)testHashAndIsEqual;

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


#pragma mark -

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
        return UMKRandomBoolean() ? [self mockPassingValidatorWithErrorPointer:NULL] : [self mockFailingValidatorWithErrorPointer:NULL error:self.randomError];
    });
    
    validator = [[TWTCompoundValidator alloc] initWithType:randomType subvalidators:randomSubvalidators];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertEqual(validator.compoundValidatorType, randomType, @"type set incorrectly");
    XCTAssertEqualObjects(validator.subvalidators, randomSubvalidators, @"subvalidators set incorrectly");

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
        return UMKRandomBoolean() ? [self mockPassingValidatorWithErrorPointer:NULL] : [self mockFailingValidatorWithErrorPointer:NULL error:self.randomError];
    });

    TWTCompoundValidator *validator = [[TWTCompoundValidator alloc] initWithType:randomType subvalidators:randomSubvalidators];
    TWTCompoundValidator *copy = [validator copy];
    XCTAssertEqual(copy, validator, @"copy returns different object");
    XCTAssertEqual(randomType, copy.compoundValidatorType, @"type was not set correctly");
    XCTAssertEqualObjects(randomSubvalidators, copy.subvalidators, @"subvalidators was not set correctly");
}


- (void)testHashAndIsEqual
{
    TWTCompoundValidatorType randomType1 = [self randomCompoundValidatorType];
    NSArray *randomSubvalidators1 = UMKGeneratedArrayWithElementCount(1 + random() % 5, ^id(NSUInteger index) {
        return UMKRandomBoolean() ? [self mockPassingValidatorWithErrorPointer:NULL] : [self mockFailingValidatorWithErrorPointer:NULL error:self.randomError];
    });
    
    TWTCompoundValidatorType randomType2 = [self randomCompoundValidatorType];
    while (randomType2 == randomType1) {
        randomType2 = [self randomCompoundValidatorType];
    }
    
    NSArray *randomSubvalidators2 = UMKGeneratedArrayWithElementCount(1 + randomSubvalidators1.count, ^id(NSUInteger index) {
        return UMKRandomBoolean() ? [self mockPassingValidatorWithErrorPointer:NULL] : [self mockFailingValidatorWithErrorPointer:NULL error:self.randomError];
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


#pragma mark - And Validation Tests

- (void)testValidateValueErrorForAndWithNoValidators
{
    TWTCompoundValidator *validator = [TWTCompoundValidator andValidatorWithSubvalidators:nil];
    XCTAssertTrue([validator validateValue:nil error:NULL], @"fails with nil validators");
    XCTAssertTrue([validator validateValue:UMKRandomUnsignedNumber() error:NULL], @"fails with nil validators");

    validator = [TWTCompoundValidator andValidatorWithSubvalidators:@[ ]];
    XCTAssertTrue([validator validateValue:nil error:NULL], @"fails with no validators");
    XCTAssertTrue([validator validateValue:UMKRandomUnicodeStringWithLength(10) error:NULL], @"fails with no validators");
}


- (void)testValidateValueErrorForAndWithOnePassingValidator
{
    NSArray *subvalidators = @[ [self mockPassingValidatorWithErrorPointer:NULL] ];
    TWTCompoundValidator *validator = [TWTCompoundValidator andValidatorWithSubvalidators:subvalidators];
    XCTAssertTrue([validator validateValue:nil error:NULL], @"fails with one passing validator");
    XCTAssertTrue([validator validateValue:UMKRandomAlphanumericStringWithLength(10) error:NULL], @"fails with one passing validator");
    
    NSError *error = nil;
    subvalidators = @[ [self mockPassingValidatorWithErrorPointer:&error] ];
    validator = [TWTCompoundValidator andValidatorWithSubvalidators:subvalidators];
    XCTAssertTrue([validator validateValue:nil error:&error], @"fails with one passing validator");
    XCTAssertTrue([validator validateValue:UMKRandomUnsignedNumber() error:&error], @"fails with one passing validator");
}


- (void)testValidateValueErrorForAndWithMultiplePassingValidators
{
    NSArray *subvalidators = UMKGeneratedArrayWithElementCount(2 + random() % 8, ^id(NSUInteger index) {
        return [self mockPassingValidatorWithErrorPointer:NULL];
    });

    TWTCompoundValidator *validator = [TWTCompoundValidator andValidatorWithSubvalidators:subvalidators];
    XCTAssertTrue([validator validateValue:nil error:nil], @"fails with multiple passing validators");
    XCTAssertTrue([validator validateValue:UMKRandomUnicodeStringWithLength(10) error:nil], @"fails with multiple passing validators");

    NSError *error = nil;
    subvalidators = @[ [self mockPassingValidatorWithErrorPointer:&error],
                       [self mockPassingValidatorWithErrorPointer:&error],
                       [self mockPassingValidatorWithErrorPointer:&error] ];

    validator = [TWTCompoundValidator andValidatorWithSubvalidators:subvalidators];
    XCTAssertTrue([validator validateValue:nil error:&error], @"fails with multiple passing validators");
    XCTAssertTrue([validator validateValue:UMKRandomAlphanumericStringWithLength(10) error:&error], @"fails with multiple passing validators");
}


- (void)testValidateValueErrorForAndWithOneFailingValidator
{
    NSArray *subvalidators = @[ [self mockFailingValidatorWithErrorPointer:NULL error:[self randomError]] ];
    TWTCompoundValidator *validator = [TWTCompoundValidator andValidatorWithSubvalidators:subvalidators];
    XCTAssertFalse([validator validateValue:nil error:NULL]);
    XCTAssertFalse([validator validateValue:UMKRandomUnsignedNumber() error:NULL]);

    NSError *error = nil;
    NSError *expectedError = [self randomError];
    subvalidators = @[ [self mockFailingValidatorWithErrorPointer:&error error:expectedError] ];
    validator = [TWTCompoundValidator andValidatorWithSubvalidators:subvalidators];
    XCTAssertFalse([validator validateValue:nil error:&error], @"passes with one failing validator");
    XCTAssertEqualObjects(error, expectedError, @"incorrect error returned");
    error = nil;
    XCTAssertFalse([validator validateValue:UMKRandomUnicodeStringWithLength(10) error:&error], @"passes with one failing validator");
    XCTAssertEqualObjects(error, expectedError, @"incorrect error returned");
}


- (void)testValidateValueErrorForAndWithMultipleFailingValidators
{
    NSArray *subvalidators = UMKGeneratedArrayWithElementCount(4 + random() % 6, ^id(NSUInteger index) {
        if (index % 2 == 0) {
            return [self mockPassingValidatorWithErrorPointer:NULL];
        } else {
            return [self mockFailingValidatorWithErrorPointer:NULL error:[self randomError]];
        }
    });

    TWTCompoundValidator *validator = [TWTCompoundValidator andValidatorWithSubvalidators:subvalidators];
    XCTAssertFalse([validator validateValue:nil error:NULL], @"passes with multiple failing validators");
    XCTAssertFalse([validator validateValue:UMKRandomAlphanumericStringWithLength(10) error:NULL], @"passes with multiple failing validators");

    NSError *error = nil;
    NSArray *expectedErrors = UMKGeneratedArrayWithElementCount(3, ^id(NSUInteger index) {
        return [self randomError];
    });

    subvalidators = @[ [self mockPassingValidatorWithErrorPointer:&error],
                       [self mockFailingValidatorWithErrorPointer:&error error:expectedErrors[0]],
                       [self mockFailingValidatorWithErrorPointer:&error error:expectedErrors[1]],
                       [self mockPassingValidatorWithErrorPointer:&error],
                       [self mockFailingValidatorWithErrorPointer:&error error:expectedErrors[2]],
                       [self mockPassingValidatorWithErrorPointer:&error] ];

    validator = [TWTCompoundValidator andValidatorWithSubvalidators:subvalidators];
    XCTAssertFalse([validator validateValue:nil error:&error], @"passes with multiple failing validators");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeCompoundValidatorError, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_underlyingErrors, expectedErrors, @"incorrect underlying errors");

    error = nil;
    XCTAssertFalse([validator validateValue:UMKRandomUnsignedNumber() error:&error], @"passes with multiple failing validators");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeCompoundValidatorError, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_underlyingErrors, expectedErrors, @"incorrect underlying errors");
}


#pragma mark - Or Validation Tests

- (void)testValidateValueErrorForOrWithNoValidators
{
    TWTCompoundValidator *validator = [TWTCompoundValidator orValidatorWithSubvalidators:nil];
    XCTAssertFalse([validator validateValue:nil error:NULL], @"passes with nil validators");
    XCTAssertFalse([validator validateValue:UMKRandomUnsignedNumber() error:NULL], @"passes with nil validators");

    NSError *error = nil;
    XCTAssertFalse([validator validateValue:nil error:&error], @"passes with nil validators");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeCompoundValidatorError, @"incorrect error code");
    XCTAssertNil(error.twt_validatedValue, @"non-nil validatedValue");
    XCTAssertNil(error.twt_underlyingErrors, @"non-nil incorrect underlying errors");

    id value = UMKRandomAlphanumericStringWithLength(10);
    error = nil;
    XCTAssertFalse([validator validateValue:value error:&error], @"passes with nil validators");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeCompoundValidatorError, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validatedValue");
    XCTAssertNil(error.twt_underlyingErrors, @"non-nil incorrect underlying errors");

    validator = [TWTCompoundValidator orValidatorWithSubvalidators:@[ ]];
    XCTAssertFalse([validator validateValue:nil error:NULL], @"passes with nil validators");
    XCTAssertFalse([validator validateValue:UMKRandomUnsignedNumber() error:NULL], @"passes with nil validators");

    error = nil;
    XCTAssertFalse([validator validateValue:nil error:&error], @"passes with nil validators");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeCompoundValidatorError, @"incorrect error code");
    XCTAssertNil(error.twt_validatedValue, @"non-nil validatedValue");
    XCTAssertNil(error.twt_underlyingErrors, @"non-nil incorrect underlying errors");

    value = UMKRandomUnicodeStringWithLength(10);
    error = nil;
    XCTAssertFalse([validator validateValue:value error:&error], @"passes with nil validators");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeCompoundValidatorError, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validatedValue");
    XCTAssertNil(error.twt_underlyingErrors, @"non-nil incorrect underlying errors");
}


- (void)testValidateValueErrorForOrWithOnePassingValidator
{
    NSArray *subvalidators = @[ [self mockPassingValidatorWithErrorPointer:NULL] ];
    TWTCompoundValidator *validator = [TWTCompoundValidator orValidatorWithSubvalidators:subvalidators];
    XCTAssertTrue([validator validateValue:nil error:NULL], @"fails with one passing validator");
    XCTAssertTrue([validator validateValue:UMKRandomAlphanumericStringWithLength(10) error:NULL], @"fails with one passing validator");

    NSError *error = nil;
    subvalidators = @[ [self mockPassingValidatorWithErrorPointer:&error] ];
    validator = [TWTCompoundValidator orValidatorWithSubvalidators:subvalidators];
    XCTAssertTrue([validator validateValue:nil error:&error], @"fails with one passing validator");
    XCTAssertTrue([validator validateValue:UMKRandomUnsignedNumber() error:&error], @"fails with one passing validator");
}


- (void)testValidateValueErrorForOrWithMultiplePassingValidators
{
    NSArray *subvalidators = UMKGeneratedArrayWithElementCount(2 + random() % 8, ^id(NSUInteger index) {
        if (index % 2 == 0) {
            return [self mockPassingValidatorWithErrorPointer:NULL];
        } else {
            return [self mockFailingValidatorWithErrorPointer:NULL error:[self randomError]];
        }
    });

    TWTCompoundValidator *validator = [TWTCompoundValidator orValidatorWithSubvalidators:subvalidators];
    XCTAssertTrue([validator validateValue:nil error:NULL], @"fails with multiple passing validators");
    XCTAssertTrue([validator validateValue:UMKRandomAlphanumericStringWithLength(10) error:NULL], @"fails with multiple passing validators");

    NSError *error = nil;
    subvalidators = @[ [self mockPassingValidatorWithErrorPointer:&error],
                       [self mockFailingValidatorWithErrorPointer:&error error:[self randomError]],
                       [self mockFailingValidatorWithErrorPointer:&error error:[self randomError]],
                       [self mockPassingValidatorWithErrorPointer:&error],
                       [self mockFailingValidatorWithErrorPointer:&error error:[self randomError]],
                       [self mockPassingValidatorWithErrorPointer:&error] ];

    validator = [TWTCompoundValidator orValidatorWithSubvalidators:subvalidators];
    XCTAssertTrue([validator validateValue:nil error:&error], @"fails with multiple passing validators");

    error = nil;
    XCTAssertTrue([validator validateValue:UMKRandomUnsignedNumber() error:&error], @"fails with multiple passing validators");
}


- (void)testValidateValueErrorForOrWithOneFailingValidator
{
    NSArray *subvalidators = @[ [self mockFailingValidatorWithErrorPointer:NULL error:[self randomError]] ];
    TWTCompoundValidator *validator = [TWTCompoundValidator orValidatorWithSubvalidators:subvalidators];
    XCTAssertFalse([validator validateValue:nil error:NULL]);
    XCTAssertFalse([validator validateValue:UMKRandomUnsignedNumber() error:NULL]);

    NSError *error = nil;
    NSError *expectedError = [self randomError];
    subvalidators = @[ [self mockFailingValidatorWithErrorPointer:&error error:expectedError] ];
    validator = [TWTCompoundValidator orValidatorWithSubvalidators:subvalidators];
    XCTAssertFalse([validator validateValue:nil error:&error], @"passes with one failing validator");
    XCTAssertEqualObjects(error, expectedError, @"incorrect error returned");
    error = nil;
    XCTAssertFalse([validator validateValue:UMKRandomUnicodeStringWithLength(10) error:&error], @"passes with one failing validator");
    XCTAssertEqualObjects(error, expectedError, @"incorrect error returned");
}


- (void)testValidateValueErrorForOrWithMultipleFailingValidators
{
    NSArray *subvalidators = UMKGeneratedArrayWithElementCount(2 + random() % 8, ^id(NSUInteger index) {
        return [self mockFailingValidatorWithErrorPointer:NULL error:[self randomError]];
    });

    TWTCompoundValidator *validator = [TWTCompoundValidator orValidatorWithSubvalidators:subvalidators];
    XCTAssertFalse([validator validateValue:nil error:nil], @"passes with multiple failing validators");
    XCTAssertFalse([validator validateValue:UMKRandomUnicodeStringWithLength(10) error:nil], @"passes with multiple failing validators");

    NSArray *expectedErrors = UMKGeneratedArrayWithElementCount(3, ^id(NSUInteger index) {
        return [self randomError];
    });

    NSError *error = nil;
    subvalidators = @[ [self mockFailingValidatorWithErrorPointer:&error error:expectedErrors[0]],
                       [self mockFailingValidatorWithErrorPointer:&error error:expectedErrors[1]],
                       [self mockFailingValidatorWithErrorPointer:&error error:expectedErrors[2]] ];

    validator = [TWTCompoundValidator orValidatorWithSubvalidators:subvalidators];
    XCTAssertFalse([validator validateValue:nil error:&error], @"passes with multiple failing validators");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeCompoundValidatorError, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_underlyingErrors, expectedErrors, @"incorrect underlying errors");

    error = nil;
    XCTAssertFalse([validator validateValue:UMKRandomUnsignedNumber() error:&error], @"passes with multiple failing validators");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeCompoundValidatorError, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_underlyingErrors, expectedErrors, @"incorrect underlying errors");
}


//- (void)testValidateValueErrorForMutualExclusionWithNoValidators
//{
//    TWTCompoundValidator *validator = [TWTCompoundValidator mutualExclusionValidatorWithSubvalidators:nil];
//    XCTAssertFalse([validator validateValue:nil error:NULL], @"passes with nil validators");
//    XCTAssertFalse([validator validateValue:UMKRandomUnsignedNumber() error:NULL], @"passes with nil validators");
//
//    validator = [TWTCompoundValidator mutualExclusionValidatorWithSubvalidators:@[ ]];
//    XCTAssertFalse([validator validateValue:nil error:NULL], @"passes with no validators");
//    XCTAssertFalse([validator validateValue:UMKRandomUnicodeStringWithLength(10) error:NULL], @"passes with no validators");
//}


//- (void)testValidateValueErrorForMutualExclusionWithOnePassingValidator;
//- (void)testValidateValueErrorForMutualExclusionWithMultiplePassingValidators;
//- (void)testValidateValueErrorForMutualExclusionWithOneFailingValidator;
//- (void)testValidateValueErrorForMutualExclusionWithMultipleFailingValidators;

@end
