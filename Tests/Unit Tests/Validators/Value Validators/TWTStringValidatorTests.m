//
//  TWTStringValidatorTests.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 4/7/2014.
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


@interface TWTStringValidatorTests : TWTRandomizedTestCase

- (void)testInit;
- (void)testBoundedLengthInit;
- (void)testRegularExpressionInit;

- (void)testCopy;
- (void)testHashAndIsEqual;

- (void)testValidateValueErrorBoundedLengthMinimum;
- (void)testValidateValueErrorBoundedLengthMaximum;

- (void)testValidateValueErrorRegularExpression;

- (void)testPrefixValidateValueError;
- (void)testSuffixValidateValueError;
- (void)testSubstringValidateValueError;

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
    NSMatchingOptions options = UMKRandomBoolean() ? NSMatchingAnchored : 0;
    validator = [TWTStringValidator stringValidatorWithRegularExpression:regularExpression options:options];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
    XCTAssertEqualObjects(validator.valueClass, [NSString class], @"value class is not NSString");
    XCTAssertEqualObjects(validator.regularExpression, regularExpression, @"regular expression is not set correctly");
    XCTAssertEqual(validator.options, options, @"options is not set correctly");

    regularExpression = [[NSRegularExpression alloc] initWithPattern:@"[^ ][a-zA-Z]+---" options:0 error:NULL];
    options = UMKRandomBoolean() ? NSMatchingAnchored : 0;
    validator = [[TWTRegularExpressionStringValidator alloc] initWithRegularExpression:regularExpression options:options];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
    XCTAssertEqualObjects(validator.valueClass, [NSString class], @"value class is not NSString");
    XCTAssertEqualObjects(validator.regularExpression, regularExpression, @"regular expression is not set correctly");
    XCTAssertEqual(validator.options, options, @"options is not set correctly");
}


- (void)testCopy
{
    BOOL allowsNil = UMKRandomBoolean();
    BOOL allowsNull = UMKRandomBoolean();

    NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:@"\\(\\d{3}\\) \\d{3}-\\d{4}" options:0 error:NULL];
    NSMatchingOptions options = UMKRandomBoolean() ? NSMatchingAnchored : 0;
    TWTRegularExpressionStringValidator *validator = [TWTStringValidator stringValidatorWithRegularExpression:regularExpression options:options];
    validator.allowsNil = allowsNil;
    validator.allowsNull = allowsNull;

    TWTRegularExpressionStringValidator *copy = [validator copy];

    XCTAssertEqualObjects(validator, copy, @"copy is not equal to original");
    XCTAssertEqualObjects(copy.valueClass, [NSString class], @"value class is not set correctly");
    XCTAssertEqual(copy.allowsNil, allowsNil, @"allowsNil is not set correctly");
    XCTAssertEqual(copy.allowsNull, allowsNull, @"allowsNull is not set correctly");
    XCTAssertEqualObjects(copy.regularExpression, regularExpression, @"regular expression is not set correctly");
    XCTAssertEqual(copy.options, options, @"options is not set correctly");
}


- (void)testHashAndIsEqual
{
    NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:@"\\d{5}" options:0 error:NULL];
    NSMatchingOptions options = UMKRandomBoolean() ? NSMatchingAnchored : 0;

    TWTRegularExpressionStringValidator *validator1 = [TWTStringValidator stringValidatorWithRegularExpression:regularExpression options:options];
    TWTRegularExpressionStringValidator *validator2 = [TWTStringValidator stringValidatorWithRegularExpression:regularExpression options:options];

    XCTAssertEqual(validator1.hash, validator2.hash, @"hashes are not equal for equal objects");
    XCTAssertEqualObjects(validator1, validator2, @"equal objects are not equal");

    // Allows nil
    validator1.allowsNil = !validator2.allowsNil;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");

    validator2.allowsNil = validator1.allowsNil;
    XCTAssertEqual(validator1.hash, validator2.hash, @"hashes are not equal for equal objects");
    XCTAssertEqualObjects(validator1, validator2, @"equal objects are not equal");

    // Allows nil
    validator1.allowsNull = !validator2.allowsNull;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");

    validator2.allowsNull = validator1.allowsNull;
    XCTAssertEqual(validator1.hash, validator2.hash, @"hashes are not equal for equal objects");
    XCTAssertEqualObjects(validator1, validator2, @"equal objects are not equal");

    // Regular expression
    NSRegularExpression *otherRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"\\w+" options:0 error:NULL];
    validator2 = [TWTStringValidator stringValidatorWithRegularExpression:otherRegularExpression options:options];
    validator2.allowsNil = validator1.allowsNil;
    validator2.allowsNull = validator1.allowsNull;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");

    // Options
    validator2 = [TWTStringValidator stringValidatorWithRegularExpression:regularExpression options:NSMatchingWithoutAnchoringBounds];
    validator2.allowsNil = validator1.allowsNil;
    validator2.allowsNull = validator1.allowsNull;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");
}


- (void)testValidateValueErrorBoundedLengthMinimum
{
    NSUInteger minimumLength = random() % 100 + 1;

    TWTBoundedLengthStringValidator *validator = [TWTStringValidator stringValidatorWithMinimumLength:minimumLength maximumLength:NSUIntegerMax];
    NSString *value = UMKRandomUnicodeStringWithLength(minimumLength);
    XCTAssertTrue([validator validateValue:value error:NULL], @"fails with minimum length");

    value = UMKRandomUnicodeStringWithLength(minimumLength - 1);
    XCTAssertFalse([validator validateValue:value error:NULL], @"passes with smaller length");

    NSError *error = nil;
    XCTAssertFalse([validator validateValue:value error:&error], @"passes with smaller length");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeLengthLessThanMinimum, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validated value");
}


- (void)testValidateValueErrorBoundedLengthMaximum
{
    NSUInteger maximumLength = random() % 100 + 1;

    TWTBoundedLengthStringValidator *validator = [TWTStringValidator stringValidatorWithMinimumLength:0 maximumLength:maximumLength];
    NSString *value = UMKRandomUnicodeStringWithLength(maximumLength);
    XCTAssertTrue([validator validateValue:value error:NULL], @"fails with maximum length");

    value = UMKRandomUnicodeStringWithLength(maximumLength + 1);
    XCTAssertFalse([validator validateValue:value error:NULL], @"passes with larger length");

    NSError *error = nil;
    XCTAssertFalse([validator validateValue:value error:&error], @"passes with larger length");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeLengthGreaterThanMaximum, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validated value");
}


- (void)testValidateValueErrorRegularExpression
{
    NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:@"^[A-Z][a-z]+ [0-9]+$" options:0 error:NULL];
    TWTRegularExpressionStringValidator *validator = [TWTStringValidator stringValidatorWithRegularExpression:regularExpression options:0];

    XCTAssertTrue([validator validateValue:@"Abcdefghij 123456" error:NULL], @"fails with matching string");

    NSString *value = [@"1" stringByAppendingString:UMKRandomUnicodeString()];
    NSError *error = nil;
    XCTAssertFalse([validator validateValue:value error:&error], @"passes with non-matching string");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeValueDoesNotMatchFormat, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validated value");
}


- (void)testPrefixValidateValueError
{
    NSUInteger prefixLength = random() % 10 + 10;
    NSString *prefix = UMKRandomAlphanumericStringWithLength(prefixLength);
    NSString *value = [prefix uppercaseString];
    
    // validate with case sensitive
    TWTStringValidator *validator = [TWTStringValidator stringValidatorWithPrefixString:prefix caseSensitive:YES];
    XCTAssertFalse([validator validateValue:value error:NULL], @"does not fail case sensitive validation");
    
    // validate with case insensitive
    validator = [TWTStringValidator stringValidatorWithPrefixString:prefix caseSensitive:NO];
    XCTAssertTrue([validator validateValue:value error:NULL], @"fails with matching string");

    // validate with invalid value
    value = [@"1" stringByAppendingString:UMKRandomUnicodeString()];
    NSError *error = nil;
    
    XCTAssertFalse([validator validateValue:value error:&error], @"passes with non-matching string");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeValueDoesNotMatchFormat, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validated value");
}


- (void)testSuffixValidateValueError
{
    NSUInteger suffixLength = random() % 10 + 10;
    NSString *suffix = UMKRandomAlphanumericStringWithLength(suffixLength);
    NSString *value = [suffix uppercaseString];
    
    // validate with case sensitive
    TWTStringValidator *validator = [TWTStringValidator stringValidatorWithSuffixString:suffix caseSensitive:YES];
    XCTAssertFalse([validator validateValue:value error:NULL], @"does not fail case sensitive validation");
    
    // validate with case insensitive
    validator = [TWTStringValidator stringValidatorWithSuffixString:suffix caseSensitive:NO];
    XCTAssertTrue([validator validateValue:value error:NULL], @"fails with matching string");
    
    // validate with invalid value
    value = [@"1" stringByAppendingString:UMKRandomUnicodeString()];
    NSError *error = nil;
    
    XCTAssertFalse([validator validateValue:value error:&error], @"passes with non-matching string");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeValueDoesNotMatchFormat, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validated value");
}


- (void)testSubstringValidateValueError
{
    NSUInteger substringLength = random() % 10 + 10;
    NSString *substring = UMKRandomAlphanumericStringWithLength(substringLength);
    NSString *value = [[substring uppercaseString] stringByAppendingString:UMKRandomAlphanumericString()];
    
    // validate with case sensitive
    TWTSubstringValidator *validator = [TWTStringValidator stringValidatorWithSubstring:substring caseSensitive:YES];
    XCTAssertFalse([validator validateValue:value error:NULL], @"does not fail case sensitive validation");
    
    // validate with case insensitive
    validator = [TWTStringValidator stringValidatorWithSubstring:substring caseSensitive:NO];
    XCTAssertTrue([validator validateValue:value error:NULL], @"fails with matching string");
    
    // validate with invalid value
    value = UMKRandomAlphanumericString();
    NSError *error = nil;
    
    XCTAssertFalse([validator validateValue:value error:&error], @"passes with non-matching string");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeValueDoesNotMatchFormat, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validated value");
}

@end
