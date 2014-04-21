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

#import <TWTValidation/TWTCompoundValidator.h>
#import <TWTValidation/TWTValidationErrors.h>

@import ObjectiveC.runtime;


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


- (NSSet *)validatorsForValue:(id)value key:(NSString *)key
{
    NSString *capitalizedKey = nil;
    if (key.length < 2) {
        capitalizedKey = [key uppercaseString];
    } else {
        capitalizedKey = [NSString stringWithFormat:@"%@%@", [[key substringToIndex:1] uppercaseString], [key substringFromIndex:1]];
    }

    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"validatorsFor%@", capitalizedKey]);
    NSSet *validators = nil;

    if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        validators = [value performSelector:selector];
#pragma clang diagnostic pop
    }

    return validators;
}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    NSMutableArray *errors = outError ? [[NSMutableArray alloc] init] : nil;

    BOOL validated = YES;
    for (NSString *key in self.keys) {
        NSError *error = nil;
        TWTCompoundValidator *andValidator = [TWTCompoundValidator andValidatorWithSubvalidators:[[self validatorsForValue:value key:key] allObjects]];
        if (![andValidator validateValue:[value objectForKey:key] error:outError ? &error : NULL]) {
            validated = NO;
            if (error) {
                [errors addObjectsFromArray:error.twt_underlyingErrors];
            }
        }
    }

    if (!validated && outError) {
        *outError = [NSError twt_validationErrorWithCode:TWTValidationErrorCodeKeyValueCodingValidatorError
                                                   value:value
                                    localizedDescription:NSLocalizedString(@"TWTKeyValueCodingValidator.validationError", nil)
                                        underlyingErrors:errors];
    }

    return validated;
}

@end
