//
//  TWTKeyedCollectionValidatorTests.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 6/1/2014.
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


#pragma mark Invalid Keyed Collection Class Interfaces

@interface TWTNoCountKeyedCollection : NSObject <NSFastEnumeration>

- (id)objectForKey:(id)key;

@end


@interface TWTNoFastEnumerationKeyedCollection : NSObject

- (NSUInteger)count;
- (id)objectForKey:(id)key;

@end


@interface TWTNoObjectForKeyKeyedCollection : NSObject <NSFastEnumeration>

- (NSUInteger)count;

@end


#pragma mark

@interface TWTKeyedCollectionValidatorTests : TWTRandomizedTestCase

- (void)testInit;
- (void)testCopy;
- (void)testHashAndIsEqual;

- (void)testValidateValueErrorNilAndNullObjects;
- (void)testValidateValueErrorNonKeyedCollectionObjects;
- (void)testValidateValueErrorCount;
- (void)testValidateValueErrorKeys;
- (void)testValidateValueErrorValues;
- (void)testValidateValueErrorKeyValuePairs;

@end


@implementation TWTKeyedCollectionValidatorTests

- (TWTKeyValuePairValidator *)randomKeyValuePairValidatorWithKey:(id)key
{
    return [[TWTKeyValuePairValidator alloc] initWithKey:(key ? key : [NSNull null]) valueValidator:[self randomValidator]];
}


- (TWTKeyValuePairValidator *)randomKeyValuePairValidator
{
    return [self randomKeyValuePairValidatorWithKey:UMKRandomUnicodeString()];
}


- (TWTKeyValuePairValidator *)passingKeyValuePairValidatorWithKey:(id)key
{
    return [[TWTKeyValuePairValidator alloc] initWithKey:(key ? key : [NSNull null]) valueValidator:[self passingValidator]];
}


- (TWTKeyValuePairValidator *)passingKeyValuePairValidatorWithRandomKey
{
    return [self passingKeyValuePairValidatorWithKey:UMKRandomUnicodeString()];
}


- (TWTKeyValuePairValidator *)failingKeyValuePairValidatorWithKey:(id)key error:(NSError *)error
{
    return [[TWTKeyValuePairValidator alloc] initWithKey:(key ? key : [NSNull null]) valueValidator:[self failingValidatorWithError:error]];
}


- (NSDictionary *)randomDictionary
{
    return UMKGeneratedDictionaryWithElementCount(random() % 10 + 1, ^id{
        return UMKRandomUnicodeStringWithLength(random() % 10 + 1);
    }, ^id(id key) {
        return [self randomObject];
    });
}


- (NSMapTable *)randomMapTable
{
    NSMapTable *mapTable = [NSMapTable strongToStrongObjectsMapTable];
    NSUInteger elementCount = random() % 10 + 1;
    for (NSUInteger i = 0; i < elementCount; ++i) {
        [mapTable setObject:[self randomNonNilObject] forKey:UMKRandomUnicodeStringWithLength(random() % 10 + 1)];
    }

    return mapTable;
}


- (void)testInit
{
    TWTKeyedCollectionValidator *validator = [[TWTKeyedCollectionValidator alloc] init];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertNil(validator.countValidator, @"count validator is non-nil");
    XCTAssertNil(validator.keyValidators, @"key validators is non-nil");
    XCTAssertNil(validator.valueValidators, @"value validators is non-nil");
    XCTAssertNil(validator.keyValuePairValidators, @"key-value pair validators is non-nil");

    TWTValidator *countValidator = [self randomValidator];
    NSArray *keyValidators = UMKGeneratedArrayWithElementCount(random() % 5 + 1, ^id(NSUInteger index) {
        return [self randomValidator];
    });

    NSArray *valueValidators = UMKGeneratedArrayWithElementCount(random() % 5 + 1, ^id(NSUInteger index) {
        return [self randomValidator];
    });

    NSArray *keyValuePairValidators = UMKGeneratedArrayWithElementCount(random() % 5 + 1, ^id(NSUInteger index) {
        return [self randomKeyValuePairValidator];
    });

    validator = [[TWTKeyedCollectionValidator alloc] initWithCountValidator:countValidator
                                                              keyValidators:keyValidators
                                                            valueValidators:valueValidators
                                                     keyValuePairValidators:keyValuePairValidators];

    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertEqualObjects(validator.countValidator, countValidator, @"count validator is not set correctly");
    XCTAssertEqualObjects(validator.keyValidators, keyValidators, @"key validators is not set correctly");
    XCTAssertEqualObjects(validator.valueValidators, valueValidators, @"value validators is not set correctly");
    XCTAssertEqualObjects(validator.keyValuePairValidators, keyValuePairValidators, @"key-value pair validators is not set correctly");
}


- (void)testCopy
{
    TWTValidator *countValidator = [self randomValidator];
    NSArray *keyValidators = UMKGeneratedArrayWithElementCount(random() % 5 + 1, ^id(NSUInteger index) {
        return [self randomValidator];
    });

    NSArray *valueValidators = UMKGeneratedArrayWithElementCount(random() % 5 + 1, ^id(NSUInteger index) {
        return [self randomValidator];
    });

    NSArray *keyValuePairValidators = UMKGeneratedArrayWithElementCount(random() % 5 + 1, ^id(NSUInteger index) {
        return [self randomKeyValuePairValidator];
    });

    TWTKeyedCollectionValidator *validator = [[TWTKeyedCollectionValidator alloc] initWithCountValidator:countValidator
                                                                                           keyValidators:keyValidators
                                                                                         valueValidators:valueValidators
                                                                                  keyValuePairValidators:keyValuePairValidators];
    
    TWTKeyedCollectionValidator *copy = [validator copy];

    XCTAssertEqualObjects(validator, copy, @"copy is not equal to original");
    XCTAssertEqualObjects(copy.countValidator, countValidator, @"count validator is not set correctly");
    XCTAssertEqualObjects(copy.keyValidators, keyValidators, @"key validators is not set correctly");
    XCTAssertEqualObjects(copy.valueValidators, valueValidators, @"value validators is not set correctly");
    XCTAssertEqualObjects(copy.keyValuePairValidators, keyValuePairValidators, @"key-value pair validators is not set correctly");
}


- (void)testHashAndIsEqual
{
    TWTValidator *countValidator1 = [self randomValidator];
    NSArray *keyValidators1 = UMKGeneratedArrayWithElementCount(random() % 5 + 1, ^id(NSUInteger index) {
        return [self randomValidator];
    });

    NSArray *valueValidators1 = UMKGeneratedArrayWithElementCount(random() % 5 + 1, ^id(NSUInteger index) {
        return [self randomValidator];
    });

    NSArray *keyValuePairValidators1 = UMKGeneratedArrayWithElementCount(random() % 5 + 1, ^id(NSUInteger index) {
        return [self randomKeyValuePairValidator];
    });

    TWTValidator *countValidator2 = [TWTCompoundValidator notValidatorWithSubvalidator:countValidator1];
    NSArray *keyValidators2 = UMKGeneratedArrayWithElementCount(keyValidators1.count + 1, ^id(NSUInteger index) {
        return [self randomValidator];
    });

    NSArray *valueValidators2 = UMKGeneratedArrayWithElementCount(valueValidators1.count + 1, ^id(NSUInteger index) {
        return [self randomValidator];
    });

    NSArray *keyValuePairValidators2 = UMKGeneratedArrayWithElementCount(keyValuePairValidators1.count + 1, ^id(NSUInteger index) {
        return [self randomKeyValuePairValidator];
    });

    TWTKeyedCollectionValidator *equalValidator1 = [[TWTKeyedCollectionValidator alloc] initWithCountValidator:countValidator1
                                                                                                 keyValidators:keyValidators1
                                                                                               valueValidators:valueValidators1
                                                                                        keyValuePairValidators:keyValuePairValidators1];
    TWTKeyedCollectionValidator *equalValidator2 = [[TWTKeyedCollectionValidator alloc] initWithCountValidator:countValidator1
                                                                                                 keyValidators:keyValidators1
                                                                                               valueValidators:valueValidators1
                                                                                        keyValuePairValidators:keyValuePairValidators1];
    TWTKeyedCollectionValidator *unequalValidator1 = [[TWTKeyedCollectionValidator alloc] initWithCountValidator:countValidator2
                                                                                                   keyValidators:keyValidators1
                                                                                                 valueValidators:valueValidators1
                                                                                          keyValuePairValidators:keyValuePairValidators1];
    TWTKeyedCollectionValidator *unequalValidator2 = [[TWTKeyedCollectionValidator alloc] initWithCountValidator:countValidator1
                                                                                                   keyValidators:keyValidators2
                                                                                                 valueValidators:valueValidators1
                                                                                          keyValuePairValidators:keyValuePairValidators1];
    TWTKeyedCollectionValidator *unequalValidator3 = [[TWTKeyedCollectionValidator alloc] initWithCountValidator:countValidator1
                                                                                                   keyValidators:keyValidators1
                                                                                                 valueValidators:valueValidators2
                                                                                          keyValuePairValidators:keyValuePairValidators1];
    TWTKeyedCollectionValidator *unequalValidator4 = [[TWTKeyedCollectionValidator alloc] initWithCountValidator:countValidator1
                                                                                                   keyValidators:keyValidators1
                                                                                                 valueValidators:valueValidators1
                                                                                          keyValuePairValidators:keyValuePairValidators2];

    XCTAssertEqual(equalValidator1.hash, equalValidator2.hash, @"hashes are different for equal objects");
    XCTAssertEqualObjects(equalValidator1, equalValidator2, @"equal objects are not equal");
    XCTAssertNotEqualObjects(equalValidator1, unequalValidator1, @"unequal objects are equal");
    XCTAssertNotEqualObjects(equalValidator1, unequalValidator2, @"unequal objects are equal");
    XCTAssertNotEqualObjects(equalValidator1, unequalValidator3, @"unequal objects are equal");
    XCTAssertNotEqualObjects(equalValidator1, unequalValidator4, @"unequal objects are equal");
}


- (void)testValidateValueErrorNilAndNullObjects
{
    TWTKeyedCollectionValidator *validator = [[TWTKeyedCollectionValidator alloc] initWithCountValidator:nil
                                                                                           keyValidators:nil
                                                                                         valueValidators:nil
                                                                                  keyValuePairValidators:nil];

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


- (void)testValidateValueErrorNonKeyedCollectionObjects
{
    TWTKeyedCollectionValidator *validator = [[TWTKeyedCollectionValidator alloc] initWithCountValidator:nil
                                                                                           keyValidators:nil
                                                                                         valueValidators:nil
                                                                                  keyValuePairValidators:nil];

    NSError *error = nil;
    id value = [[TWTNoCountKeyedCollection alloc] init];
    XCTAssertFalse([validator validateValue:value error:&error], @"passes when value does not respond to -count");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeValueNotKeyedCollection, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validated value");

    value = [[TWTNoFastEnumerationKeyedCollection alloc] init];
    XCTAssertFalse([validator validateValue:value error:&error], @"passes when value does not conform to NSFastEnumeration");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeValueNotKeyedCollection, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validated value");

    value = [[TWTNoObjectForKeyKeyedCollection alloc] init];
    XCTAssertFalse([validator validateValue:value error:&error], @"passes when value does not respond to -objectForKey:");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeValueNotKeyedCollection, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validated value");

    // Make sure the random object is not the NSNull instance
    while ((value = [self randomNonNilObject]) && (value == [NSNull null]));

    XCTAssertFalse([validator validateValue:value error:&error], @"passes when value is not a keyed collection");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeValueNotKeyedCollection, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validated value");
}


- (void)testValidateValueErrorCount
{
    for (id collection in @[ [self randomDictionary], [self randomMapTable] ]) {
        NSArray *keyValidators = @[ [self passingValidator] ];
        NSArray *valueValidators = @[ [self passingValidator] ];
        NSArray *keyValuePairValidators = @[ [self passingKeyValuePairValidatorWithRandomKey] ];

        TWTKeyedCollectionValidator *validator = [[TWTKeyedCollectionValidator alloc] initWithCountValidator:nil
                                                                                               keyValidators:keyValidators
                                                                                             valueValidators:valueValidators
                                                                                      keyValuePairValidators:keyValuePairValidators];
        XCTAssertTrue([validator validateValue:collection error:NULL], @"fails with no count validator");

        TWTValidator *countValidator = [self passingValidator];
        validator = [[TWTKeyedCollectionValidator alloc] initWithCountValidator:countValidator
                                                                  keyValidators:nil
                                                                valueValidators:nil
                                                         keyValuePairValidators:nil];
        XCTAssertTrue([validator validateValue:collection error:NULL], @"fails with passing count validator");

        countValidator = [self failingValidatorWithError:nil];
        validator = [[TWTKeyedCollectionValidator alloc] initWithCountValidator:countValidator
                                                                  keyValidators:nil
                                                                valueValidators:nil
                                                         keyValuePairValidators:nil];
        XCTAssertFalse([validator validateValue:collection error:NULL], @"passes with failing count validator");

        NSError *expectedError = UMKRandomError();
        NSError *error = nil;
        countValidator = [self failingValidatorWithError:expectedError];
        validator = [[TWTKeyedCollectionValidator alloc] initWithCountValidator:countValidator
                                                                  keyValidators:nil
                                                                valueValidators:nil
                                                         keyValuePairValidators:nil];
        XCTAssertFalse([validator validateValue:collection error:&error], @"passes with failing count validator");
        XCTAssertNotNil(error, @"error is nil");
        XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
        XCTAssertEqual(error.code, TWTValidationErrorCodeKeyedCollectionValidatorError, @"incorrect error code");
        XCTAssertEqualObjects(error.twt_validatedValue, collection, @"incorrect validated value");
        XCTAssertEqualObjects(error.twt_countValidationError, expectedError, @"count validation error is not set correctly");
        XCTAssertNil(error.twt_keyValidationErrors, @"error contains key validation errors, but none occurred");
        XCTAssertNil(error.twt_valueValidationErrors, @"error contains value validation errors, but none occurred");
        XCTAssertNil(error.twt_keyValuePairValidationErrors, @"error contains key-value pair validation errors, but none occurred");
    }
}


- (void)testValidateValueErrorKeys
{
    for (id collection in @[ [self randomDictionary], [self randomMapTable] ]) {
        TWTValidator *countValidator = [self passingValidator];
        NSArray *valueValidators = @[ [self passingValidator] ];
        NSArray *keyValuePairValidators = @[ [self passingKeyValuePairValidatorWithRandomKey] ];

        // nil validators
        TWTKeyedCollectionValidator *validator = [[TWTKeyedCollectionValidator alloc] initWithCountValidator:countValidator
                                                                                               keyValidators:nil
                                                                                             valueValidators:valueValidators
                                                                                      keyValuePairValidators:keyValuePairValidators];
        XCTAssertTrue([validator validateValue:collection error:NULL], @"fails with nil key validators");

        // Empty validators
        validator = [[TWTKeyedCollectionValidator alloc] initWithCountValidator:countValidator
                                                                  keyValidators:@[ ]
                                                                valueValidators:valueValidators
                                                         keyValuePairValidators:keyValuePairValidators];
        XCTAssertTrue([validator validateValue:collection error:NULL], @"fails with empty key validators");

        // Passing validators
        NSArray *keyValidators = UMKGeneratedArrayWithElementCount(2 + random() % 8, ^id(NSUInteger index) {
            return [self passingValidator];
        });

        validator = [[TWTKeyedCollectionValidator alloc] initWithCountValidator:nil
                                                                  keyValidators:keyValidators
                                                                valueValidators:nil
                                                         keyValuePairValidators:nil];
        XCTAssertTrue([validator validateValue:collection error:nil], @"fails with passing key validators");

        // Failing validators
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

        keyValidators = [keyValidators arrayByAddingObjectsFromArray:failingValidators];
        validator = [[TWTKeyedCollectionValidator alloc] initWithCountValidator:nil
                                                                  keyValidators:keyValidators
                                                                valueValidators:nil
                                                         keyValuePairValidators:nil];

        XCTAssertFalse([validator validateValue:collection error:&error], @"passes with failing key validators");
        XCTAssertNotNil(error, @"error is nil");
        XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
        XCTAssertEqual(error.code, TWTValidationErrorCodeKeyedCollectionValidatorError, @"incorrect error code");
        XCTAssertEqualObjects(error.twt_validatedValue, collection, @"incorrect validated value");
        XCTAssertNil(error.twt_countValidationError, @"error contains count validation error, but none occurred");
        XCTAssertEqualObjects(error.twt_keyValidationErrors, cumulativeErrors, @"key validation errors is not set correctly");
        XCTAssertNil(error.twt_valueValidationErrors, @"error contains value validation errors, but none occurred");
        XCTAssertNil(error.twt_keyValuePairValidationErrors, @"error contains key-value pair validation errors, but none occurred");
    }
}


- (void)testValidateValueErrorValues
{
    for (id collection in @[ [self randomDictionary], [self randomMapTable] ]) {
        TWTValidator *countValidator = [self passingValidator];
        NSArray *keyValidators = @[ [self passingValidator] ];
        NSArray *keyValuePairValidators = @[ [self passingKeyValuePairValidatorWithRandomKey] ];

        // nil validators
        TWTKeyedCollectionValidator *validator = [[TWTKeyedCollectionValidator alloc] initWithCountValidator:countValidator
                                                                                               keyValidators:keyValidators
                                                                                             valueValidators:nil
                                                                                      keyValuePairValidators:keyValuePairValidators];
        XCTAssertTrue([validator validateValue:collection error:NULL], @"fails with nil value validators");

        // Empty validators
        validator = [[TWTKeyedCollectionValidator alloc] initWithCountValidator:countValidator
                                                                  keyValidators:keyValidators
                                                                valueValidators:@[ ]
                                                         keyValuePairValidators:keyValuePairValidators];
        XCTAssertTrue([validator validateValue:collection error:NULL], @"fails with empty value validators");

        // Passing validators
        NSArray *valueValidators = UMKGeneratedArrayWithElementCount(2 + random() % 8, ^id(NSUInteger index) {
            return [self passingValidator];
        });

        validator = [[TWTKeyedCollectionValidator alloc] initWithCountValidator:nil
                                                                  keyValidators:nil
                                                                valueValidators:valueValidators
                                                         keyValuePairValidators:nil];
        XCTAssertTrue([validator validateValue:collection error:nil], @"fails with passing value validators");

        // Failing validators
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

        valueValidators = [valueValidators arrayByAddingObjectsFromArray:failingValidators];
        validator = [[TWTKeyedCollectionValidator alloc] initWithCountValidator:nil
                                                                  keyValidators:nil
                                                                valueValidators:valueValidators
                                                         keyValuePairValidators:nil];

        XCTAssertFalse([validator validateValue:collection error:&error], @"passes with failing value validators");
        XCTAssertNotNil(error, @"error is nil");
        XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
        XCTAssertEqual(error.code, TWTValidationErrorCodeKeyedCollectionValidatorError, @"incorrect error code");
        XCTAssertEqualObjects(error.twt_validatedValue, collection, @"incorrect validated value");
        XCTAssertNil(error.twt_countValidationError, @"error contains count validation error, but none occurred");
        XCTAssertNil(error.twt_keyValidationErrors, @"error contains key validation errors, but none occurred");
        XCTAssertEqualObjects(error.twt_valueValidationErrors, cumulativeErrors, @"value validation errors is not set correctly");
        XCTAssertNil(error.twt_keyValuePairValidationErrors, @"error contains key-value pair validation errors, but none occurred");
    }
}


- (void)testValidateValueErrorKeyValuePairs
{
    for (id collection in @[ [self randomDictionary], [self randomMapTable] ]) {
        TWTValidator *countValidator = [self passingValidator];
        NSArray *keyValidators = @[ [self passingValidator] ];
        NSArray *valueValidators = @[ [self passingValidator] ];

        // nil validators
        TWTKeyedCollectionValidator *validator = [[TWTKeyedCollectionValidator alloc] initWithCountValidator:countValidator
                                                                                               keyValidators:keyValidators
                                                                                             valueValidators:valueValidators
                                                                                      keyValuePairValidators:nil];
        XCTAssertTrue([validator validateValue:collection error:NULL], @"fails with nil key-value pair validators");

        // Empty validators
        validator = [[TWTKeyedCollectionValidator alloc] initWithCountValidator:countValidator
                                                                  keyValidators:keyValidators
                                                                valueValidators:valueValidators
                                                         keyValuePairValidators:@[ ]];
        XCTAssertTrue([validator validateValue:collection error:NULL], @"fails with empty key-value pair validators");

        // Passing validators for missing keys
        NSArray *keys = [collection allKeys];
        NSArray *keyValuePairValidators = UMKGeneratedArrayWithElementCount(keys.count, ^id(NSUInteger index) {
            id key = [self randomObject];
            while ([keys containsObject:key]) {
                key = [self randomObject];
            }

            return [self passingKeyValuePairValidatorWithKey:key];
        });

        validator = [[TWTKeyedCollectionValidator alloc] initWithCountValidator:nil
                                                                  keyValidators:nil
                                                                valueValidators:nil
                                                         keyValuePairValidators:keyValuePairValidators];
        XCTAssertTrue([validator validateValue:collection error:nil], @"fails with passing key-value pair validators for missing keys");


        // Passing validators for present keys
        keyValuePairValidators = UMKGeneratedArrayWithElementCount(keys.count, ^id(NSUInteger index) {
            return [self passingKeyValuePairValidatorWithKey:keys[index]];
        });

        validator = [[TWTKeyedCollectionValidator alloc] initWithCountValidator:nil
                                                                  keyValidators:nil
                                                                valueValidators:nil
                                                         keyValuePairValidators:keyValuePairValidators];
        XCTAssertTrue([validator validateValue:collection error:nil], @"fails with passing key-value pair validators for present keys");

        // Failing validators for missing keys
        keyValuePairValidators = UMKGeneratedArrayWithElementCount(keys.count, ^id(NSUInteger index) {
            id key = [self randomObject];
            while ([keys containsObject:key]) {
                key = [self randomObject];
            }

            return [self failingKeyValuePairValidatorWithKey:key error:UMKRandomError()];
        });

        validator = [[TWTKeyedCollectionValidator alloc] initWithCountValidator:nil
                                                                  keyValidators:nil
                                                                valueValidators:nil
                                                         keyValuePairValidators:keyValuePairValidators];
        XCTAssertTrue([validator validateValue:collection error:nil], @"fails with failing key-value pair validators for missing keys");

        // Failing validators for present keys
        NSError *error = nil;
        NSArray *expectedErrors = UMKGeneratedArrayWithElementCount(keys.count, ^id(NSUInteger index) {
            return UMKRandomError();
        });

        NSArray *failingValidators = UMKGeneratedArrayWithElementCount(keys.count , ^id(NSUInteger index) {
            return [[TWTKeyValuePairValidator alloc] initWithKey:keys[index]
                                                  valueValidator:[self failingValidatorWithError:expectedErrors[index]]];
        });

        keyValuePairValidators = [keyValuePairValidators arrayByAddingObjectsFromArray:failingValidators];
        validator = [[TWTKeyedCollectionValidator alloc] initWithCountValidator:nil
                                                                  keyValidators:nil
                                                                valueValidators:nil
                                                         keyValuePairValidators:keyValuePairValidators];

        XCTAssertFalse([validator validateValue:collection error:&error], @"passes with failing key-value pair validators for present keys");
        XCTAssertNotNil(error, @"error is nil");
        XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
        XCTAssertEqual(error.code, TWTValidationErrorCodeKeyedCollectionValidatorError, @"incorrect error code");
        XCTAssertEqualObjects(error.twt_validatedValue, collection, @"incorrect validated value");
        XCTAssertNil(error.twt_countValidationError, @"error contains count validation error, but none occurred");
        XCTAssertNil(error.twt_keyValidationErrors, @"error contains key validation errors, but none occurred");
        XCTAssertNil(error.twt_valueValidationErrors, @"error contains value validation errors, but none occurred");
        XCTAssertEqualObjects(error.twt_keyValuePairValidationErrors, expectedErrors, @"key-value pair validation errors is not set correctly");
    }
}

@end


#pragma mark - Invalid Keyed Collection Class Implementations


@implementation TWTNoCountKeyedCollection

- (id)objectForKey:(id)key
{
    return nil;
}


- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len
{
    return 0;
}

@end


@implementation TWTNoFastEnumerationKeyedCollection

- (NSUInteger)count
{
    return 0;
}


- (id)objectForKey:(id)key
{
    return nil;
}

@end


@implementation TWTNoObjectForKeyKeyedCollection

- (NSUInteger)count
{
    return 0;
}


- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len
{
    return 0;
}

@end
