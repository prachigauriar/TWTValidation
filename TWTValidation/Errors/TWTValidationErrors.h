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

extern NSString *const TWTValidationErrorDomain;
extern NSString *const TWTValidationValidatedValueKey;
extern NSString *const TWTValidationValidatedKeyKey;
extern NSString *const TWTValidationUnderlyingErrorsKey;

extern NSString *const TWTValidationCountValidationErrorKey;
extern NSString *const TWTValidationElementValidationErrorsKey;

extern NSString *const TWTValidationKeyValidationErrorsKey;
extern NSString *const TWTValidationValueValidationErrorsKey;
extern NSString *const TWTValidationKeyValuePairValidationErrorsKey;

typedef NS_ENUM(NSInteger, TWTValidationErrorCode) {
    TWTValidationErrorCodeValueNil,
    TWTValidationErrorCodeValueNull,
    TWTValidationErrorCodeValueHasIncorrectClass,
    
    TWTValidationErrorCodeValueIsNonIntegral,
    TWTValidationErrorCodeValueLessThanMinimum,
    TWTValidationErrorCodeValueGreaterThanMaximum,
    
    TWTValidationErrorCodeValueDoesNotMatchFormat,
    TWTValidationErrorCodeLengthLessThanMinimum,
    TWTValidationErrorCodeLengthGreaterThanMaximum,
    
    TWTValidationErrorCodeCompoundValidatorError,
    
    TWTValidationErrorCodeCollectionValidatorError,
    TWTValidationErrorCodeKeyedCollectionValidatorError,
};


@interface NSError (TWTValidation)

+ (NSError *)twt_validationErrorWithCode:(NSInteger)code value:(id)value localizedDescription:(NSString *)description;
+ (NSError *)twt_validationErrorWithCode:(NSInteger)code value:(id)value localizedDescription:(NSString *)description underlyingErrors:(NSArray *)errors;

- (id)twt_validatedKey;
- (id)twt_validatedValue;

- (NSArray *)twt_underlyingErrors;

- (NSError *)twt_countValidationError;
- (NSArray *)twt_elementValidationErrors;

- (NSArray *)twt_keyValidationErrors;
- (NSArray *)twt_valueValidationErrors;
- (NSArray *)twt_keyValuePairValidationErrors;

@end
