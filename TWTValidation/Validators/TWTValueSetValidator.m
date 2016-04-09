//
//  TWTValueSetValidator.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 8/13/2014.
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

#import <TWTValidation/TWTValueSetValidator.h>

#import <TWTValidation/TWTValidationErrors.h>
#import <TWTValidation/TWTValidationLocalization.h>


@implementation TWTValueSetValidator

- (instancetype)init
{
    return [self initWithValidValues:nil allowsNil:NO];
}


- (instancetype)initWithValidValues:(NSSet *)validValues
{
    return [self initWithValidValues:validValues allowsNil:NO];
}


- (instancetype)initWithValidValues:(NSSet *)validValues allowsNil:(BOOL)allowsNil
{
    self = [super init];
    if (self) {
        _validValues = [validValues copy];
        _allowsNil = allowsNil;
    }

    return self;
}


+ (instancetype)valueSetValidatorWithValidValues:(NSSet *)validValues;
{
    return [[self alloc] initWithValidValues:validValues];
}

+ (instancetype)valueSetValidatorWithValidValues:(NSSet *)validValues allowsNil:(BOOL)allowsNil
{
  return [[self alloc] initWithValidValues:validValues allowsNil:allowsNil];
}


- (NSUInteger)hash
{
    return [super hash] ^ self.allowsNil ^ self.validValues.hash;
}


- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    } else if (self == object) {
        return YES;
    }

    typeof(self) other = object;
    return self.allowsNil == other.allowsNil && [self.validValues isEqualToSet:other.validValues];
}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    if ((!value && self.allowsNil) || [self.validValues containsObject:value]) {
        return YES;
    }

    if (outError) {
        NSInteger code = 0;
        NSString *description = nil;

        if (!value) {
            code = TWTValidationErrorCodeValueNil;
            description = TWTLocalizedString(@"TWTValidator.valueNil.validationError");
        } else {
            code = TWTValidationErrorCodeValueNotInSet;
            NSString *descriptionFormat = TWTLocalizedString(@"TWTValueSetValidator.valueNotInSet.validationError.format");
            description = [NSString stringWithFormat:descriptionFormat, value, self.validValues];
        }

        *outError = [NSError twt_validationErrorWithCode:code failingValidator:self value:value localizedDescription:description];
    }

    return NO;
}

@end
