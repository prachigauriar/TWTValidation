//
//  TWTNumberValidator.m
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

#import <TWTValidation/TWTNumberValidator.h>

#import <TWTValidation/TWTValidationErrors.h>
#import <TWTValidation/TWTValidationLocalization.h>


@interface TWTNumberValidator ()

@property (nonatomic, strong, readwrite) NSNumber *minimum;
@property (nonatomic, strong, readwrite) NSNumber *maximum;

@end


@implementation TWTNumberValidator

- (instancetype)init
{
    return [self initWithMinimum:nil maximum:nil];
}


- (instancetype)initWithMinimum:(NSNumber *)minimum maximum:(NSNumber *)maximum
{
    // If both minimum and maximum are defined, assert minimum <= maximum
    NSParameterAssert(!minimum || !maximum || [minimum compare:maximum] <= NSOrderedSame);

    self = [super init];
    if (self) {
        self.valueClass = [NSNumber class];
        _minimum = minimum;
        _maximum = maximum;
    }

    return self;
}


- (instancetype)copyWithZone:(NSZone *)zone
{
    typeof(self) copy = [super copyWithZone:zone];
    copy.requiresIntegralValue = self.requiresIntegralValue;
    copy.minimum = self.minimum;
    copy.minimumExclusive = self.isMinimumExclusive;
    copy.maximum = self.maximum;
    copy.maximumExclusive = self.isMaximumExclusive;
    return copy;
}


- (NSUInteger)hash
{
    return [super hash] ^ self.minimum.hash ^ self.maximum.hash;
}


- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    } else if (self == object) {
        return YES;
    }
    
    typeof(self) other = object;
    return other.requiresIntegralValue == self.requiresIntegralValue &&
        other.isMaximumExclusive == self.isMaximumExclusive &&
        other.isMinimumExclusive == self.isMinimumExclusive &&
        (self.minimum == other.minimum || (self.minimum && [other.minimum isEqualToNumber:self.minimum])) &&
        (self.maximum == other.maximum || (self.maximum && [other.maximum isEqualToNumber:self.maximum]));
}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    if (![super validateValue:value error:outError]) {
        return NO;
    } else if (TWTValidatorValueIsNilOrNull(value)) {
        // This will only happen if nil or null is allowed
        return YES;
    }

    NSInteger errorCode = -1;
    double doubleValue = [value doubleValue];

    NSComparisonResult minimumComparisonResult = self.isMinimumExclusive ? NSOrderedSame : NSOrderedDescending;
    NSComparisonResult maximumComparisonResult = self.isMaximumExclusive ? NSOrderedSame : NSOrderedAscending;

    if (self.minimum && [self.minimum compare:value] >= minimumComparisonResult) {
        errorCode = TWTValidationErrorCodeValueLessThanMinimum;
    } else if (self.maximum && [self.maximum compare:value] <= maximumComparisonResult) {
        errorCode = TWTValidationErrorCodeValueGreaterThanMaximum;
    } else if (self.requiresIntegralValue && trunc(doubleValue) != doubleValue) {
        errorCode = TWTValidationErrorCodeValueIsNotIntegral;
    } else {
        return YES;
    }

    if (outError) {
        NSString *description = nil;
        switch (errorCode) {
            case TWTValidationErrorCodeValueLessThanMinimum: {
                NSString *descriptionFormat = TWTLocalizedString(@"TWTNumberValidator.valueLessThanMinimum.validationError.format");
                description = [NSString stringWithFormat:descriptionFormat, value, self.minimum];
                break;
            }
            case TWTValidationErrorCodeValueGreaterThanMaximum: {
                NSString *descriptionFormat = TWTLocalizedString(@"TWTNumberValidator.valueGreaterThanMaximum.validationError.format");
                description = [NSString stringWithFormat:descriptionFormat, value, self.maximum];
                break;
            }
            case TWTValidationErrorCodeValueIsNotIntegral: {
                NSString *descriptionFormat = TWTLocalizedString(@"TWTNumberValidator.valueIsNotIntegral.validationError.format");
                description = [NSString stringWithFormat:descriptionFormat, value];
            }
        }

        *outError = [NSError twt_validationErrorWithCode:errorCode failingValidator:self value:value localizedDescription:description];
    }
    
    return NO;
}

@end
