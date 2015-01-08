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

@class TWTValidator;

/*!
 @abstract The error domain for errors originating from TWTValidation.
 */
extern NSString *const TWTValidationErrorDomain;

/*!
 @abstract userInfo key whose value is the validator that failed.
 */
extern NSString *const TWTValidationFailingValidatorKey;

/*!
 @abstract userInfo key whose value is the value that was validated.
 @discussion If the userInfo dictionary does not contain this key, the validated value was nil.
 */
extern NSString *const TWTValidationValidatedValueKey;

/*!
 @abstract userInfo key whose value is the collection of errors that caused the error.
 */
extern NSString *const TWTValidationUnderlyingErrorsKey;

/*!
 @abstract userInfo key whose value is a dictionary containing the underlying errors for each key-value coding key.
 */
extern NSString *const TWTValidationUnderlyingErrorsByKeyKey;

/*!
 @abstract userInfo key whose value is the error that occurred while validating a collection’s count.
 */
extern NSString *const TWTValidationCountValidationErrorKey;

/*!
 @abstract userInfo key whose value is the errors that occurred while validating a collection’s elements.
 */
extern NSString *const TWTValidationElementValidationErrorsKey;

/*!
 @abstract userInfo key whose value is the errors that occurred while validating a keyed collection’s keys.
 */
extern NSString *const TWTValidationKeyValidationErrorsKey;

/*!
 @abstract userInfo key whose value is the errors that occurred while validating a keyed collection’s
     values.
 */
extern NSString *const TWTValidationValueValidationErrorsKey;

/*!
 @abstract userInfo key whose value is the errors that occurred while validating a keyed collection’s
     key-value pairs.
 */
extern NSString *const TWTValidationKeyValuePairValidationErrorsKey;

/*!
 @abstract The error domain for errors originating from TWTValidation’s JSON schema parser.
 */
extern NSString *const TWTJSONSchemaParserErrorDomain;

/*!
 @abstract userInfo key whose value is the object that caused the JSON schema parsing error.
*/
extern NSString *const TWTJSONSchemaParserInvalidObjectKey;


/*!
 @abstract TWTValidationErrorCode defines constants used as error codes by TWTValidation.
 */
typedef NS_ENUM(NSInteger, TWTValidationErrorCode) {
    /*! Indicates a value is nil. */
    TWTValidationErrorCodeValueNil,

    /*! Indicates a value is the NSNull instance. */
    TWTValidationErrorCodeValueNull,

    /*! Indicates a value is of the wrong class. */
    TWTValidationErrorCodeValueHasIncorrectClass,

    /*! Indicates a value is not an integer. */
    TWTValidationErrorCodeValueIsNotIntegral,

    /*! Indicates a value is less than the smallest allowed value. */
    TWTValidationErrorCodeValueLessThanMinimum,

    /*! Indicates a value is greater than the largest allowed value. */
    TWTValidationErrorCodeValueGreaterThanMaximum,

    /*! Indicates a value does not match the required format. */
    TWTValidationErrorCodeValueDoesNotMatchFormat,
    
    /*! Indicates a value’s length is less than the smallest allowed length. */
    TWTValidationErrorCodeLengthLessThanMinimum,

    /*! Indicates a value’s length is greater than than the largest allowed length. */
    TWTValidationErrorCodeLengthGreaterThanMaximum,

    /*! Indicates an error occurred in a key-value coding validator. */
    TWTValidationErrorCodeKeyValueCodingValidatorError,

    /*! Indicates an error occurred in a compound validator. */
    TWTValidationErrorCodeCompoundValidatorError,
    
    /*! Indicates an error occurred in a collection validator. */
    TWTValidationErrorCodeCollectionValidatorError,

    /*! Indicates an error occurred in a keyed collection validator. */
    TWTValidationErrorCodeKeyedCollectionValidatorError,

    /*! Indicates a value is not in the set of acceptable values. */
    TWTValidationErrorCodeValueNotInSet,

    /*! Indicates a value is not a collection for the purposes of collection validation. */
    TWTValidationErrorCodeValueNotCollection,

    /*! Indicates a value is not a keyed collection for the purposes of keyed collection validation. */
    TWTValidationErrorCodeValueNotKeyedCollection
};


/*!
 @abstract TWTJSONSchemaParserErrorCode defines constants used as error codes by TWTJSONSchemaParser.
 */
typedef NS_ENUM(NSUInteger, TWTJSONSchemaParserErrorCode) {
    /*! Indicates a JSON structure is not of the expected class. */
    TWTJSONSchemaParserErrorCodeInvalidClass,

    /*! Indicates a value is not valid with respect to the schema definition, (e.g., the value of "minLength" is not a positive integer). */
    TWTJSONSchemaParserErrorCodeInvalidValue,

    /*! Indicates a collection is empty where at least one item is required. */
    TWTJSONSchemaParserErrorCodeRequiresAtLeastOneItem,
};


/*!
 The TWTValidation category on NSError adds factory methods and accessors to easily construct and extract
 information from validation errors.
 */
@interface NSError (TWTValidation)

/*!
 @abstract Creates and returns a new error in the TWTValidationErrorDomain domain with the specified code,
     validated value, and localized description.
 @discussion This method has been deprecated. Use +twt_validationErrorWithCode:failingValidator:value:localizedDescription:
     instead. Validation errors should always include the validator that failed.
 
 @param code The error code for the new error.
 @param value The value being validated when the error occured. If non-nil, this object will be the value
     corresponding to TWTValidationValidatedValueKey in the error’s userInfo dictionary.
 @param description A human-readable description of the error. If non-nil, this string will be the
     value corresponding to NSLocalizedDescriptionKey in the error’s userInfo dictionary.
 @result A new validation error with the specified code, validated value, and localized description.
 */
+ (NSError *)twt_validationErrorWithCode:(NSInteger)code value:(id)value localizedDescription:(NSString *)description
    __deprecated_msg("Use +twt_validationErrorWithCode:failingValidator:value:localizedDescription: instead.");

/*!
 @abstract Creates and returns a new error in the TWTValidationErrorDomain domain with the specified code,
     validated value, localized description, and underlying errors.
 @discussion This method has been deprecated. Use 
     +twt_validationErrorWithCode:failingValidator:value:localizedDescription:underlyingErrors: instead. Validation
     errors should always include the validator that failed.
 @param code The error code for the new error.
 @param value The value being validated when the error occured. If non-nil, this object will be the value
     corresponding to TWTValidationValidatedValueKey in the error’s userInfo dictionary.
 @param description A human-readable description of the error. If non-nil, this string will be the
     value corresponding to NSLocalizedDescriptionKey in the error’s userInfo dictionary.
 @param errors The underyling errors that caused the new error to occur. If non-nil, this array will be 
     the value corresponding to TWTValidationUnderlyingErrorsKey in the error’s userInfo dictionary.
 @result A new validation error with the specified code, validated value, localized description, and
     underlying errors.
 */
+ (NSError *)twt_validationErrorWithCode:(NSInteger)code
                                   value:(id)value
                    localizedDescription:(NSString *)description
                        underlyingErrors:(NSArray *)errors
    __deprecated_msg("Use +twt_validationErrorWithCode:failingValidator:value:localizedDescription:underlyingErrors: instead.");

/*!
 @abstract Creates and returns a new error in the TWTValidationErrorDomain domain with the specified code,
     failing validator, validated value, and localized description.
 @discussion This is equivalent to invoking 
 
     [NSError twt_validationErrorWithCode:code 
                         failingValidator:validator 
                                    value:value
                     localizedDescription:description 
                         underlyingErrors:nil];

 @param code The error code for the new error.
 @param validator The validator that failed.
 @param value The value being validated when the error occured. If non-nil, this object will be the value
     corresponding to TWTValidationValidatedValueKey in the error’s userInfo dictionary.
 @param description A human-readable description of the error. If non-nil, this string will be the
     value corresponding to NSLocalizedDescriptionKey in the error’s userInfo dictionary.
 @result A new validation error with the specified code, validated value, and localized description.
 */
+ (NSError *)twt_validationErrorWithCode:(NSInteger)code
                        failingValidator:(TWTValidator *)validator
                                   value:(id)value
                    localizedDescription:(NSString *)description;

/*!
 @abstract Creates and returns a new error in the TWTValidationErrorDomain domain with the specified code,
     failing validator, validated value, localized description, and underlying errors.
 @param code The error code for the new error.
 @param validator The validator that failed.
 @param value The value being validated when the error occured. If non-nil, this object will be the value
     corresponding to TWTValidationValidatedValueKey in the error’s userInfo dictionary.
 @param description A human-readable description of the error. If non-nil, this string will be the
     value corresponding to NSLocalizedDescriptionKey in the error’s userInfo dictionary.
 @param errors The underyling errors that caused the new error to occur. If non-nil, this array will be
     the value corresponding to TWTValidationUnderlyingErrorsKey in the error’s userInfo dictionary.
 @result A new validation error with the specified code, validated value, localized description, and
     underlying errors.
 */
+ (NSError *)twt_validationErrorWithCode:(NSInteger)code
                        failingValidator:(TWTValidator *)validator
                                   value:(id)value
                    localizedDescription:(NSString *)description
                        underlyingErrors:(NSArray *)errors;

/*!
 @abstract Returns an error’s failing validator.
 @discussion This is equivalent to accessing error.userInfo[TWTValidationFailingValidatorKey].
 @result The error’s failing validator.
 */
- (TWTValidator *)twt_failingValidator;

/*!
 @abstract Returns an error’s validated value.
 @discussion This is equivalent to accessing error.userInfo[TWTValidationValidatedValueKey].
 @result The error’s validated value.
 */
- (id)twt_validatedValue;

/*!
 @abstract Returns the error’s underlying errors.
 @discussion This is equivalent to accessing error.userInfo[TWTValidationUnderlyingErrorsKey].
 @result The error’s underlying errors.
 */
- (NSArray *)twt_underlyingErrors;

/*!
 @abstract Returns the error’s underlying errors by key.
 @discussion This is equivalent to accessing error.userInfo[TWTValidationUnderlyingErrorsByKeyKey].
 @result The error’s underlying errors by key.
 */
- (NSDictionary *)twt_underlyingErrorsByKey;

/*!
 @abstract Returns the count validation error that caused the error.
 @discussion This is equivalent to accessing error.userInfo[TWTValidationCountValidationErrorKey].
 @result The error’s count validation error.
 */
- (NSError *)twt_countValidationError;

/*!
 @abstract Returns the element validation errors that caused the error.
 @discussion This is equivalent to accessing error.userInfo[TWTValidationElementValidationErrorsKey].
 @result The error’s element validation errors.
 */
- (NSArray *)twt_elementValidationErrors;

/*!
 @abstract Returns the key validation errors that caused the error.
 @discussion This is equivalent to accessing error.userInfo[TWTValidationKeyValidationErrorsKey].
 @result The error’s key validation errors.
 */
- (NSArray *)twt_keyValidationErrors;

/*!
 @abstract Returns the value validation errors that caused the error.
 @discussion This is equivalent to accessing error.userInfo[TWTValidationValueValidationErrorsKey].
 @result The error’s value validation errors.
 */
- (NSArray *)twt_valueValidationErrors;

/*!
 @abstract Returns the key-value pair validation errors that caused the error.
 @discussion This is equivalent to accessing error.userInfo[TWTValidationKeyValuePairValidationErrorsKey].
 @result The error’s key-value pair validation errors.
 */
- (NSArray *)twt_keyValuePairValidationErrors;

@end
