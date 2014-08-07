//
//  TWTValidationErrors.m
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

#import <TWTValidation/TWTValidationErrors.h>


#pragma mark Constants

NSString *const TWTValidationErrorDomain = @"TWTValidationErrorDomain";

NSString *const TWTValidationFailingValidatorKey = @"TWTValidationFailingValidator";
NSString *const TWTValidationValidatedValueKey = @"TWTValidationValidatedValue";
NSString *const TWTValidationUnderlyingErrorsKey = @"TWTValidationUnderlyingErrors";
NSString *const TWTValidationUnderlyingErrorsByKeyKey = @"TWTValidationUnderlyingErrorsByKey";

NSString *const TWTValidationCountValidationErrorKey = @"TWTValidationCountValidationError";
NSString *const TWTValidationElementValidationErrorsKey = @"TWTValidationElementValidationErrors";

NSString *const TWTValidationKeyValidationErrorsKey = @"TWTValidationKeyValidationErrors";
NSString *const TWTValidationValueValidationErrorsKey = @"TWTValidationValueValidationErrors";
NSString *const TWTValidationKeyValuePairValidationErrorsKey = @"TWTValidationKeyValuePairValidationErrors";


#pragma mark

@implementation NSError (TWTValidation)

+ (NSError *)twt_validationErrorWithCode:(NSInteger)code value:(id)value localizedDescription:(NSString *)description
{
    return [self twt_validationErrorWithCode:code failingValidator:nil value:value localizedDescription:description underlyingErrors:nil];
}


+ (NSError *)twt_validationErrorWithCode:(NSInteger)code value:(id)value localizedDescription:(NSString *)description underlyingErrors:(NSArray *)errors
{
    return [self twt_validationErrorWithCode:code failingValidator:nil value:value localizedDescription:description underlyingErrors:errors];
}


+ (NSError *)twt_validationErrorWithCode:(NSInteger)code
                        failingValidator:(TWTValidator *)validator
                                   value:(id)value
                    localizedDescription:(NSString *)description
{
    return [self twt_validationErrorWithCode:code failingValidator:validator value:value localizedDescription:description underlyingErrors:nil];
}


+ (NSError *)twt_validationErrorWithCode:(NSInteger)code
                        failingValidator:(TWTValidator *)validator
                                   value:(id)value
                    localizedDescription:(NSString *)description
                        underlyingErrors:(NSArray *)errors
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:4];
    if (validator) {
        userInfo[TWTValidationFailingValidatorKey] = validator;
    }

    if (value) {
        userInfo[TWTValidationValidatedValueKey] = value;
    }
    
    if (description) {
        userInfo[NSLocalizedDescriptionKey] = [description copy];
    }
    
    if (errors.count) {
        userInfo[TWTValidationUnderlyingErrorsKey] = [errors copy];
    }
    
    return [NSError errorWithDomain:TWTValidationErrorDomain code:code userInfo:userInfo];
}


- (TWTValidator *)twt_failingValidator
{
    return self.userInfo[TWTValidationFailingValidatorKey];
}


- (id)twt_validatedValue
{
    return self.userInfo[TWTValidationValidatedValueKey];
}


- (NSArray *)twt_underlyingErrors
{
    return self.userInfo[TWTValidationUnderlyingErrorsKey];
}


- (NSDictionary *)twt_underlyingErrorsByKey
{
    return self.userInfo[TWTValidationUnderlyingErrorsByKeyKey];
}


- (NSError *)twt_countValidationError
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


- (NSArray *)twt_valueValidationErrors
{
    return self.userInfo[TWTValidationValueValidationErrorsKey];
}


- (NSArray *)twt_keyValuePairValidationErrors
{
    return self.userInfo[TWTValidationKeyValuePairValidationErrorsKey];
}

@end
