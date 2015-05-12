//
//  TWTCollectionValidatorTests.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 5/17/2014.
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


#pragma mark Invalid Collection Class Interfaces

@interface TWTNoCountCollection : NSObject <NSFastEnumeration>
@end


@interface TWTNoFastEnumerationCollection : NSObject

- (NSUInteger)count;

@end


#pragma mark

@interface TWTCollectionValidatorTests : TWTRandomizedTestCase

- (void)testInit;
- (void)testCopy;
- (void)testHashAndIsEqual;

- (void)testValidateValueErrorNilAndNullObjects;
- (void)testValidateValueErrorNonCollectionObjects;
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
    NSArray *elementValidators2 = UMKGeneratedArrayWithElementCount(elementValidators1.count + 1, ^id(NSUInteger index) {
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


- (void)testValidateValueErrorNilAndNullObjects
{
    TWTCollectionValidator *validator = [[TWTCollectionValidator alloc] initWithCountValidator:nil elementValidators:nil];

    NSError *error = nil;
    XCTAssertFalse([validator validateValue:nil error:&error], @"passes when value is nil");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeValueNil, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, nil, @"incorrect validated value");

    error = nil;
    XCTAssertFalse([validator validateValue:[NSNull null] error:&error], @"passes when value is null");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeValueNull, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, [NSNull null], @"incorrect validated value");
}


- (void)testValidateValueErrorNonCollectionObjects
{
    TWTCollectionValidator *validator = [[TWTCollectionValidator alloc] initWithCountValidator:nil elementValidators:nil];

    NSError *error = nil;
    id value = [[TWTNoCountCollection alloc] init];
    XCTAssertFalse([validator validateValue:value error:&error], @"passes when value does not respond to -count");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeValueNotCollection, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validated value");

    value = [[TWTNoFastEnumerationCollection alloc] init];
    XCTAssertFalse([validator validateValue:value error:&error], @"passes when value does not conform to NSFastEnumeration");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeValueNotCollection, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validated value");

    // Make sure the random object is not the NSNull instance
    while ((value = [self randomNonNilObject]) && (value == [NSNull null]));

    XCTAssertFalse([validator validateValue:value error:&error], @"passes when value is not a collection");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeValueNotCollection, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validated value");
}


- (void)testValidateValueErrorCount
{
    NSArray *array = UMKGeneratedArrayWithElementCount(random() % 10 + 1, ^id(NSUInteger index) {
        return [self randomObject];
    });

    NSSet *set = UMKGeneratedSetWithElementCount(random() % 10 + 1, ^id{
        return [self randomObject];
    });

    NSOrderedSet *orderedSet = [[NSOrderedSet alloc] initWithArray:UMKGeneratedArrayWithElementCount(random() % 10 + 1, ^id(NSUInteger index) {
        return [self randomObject];
    })];

    for (id collection in @[ array, set, orderedSet ]) {
        NSArray *elementValidators = @[ [self passingValidator] ];
        TWTCollectionValidator *validator = [[TWTCollectionValidator alloc] initWithCountValidator:nil elementValidators:elementValidators];
        XCTAssertTrue([validator validateValue:collection error:NULL], @"fails with no count validator");

        TWTValidator *countValidator = [self passingValidator];
        validator = [[TWTCollectionValidator alloc] initWithCountValidator:countValidator elementValidators:nil];
        XCTAssertTrue([validator validateValue:collection error:NULL], @"fails with passing count validator");

        countValidator = [self failingValidatorWithError:nil];
        validator = [[TWTCollectionValidator alloc] initWithCountValidator:countValidator elementValidators:nil];
        XCTAssertFalse([validator validateValue:collection error:NULL], @"passes with failing count validator");

        NSError *expectedError = UMKRandomError();
        NSError *error = nil;
        countValidator = [self failingValidatorWithError:expectedError];
        validator = [[TWTCollectionValidator alloc] initWithCountValidator:countValidator elementValidators:nil];
        XCTAssertFalse([validator validateValue:collection error:&error], @"passes with failing count validator");
        XCTAssertNotNil(error, @"error is nil");
        XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
        XCTAssertEqual(error.code, TWTValidationErrorCodeCollectionValidatorError, @"incorrect error code");
        XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
        XCTAssertEqualObjects(error.twt_validatedValue, collection, @"incorrect validated value");
        XCTAssertEqualObjects(error.twt_countValidationError, expectedError, @"count validation error is not set correctly");
    }
}


- (void)testValidateValueErrorElements
{
    NSArray *array = UMKGeneratedArrayWithElementCount(random() % 10 + 1, ^id(NSUInteger index) {
        return [self randomObject];
    });

    NSSet *set = UMKGeneratedSetWithElementCount(random() % 10 + 1, ^id{
        return [self randomObject];
    });

    NSOrderedSet *orderedSet = [[NSOrderedSet alloc] initWithArray:UMKGeneratedArrayWithElementCount(random() % 10 + 1, ^id(NSUInteger index) {
        return [self randomObject];
    })];

    for (id collection in @[ array, set, orderedSet ]) {
        TWTValidator *countValidator = [self passingValidator];
        TWTCollectionValidator *validator = [[TWTCollectionValidator alloc] initWithCountValidator:countValidator elementValidators:nil];
        XCTAssertTrue([validator validateValue:collection error:nil], @"fails with nil element validators");

        validator = [[TWTCollectionValidator alloc] initWithCountValidator:nil elementValidators:@[]];
        XCTAssertTrue([validator validateValue:collection error:nil], @"fails with empty element validators");

        NSArray *elementValidators = UMKGeneratedArrayWithElementCount(2 + random() % 8, ^id(NSUInteger index) {
            return [self passingValidator];
        });

        validator = [[TWTCollectionValidator alloc] initWithCountValidator:nil elementValidators:elementValidators];
        XCTAssertTrue([validator validateValue:collection error:nil], @"fails with passing element validators");

        NSError *error = nil;
        NSArray *expectedErrors = UMKGeneratedArrayWithElementCount(random() % 10 + 1, ^id(NSUInteger index) {
            return UMKRandomError();
        });

        NSArray *failingValidators = UMKGeneratedArrayWithElementCount(expectedErrors.count, ^id(NSUInteger index) {
            return [self failingValidatorWithError:expectedErrors[index]];
        });

        NSUInteger elementCount = [collection count];
        NSMutableArray *cumulativeErrors = [[NSMutableArray alloc] initWithCapacity:expectedErrors.count * elementCount];
        for (NSUInteger i = 0; i < elementCount; ++i) {
            [cumulativeErrors addObjectsFromArray:expectedErrors];
        }

        elementValidators = [elementValidators arrayByAddingObjectsFromArray:failingValidators];
        validator = [[TWTCollectionValidator alloc] initWithCountValidator:nil elementValidators:elementValidators];
        XCTAssertFalse([validator validateValue:collection error:&error], @"passes with failing element validators");
        XCTAssertNotNil(error, @"error is nil");
        XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
        XCTAssertEqual(error.code, TWTValidationErrorCodeCollectionValidatorError, @"incorrect error code");
        XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
        XCTAssertEqualObjects(error.twt_validatedValue, collection, @"incorrect validated value");
        XCTAssertEqualObjects(error.twt_elementValidationErrors, cumulativeErrors, @"element validation errors is not set correctly");
    }
}

@end


#pragma mark - Invalid Collection Class Implementations

@implementation TWTNoCountCollection

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len
{
    return 0;
}

@end


@implementation TWTNoFastEnumerationCollection

- (NSUInteger)count
{
    return 0;
}

@end
