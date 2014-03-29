//
//  TWTNumberValidator.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/28/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import <TWTValidation/TWTNumberValidator.h>

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


+ (instancetype)numberValidatorWithMinimum:(NSNumber *)minimum maximum:(NSNumber *)maximum
{
    return [[self alloc] initWithMinimum:minimum maximum:maximum];
}


- (instancetype)copyWithZone:(NSZone *)zone
{
    typeof(self) copy = [super copyWithZone:zone];
    copy.requiresIntegralValue = self.requiresIntegralValue;
    copy.minimum = self.minimum;
    copy.maximum = self.maximum;
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
    }
    
    typeof(self) other = object;
    return other.requiresIntegralValue == self.requiresIntegralValue && (self.minimum && [other.minimum isEqualToNumber:self.minimum]) &&
        (self.maximum && [other.maximum isEqualToNumber:self.maximum]);
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
    
    if (self.minimum && [value compare:self.minimum] < NSOrderedSame) {
        errorCode = TWTValidationErrorCodeValueLessThanMinimum;
    } else if (self.maximum && [value compare:self.maximum] > NSOrderedSame) {
        errorCode = TWTValidationErrorCodeValueGreaterThanMaximum;
    } else if (self.requiresIntegralValue && trunc(doubleValue) != doubleValue) {
        errorCode = TWTValidationErrorCodeValueIsNonIntegral;
    } else {
        return YES;
    }

    if (outError) {
        NSString *description = nil;
        switch (errorCode) {
            case TWTValidationErrorCodeValueLessThanMinimum: {
                NSString *descriptionFormat = NSLocalizedString(@"number (%1$@) is less than minimum (%2$@)",
                                                                @"TWTValidationErrorCodeValueLessThanMinimum error message");
                description = [NSString stringWithFormat:descriptionFormat, value, self.minimum];
                break;
            }
            case TWTValidationErrorCodeValueGreaterThanMaximum: {
                NSString *descriptionFormat = NSLocalizedString(@"number (%1$@) is greater than maximum (%2$@)",
                                                                @"TWTValidationErrorCodeValueGreaterThanMaximum error message");
                description = [NSString stringWithFormat:descriptionFormat, value, self.maximum];
                break;
            }
            case TWTValidationErrorCodeValueIsNonIntegral: {
                NSString *descriptionFormat = NSLocalizedString(@"number (%1$@) is not an integer",
                                                                @"TWTValidationErrorCodeValueIsNonIntegral error message");
                description = [NSString stringWithFormat:descriptionFormat, value];
            }
        }

        *outError = [NSError errorWithDomain:TWTValidatorErrorDomain code:errorCode userInfo:@{ NSLocalizedDescriptionKey : description }];
    }
    
    return NO;
}

@end
