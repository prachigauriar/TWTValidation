//
//  TWTValidationErrors.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/29/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import <TWTValidation/TWTValidationErrors.h>

#pragma mark Constants

NSString *const TWTValidationErrorDomain = @"TWTValidationErrorDomain";
NSString *const TWTValidationValidatedValueKey = @"TWTValidationValidatedValue";
NSString *const TWTValidationUnderlyingErrorsKey = @"TWTValidationUnderlyingErrors";

NSString *const TWTValidationCountValidationErrorKey = @"TWTValidationCountValidationError";
NSString *const TWTValidationElementValidationErrorsKey = @"TWTValidationElementValidationErrors";

NSString *const TWTValidationKeyValidationErrorsKey = @"TWTValidationKeyValidationErrors";
NSString *const TWTValidationKeyValuePairValidationErrorsKey = @"TWTValidationKeyValuePairValidationErrors";


#pragma mark

@implementation NSError (TWTValidation)

+ (NSError *)twt_validationErrorWithCode:(NSInteger)code value:(id)value localizedDescription:(NSString *)description
{
    return [self twt_validationErrorWithCode:code value:value localizedDescription:description underlyingErrors:nil];
}


+ (NSError *)twt_validationErrorWithCode:(NSInteger)code value:(id)value localizedDescription:(NSString *)description underlyingErrors:(NSArray *)errors
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:3];
    if (value) {
        userInfo[TWTValidationValidatedValueKey] = value;
    }
    
    if (description) {
        userInfo[NSLocalizedDescriptionKey] = [description copy];
    }
    
    if (errors.count) {
        userInfo[TWTValidationUnderlyingErrorsKey] = [errors copy];
    }
    
    return [NSError errorWithDomain:TWTValidationErrorDomain code:code userInfo:[userInfo copy]];
}


- (id)twt_validatedValue
{
    return self.userInfo[TWTValidationValidatedValueKey];
}


- (NSArray *)twt_underlyingErrors
{
    return self.userInfo[TWTValidationUnderlyingErrorsKey];
}


- (NSError *)twt_countValidatorError
{
    return self.userInfo[TWTValidationCountValidationErrorKey];
}


- (NSArray *)twt_elementValidationErrors
{
    return self.userInfo[TWTValidationElementValidationErrorsKey];
}


- (NSArray *)twt_keyValidationErrors
{
    return self.userInfo[TWTValidationKeyValidationErrorsKey];
}


- (NSArray *)twt_keyValuePairValidationErrors
{
    return self.userInfo[TWTValidationKeyValuePairValidationErrorsKey];
}

@end
