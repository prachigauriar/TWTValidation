//
//  TWTBlockValidatorTests.m
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

#import <TWTValidation/TWTBlockValidator.h>

@interface TWTBlockValidatorTests : TWTRandomizedTestCase

- (void)testInit;
- (void)testCopy;
- (void)testHashAndIsEqual;
- (void)testValidateValueError;

@end


@implementation TWTBlockValidatorTests

- (TWTValidationBlock)stringValidationBlockWithLength:(NSUInteger)length error:(NSError *)error
{
    return ^BOOL(id value, NSError *__autoreleasing *outError) {
        if ([value length] == length) {
            return YES;
        }

        if (outError) {
            *outError = error;
        }
        
        return NO;
    };
}


- (void)testInit
{
    TWTBlockValidator *validator = [[TWTBlockValidator alloc] init];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertNil(validator.block, @"block is non-nil");
    
    TWTValidationBlock validationBlock = [self stringValidationBlockWithLength:random() error:[self randomError]];
    validator = [[TWTBlockValidator alloc] initWithBlock:validationBlock];
    XCTAssertEqualObjects(validationBlock, validator.block, @"block was not set correctly");
}


- (void)testCopy
{
    TWTValidationBlock validationBlock = [self stringValidationBlockWithLength:random() error:[self randomError]];
    TWTBlockValidator *validator = [[TWTBlockValidator alloc] initWithBlock:validationBlock];
    TWTBlockValidator *copy = [validator copy];
    XCTAssertEqual(copy, validator, @"copy returns different object");
    XCTAssertEqualObjects(validationBlock, copy.block, @"block was not set correctly");
}


- (void)testHashAndIsEqual
{
    TWTBlockValidator *equalValidator1 = [[TWTBlockValidator alloc] initWithBlock:[self stringValidationBlockWithLength:random() error:[self randomError]]];
    TWTBlockValidator *equalValidator2 = [[TWTBlockValidator alloc] initWithBlock:equalValidator1.block];
    TWTBlockValidator *unequalValidator = [[TWTBlockValidator alloc] initWithBlock:[self stringValidationBlockWithLength:random() error:[self randomError]]];
    
    XCTAssertEqual(equalValidator1.hash, equalValidator2.hash, @"hashes are different for equal objects");
    XCTAssertEqualObjects(equalValidator1, equalValidator2, @"equal objects are not equal");
    
    XCTAssertNotEqualObjects(equalValidator1, unequalValidator, @"unequal objects are equal");
}


- (void)testValidateValueError
{
    NSError *error = nil;
    
    // Nil block tests
    TWTBlockValidator *validator = [[TWTBlockValidator alloc] init];
    XCTAssertTrue([validator validateValue:nil error:&error], @"validator with nil block returns NO");
    XCTAssertTrue([validator validateValue:UMKRandomUnsignedNumber() error:&error], @"validator with nil block returns NO");

    NSUInteger randomLength = 1 + random() % 10;
    NSError *randomError = [self randomError];
    TWTValidationBlock validationBlock = [self stringValidationBlockWithLength:randomLength error:randomError];
    validator = [[TWTBlockValidator alloc] initWithBlock:validationBlock];
    
    // Validation succeeds
    error = nil;
    XCTAssertTrue([validator validateValue:UMKRandomUnicodeStringWithLength(randomLength) error:NULL], @"validator returns NO");
    XCTAssertTrue([validator validateValue:UMKRandomUnicodeStringWithLength(randomLength) error:&error], @"validator returns NO");

    // Validation fails
    error = nil;
    XCTAssertFalse([validator validateValue:UMKRandomUnicodeStringWithLength(randomLength + 1 + random() % 10) error:NULL], @"validator returns YES");
    XCTAssertFalse([validator validateValue:UMKRandomUnicodeStringWithLength(randomLength + 1 + random() % 10) error:&error], @"validator returns YES");
    XCTAssertEqualObjects(error, randomError, @"returns incorrect error");
}

@end
