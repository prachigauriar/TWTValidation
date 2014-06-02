//
//  TWTValidationErrors.h
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/29/2014.
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

@import Foundation;

/*!
 @abstract The error domain for errors originating from TWTValidation.
 */
extern NSString *const TWTValidationErrorDomain;

/*!
 @abstract A userInfo dictionary key whose corresponding value is the value that was validated.
 @discussion If the userInfo dictionary does not contain this key, the validated value was nil.
 */
extern NSString *const TWTValidationValidatedValueKey;

/*!
 @abstract A userInfo dictionary key whose corresponding value is the collection of errors that caused the error.
 */
extern NSString *const TWTValidationUnderlyingErrorsKey;

/*!
 @abstract A userInfo dictionary key whose corresponding value is the error that occurred while validating a 
     collection’s count.
 */
extern NSString *const TWTValidationCountValidationErrorKey;

/*!
 @abstract A userInfo dictionary key whose corresponding value is the errors that occurred while validating a
     collection’s elements.
 */
extern NSString *const TWTValidationElementValidationErrorsKey;

/*!
 @abstract A userInfo dictionary key whose corresponding value is the errors that occurred while validating a
     keyed collection’s keys.
 */
extern NSString *const TWTValidationKeyValidationErrorsKey;

/*!
 @abstract A userInfo dictionary key whose corresponding value is the errors that occurred while validating a
     keyed collection’s values.
 */
extern NSString *const TWTValidationValueValidationErrorsKey;

/*!
 @abstract A userInfo dictionary key whose corresponding value is the errors that occurred while validating a
     keyed collection’s key-value pairs.
 */
extern NSString *const TWTValidationKeyValuePairValidationErrorsKey;

/*!
 @abstract TWTValidationErrorCode defines constants used as error codes by TWTValidation.
 */
typedef NS_ENUM(NSInteger, TWTValidationErrorCode) {
    /*! Indicates a value is nil, but nil is not allowed. */
    TWTValidationErrorCodeValueNil,

    /*! Indicates a value is the NSNull instance, but that is not allowed. */
    TWTValidationErrorCodeValueNull,

    /*! Indicates a value is of the wrong class. */
    TWTValidationErrorCodeValueHasIncorrectClass,

    /*! Indicates a value is not an integer, but only integers are allowed. */
    TWTValidationErrorCodeValueIsNotIntegral,

    /*! Indicates a value is less than the smallest allowed value. */
    TWTValidationErrorCodeValueLessThanMinimum,

    /*! Indicates a value is greater than the largest allowed value. */
    TWTValidationErrorCodeValueGreaterThanMaximum,
    
    /*! Indicates a value does not match the required format. */
    TWTValidationErrorCodeValueDoesNotMatchFormat,

    /*! Indicates a value’s length is less than the smallest allowed amount. */
    TWTValidationErrorCodeLengthLessThanMinimum,

    /*! Indicates a value’s length is greater than than the largest allowed amount. */
    TWTValidationErrorCodeLengthGreaterThanMaximum,

    /*! Indicates an error occurred in a key-value coding validator. */
    TWTValidationErrorCodeKeyValueCodingValidatorError,

    /*! Indicates an error occurred in a compound validator. */
    TWTValidationErrorCodeCompoundValidatorError,
    
    /*! Indicates an error occurred in a collection validator. */
    TWTValidationErrorCodeCollectionValidatorError,

    /*! Indicates an error occurred in a keyed collection validator. */
    TWTValidationErrorCodeKeyedCollectionValidatorError,
};


/*!
 The TWTValidation category on NSError adds factory methods and accessors to easily construct and analyze
 errors from TWTValidation.
 */
@interface NSError (TWTValidation)

/*!
 @abstract Creates a new error in the TWTValidationErrorDomain domain with the specified code, validated
     value, and localized description.
 @param code The error code for the new error.
 @param value The value being validated when the error occured.
 @param localizedDescription A human-readable description of the error.
 @result A new validation error with the specified code, validated value, and localized description.
 */
+ (NSError *)twt_validationErrorWithCode:(NSInteger)code value:(id)value localizedDescription:(NSString *)description;

/*!
 @abstract Creates a new error in the TWTValidationErrorDomain domain with the specified code, validated
     value, localized description, and underlying errors.
 @param code The error code for the new error.
 @param value The value being validated when the error occured.
 @param localizedDescription A human-readable description of the error.
 @param underlyingErrors The underyling errors that caused the new error to occur,
 @result A new validation error with the specified code, validated value, localized description, and 
     underlying errors.
 */
+ (NSError *)twt_validationErrorWithCode:(NSInteger)code value:(id)value localizedDescription:(NSString *)description underlyingErrors:(NSArray *)errors;

/*!
 @abstract Returns an error’s validated value.
 @discussion This is equivalent to error.userInfo[TWTValidationValidatedValueKey].
 @result The error’s validated value.
 */
- (id)twt_validatedValue;

/*!
 @abstract Returns an error’s underlying errors.
 @discussion This is equivalent to error.userInfo[TWTValidationUnderlyingErrorsKey].
 @result The error’s underlying errors.
 */
- (NSArray *)twt_underlyingErrors;

/*!
 @abstract Returns the count validation error that caused the error.
 @discussion This is equivalent to error.userInfo[TWTValidationCountValidationErrorKey].
 @result The error’s count validation error.
 */
- (NSError *)twt_countValidationError;

/*!
 @abstract Returns the element validation errors that caused the error.
 @discussion This is equivalent to error.userInfo[TWTValidationElementValidationErrorsKey].
 @result The error’s element validation errors.
 */
- (NSArray *)twt_elementValidationErrors;

/*!
 @abstract Returns the key validation errors that caused the error.
 @discussion This is equivalent to error.userInfo[TWTValidationKeyValidationErrorsKey].
 @result The error’s key validation errors.
 */
- (NSArray *)twt_keyValidationErrors;

/*!
 @abstract Returns the value validation errors that caused the error.
 @discussion This is equivalent to error.userInfo[TWTValidationValueValidationErrorsKey].
 @result The error’s value validation errors.
 */
- (NSArray *)twt_valueValidationErrors;

/*!
 @abstract Returns the key-value pair validation errors that caused the error.
 @discussion This is equivalent to error.userInfo[TWTValidationKeyValuePairValidationErrorsKey].
 @result The error’s key-value pair validation errors.
 */
- (NSArray *)twt_keyValuePairValidationErrors;

@end
