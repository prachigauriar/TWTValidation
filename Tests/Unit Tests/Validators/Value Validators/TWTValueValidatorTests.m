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

#import <TWTValidation/TWTValidation.h>

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

    XCTAssertEqual(validator1.hash, validator2.hash, @"hashs are not equal for equal objects");
    XCTAssertEqualObjects(validator1, validator2, @"equal objects are not equal");

    // Value class
    while (validator1.valueClass == validator2.valueClass) {
        validator1.valueClass = [self randomClass];
    }

    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");

    validator2.valueClass = validator1.valueClass;
    XCTAssertEqual(validator1.hash, validator2.hash, @"hashs are not equal for equal objects");
    XCTAssertEqualObjects(validator1, validator2, @"equal objects are not equal");

    // Allows nil
    validator1.allowsNil = !validator2.allowsNil;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");

    validator2.allowsNil = validator1.allowsNil;
    XCTAssertEqual(validator1.hash, validator2.hash, @"hashs are not equal for equal objects");
    XCTAssertEqualObjects(validator1, validator2, @"equal objects are not equal");

    // Allows nil
    validator1.allowsNull = !validator2.allowsNull;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");

    validator2.allowsNull = validator1.allowsNull;
    XCTAssertEqual(validator1.hash, validator2.hash, @"hashs are not equal for equal objects");
    XCTAssertEqualObjects(validator1, validator2, @"equal objects are not equal");
}


//- (void)testValidateValueErrorValueClass;
//- (void)testValidateValueErrorAllowsNil;
//- (void)testValidateValueErrorAllowsNull;

@end
