//
//  TWTValidator.h
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/27/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

@import Foundation;

extern NSString *const TWTValidatorErrorDomain;
extern NSString *const TWTValidatorUnderlyingErrorsKey;

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
    TWTValidationErrorCodeSubvalidatorError,
};


@interface TWTValidator : NSObject <NSCopying>

- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError;

@end
