//
//  TWTValueValidator.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/28/2014.
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

#import <TWTValidation/TWTValidationErrors.h>
#import <TWTValidation/TWTValidationLocalization.h>


@implementation TWTValueValidator

+ (instancetype)valueValidatorWithClass:(Class)valueClass allowsNil:(BOOL)allowsNil allowsNull:(BOOL)allowsNull
{
    TWTValueValidator *validator = [[self alloc] init];
    validator.valueClass = valueClass;
    validator.allowsNil = allowsNil;
    validator.allowsNull = allowsNull;
    return validator;
}


- (instancetype)copyWithZone:(NSZone *)zone
{
    return [[self class] valueValidatorWithClass:self.valueClass allowsNil:self.allowsNil allowsNull:self.allowsNull];
}


- (NSUInteger)hash
{
    return [super hash] ^ self.allowsNil ^ self.allowsNull ^ self.valueClass.hash;
}


- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    } else if (self == object) {
        return YES;
    }
    
    typeof(self) other = object;
    return other.allowsNil == self.allowsNil && other.allowsNull == self.allowsNull && other.valueClass == self.valueClass;
}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    NSInteger errorCode = -1;

    if (!value) {
        if (self.allowsNil) {
            return YES;
        }

        errorCode = TWTValidationErrorCodeValueNil;
    } else if ([value isEqual:[NSNull null]]) {
        if (self.allowsNull) {
            return YES;
        }

        errorCode = TWTValidationErrorCodeValueNull;
    } else {
        if (!self.valueClass || [[value class] isSubclassOfClass:self.valueClass]) {
            return YES;
        }
        
        errorCode = TWTValidationErrorCodeValueHasIncorrectClass;
    }
    
    // Construct the error based on the code
    if (outError) {
        NSString *description = nil;
        switch (errorCode) {
            case TWTValidationErrorCodeValueNil:
                description = TWTLocalizedString(@"TWTValueValidator.valueNil.validationError");
                break;
            case TWTValidationErrorCodeValueNull:
                description = TWTLocalizedString(@"TWTValueValidator.valueNull.validationError");
                break;
            case TWTValidationErrorCodeValueHasIncorrectClass: {
                NSString *descriptionFormat = TWTLocalizedString(@"TWTValueValidator.valueHasIncorrectClass.validationError.format");
                description = [NSString stringWithFormat:descriptionFormat, [value class], self.valueClass];
                break;
            }
        }

        *outError = [NSError twt_validationErrorWithCode:errorCode failingValidator:self value:value localizedDescription:description];
    }
    
    return NO;
}

@end
