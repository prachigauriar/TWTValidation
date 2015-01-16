//
//  TWTJSONSchemaAmbiguousTypeValidator.m
//  TWTValidation
//
//  Created by Jill Cohen on 1/16/15.
//  Copyright (c) 2015 Two Toasters, LLC.
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

#import <TWTValidation/TWTJSONSchemaAmbiguousTypeValidator.h>

#import <TWTValidation/TWTJSONSchemaValidTypesConstants.h>


@implementation TWTJSONSchemaAmbiguousTypeValidator

- (instancetype)initWithTypeValidators:(NSDictionary *)typeValidators requiresType:(BOOL)requiresType
{
    self = [super init];
    if (self) {
        _typeValidators = [typeValidators copy];
        _requiresType = requiresType;
    }
    return self;
}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    // Does not call super because NULL may be valid
    BOOL validated = YES;
    NSError *error = nil;
    if (self.requiresType) {
        TWTCompoundValidator *orValidator = [TWTCompoundValidator orValidatorWithSubvalidators:self.typeValidators.allValues];
        validated = [orValidator validateValue:value error:outError ? &error : NULL];
    } else {
        TWTValidator *typeValidator = [self validatorForValue:value];
        if (typeValidator) {
            validated = [typeValidator validateValue:value error:outError ? &error : NULL];
        }
    }

    return validated;
}


- (TWTValidator *)validatorForValue:(id)value
{
    for (NSString *typeKeyword in self.typeValidators) {
        Class validClass = nil;

        if ([typeKeyword isEqualToString:TWTJSONSchemaTypeKeywordArray]) {
            validClass = [NSArray class];
        } else if ([[NSSet setWithObjects:TWTJSONSchemaTypeKeywordBoolean, TWTJSONSchemaTypeKeywordInteger, TWTJSONSchemaTypeKeywordNumber, nil] containsObject:typeKeyword]) {
            // could this cause problems if both bool and integer, for example, are valid?
            validClass = [NSNumber class];
        } else if ([typeKeyword isEqualToString:TWTJSONSchemaTypeKeywordObject]) {
            validClass = [NSString class];
        } else if ([typeKeyword isEqualToString:TWTJSONSchemaTypeKeywordString]) {
            validClass = [NSString class];
        } else if ([typeKeyword isEqualToString:TWTJSONSchemaTypeKeywordNull]) {
            validClass = [NSNull class];
        }

        if ([value isKindOfClass:validClass]) {
            return self.typeValidators[typeKeyword];
        }
    }

    return nil;
}

@end
