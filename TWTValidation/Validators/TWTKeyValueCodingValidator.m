//
//  TWTKeyValueCodingValidator.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 4/21/2014.
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

#import <TWTValidation/TWTKeyValueCodingValidator.h>

@import ObjectiveC.runtime;

#import <TWTValidation/TWTCompoundValidator.h>
#import <TWTValidation/TWTValidationErrors.h>


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
    NSMutableDictionary *errors = outError ? [[NSMutableDictionary alloc] init] : nil;

    // For each key, get the validators from object (using +twt_validatorsFor«Key»). If object didn’t return any,
    // fall back on -validateValue:forKey:error: instead.
    BOOL validated = YES;
    for (NSString *key in self.keys) {
        NSError *error = nil;
        id value = [object valueForKey:key];

        NSArray *validators = [[[object class] twt_validatorsForKey:key] allObjects];
        if (validators) {
            TWTCompoundValidator *andValidator = [TWTCompoundValidator andValidatorWithSubvalidators:validators];
            if (![andValidator validateValue:value error:outError ? &error : NULL]) {
                validated = NO;
                if (error.twt_underlyingErrors) {
                    [errors setObject:error.twt_underlyingErrors forKey:key];
                }
            }
        } else if (![object validateValue:&value forKey:key error:outError ? &error : NULL]) {
            validated = NO;
            if (error) {
                [errors setObject:error forKey:key];
            }
        }
    }

    if (!validated && outError) {
        *outError = [self validationErrorWithCode:TWTValidationErrorCodeKeyValueCodingValidatorError
                                                value:object
                                 localizedDescription:NSLocalizedString(@"TWTKeyValueCodingValidator.validationError", nil)
                                underlyingErrorsByKey:errors];
    }

    return validated;
}


- (NSError *)validationErrorWithCode:(NSInteger)code value:(id)value localizedDescription:(NSString *)description underlyingErrorsByKey:(NSDictionary *)errors
{
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:3];
    if (value) {
        userInfo[TWTValidationValidatedValueKey] = value;
    }
    
    if (description) {
        userInfo[NSLocalizedDescriptionKey] = [description copy];
    }
    
    if (errors.count) {
        userInfo[TWTValidationUnderlyingErrorsByKeyKey] = [errors copy];
    }
    
    return [NSError errorWithDomain:TWTValidationErrorDomain code:code userInfo:userInfo];
}

@end


#pragma mark

@implementation NSObject (TWTKeyValueCodingValidator)

+ (NSSet *)twt_validatorsForKey:(NSString *)key
{
    NSString *capitalizedKey = nil;
    if (key.length < 2) {
        capitalizedKey = [key uppercaseString];
    } else {
        capitalizedKey = [[[key substringToIndex:1] uppercaseString] stringByAppendingString:[key substringFromIndex:1]];
    }

    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"twt_validatorsFor%@", capitalizedKey]);
    NSSet *validators = objc_getAssociatedObject(self, selector);
    if (validators) {
        return [[NSNull null] isEqual:validators] ? nil : validators;
    }

    if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        validators = [self performSelector:selector];
    }
#pragma clang diagnostic pop

    objc_setAssociatedObject(self, selector, validators ? validators : [NSNull null], OBJC_ASSOCIATION_COPY_NONATOMIC);

    return validators;
}

@end
