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

@class TWTBoundedLengthStringValidator, TWTRegularExpressionStringValidator;

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
