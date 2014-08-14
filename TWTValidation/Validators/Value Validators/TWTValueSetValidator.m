//
//  TWTValueSetValidator.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 8/13/2014.
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

#import <TWTValidation/TWTValueSetValidator.h>

#import <TWTValidation/TWTValidationErrors.h>

#import "TWTValidationLocalization.h"


@interface TWTValueSetValidator ()

@property (nonatomic, copy, readwrite) NSSet *validValues;

@end


@implementation TWTValueSetValidator

- (instancetype)init
{
    return [self initWithValidValues:nil];
}


- (instancetype)initWithValidValues:(NSSet *)validValues
{
    self = [super init];
    if (self) {
        _validValues = [validValues copy];
    }

    return self;
}


- (instancetype)copyWithZone:(NSZone *)zone
{
    typeof(self) copy = [super copyWithZone:zone];
    copy.validValues = self.validValues;
    return copy;
}


- (NSUInteger)hash
{
    return [super hash] ^ self.validValues.hash;
}


- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    } else if (self == object) {
        return YES;
    }

    typeof(self) other = object;
    return [self.validValues isEqualToSet:other.validValues];
}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    if (![super validateValue:value error:outError]) {
        return NO;
    } else if  ([self.validValues containsObject:value]) {
        return YES;
    }

    if (outError) {
        NSString *descriptionFormat = TWTLocalizedString(@"TWTValueSetValidator.valueNotInSet.validationError.format");

        *outError = [NSError twt_validationErrorWithCode:TWTValidationErrorCodeValueNotInSet
                                        failingValidator:self
                                                   value:value
                                    localizedDescription:[NSString stringWithFormat:descriptionFormat, value, self.validValues]];
    }

    return NO;
}

@end
