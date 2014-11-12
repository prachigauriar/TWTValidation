//
//  TWTStringValidator.h
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/27/2014.
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

#import <TWTValidation/TWTValueValidator.h>

@class TWTBoundedLengthStringValidator, TWTRegularExpressionStringValidator, TWTPrefixStringValidator, TWTSuffixStringValidator, TWTSubstringValidator, TWTPatternExpressionStringValidator;

/*!
 Protocol that specifies whether a conforming validator should verify the case of the string it is checking.
 */
@protocol TWTCaseSensitiveValidating <NSObject>

/*!
 @abstract Should the conforming validator validate the case of the string
 @discussion Conforming validators should default to YES.
 */
@property (nonatomic, assign, readonly) BOOL validatesCase;

@end

/*!
 TWTStringValidators validate that values are NSString instances. Its subclasses,
 TWTBoundedLengthStringValidator and TWTRegularExpressionStringValidator validate that a string’s length is
 within a range and that the string matches a regular expression, respectively. These subclasses need not be
 instantiated directly. Instead, use one of TWTStringValidator’s factory methods. The subclasses are exposed
 only so that they can be subclassed.
 */
@interface TWTStringValidator : TWTValueValidator <NSCopying>

/*!
 @abstract Creates and returns a new string validator that validates that strings are of the specified length.
 @discussion This method simply creates a new TWTBoundedLengthStringValidator whose minimum and maximum
     lengths are set to length.
 @param length The length of valid strings.
 @result A newly created string validator that validates that strings are the specified length.
 */
+ (TWTBoundedLengthStringValidator *)stringValidatorWithLength:(NSUInteger)length;

/*!
 @abstract Creates and returns a new string validator that validates that strings have the specified minimum
     and maximum lengths.
 @discussion This method creates a new TWTBoundedLengthStringValidator with the appropriate minimum and
     maximum lengths.
 @param minimumLength The minimum length for valid strings. Use 0 to indicate no minimum.
 @param maximumLength The maximum length for valid strings. Use NSUIntegerMax to indicate no maximum.
 @result A newly created string validator that validates that strings have the specified minimum and maximum
     lengths.
 */
+ (TWTBoundedLengthStringValidator *)stringValidatorWithMinimumLength:(NSUInteger)minimumLength maximumLength:(NSUInteger)maximumLength;

/*!
 @abstract Creates and returns a new string validator that validates that strings match the specified regular
     expression.
 @param regularExpression The regular expression.
 @param options The regular expression matching options to use when validating values.
 @result A newly created string validator that validates that strings match the specified regular expression.
 */
+ (TWTRegularExpressionStringValidator *)stringValidatorWithRegularExpression:(NSRegularExpression *)regularExpression options:(NSMatchingOptions)options;


/*!
 @abstract Creates and returns a new string validator that validates that strings have the matching prefix
 @param prefixString The prefix to validate
 @param caseSensitive Should the validation be case sensitive
 @result A newly created string validator that valdiates that strings have the correct prefix
 */
+ (TWTPrefixStringValidator *)stringValidatorWithPrefixString:(NSString *)prefixString caseSensitive:(BOOL)caseSensitive;


/*!
 @abstract Create and returns a new string validator that validates that strings have the matching suffix
 @param suffixString The suffix to validate
 @param caseSensitive Should the valdiation be case sensitive
 @result A newly created string validator that validates that strings have the correct suffix
 */
+ (TWTSuffixStringValidator *)stringValidatorWithSuffixString:(NSString *)suffixString caseSensitive:(BOOL)caseSensitive;


/*!
 @abstract Creates and returns a new string validator that validates that strings have the matching substring
 @param substring The substring to validate
 @param caseSensitive Should the validation be case sensitive
 @result A newly created string validator that validates that strings have the matching substrings
 */
+ (TWTSubstringValidator *)stringValidatorWithSubstring:(NSString *)substring caseSensitive:(BOOL)caseSensitive;


/*!
 @abstract Creates and returns a new wildcard based pattern expression string validator with the specified wild card based string.
 @param patternString The pattern string to use when validating. This string can support the use of
    '?' to match 1 character or '*' to match zero or more characters.
 @param caseSensitive Should case be considered when validating
 @result An initialized validator that checks the predicate to validate the value.
 */
+ (TWTPatternExpressionStringValidator *)stringValidatorWithPatternString:(NSString *)patternString caseSensitive:(BOOL)caseSensitive;

@end


/*!
 TWTBoundedLengthStringValidators validate that strings have lengths within mininimum and maximum values. 
 There is no need to create instances of this class directly. Instead, use the appropriate factory methods
 on TWTStringValidator. This class is exposed so that it may be easily subclassed if necessary.
 */
@interface TWTBoundedLengthStringValidator : TWTStringValidator <NSCopying>

/*! 
 @abstract The minimum length that the validator considers valid.
 @discussion The default is 0, which indicates no minimum length.
 */
@property (nonatomic, assign, readonly) NSUInteger minimumLength;

/*! 
 @abstract The maximum length that the validator considers valid.
 @discussion The default is NSUIntegerMax, which indicates no maximum length.
 */
@property (nonatomic, assign, readonly) NSUInteger maximumLength;

/*!
 @abstract Initializes a new bounded length string validator with the specified minimum and maximum lengths.
 @discussion This is the class’s designated initializer.
 @param minimumLength The minimum string length that the validator considers valid. 0 indicates no minimum
     length. 
 @param maximumLength The maximum string length that the validator considers valid. NSUIntegerMax indicates
     no maximum length. 
 @result An initialized bounded length string validator with the specified minimum and maximum lengths.
 */
- (instancetype)initWithMinimumLength:(NSUInteger)minimumLength maximumLength:(NSUInteger)maximumLength;

@end


/*!
 TWTRegularExpressionStringValidators validate that a string matches a regular expression. There is no need to
 create instances of this class directly. Instead, use the appropriate factory methods on TWTStringValidator.
 This class is exposed so that it may be easily subclassed if necessary.
 */
@interface TWTRegularExpressionStringValidator : TWTStringValidator

/*! 
 @abstract The regular expression that values must match in order to be considered valid.
 @discussion If nil, all strings are considered valid. nil by default.
 */
@property (nonatomic, strong, readonly) NSRegularExpression *regularExpression;

/*!
 @abstract The matching options to use when checking if a string matches the regular expression.
 @discussion 0 by default.
 */
@property (nonatomic, assign, readonly) NSMatchingOptions options;

/*!
 @abstract Initializes a new regular expression string validator with the specified regular expression.
 @discussion This is the class’s designated initializer.
 @param regularExpression The regular expression that values must match to be considered valid. If nil, all
     strings are considered valid.
 @param options The matching options to use when checking if a string matches the regular expression.
 @result An initialized regular expression string length validator with the specified regular expression.
 */
- (instancetype)initWithRegularExpression:(NSRegularExpression *)regularExpression options:(NSMatchingOptions)options;

@end


/*!
 TWTPrefixStringValidators validate that a string has a specified prefix. There is no need to create
 instances of this directly. Instead use +[TWTStringValidator stringValidatorWithPrefixString:]. This 
 class is exposed so that it may be easily subclassed if necessary.
 */
@interface TWTPrefixStringValidator : TWTStringValidator <TWTCaseSensitiveValidating>

/*!
 @abstract The prefix to use when validating a string.
 @discussion nil by default
 */
@property (nonatomic, copy, readonly) NSString *prefix;

/*!
 @abstract Initializes a new prefix string validator with the specified prefix string.
 @param prefix The prefix to use when validating a string
 @param caseSensitive Should case be considered when validating the prefix
 @return An initialized validator that checks the prefix of the value
 */
- (instancetype)initWithPrefixString:(NSString *)prefix caseSensitive:(BOOL)caseSensitive;

@end


/*!
 TWTSuffixStringValidators validate that a string has a specified prefix. There is no need to create
 instances of this directly. Instead use +[TWTStringValidator stringValidatorWithSuffixString:]. This
 class is exposed so that it may be easily subclassed if necessary.
 */
@interface TWTSuffixStringValidator : TWTStringValidator <TWTCaseSensitiveValidating>

/*!
 @abstract The suffix to use when validationg a string
 @discussion nil by default
 */
@property (nonatomic, copy, readonly) NSString *suffix;

/*!
 @abstract Initializes a new suffix string validator with the specified suffix string.
 @param suffix The suffix to use when validating a string
 @param caseSensitive Should case be considered when validating
 @return An initialized validator that checks the suffix of the value
 */
- (instancetype)initWithSuffixString:(NSString *)suffix caseSensitive:(BOOL)caseSensitive;

@end


/*!
 TWTSubstringValidators validate that a string has a specified substring. There is no need
 to create instances of this directly. Instead use +[TWTStringValidator stringValidatorWithSubstring:caseSensitive:].
 This class is exposed so that it may be easily subclassed if necessary.
 */
@interface TWTSubstringValidator : TWTStringValidator <TWTCaseSensitiveValidating>

/*!
 @abstract The substring to search for in the matching string
 @discussion nil by default
 */
@property (nonatomic, copy, readonly) NSString *substring;

/*!
 @abstract Initializes a new substring validator with the specified substring to search for
 @param substring The substring to use when validating a string
 @param caseSensitive Should case be considered when validating
 @return An initialized validator that checks the substring's existence in the value.
 */
- (instancetype)initWithSubstring:(NSString *)substring caseSensitive:(BOOL)caseSensitive;

@end


@interface TWTPatternExpressionStringValidator : TWTStringValidator <TWTCaseSensitiveValidating>

/*!
 @abstract Initializes a new pattern-expression based string validator with the specified wild card based string.
 @param patternString The pattern string to use when validating. This string can support the use of
    '?' to match 1 character or '*' to match zero or more characters.
 @param caseSensitive Should case be considered when validating
 @return An initialized validator that checks the predicate to validate the value.
 */
- (instancetype)initWithPatternString:(NSString *)patternString caseSensitive:(BOOL)caseSensitive;

@end
