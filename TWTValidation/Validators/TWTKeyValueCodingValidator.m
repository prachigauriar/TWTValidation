//
//  TWTKeyValueCodingValidator.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 4/21/2014.
//  Copyright (c) 2015 Ticketmaster Entertainment, Inc. All rights reserved.
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

#import <TWTValidation/TWTKeyValueCodingValidator.h>

@import ObjectiveC.runtime;

#import <TWTValidation/TWTCompoundValidator.h>
#import <TWTValidation/TWTValidationErrors.h>
#import <TWTValidation/TWTValidationLocalization.h>


#pragma mark Functions

static NSString *TWTCapitalizedKey(NSString *key)
{
    return key.length < 2 ? [key uppercaseString] : [[[key substringToIndex:1] uppercaseString] stringByAppendingString:[key substringFromIndex:1]];
}


static SEL TWTKeyValueCodingValidatorSelectorForKey(NSString *key)
{
    return NSSelectorFromString([NSString stringWithFormat:@"twt_validatorsFor%@", TWTCapitalizedKey(key)]);
}


#pragma mark -

@implementation TWTKeyValueCodingValidator

- (instancetype)init
{
    return [self initWithKeys:nil];
}


- (instancetype)initWithKeys:(NSSet *)keys
{
    self = [super init];
    if (self) {
        _keys = [keys copy];
    }

    return self;
}


- (NSUInteger)hash
{
    return self.keys.hash;
}


- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    } else if (self == object) {
        return YES;
    }

    typeof(self) other = object;
    return [self.keys isEqualToSet:other.keys];
}


- (BOOL)validateValue:(id)object error:(out NSError *__autoreleasing *)outError
{
    if (![super validateValue:object error:outError]) {
        return NO;
    }

    NSMutableDictionary *errorsByKey = outError ? [[NSMutableDictionary alloc] init] : nil;

    // For each key, get the validators from object (using -twt_validatorsForKey:). If object didn’t return any,
    // ask the object’s class for its validators (using +twt_validatorsForKey:). If that didn’t return any either,
    // fall back on -validateValue:forKey:error: instead.
    BOOL validated = YES;
    for (NSString *key in self.keys) {
        NSError *error = nil;
        id value = [object valueForKey:key];

        // Ask the object
        NSSet *validatorSet = [object twt_validatorsForKey:key];

        // Ask the class
        if (!validatorSet) {
            validatorSet = [[object class] twt_validatorsForKey:key];
        }

        if (validatorSet) {
            TWTCompoundValidator *andValidator = [TWTCompoundValidator andValidatorWithSubvalidators:[validatorSet allObjects]];
            if (![andValidator validateValue:value error:outError ? &error : NULL]) {
                validated = NO;
                if (error.twt_underlyingErrors) {
                    errorsByKey[key] = error.twt_underlyingErrors;
                }
            }
        } else if (![object validateValue:&value forKey:key error:outError ? &error : NULL]) {
            validated = NO;
            if (error) {
                errorsByKey[key] = @[ error ];
            }
        }
    }

    if (!validated && outError) {
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:4];
        userInfo[TWTValidationFailingValidatorKey] = self;
        userInfo[NSLocalizedDescriptionKey] = TWTLocalizedString(@"TWTKeyValueCodingValidator.validationError");

        if (object) {
            userInfo[TWTValidationValidatedValueKey] = object;
        }

        if (errorsByKey.count) {
            userInfo[TWTValidationUnderlyingErrorsByKeyKey] = [errorsByKey copy];
        }

        *outError = [NSError errorWithDomain:TWTValidationErrorDomain
                                        code:TWTValidationErrorCodeKeyValueCodingValidatorError
                                    userInfo:userInfo];
    }

    return validated;
}

@end


#pragma mark

@implementation NSObject (TWTKeyValueCodingValidator)

+ (NSSet *)twt_validatorsForKey:(NSString *)key
{
    SEL selector = TWTKeyValueCodingValidatorSelectorForKey(key);
    NSSet *validators = objc_getAssociatedObject(self, selector);
    if (validators) {
        return [[NSNull null] isEqual:validators] ? nil : validators;
    }

    if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        validators = [self performSelector:selector];
#pragma clang diagnostic pop
    }

    objc_setAssociatedObject(self, selector, validators ? validators : [NSNull null], OBJC_ASSOCIATION_COPY_NONATOMIC);

    return validators;
}


- (NSSet *)twt_validatorsForKey:(NSString *)key
{
    SEL selector = TWTKeyValueCodingValidatorSelectorForKey(key);

    if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return [self performSelector:selector];
#pragma clang diagnostic pop
    }

    return nil;
}

@end
