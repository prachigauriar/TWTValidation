//
//  TWTStringValidatorTests.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 4/7/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import "TWTRandomizedTestCase.h"

#import <TWTValidation/TWTValidation.h>

@interface TWTStringValidatorTests : TWTRandomizedTestCase

- (void)testInit;
- (void)testBoundedLengthInit;
- (void)testRegularExpressionInit;

- (void)testCopy;
- (void)testHashAndIsEqual;

@end


@implementation TWTStringValidatorTests

- (void)testInit
{
    TWTStringValidator *validator = [[TWTStringValidator alloc] init];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
    XCTAssertEqualObjects(validator.valueClass, [NSString class], @"value class is not NSString");
}


- (void)testBoundedLengthInit
{
    NSUInteger length = random();
    TWTBoundedLengthStringValidator *validator = [TWTStringValidator stringValidatorWithLength:length];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
    XCTAssertEqualObjects(validator.valueClass, [NSString class], @"value class is not NSString");
    XCTAssertEqual([validator minimumLength], length, @"minimum length is not set correctly");
    XCTAssertEqual([validator maximumLength], length, @"maximum length is not set correctly");

    NSUInteger minimumLength = random();
    NSUInteger maximumLength = random() + minimumLength;
    validator = (TWTBoundedLengthStringValidator *)[TWTStringValidator stringValidatorWithMinimumLength:minimumLength maximumLength:maximumLength];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
    XCTAssertEqualObjects(validator.valueClass, [NSString class], @"value class is not NSString");
    XCTAssertEqual([validator minimumLength], minimumLength, @"minimum length is not set correctly");
    XCTAssertEqual([validator maximumLength], maximumLength, @"maximum length is not set correctly");

    validator = [[TWTBoundedLengthStringValidator alloc] init];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
    XCTAssertEqualObjects(validator.valueClass, [NSString class], @"value class is not NSString");
    XCTAssertEqual([validator minimumLength], (NSUInteger)0, @"minimum length is not set correctly");
    XCTAssertEqual([validator maximumLength], NSUIntegerMax, @"maximum length is not set correctly");

    validator = [[TWTBoundedLengthStringValidator alloc] initWithMinimumLength:minimumLength maximumLength:maximumLength];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
    XCTAssertEqualObjects(validator.valueClass, [NSString class], @"value class is not NSString");
    XCTAssertEqual([validator minimumLength], minimumLength, @"minimum length is not set correctly");
    XCTAssertEqual([validator maximumLength], maximumLength, @"maximum length is not set correctly");
}


- (void)testRegularExpressionInit
{
    TWTRegularExpressionStringValidator *validator = [TWTStringValidator stringValidatorWithRegularExpression:nil options:0];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
    XCTAssertEqualObjects(validator.valueClass, [NSString class], @"value class is not NSString");
    XCTAssertNil(validator.regularExpression, @"regular expression is not set correctly");
    XCTAssertEqual(validator.options, (NSMatchingOptions)0, @"options is not set correctly");

    NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:@"[A-Za-z_]\\w+-[0-9]{3}" options:0 error:NULL];
    
//
//    validator = [[TWTBoundedLengthStringValidator alloc] init];
//    XCTAssertNotNil(validator, @"returns nil");
//    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
//    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
//    XCTAssertEqualObjects(validator.valueClass, [NSString class], @"value class is not NSString");
//    XCTAssertEqual([validator minimumLength], (NSUInteger)0, @"minimum length is not set correctly");
//    XCTAssertEqual([validator maximumLength], NSUIntegerMax, @"maximum length is not set correctly");
//
//    validator = [[TWTBoundedLengthStringValidator alloc] initWithMinimumLength:minimumLength maximumLength:maximumLength];
//    XCTAssertNotNil(validator, @"returns nil");
//    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
//    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
//    XCTAssertEqualObjects(validator.valueClass, [NSString class], @"value class is not NSString");
//    XCTAssertEqual([validator minimumLength], minimumLength, @"minimum length is not set correctly");
//    XCTAssertEqual([validator maximumLength], maximumLength, @"maximum length is not set correctly");
}

@end
