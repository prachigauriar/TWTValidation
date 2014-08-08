//
//  TWTKeyValueCodingValidatorTests.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 8/7/2014.
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

typedef NS_ENUM(NSInteger, TWTKVCValidatorErrorCode) {
    TWTKVCValidatorErrorCodeKeyParameter,
    TWTKVCValidatorErrorCodeDynamicDispatch,
    TWTKVCValidatorErrorCodeKeyValueValidation
};

@interface TWTKeyValueCodingValidatorTests : TWTRandomizedTestCase

@property (nonatomic, strong) id keyParameterProperty;
@property (nonatomic, strong) id dynamicDispatchProperty;
@property (nonatomic, strong) id keyValueValidationProperty;
@property (nonatomic, strong) id noValidatorsProperty;
@property (nonatomic, strong) id nilValidatorsProperty;

- (void)testInit;
- (void)testCopy;
- (void)testHashAndIsEqual;

- (void)testValidateValueErrorNilObject;
- (void)testValidateValueErrorKeyParameter;
- (void)testValidateValueErrorDynamicDispatch;
- (void)testValidateValueErrorKeyValueValidation;
- (void)testValidateValueErrorNoValidatorsProperty;
- (void)testValidateValueErrorNilValidatorsProperty;

- (void)testValidateValueErrorNoKeys;
- (void)testValidateValueErrorMultipleKeys;

@end


@implementation TWTKeyValueCodingValidatorTests

- (void)setUp
{
    [super setUp];
    self.keyParameterProperty = [self randomObject];
    self.dynamicDispatchProperty = [self randomObject];
    self.keyValueValidationProperty = [self randomObject];
    self.noValidatorsProperty = [self randomObject];
    self.nilValidatorsProperty = [self randomObject];
}


- (NSSet *)randomKeySetWithCount:(NSUInteger)count
{
    return UMKGeneratedSetWithElementCount(count, ^id{
        return UMKRandomIdentifierStringWithLength(10);
    });
}


#pragma mark - Validators

+ (NSSet *)twt_validatorsForKey:(NSString *)key
{
    if ([key isEqualToString:@"keyParameterProperty"]) {
        return [NSSet setWithObject:[self failingValidatorWithError:[NSError errorWithDomain:TWTValidationErrorDomain
                                                                                        code:TWTKVCValidatorErrorCodeKeyParameter
                                                                                    userInfo:nil]]];
    }

    return [super twt_validatorsForKey:key];
}


+ (NSSet *)twt_validatorsForDynamicDispatchProperty
{
    return [NSSet setWithObject:[self failingValidatorWithError:[NSError errorWithDomain:TWTValidationErrorDomain
                                                                                    code:TWTKVCValidatorErrorCodeDynamicDispatch
                                                                                userInfo:nil]]];
}


+ (NSSet *)twt_validatorsForNoValidatorsProperty:(NSString *)key
{
    return [NSSet set];
}


+ (NSSet *)twt_validatorsForNilValidatorsProperty:(NSString *)key
{
    return nil;
}


- (BOOL)validateKeyValueValidationProperty:(inout __autoreleasing id *)ioValue error:(out NSError *__autoreleasing *)outError
{
    if (outError) {
        *outError = [NSError errorWithDomain:TWTValidationErrorDomain code:TWTKVCValidatorErrorCodeKeyValueValidation userInfo:nil];
    }

    return NO;
}


#pragma mark - Tests

- (void)testInit
{
    TWTKeyValueCodingValidator *validator = [[TWTKeyValueCodingValidator alloc] init];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertNil(validator.keys, @"non-nil keys");

    NSSet *keys = [self randomKeySetWithCount:random() % 10 + 1];

    validator = [[TWTKeyValueCodingValidator alloc] initWithKeys:keys];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertEqualObjects(validator.keys, keys, @"keys is not set correctly");
}


- (void)testCopy
{
    NSSet *keys = [self randomKeySetWithCount:random() % 10 + 1];

    TWTKeyValueCodingValidator *validator = [[TWTKeyValueCodingValidator alloc] initWithKeys:keys];
    TWTKeyValueCodingValidator *copy = [validator copy];
    XCTAssertEqual(copy, validator, @"copy returns different object");
    XCTAssertEqualObjects(validator.keys, copy.keys, @"keys is not set correctly");
}


- (void)testHashAndIsEqual
{
    NSSet *keys1 = [self randomKeySetWithCount:random() % 10 + 1];
    NSSet *keys2 = [self randomKeySetWithCount:keys1.count + 1];

    TWTKeyValueCodingValidator *equalValidator1 = [[TWTKeyValueCodingValidator alloc] initWithKeys:keys1];
    TWTKeyValueCodingValidator *equalValidator2 = [[TWTKeyValueCodingValidator alloc] initWithKeys:keys1];
    TWTKeyValueCodingValidator *unequalValidator = [[TWTKeyValueCodingValidator alloc] initWithKeys:keys2];

    XCTAssertEqual(equalValidator1.hash, equalValidator2.hash, @"hashes are different for equal objects");
    XCTAssertEqualObjects(equalValidator1, equalValidator2, @"equal objects are not equal");
    XCTAssertNotEqualObjects(equalValidator1, unequalValidator, @"unequal objects are equal");
}


- (void)testValidateValueErrorNilObject
{
    TWTKeyValueCodingValidator *validator = [[TWTKeyValueCodingValidator alloc] initWithKeys:[self randomKeySetWithCount:random() % 10 + 1]];
    XCTAssertFalse([validator validateValue:nil error:NULL], @"validation fails with nil value");
}


- (void)assertValidationFailureWithKey:(NSString *)key errorCode:(NSInteger)errorCode
{
    TWTKeyValueCodingValidator *validator = [[TWTKeyValueCodingValidator alloc] initWithKeys:[NSSet setWithObject:key]];
    NSError *error = nil;
    XCTAssertFalse([validator validateValue:self error:&error], @"failing validator passes");
    XCTAssertEqual(error.code, TWTValidationErrorCodeKeyValueCodingValidatorError, @"incorrect error is returned");

    NSArray *errors = error.twt_underlyingErrorsByKey[key];
    XCTAssertEqual([errors.firstObject code], errorCode, @"incorrect underlying error code");
}


- (void)testValidateValueErrorKeyParameter
{
    [self assertValidationFailureWithKey:@"keyParameterProperty" errorCode:TWTKVCValidatorErrorCodeKeyParameter];
}


- (void)testValidateValueErrorDynamicDispatch
{
    [self assertValidationFailureWithKey:@"dynamicDispatchProperty" errorCode:TWTKVCValidatorErrorCodeDynamicDispatch];
}


- (void)testValidateValueErrorKeyValueValidation
{
    [self assertValidationFailureWithKey:@"keyValueValidationProperty" errorCode:TWTKVCValidatorErrorCodeKeyValueValidation];
}


- (void)testValidateValueErrorNoValidatorsProperty
{
    TWTKeyValueCodingValidator *validator = [[TWTKeyValueCodingValidator alloc] initWithKeys:[NSSet setWithObject:@"noValidatorsProperty"]];
    XCTAssertTrue([validator validateValue:self error:NULL], @"no validators fails");
}


- (void)testValidateValueErrorNilValidatorsProperty
{
    TWTKeyValueCodingValidator *validator = [[TWTKeyValueCodingValidator alloc] initWithKeys:[NSSet setWithObject:@"nilValidatorsProperty"]];
    XCTAssertTrue([validator validateValue:self error:NULL], @"nil validators fails");
}


- (void)testValidateValueErrorNoKeys
{
    TWTKeyValueCodingValidator *validator = [[TWTKeyValueCodingValidator alloc] initWithKeys:nil];
    XCTAssertTrue([validator validateValue:self error:NULL], @"fails with nil keys");

    validator = [[TWTKeyValueCodingValidator alloc] initWithKeys:[NSSet set]];
    XCTAssertTrue([validator validateValue:self error:NULL], @"fails with no keys");
}


- (void)testValidateValueErrorMultipleKeys
{
    NSSet *keys = [NSSet setWithObjects:@"keyParameterProperty", @"dynamicDispatchProperty", nil];
    TWTKeyValueCodingValidator *validator = [[TWTKeyValueCodingValidator alloc] initWithKeys:keys];

    NSError *error = nil;
    XCTAssertFalse([validator validateValue:self error:&error], @"failing validator passes");
    XCTAssertEqual(error.code, TWTValidationErrorCodeKeyValueCodingValidatorError, @"incorrect error is returned");

    XCTAssertEqual(error.twt_underlyingErrorsByKey.count, keys.count, @"incorrect underlying errors by key");

    NSArray *errors = error.twt_underlyingErrorsByKey[@"keyParameterProperty"];
    XCTAssertEqual([errors.firstObject code], TWTKVCValidatorErrorCodeKeyParameter, @"incorrect underlying error code");

    errors = error.twt_underlyingErrorsByKey[@"dynamicDispatchProperty"];
    XCTAssertEqual([errors.firstObject code], TWTKVCValidatorErrorCodeDynamicDispatch, @"incorrect underlying error code");
}

@end
