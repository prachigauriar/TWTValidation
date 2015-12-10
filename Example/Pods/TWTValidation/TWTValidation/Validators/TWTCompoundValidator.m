//
//  TWTCompoundValidator.m
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

#import <TWTValidation/TWTCompoundValidator.h>

#import <TWTValidation/TWTValidationErrors.h>
#import <TWTValidation/TWTValidationLocalization.h>

@implementation TWTCompoundValidator

- (instancetype)init
{
    return [self initWithType:TWTCompoundValidatorTypeAnd subvalidators:nil];
}


- (instancetype)initWithType:(TWTCompoundValidatorType)type subvalidators:(NSArray *)subvalidators
{
    NSParameterAssert(type != TWTCompoundValidatorTypeNot || subvalidators.count == 1);

    self = [super init];
    if (self) {
        _compoundValidatorType = type;
        _subvalidators = [subvalidators copy];
    }

    return self;
}


+ (instancetype)notValidatorWithSubvalidator:(TWTValidator *)subvalidator
{
    NSParameterAssert(subvalidator);
    return [[self alloc] initWithType:TWTCompoundValidatorTypeNot subvalidators:@[ subvalidator ]];
}


+ (instancetype)andValidatorWithSubvalidators:(NSArray *)subvalidators
{
    return [[self alloc] initWithType:TWTCompoundValidatorTypeAnd subvalidators:subvalidators];
}


+ (instancetype)orValidatorWithSubvalidators:(NSArray *)subvalidators
{
    return [[self alloc] initWithType:TWTCompoundValidatorTypeOr subvalidators:subvalidators];
}


+ (instancetype)mutualExclusionValidatorWithSubvalidators:(NSArray *)subvalidators
{
    return [[self alloc] initWithType:TWTCompoundValidatorTypeMutualExclusion subvalidators:subvalidators];
}


- (NSUInteger)hash
{
    return [super hash] ^ self.compoundValidatorType ^ self.subvalidators.hash;
}


- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    } else if (self == object) {
        return YES;
    }
    
    typeof(self) other = object;
    return other.compoundValidatorType == self.compoundValidatorType && [other.subvalidators isEqualToArray:self.subvalidators];
}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    // Only collect errors if outError is non-NULL
    NSMutableArray *errors = outError ? [[NSMutableArray alloc] init] : nil;

    NSUInteger validatedCount = 0;
    for (TWTValidator *subvalidator in self.subvalidators) {
        NSError *error = nil;

        // Only pass in an error if outError is non-nil. This will save the subvalidators some work
        if ([subvalidator validateValue:value error:outError ? &error : NULL]) {
            ++validatedCount;
        } else if (error) {
            [errors addObject:error];
        }
    }

    BOOL validated = NO;
    switch (self.compoundValidatorType) {
        case TWTCompoundValidatorTypeNot:
            validated = validatedCount == 0;
            break;
        case TWTCompoundValidatorTypeAnd:
            validated = validatedCount == self.subvalidators.count;
            break;
        case TWTCompoundValidatorTypeOr:
            validated = validatedCount > 0;
            break;
        case TWTCompoundValidatorTypeMutualExclusion:
            validated = validatedCount == 1;
            break;
    }
    
    if (!validated && outError) {
        NSString *description = nil;
        switch (self.compoundValidatorType) {
            case TWTCompoundValidatorTypeNot:
                description = TWTLocalizedString(@"TWTCompoundValidator.not.validationError");
                break;
            case TWTCompoundValidatorTypeAnd:
                description = TWTLocalizedString(@"TWTCompoundValidator.and.validationError");
                break;
            case TWTCompoundValidatorTypeOr:
                description = TWTLocalizedString(@"TWTCompoundValidator.or.validationError");
                break;
            case TWTCompoundValidatorTypeMutualExclusion:
                description = TWTLocalizedString(@"TWTCompoundValidator.mutualExclusion.validationError");
                break;
        }
        
        *outError = [NSError twt_validationErrorWithCode:TWTValidationErrorCodeCompoundValidatorError
                                                   value:value
                                    localizedDescription:description
                                        underlyingErrors:errors];
    }

    return validated;
}

@end
