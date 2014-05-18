//
//  TWTCollectionValidatorTests.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 5/17/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import "TWTRandomizedTestCase.h"

#import <TWTValidation/TWTValidation.h>


@interface TWTCollectionValidatorTests : TWTRandomizedTestCase

- (void)testInit;
- (void)testCopy;
- (void)testHashAndIsEqual;

- (void)testValidateValueErrorCount;
- (void)testValidateValueErrorElements;

@end


@implementation TWTCollectionValidatorTests

- (void)testInit
{
    TWTCollectionValidator *validator = [[TWTCollectionValidator alloc] init];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertNil(validator.countValidator, @"count validator is non-nil");
    XCTAssertNil(validator.elementValidators, @"element validators is non-nil");

    TWTValidator *countValidator = [self randomValidator];
    NSArray *elementValidators = UMKGeneratedArrayWithElementCount(random() % 5 + 1, ^id(NSUInteger index) {
        return [self randomValidator];
    });

    validator = [[TWTCollectionValidator alloc] initWithCountValidator:countValidator elementValidators:elementValidators];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertEqualObjects(validator.countValidator, countValidator, @"count validator is not set correctly");
    XCTAssertEqualObjects(validator.elementValidators, elementValidators, @"element validators is not set correctly");
}


- (void)testCopy
{
    TWTValidator *countValidator = [self randomValidator];
    NSArray *elementValidators = UMKGeneratedArrayWithElementCount(random() % 5 + 1, ^id(NSUInteger index) {
        return [self randomValidator];
    });

    TWTCollectionValidator *validator = [[TWTCollectionValidator alloc] initWithCountValidator:countValidator elementValidators:elementValidators];
    TWTCollectionValidator *copy = [validator copy];

    XCTAssertEqualObjects(validator, copy, @"copy is not equal to original");
    XCTAssertEqualObjects(copy.countValidator, countValidator, @"count validator is not set correctly");
    XCTAssertEqualObjects(copy.elementValidators, elementValidators, @"element validators is not set correctly");
}


- (void)testHashAndIsEqual
{
    TWTValidator *countValidator1 = [self randomValidator];
    NSArray *elementValidators1 = UMKGeneratedArrayWithElementCount(random() % 5 + 1, ^id(NSUInteger index) {
        return [self randomValidator];
    });

    TWTValidator *countValidator2 = [TWTCompoundValidator notValidatorWithSubvalidator:countValidator1];
    NSArray *elementValidators2 = UMKGeneratedArrayWithElementCount(random() % 5 + 1, ^id(NSUInteger index) {
        return [self randomValidator];
    });

    TWTCollectionValidator *equalValidator1 = [[TWTCollectionValidator alloc] initWithCountValidator:countValidator1 elementValidators:elementValidators1];
    TWTCollectionValidator *equalValidator2 = [[TWTCollectionValidator alloc] initWithCountValidator:countValidator1 elementValidators:elementValidators1];
    TWTCollectionValidator *unequalValidator1 = [[TWTCollectionValidator alloc] initWithCountValidator:countValidator2 elementValidators:elementValidators1];
    TWTCollectionValidator *unequalValidator2 = [[TWTCollectionValidator alloc] initWithCountValidator:countValidator1 elementValidators:elementValidators2];

    XCTAssertEqual(equalValidator1.hash, equalValidator2.hash, @"hashes are different for equal objects");
    XCTAssertEqualObjects(equalValidator1, equalValidator2, @"equal objects are not equal");
    XCTAssertNotEqualObjects(equalValidator1, unequalValidator1, @"unequal objects are equal");
    XCTAssertNotEqualObjects(equalValidator1, unequalValidator2, @"unequal objects are equal");
}


- (void)testValidateValueErrorCount
{
    NSArray *array = UMKGeneratedArrayWithElementCount(random() % 100 + 1, ^id(NSUInteger index) {
        return [self randomObject];
    });

    TWTCollectionValidator *validator = [[TWTCollectionValidator alloc] initWithCountValidator:nil elementValidators:nil];
    XCTAssertTrue([validator validateValue:array error:NULL], @"fails with no count validator");

    TWTValidator *countValidator = [self mockPassingValidatorWithErrorPointer:NULL];
    validator = [[TWTCollectionValidator alloc] initWithCountValidator:countValidator elementValidators:nil];
    XCTAssertTrue([validator validateValue:array error:NULL], @"fails with passing count validator");

    countValidator = [self mockFailingValidatorWithErrorPointer:NULL error:nil];
    validator = [[TWTCollectionValidator alloc] initWithCountValidator:countValidator elementValidators:nil];
    XCTAssertFalse([validator validateValue:array error:NULL], @"passes with failing count validator");

    NSError *randomError = [self randomError];
    NSError *error = nil;
    countValidator = [self mockFailingValidatorWithErrorPointer:&error error:randomError];
    validator = [[TWTCollectionValidator alloc] initWithCountValidator:countValidator elementValidators:nil];
    XCTAssertFalse([validator validateValue:array error:&error], @"passes with failing count validator");
    XCTAssertNotNil(error, @"error is nil");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeCollectionValidatorError, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_validatedValue, array, @"incorrect validated value");
    XCTAssertEqualObjects(error.twt_countValidationError, randomError, @"error is not set correctly");
}


@end
