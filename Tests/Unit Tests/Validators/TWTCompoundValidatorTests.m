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

@interface TWTCompoundValidatorTests : TWTRandomizedTestCase

- (void)testInit;
- (void)testCopy;
- (void)testHashAndIsEqual;

- (void)testValidateValueErrorAnd;
- (void)testValidateValueErrorOr;
- (void)testValidateValueErrorMutualExclusion;

@end


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


- (void)testValidateValueErrorAnd
{
    TWTCompoundValidator *validator = [TWTCompoundValidator andValidatorWithSubvalidators:nil];
    XCTAssertTrue([validator validateValue:nil error:NULL]);
    XCTAssertTrue([validator validateValue:UMKRandomUnsignedNumber() error:NULL]);
    
    NSArray *subvalidators = @[ [self mockPassingValidatorWithErrorPointer:NULL] ];
    
    validator = [TWTCompoundValidator andValidatorWithSubvalidators:subvalidators];
    XCTAssertTrue([validator validateValue:nil error:NULL]);
    XCTAssertTrue([validator validateValue:UMKRandomUnsignedNumber() error:NULL]);
    
    NSError *error = nil;
    subvalidators = @[ [self mockPassingValidatorWithErrorPointer:&error] ];
    validator = [TWTCompoundValidator andValidatorWithSubvalidators:subvalidators];
    XCTAssertTrue([validator validateValue:nil error:&error]);
    XCTAssertTrue([validator validateValue:UMKRandomUnsignedNumber() error:&error]);
    
    XCTFail(@"Test passing with more than one validator.");
    XCTFail(@"Test failing with one validator.");
    XCTFail(@"Test failing with more than one validator.");
}

@end
