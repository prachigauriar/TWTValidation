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

@class TWTBoundedLengthStringValidator, TWTBoundedComposedCharacterLengthStringValidator,
       TWTRegularExpressionStringValidator, TWTPrefixStringValidator, TWTSuffixStringValidator,
       TWTSubstringStringValidator, TWTWildcardPatternStringValidator, TWTCharacterSetStringValidator;


/*!
 Protocol that specifies whether a conforming validator should perform case-sensitive string comparisons.
 */
@protocol TWTCaseSensitiveValidating <NSObject>

/*!
 @abstract Whether the receiver should perform case-sensitive string comparisons.
 @discussion The default should be YES.
 */
@property (nonatomic, assign, readonly, getter = isCaseSensitive) BOOL caseSensitive;

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
 @abstract Creates and returns a new string validator that validates that strings have the specified minimum 
     and maximum lengths, where length is defined as the number of composed characters.
 @discussion This method creates a new TWTBoundedComposedCharacterLengthStringValidator with the appropriate 
     minimum and maximum lengths.
 @param minimumLength The minimum length for valid strings. Use 0 to indicate no minimum.
 @param maximumLength The maximum length for valid strings. Use NSUIntegerMax to indicate no maximum.
 @result A newly created string validator that validates that strings have the specified minimum and maximum
     lengths.
 */
+ (TWTBoundedComposedCharacterLengthStringValidator *)stringValidatorWithComposedCharacterMinimumLength:(NSUInteger)minimumLength maximumLength:(NSUInteger)maximumLength;

/*!
 @abstract Creates and returns a new string validator that validates that strings match the specified regular
     expression.
 @param regularExpression The regular expression. If nil, all strings pass validation.
 @param options The regular expression matching options to use when validating values.
 @result A newly created string validator that validates that strings match the specified regular expression.
 */
+ (TWTRegularExpressionStringValidator *)stringValidatorWithRegularExpression:(NSRegularExpression *)regularExpression options:(NSMatchingOptions)options;

/*!
 @abstract Creates and returns a new string validator that validates that strings have the specified prefix.
 @param prefix The string that must prefix valid strings. If nil, all strings pass validation.
 @param caseSensitive Whether the validator should perform case-sensitive comparisons.
 @result A newly created string validator that validates that strings have the specified prefix.
 */
+ (TWTPrefixStringValidator *)stringValidatorWithPrefix:(NSString *)prefix caseSensitive:(BOOL)caseSensitive;

/*!
 @abstract Create and returns a new string validator that validates that strings have the specified suffix.
 @param suffix The string that must suffix valid strings. If nil, all strings pass validation.
 @param caseSensitive Whether the validator should perform case-sensitive comparisons.
 @result A newly created string validator that validates that strings have the specified suffix.
 */
+ (TWTSuffixStringValidator *)stringValidatorWithSuffix:(NSString *)suffix caseSensitive:(BOOL)caseSensitive;

/*!
 @abstract Creates and returns a new string validator that validates that strings contain the specified substring.
 @param substring The substring that valid strings must contain. If nil, all strings pass validation.
 @param caseSensitive Whether the validator should perform case-sensitive comparisons.
 @result A newly created string validator that validates that strings contain the specified substring.
 */
+ (TWTSubstringStringValidator *)stringValidatorWithSubstring:(NSString *)substring caseSensitive:(BOOL)caseSensitive;

/*!
 @abstract Creates and returns a new wildcard pattern string validator with the specified wildcard pattern.
 @param pattern The wildcard pattern that valid strings must match. The '?' wildcard matches one character,
     and the '*' wildcard matches zero or more characters. If nil, all strings pass validation.
 @param caseSensitive Whether the validator should perform case-sensitive comparisons.
 @result A newly created string validator that validates that strings match the specified wildcard pattern.
 */
+ (TWTWildcardPatternStringValidator *)stringValidatorWithPattern:(NSString *)pattern caseSensitive:(BOOL)caseSensitive;

/*!
 @abstract Creates and returns a new character set string validator with the specified character set.
 @param characterSet The set of characters that can result in a valid string.
 @result An newly created string validator that validates that strings have only characters in the 
    specified character set.
 */
+ (TWTCharacterSetStringValidator *)stringValidatorWithCharacterSet:(NSCharacterSet *)characterSet;

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
 TWTBoundedComposedCharacterLengthStringValidators validate that unicode strings have lengths within mininimum and maximum values, 
 treating "length" as the number of composed characters. This class should be used when validating length on characters that
 are not contained on the Basic Multilingual Plane, for example, emojis and decomposed characters (é represented as \u0065\u0301).
 There is no need to create instances of this class directly. Instead, use the appropriate factory methods
 on TWTStringValidator. This class is exposed so that it may be easily subclassed if necessary.
 */
@interface TWTBoundedComposedCharacterLengthStringValidator : TWTBoundedLengthStringValidator

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
 @result An initialized regular expression string validator with the specified regular expression.
 */
- (instancetype)initWithRegularExpression:(NSRegularExpression *)regularExpression options:(NSMatchingOptions)options;

@end


/*!
 TWTPrefixStringValidators validate that a string has a specified prefix. There is no need to create
 instances of this directly. Instead use +[TWTStringValidator stringValidatorWithPrefix:caseSensitive:].
 This class is exposed so that it may be easily subclassed if necessary.
 */
@interface TWTPrefixStringValidator : TWTStringValidator <TWTCaseSensitiveValidating>

/*!
 @abstract The prefix that strings must have to be considered valid.
 @discussion If nil, all strings are considered valid. nil by default.
 */
@property (nonatomic, copy, readonly) NSString *prefix;

/*!
 @abstract Initializes a new prefix string validator with the specified prefix.
 @discussion This is the class’s designated initializer.
 @param prefix The string that must prefix valid strings.
 @param caseSensitive Whether the validator should perform case-sensitive comparisons.
 @result An initialized prefix string validator with the specified prefix.
 */
- (instancetype)initWithPrefix:(NSString *)prefix caseSensitive:(BOOL)caseSensitive;

@end


/*!
 TWTSuffixStringValidators validate that a string has a specified prefix. There is no need to create
 instances of this directly. Instead use +[TWTStringValidator stringValidatorWithSuffix:caseSensitive:].
 This class is exposed so that it may be easily subclassed if necessary.
 */
@interface TWTSuffixStringValidator : TWTStringValidator <TWTCaseSensitiveValidating>

/*!
 @abstract The suffix that strings must have to be considered valid.
 @discussion If nil, all strings are considered valid. nil by default.
 */
@property (nonatomic, copy, readonly) NSString *suffix;

/*!
 @abstract Initializes a new suffix string validator with the specified suffix.
 @discussion This is the class’s designated initializer.
 @param suffix The string that must suffix valid strings.
 @param caseSensitive Whether the validator should perform case-sensitive comparisons.
 @result An initialized suffix string validator with the specified suffix.
 */
- (instancetype)initWithSuffix:(NSString *)suffix caseSensitive:(BOOL)caseSensitive;

@end


/*!
 TWTSubstringStringValidators validate that a string contains a specified substring. There is no need
 to create instances of this directly. Instead use +[TWTStringValidator stringValidatorWithSubstring:
 caseSensitive:]. This class is exposed so that it may be easily subclassed if necessary.
 */
@interface TWTSubstringStringValidator : TWTStringValidator <TWTCaseSensitiveValidating>

/*!
 @abstract The substring that strings must contain to be considered valid.
 @discussion If nil, all strings are considered valid. nil by default.
 */
@property (nonatomic, copy, readonly) NSString *substring;

/*!
 @abstract Initializes a new substring string validator with the specified substring.
 @discussion This is the class’s designated initializer.
 @param substring The substring that valid strings must contain.
 @param caseSensitive Whether the validator should perform case-sensitive comparisons.
 @result An initialized substring string validator with the specified substring.
 */
- (instancetype)initWithSubstring:(NSString *)substring caseSensitive:(BOOL)caseSensitive;

@end


/*!
 TWTWildcardPatternStringValidators validate that a string matches a specified wildcard pattern. There is
 no need to create instances of this directly. Instead use +[TWTStringValidator stringValidatorWithPattern:
 caseSensitive:]. This class is exposed so that it may be easily subclassed if necessary.
 */
@interface TWTWildcardPatternStringValidator : TWTStringValidator <TWTCaseSensitiveValidating>

/*!
 @abstract The wildcard pattern that strings must match to be considered valid.
 @discussion The '?' wildcard matches one character, and the '*' wildcard matches zero or more characters.
     If nil, all strings are considered valid. nil by default.
 */
@property (nonatomic, copy, readonly) NSString *pattern;

/*!
 @abstract Initializes a new wildcard pattern string validator with the specified wildcard pattern.
 @param pattern The wildcard pattern that valid strings must match. The '?' wildcard matches one character,
     and the '*' wildcard matches zero or more characters.
 @discussion This is the class’s designated initializer.
 @param caseSensitive Whether the validator should perform case-sensitive comparisons.
 @result An initialized wildcard pattern validator with the specified wildcard pattern.
 */
- (instancetype)initWithPattern:(NSString *)pattern caseSensitive:(BOOL)caseSensitive;

@end


/*!
 TWTCharacterSetStringValidators validate that a string has only the characters specified in the given 
 character set. There is no need to create instances of this directly. Instead use +[TWTStringValidator
 stringValidatorWithCharacterSet:]. This class is exposed so that it may be easily subclassed if necessary.
 */
@interface TWTCharacterSetStringValidator : TWTStringValidator

/*!
 @abstract The character set of characters that valid strings must contain.
 @discussion If nil, all strings are considered valid. nil by default.
 */
@property (nonatomic, copy, readonly) NSCharacterSet *characterSet;

/*!
 @abstract Initializes a new character set string validator with the specified character set.
 @discussion This is the class’s designated initializer.
 @param characterSet The set of characters that can result in a valid string.
 @result An initialized character set validator with the specified character set.
 */
- (instancetype)initWithCharacterSet:(NSCharacterSet *)characterSet;

@end
