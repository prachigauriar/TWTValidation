//
//  TWTValidationErrors.h
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/29/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
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
