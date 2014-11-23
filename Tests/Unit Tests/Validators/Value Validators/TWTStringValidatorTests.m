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

- (void)testInitBoundedLength;
- (void)testCopyBoundedLength;
- (void)testHashAndIsEqualBoundedLength;
- (void)testValidateValueErrorBoundedLengthMinimum;
- (void)testValidateValueErrorBoundedLengthMaximum;

- (void)testInitRegularExpression;
- (void)testCopyRegularExpression;
- (void)testHashAndIsEqualRegularExpression;
- (void)testValidateValueErrorRegularExpression;

- (void)testInitPrefix;
- (void)testCopyPrefix;
- (void)testHashAndIsEqualPrefix;
- (void)testValidateValueErrorPrefix;

- (void)testInitSuffix;
- (void)testCopySuffix;
- (void)testHashAndIsEqualSuffix;
- (void)testValidateValueErrorSuffix;

- (void)testInitSubstring;
- (void)testCopySubstring;
- (void)testHashAndIsEqualSubstring;
- (void)testValidateValueErrorSubstring;

- (void)testInitWildcardPattern;
- (void)testCopyWildcardPattern;
- (void)testHashAndIsEqualWildcardPattern;
- (void)testValidateValueErrorWildcardPattern;

- (void)testInitCharacterSet;
- (void)testCopyCharacterSet;
- (void)testHashAndIsEqualCharacterSet;
- (void)testValidateValueErrorCharacterSet;

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


#pragma mark - Bounded Length

- (void)testInitBoundedLength
{
    NSUInteger length = random();
    TWTBoundedLengthStringValidator *validator = [TWTStringValidator stringValidatorWithLength:length];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
    XCTAssertEqualObjects(validator.valueClass, [NSString class], @"value class is not NSString");
    XCTAssertEqual(validator.minimumLength, length, @"minimum length is not set correctly");
    XCTAssertEqual(validator.maximumLength, length, @"maximum length is not set correctly");

    NSUInteger minimumLength = random();
    NSUInteger maximumLength = random() + minimumLength;
    validator = [TWTStringValidator stringValidatorWithMinimumLength:minimumLength maximumLength:maximumLength];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
    XCTAssertEqualObjects(validator.valueClass, [NSString class], @"value class is not NSString");
    XCTAssertEqual(validator.minimumLength, minimumLength, @"minimum length is not set correctly");
    XCTAssertEqual(validator.maximumLength, maximumLength, @"maximum length is not set correctly");

    validator = [[TWTBoundedLengthStringValidator alloc] init];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
    XCTAssertEqualObjects(validator.valueClass, [NSString class], @"value class is not NSString");
    XCTAssertEqual(validator.minimumLength, (NSUInteger)0, @"minimum length is not set correctly");
    XCTAssertEqual(validator.maximumLength, NSUIntegerMax, @"maximum length is not set correctly");

    validator = [[TWTBoundedLengthStringValidator alloc] initWithMinimumLength:minimumLength maximumLength:maximumLength];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
    XCTAssertEqualObjects(validator.valueClass, [NSString class], @"value class is not NSString");
    XCTAssertEqual(validator.minimumLength, minimumLength, @"minimum length is not set correctly");
    XCTAssertEqual(validator.maximumLength, maximumLength, @"maximum length is not set correctly");
}


- (void)testCopyBoundedLength
{
    BOOL allowsNil = UMKRandomBoolean();
    BOOL allowsNull = UMKRandomBoolean();

    NSUInteger minimumLength = random();
    NSUInteger maximumLength = random() + minimumLength;

    TWTBoundedLengthStringValidator *validator = [TWTStringValidator stringValidatorWithMinimumLength:minimumLength maximumLength:maximumLength];
    validator.allowsNil = allowsNil;
    validator.allowsNull = allowsNull;

    TWTBoundedLengthStringValidator *copy = [validator copy];

    XCTAssertEqualObjects(validator, copy, @"copy is not equal to original");
    XCTAssertEqualObjects(copy.valueClass, [NSString class], @"value class is not set correctly");
    XCTAssertEqual(copy.allowsNil, allowsNil, @"allowsNil is not set correctly");
    XCTAssertEqual(copy.allowsNull, allowsNull, @"allowsNull is not set correctly");
    XCTAssertEqual(copy.minimumLength, minimumLength, @"minimum length is not set correctly");
    XCTAssertEqual(copy.maximumLength, maximumLength, @"maximum length is not set correctly");
}


- (void)testHashAndIsEqualBoundedLength
{
    NSUInteger minimumLength = random() + 100;
    NSUInteger maximumLength = minimumLength + random() % 1024;

    TWTBoundedLengthStringValidator *validator1 = [TWTStringValidator stringValidatorWithMinimumLength:minimumLength maximumLength:maximumLength];
    TWTBoundedLengthStringValidator *validator2 = [TWTStringValidator stringValidatorWithMinimumLength:minimumLength maximumLength:maximumLength];

    XCTAssertEqual(validator1.hash, validator2.hash, @"hashes are not equal for equal objects");
    XCTAssertEqualObjects(validator1, validator2, @"equal objects are not equal");

    // Allows nil
    validator1.allowsNil = !validator2.allowsNil;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");

    validator2.allowsNil = validator1.allowsNil;
    XCTAssertEqual(validator1.hash, validator2.hash, @"hashes are not equal for equal objects");
    XCTAssertEqualObjects(validator1, validator2, @"equal objects are not equal");

    // Allows null
    validator1.allowsNull = !validator2.allowsNull;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");

    validator2.allowsNull = validator1.allowsNull;
    XCTAssertEqual(validator1.hash, validator2.hash, @"hashes are not equal for equal objects");
    XCTAssertEqualObjects(validator1, validator2, @"equal objects are not equal");

    // Minimum length
    validator2 = [TWTStringValidator stringValidatorWithMinimumLength:(minimumLength - random() % 100) maximumLength:maximumLength];
    validator2.allowsNil = validator1.allowsNil;
    validator2.allowsNull = validator1.allowsNull;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");

    // Maximum length
    validator2 = [TWTStringValidator stringValidatorWithMinimumLength:minimumLength maximumLength:maximumLength + random() % 100];
    validator2.allowsNil = validator1.allowsNil;
    validator2.allowsNull = validator1.allowsNull;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");
}


- (void)testValidateValueErrorBoundedLengthMinimum
{
    NSUInteger minimumLength = random() % 100 + 2;

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


#pragma mark - Regular Expression

- (void)testInitRegularExpression
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


- (void)testCopyRegularExpression
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


- (void)testHashAndIsEqualRegularExpression
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

    // Allows null
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


#pragma mark - Prefix

- (void)testInitPrefix
{
    NSString *prefix = UMKRandomUnicodeString();
    BOOL caseSensitive = UMKRandomBoolean();

    TWTPrefixStringValidator *validator = [TWTStringValidator stringValidatorWithPrefix:prefix caseSensitive:caseSensitive];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
    XCTAssertEqualObjects(validator.valueClass, [NSString class], @"value class is not NSString");
    XCTAssertEqualObjects(validator.prefix, prefix, @"prefix is not set correctly");
    XCTAssertEqual(validator.isCaseSensitive, caseSensitive, @"caseSensitive is not set correctly");

    validator = [[TWTPrefixStringValidator alloc] init];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
    XCTAssertEqualObjects(validator.valueClass, [NSString class], @"value class is not NSString");
    XCTAssertNil(validator.prefix, @"prefix is non-nil");
    XCTAssertTrue(validator.isCaseSensitive, @"caseSensitive is initially NO");

    validator = [[TWTPrefixStringValidator alloc] initWithPrefix:prefix caseSensitive:caseSensitive];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
    XCTAssertEqualObjects(validator.valueClass, [NSString class], @"value class is not NSString");
    XCTAssertEqualObjects(validator.prefix, prefix, @"prefix is not set correctly");
    XCTAssertEqual(validator.isCaseSensitive, caseSensitive, @"caseSensitive is not set correctly");
}


- (void)testCopyPrefix
{
    BOOL allowsNil = UMKRandomBoolean();
    BOOL allowsNull = UMKRandomBoolean();
    NSString *prefix = UMKRandomUnicodeString();
    BOOL caseSensitive = UMKRandomBoolean();

    TWTPrefixStringValidator *validator = [TWTStringValidator stringValidatorWithPrefix:prefix caseSensitive:caseSensitive];
    validator.allowsNil = allowsNil;
    validator.allowsNull = allowsNull;

    TWTPrefixStringValidator *copy = [validator copy];

    XCTAssertEqualObjects(validator, copy, @"copy is not equal to original");
    XCTAssertEqualObjects(copy.valueClass, [NSString class], @"value class is not set correctly");
    XCTAssertEqual(copy.allowsNil, allowsNil, @"allowsNil is not set correctly");
    XCTAssertEqual(copy.allowsNull, allowsNull, @"allowsNull is not set correctly");
    XCTAssertEqualObjects(copy.prefix, prefix, @"prefix is not set correctly");
    XCTAssertEqual(copy.isCaseSensitive, caseSensitive, @"caseSensitive is not set correctly");
}


- (void)testHashAndIsEqualPrefix
{
    NSString *prefix = UMKRandomUnicodeString();
    BOOL caseSensitive = UMKRandomBoolean();

    TWTPrefixStringValidator *validator1 = [TWTStringValidator stringValidatorWithPrefix:prefix caseSensitive:caseSensitive];
    TWTPrefixStringValidator *validator2 = [TWTStringValidator stringValidatorWithPrefix:prefix caseSensitive:caseSensitive];

    XCTAssertEqual(validator1.hash, validator2.hash, @"hashes are not equal for equal objects");
    XCTAssertEqualObjects(validator1, validator2, @"equal objects are not equal");

    // Allows nil
    validator1.allowsNil = !validator2.allowsNil;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");

    validator2.allowsNil = validator1.allowsNil;
    XCTAssertEqual(validator1.hash, validator2.hash, @"hashes are not equal for equal objects");
    XCTAssertEqualObjects(validator1, validator2, @"equal objects are not equal");

    // Allows null
    validator1.allowsNull = !validator2.allowsNull;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");

    validator2.allowsNull = validator1.allowsNull;
    XCTAssertEqual(validator1.hash, validator2.hash, @"hashes are not equal for equal objects");
    XCTAssertEqualObjects(validator1, validator2, @"equal objects are not equal");

    // Prefix
    validator2 = [TWTStringValidator stringValidatorWithPrefix:[prefix stringByAppendingString:UMKRandomUnicodeString()] caseSensitive:caseSensitive];
    validator2.allowsNil = validator1.allowsNil;
    validator2.allowsNull = validator1.allowsNull;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");

    // Case-sensitive
    validator2 = [TWTStringValidator stringValidatorWithPrefix:prefix caseSensitive:!caseSensitive];
    validator2.allowsNil = validator1.allowsNil;
    validator2.allowsNull = validator1.allowsNull;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");
}


- (void)testValidateValueErrorPrefix
{
    NSUInteger prefixLength = random() % 10 + 10;
    NSString *prefix = UMKRandomAlphanumericStringWithLength(prefixLength);
    NSString *value = [prefix uppercaseString];
    
    // validate with case sensitive
    TWTPrefixStringValidator *validator = [[TWTPrefixStringValidator alloc] initWithPrefix:prefix caseSensitive:YES];
    XCTAssertFalse([validator validateValue:value error:NULL], @"does not fail case sensitive validation");
    
    // validate with case insensitive
    validator = [TWTStringValidator stringValidatorWithPrefix:prefix caseSensitive:NO];
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


#pragma mark - Suffix

- (void)testInitSuffix
{
    NSString *suffix = UMKRandomUnicodeString();
    BOOL caseSensitive = UMKRandomBoolean();

    TWTSuffixStringValidator *validator = [TWTStringValidator stringValidatorWithSuffix:suffix caseSensitive:caseSensitive];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
    XCTAssertEqualObjects(validator.valueClass, [NSString class], @"value class is not NSString");
    XCTAssertEqualObjects(validator.suffix, suffix, @"suffix is not set correctly");
    XCTAssertEqual(validator.isCaseSensitive, caseSensitive, @"caseSensitive is not set correctly");

    validator = [[TWTSuffixStringValidator alloc] init];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
    XCTAssertEqualObjects(validator.valueClass, [NSString class], @"value class is not NSString");
    XCTAssertNil(validator.suffix, @"suffix is non-nil");
    XCTAssertTrue(validator.isCaseSensitive, @"caseSensitive is initially NO");

    validator = [[TWTSuffixStringValidator alloc] initWithSuffix:suffix caseSensitive:caseSensitive];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
    XCTAssertEqualObjects(validator.valueClass, [NSString class], @"value class is not NSString");
    XCTAssertEqualObjects(validator.suffix, suffix, @"suffix is not set correctly");
    XCTAssertEqual(validator.isCaseSensitive, caseSensitive, @"caseSensitive is not set correctly");
}


- (void)testCopySuffix
{
    BOOL allowsNil = UMKRandomBoolean();
    BOOL allowsNull = UMKRandomBoolean();
    NSString *suffix = UMKRandomUnicodeString();
    BOOL caseSensitive = UMKRandomBoolean();

    TWTSuffixStringValidator *validator = [TWTStringValidator stringValidatorWithSuffix:suffix caseSensitive:caseSensitive];
    validator.allowsNil = allowsNil;
    validator.allowsNull = allowsNull;

    TWTSuffixStringValidator *copy = [validator copy];

    XCTAssertEqualObjects(validator, copy, @"copy is not equal to original");
    XCTAssertEqualObjects(copy.valueClass, [NSString class], @"value class is not set correctly");
    XCTAssertEqual(copy.allowsNil, allowsNil, @"allowsNil is not set correctly");
    XCTAssertEqual(copy.allowsNull, allowsNull, @"allowsNull is not set correctly");
    XCTAssertEqualObjects(copy.suffix, suffix, @"suffix is not set correctly");
    XCTAssertEqual(copy.isCaseSensitive, caseSensitive, @"caseSensitive is not set correctly");
}


- (void)testHashAndIsEqualSuffix
{
    NSString *suffix = UMKRandomUnicodeString();
    BOOL caseSensitive = UMKRandomBoolean();

    TWTSuffixStringValidator *validator1 = [TWTStringValidator stringValidatorWithSuffix:suffix caseSensitive:caseSensitive];
    TWTSuffixStringValidator *validator2 = [TWTStringValidator stringValidatorWithSuffix:suffix caseSensitive:caseSensitive];

    XCTAssertEqual(validator1.hash, validator2.hash, @"hashes are not equal for equal objects");
    XCTAssertEqualObjects(validator1, validator2, @"equal objects are not equal");

    // Allows nil
    validator1.allowsNil = !validator2.allowsNil;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");

    validator2.allowsNil = validator1.allowsNil;
    XCTAssertEqual(validator1.hash, validator2.hash, @"hashes are not equal for equal objects");
    XCTAssertEqualObjects(validator1, validator2, @"equal objects are not equal");

    // Allows null
    validator1.allowsNull = !validator2.allowsNull;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");

    validator2.allowsNull = validator1.allowsNull;
    XCTAssertEqual(validator1.hash, validator2.hash, @"hashes are not equal for equal objects");
    XCTAssertEqualObjects(validator1, validator2, @"equal objects are not equal");

    // Suffix
    validator2 = [TWTStringValidator stringValidatorWithSuffix:[suffix stringByAppendingString:UMKRandomUnicodeString()] caseSensitive:caseSensitive];
    validator2.allowsNil = validator1.allowsNil;
    validator2.allowsNull = validator1.allowsNull;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");

    // Case-sensitive
    validator2 = [TWTStringValidator stringValidatorWithSuffix:suffix caseSensitive:!caseSensitive];
    validator2.allowsNil = validator1.allowsNil;
    validator2.allowsNull = validator1.allowsNull;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");
}


- (void)testValidateValueErrorSuffix
{
    NSUInteger suffixLength = random() % 10 + 10;
    NSString *suffix = UMKRandomAlphanumericStringWithLength(suffixLength);
    NSString *value = [suffix uppercaseString];
    
    // validate with case sensitive
    TWTSuffixStringValidator *validator = [[TWTSuffixStringValidator alloc] initWithSuffix:suffix caseSensitive:YES];
    XCTAssertFalse([validator validateValue:value error:NULL], @"does not fail case sensitive validation");
    
    // validate with case insensitive
    validator = [TWTStringValidator stringValidatorWithSuffix:suffix caseSensitive:NO];
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


#pragma mark - Substring

- (void)testInitSubstring
{
    NSString *substring = UMKRandomUnicodeString();
    BOOL caseSensitive = UMKRandomBoolean();

    TWTSubstringStringValidator *validator = [TWTStringValidator stringValidatorWithSubstring:substring caseSensitive:caseSensitive];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
    XCTAssertEqualObjects(validator.valueClass, [NSString class], @"value class is not NSString");
    XCTAssertEqualObjects(validator.substring, substring, @"substring is not set correctly");
    XCTAssertEqual(validator.isCaseSensitive, caseSensitive, @"caseSensitive is not set correctly");

    validator = [[TWTSubstringStringValidator alloc] init];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
    XCTAssertEqualObjects(validator.valueClass, [NSString class], @"value class is not NSString");
    XCTAssertNil(validator.substring, @"substring is non-nil");
    XCTAssertTrue(validator.isCaseSensitive, @"caseSensitive is initially NO");

    validator = [[TWTSubstringStringValidator alloc] initWithSubstring:substring caseSensitive:caseSensitive];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
    XCTAssertEqualObjects(validator.valueClass, [NSString class], @"value class is not NSString");
    XCTAssertEqualObjects(validator.substring, substring, @"substring is not set correctly");
    XCTAssertEqual(validator.isCaseSensitive, caseSensitive, @"caseSensitive is not set correctly");
}


- (void)testCopySubstring
{
    BOOL allowsNil = UMKRandomBoolean();
    BOOL allowsNull = UMKRandomBoolean();
    NSString *substring = UMKRandomUnicodeString();
    BOOL caseSensitive = UMKRandomBoolean();

    TWTSubstringStringValidator *validator = [TWTStringValidator stringValidatorWithSubstring:substring caseSensitive:caseSensitive];
    validator.allowsNil = allowsNil;
    validator.allowsNull = allowsNull;

    TWTSubstringStringValidator *copy = [validator copy];

    XCTAssertEqualObjects(validator, copy, @"copy is not equal to original");
    XCTAssertEqualObjects(copy.valueClass, [NSString class], @"value class is not set correctly");
    XCTAssertEqual(copy.allowsNil, allowsNil, @"allowsNil is not set correctly");
    XCTAssertEqual(copy.allowsNull, allowsNull, @"allowsNull is not set correctly");
    XCTAssertEqualObjects(copy.substring, substring, @"substring is not set correctly");
    XCTAssertEqual(copy.isCaseSensitive, caseSensitive, @"caseSensitive is not set correctly");
}


- (void)testHashAndIsEqualSubstring
{
    NSString *substring = UMKRandomUnicodeString();
    BOOL caseSensitive = UMKRandomBoolean();

    TWTSubstringStringValidator *validator1 = [TWTStringValidator stringValidatorWithSubstring:substring caseSensitive:caseSensitive];
    TWTSubstringStringValidator *validator2 = [TWTStringValidator stringValidatorWithSubstring:substring caseSensitive:caseSensitive];

    XCTAssertEqual(validator1.hash, validator2.hash, @"hashes are not equal for equal objects");
    XCTAssertEqualObjects(validator1, validator2, @"equal objects are not equal");

    // Allows nil
    validator1.allowsNil = !validator2.allowsNil;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");

    validator2.allowsNil = validator1.allowsNil;
    XCTAssertEqual(validator1.hash, validator2.hash, @"hashes are not equal for equal objects");
    XCTAssertEqualObjects(validator1, validator2, @"equal objects are not equal");

    // Allows null
    validator1.allowsNull = !validator2.allowsNull;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");

    validator2.allowsNull = validator1.allowsNull;
    XCTAssertEqual(validator1.hash, validator2.hash, @"hashes are not equal for equal objects");
    XCTAssertEqualObjects(validator1, validator2, @"equal objects are not equal");

    // Substring
    validator2 = [TWTStringValidator stringValidatorWithSubstring:[substring stringByAppendingString:UMKRandomUnicodeString()] caseSensitive:caseSensitive];
    validator2.allowsNil = validator1.allowsNil;
    validator2.allowsNull = validator1.allowsNull;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");

    // Case-sensitive
    validator2 = [TWTStringValidator stringValidatorWithSubstring:substring caseSensitive:!caseSensitive];
    validator2.allowsNil = validator1.allowsNil;
    validator2.allowsNull = validator1.allowsNull;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");
}


- (void)testValidateValueErrorSubstring
{
    NSUInteger substringLength = random() % 10 + 10;
    NSString *substring = UMKRandomAlphanumericStringWithLength(substringLength);
    NSString *value = [[substring uppercaseString] stringByAppendingString:UMKRandomAlphanumericString()];
    
    // validate with case sensitive
    TWTSubstringStringValidator *validator = [[TWTSubstringStringValidator alloc] initWithSubstring:substring caseSensitive:YES];
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


#pragma mark - Wildcard Pattern

- (void)testInitWildcardPattern
{
    NSString *pattern = UMKRandomUnicodeString();
    BOOL caseSensitive = UMKRandomBoolean();

    TWTWildcardPatternStringValidator *validator = [TWTStringValidator stringValidatorWithPattern:pattern caseSensitive:caseSensitive];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
    XCTAssertEqualObjects(validator.valueClass, [NSString class], @"value class is not NSString");
    XCTAssertEqualObjects(validator.pattern, pattern, @"pattern is not set correctly");
    XCTAssertEqual(validator.isCaseSensitive, caseSensitive, @"caseSensitive is not set correctly");

    validator = [[TWTWildcardPatternStringValidator alloc] init];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
    XCTAssertEqualObjects(validator.valueClass, [NSString class], @"value class is not NSString");
    XCTAssertNil(validator.pattern, @"pattern is non-nil");
    XCTAssertTrue(validator.isCaseSensitive, @"caseSensitive is initially NO");

    validator = [[TWTWildcardPatternStringValidator alloc] initWithPattern:pattern caseSensitive:caseSensitive];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
    XCTAssertEqualObjects(validator.valueClass, [NSString class], @"value class is not NSString");
    XCTAssertEqualObjects(validator.pattern, pattern, @"pattern is not set correctly");
    XCTAssertEqual(validator.isCaseSensitive, caseSensitive, @"caseSensitive is not set correctly");
}


- (void)testCopyWildcardPattern
{
    BOOL allowsNil = UMKRandomBoolean();
    BOOL allowsNull = UMKRandomBoolean();
    NSString *pattern = UMKRandomUnicodeString();
    BOOL caseSensitive = UMKRandomBoolean();

    TWTWildcardPatternStringValidator *validator = [TWTStringValidator stringValidatorWithPattern:pattern caseSensitive:caseSensitive];
    validator.allowsNil = allowsNil;
    validator.allowsNull = allowsNull;

    TWTWildcardPatternStringValidator *copy = [validator copy];

    XCTAssertEqualObjects(validator, copy, @"copy is not equal to original");
    XCTAssertEqualObjects(copy.valueClass, [NSString class], @"value class is not set correctly");
    XCTAssertEqual(copy.allowsNil, allowsNil, @"allowsNil is not set correctly");
    XCTAssertEqual(copy.allowsNull, allowsNull, @"allowsNull is not set correctly");
    XCTAssertEqualObjects(copy.pattern, pattern, @"pattern is not set correctly");
    XCTAssertEqual(copy.isCaseSensitive, caseSensitive, @"caseSensitive is not set correctly");
}


- (void)testHashAndIsEqualWildcardPattern
{
    NSString *pattern = UMKRandomUnicodeString();
    BOOL caseSensitive = UMKRandomBoolean();

    TWTWildcardPatternStringValidator *validator1 = [TWTStringValidator stringValidatorWithPattern:pattern caseSensitive:caseSensitive];
    TWTWildcardPatternStringValidator *validator2 = [TWTStringValidator stringValidatorWithPattern:pattern caseSensitive:caseSensitive];

    XCTAssertEqual(validator1.hash, validator2.hash, @"hashes are not equal for equal objects");
    XCTAssertEqualObjects(validator1, validator2, @"equal objects are not equal");

    // Allows nil
    validator1.allowsNil = !validator2.allowsNil;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");

    validator2.allowsNil = validator1.allowsNil;
    XCTAssertEqual(validator1.hash, validator2.hash, @"hashes are not equal for equal objects");
    XCTAssertEqualObjects(validator1, validator2, @"equal objects are not equal");

    // Allows null
    validator1.allowsNull = !validator2.allowsNull;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");

    validator2.allowsNull = validator1.allowsNull;
    XCTAssertEqual(validator1.hash, validator2.hash, @"hashes are not equal for equal objects");
    XCTAssertEqualObjects(validator1, validator2, @"equal objects are not equal");

    // WildcardPattern
    validator2 = [TWTStringValidator stringValidatorWithPattern:[pattern stringByAppendingString:UMKRandomUnicodeString()] caseSensitive:caseSensitive];
    validator2.allowsNil = validator1.allowsNil;
    validator2.allowsNull = validator1.allowsNull;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");

    // Case-sensitive
    validator2 = [TWTStringValidator stringValidatorWithPattern:pattern caseSensitive:!caseSensitive];
    validator2.allowsNil = validator1.allowsNil;
    validator2.allowsNull = validator1.allowsNull;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");
}


- (void)testValidateValueErrorWildcardPattern
{
    NSString *seed = UMKRandomAlphanumericString();
    
    // validate with case sensitive with * character
    NSString *patternString = [NSString stringWithFormat:@"%@.*", seed];
    TWTWildcardPatternStringValidator *validator = [[TWTWildcardPatternStringValidator alloc] initWithPattern:patternString caseSensitive:YES];
    
    NSString *wildcardValue = [NSString stringWithFormat:@"%@.%@", seed.uppercaseString, UMKRandomAlphanumericString()];
    XCTAssertFalse([validator validateValue:wildcardValue error:NULL], @"does not fail case sensitive validation");
    
    // validate with case insensitive with * character
    validator = [TWTStringValidator stringValidatorWithPattern:patternString caseSensitive:NO];
    wildcardValue = [NSString stringWithFormat:@"%@.%@", seed.uppercaseString, UMKRandomAlphanumericString()];
    XCTAssertTrue([validator validateValue:wildcardValue error:NULL], @"fails with matching string");
    
    // validate with case sensitive with ? character
    patternString = [NSString stringWithFormat:@"%@.?", seed];
    validator = [TWTStringValidator stringValidatorWithPattern:patternString caseSensitive:YES];
    
    wildcardValue = [NSString stringWithFormat:@"%@.%@", seed.uppercaseString, UMKRandomAlphanumericStringWithLength(1)];
    XCTAssertFalse([validator validateValue:wildcardValue error:NULL], @"does not fail case sensitive validation");
    
    // validate with case insensitive with ? character
    validator = [TWTStringValidator stringValidatorWithPattern:patternString caseSensitive:NO];
    wildcardValue = [NSString stringWithFormat:@"%@.%@", seed.uppercaseString, UMKRandomAlphanumericStringWithLength(1)];
    XCTAssertTrue([validator validateValue:wildcardValue error:NULL], @"fails with matching string");
    
    // validate with invalid value
    NSString *value = UMKRandomAlphanumericString();
    NSError *error = nil;
    
    XCTAssertFalse([validator validateValue:value error:&error], @"passes with non-matching string");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeValueDoesNotMatchFormat, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, value, @"incorrect validated value");
}


#pragma mark - Character Set

- (void)testInitCharacterSet
{
    NSCharacterSet *characterSet = [NSCharacterSet alphanumericCharacterSet];
    
    TWTCharacterSetStringValidator *validator = [TWTStringValidator stringValidatorWithCharacterSet:characterSet];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
    XCTAssertEqualObjects(validator.valueClass, [NSString class], @"value class is not NSString");
    XCTAssertEqualObjects(validator.characterSet, characterSet, @"character set is not set correctly");
    
    validator = [[TWTCharacterSetStringValidator alloc] init];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
    XCTAssertEqualObjects(validator.valueClass, [NSString class], @"value class is not NSString");
    XCTAssertNil(validator.characterSet, @"character set is non-nil");
    
    validator = [[TWTCharacterSetStringValidator alloc] initWithCharacterSet:characterSet];
    XCTAssertNotNil(validator, @"returns nil");
    XCTAssertFalse(validator.allowsNil, @"allowsNil is YES");
    XCTAssertFalse(validator.allowsNull, @"allowsNull is YES");
    XCTAssertEqualObjects(validator.valueClass, [NSString class], @"value class is not NSString");
    XCTAssertEqualObjects(validator.characterSet, characterSet, @"character set is not set correctly");
}


- (void)testCopyCharacterSet
{
    BOOL allowsNil = UMKRandomBoolean();
    BOOL allowsNull = UMKRandomBoolean();
    NSCharacterSet *characterSet = [NSCharacterSet alphanumericCharacterSet];
    
    TWTCharacterSetStringValidator *validator = [TWTStringValidator stringValidatorWithCharacterSet:characterSet];
    validator.allowsNil = allowsNil;
    validator.allowsNull = allowsNull;
    
    TWTCharacterSetStringValidator *copy = [validator copy];
    
    XCTAssertEqualObjects(validator, copy, @"copy is not equal to original");
    XCTAssertEqualObjects(copy.valueClass, [NSString class], @"value class is not set correctly");
    XCTAssertEqual(copy.allowsNil, allowsNil, @"allowsNil is not set correctly");
    XCTAssertEqual(copy.allowsNull, allowsNull, @"allowsNull is not set correctly");
    XCTAssertEqualObjects(copy.characterSet, characterSet, @"character set is not set correctly");
}


- (void)testHashAndIsEqualCharacterSet
{
    NSCharacterSet *characterSet = [NSCharacterSet alphanumericCharacterSet];
    
    TWTCharacterSetStringValidator *validator1 = [TWTStringValidator stringValidatorWithCharacterSet:characterSet];
    TWTCharacterSetStringValidator *validator2 = [TWTStringValidator stringValidatorWithCharacterSet:characterSet];
    
    XCTAssertEqual(validator1.hash, validator2.hash, @"hashes are not equal for equal objects");
    XCTAssertEqualObjects(validator1, validator2, @"equal objects are not equal");
    
    // Allows nil
    validator1.allowsNil = !validator2.allowsNil;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");
    
    validator2.allowsNil = validator1.allowsNil;
    XCTAssertEqual(validator1.hash, validator2.hash, @"hashes are not equal for equal objects");
    XCTAssertEqualObjects(validator1, validator2, @"equal objects are not equal");
    
    // Allows null
    validator1.allowsNull = !validator2.allowsNull;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");
    
    validator2.allowsNull = validator1.allowsNull;
    XCTAssertEqual(validator1.hash, validator2.hash, @"hashes are not equal for equal objects");
    XCTAssertEqualObjects(validator1, validator2, @"equal objects are not equal");
    
    // WildcardPattern
    validator2 = [TWTStringValidator stringValidatorWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
    validator2.allowsNil = validator1.allowsNil;
    validator2.allowsNull = validator1.allowsNull;
    XCTAssertNotEqualObjects(validator1, validator2, @"unequal objects are equal");
}


- (void)testValidateValueErrorCharacterSet
{
    NSString *stringValue = UMKRandomAlphanumericString();
    NSCharacterSet *characterSet = [NSCharacterSet characterSetWithCharactersInString:stringValue];
    NSCharacterSet *failingCharacterSet = [NSCharacterSet punctuationCharacterSet];
    
    TWTCharacterSetStringValidator *validator = [[TWTCharacterSetStringValidator alloc] initWithCharacterSet:characterSet];
    XCTAssertTrue([validator validateValue:stringValue error:NULL], @"fails when character set created from same string");
    
    validator = [TWTStringValidator stringValidatorWithCharacterSet:failingCharacterSet];
    
    // validate with invalid value
    NSError *error = nil;
    
    XCTAssertFalse([validator validateValue:stringValue error:&error], @"should fail when string doesn't match character set");
    XCTAssertNotNil(error, @"returns nil error");
    XCTAssertEqualObjects(error.domain, TWTValidationErrorDomain, @"incorrect error domain");
    XCTAssertEqual(error.code, TWTValidationErrorCodeValueDoesNotMatchFormat, @"incorrect error code");
    XCTAssertEqualObjects(error.twt_failingValidator, validator, @"incorrect failing validator");
    XCTAssertEqualObjects(error.twt_validatedValue, stringValue, @"incorrect validated value");
}

@end
