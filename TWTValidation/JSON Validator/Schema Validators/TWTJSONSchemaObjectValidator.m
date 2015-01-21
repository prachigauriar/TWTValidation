//
//  TWTJSONSchemaObjectValidator.m
//  TWTValidation
//
//  Created by Jill Cohen on 1/14/15.
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

#import <TWTValidation/TWTJSONSchemaObjectValidator.h>

#import <TWTValidation/TWTValidationErrors.h>
#import <TWTValidation/TWTValidationLocalization.h>

@interface TWTJSONSchemaObjectValidator ()

@property (nonatomic, strong, readonly) NSDictionary *propertyAndValidators;

@end


@implementation TWTJSONSchemaObjectValidator

- (instancetype)initWithMaximumPropertyCount:(NSNumber *)maximumPropertyCount
                        minimumPropertyCount:(NSNumber *)minimumPropertyCount
                        requiredPropertyKeys:(NSSet *)requiredPropertyKeys
                          propertyValidators:(NSArray *)propertyValidators
                   patternPropertyValidators:(NSArray *)patternPropertyValidators
               additionalPropertiesValidator:(TWTValidator *)additionalPropertiesValidator
                        propertyDependencies:(NSDictionary *)propertyDependencies
{
    self = [super init];
    if (self) {
        _maximumPropertyCount = maximumPropertyCount;
        _minimumPropertyCount = minimumPropertyCount;
        _requiredPropertyKeys = [requiredPropertyKeys copy];
        _propertyValidators = [propertyValidators copy];
        _patternPropertyValidators = [patternPropertyValidators copy];
        _additionalPropertiesValidator = [additionalPropertiesValidator copy];
        _propertyDependencies = [propertyDependencies copy];

        //  Make property validators accessible by their key
        NSMutableDictionary *propertyValidatorsByKey = [[NSMutableDictionary alloc] init];
        for (TWTKeyValuePairValidator *pairValidator in propertyValidators) {
            [propertyValidatorsByKey setObject:pairValidator forKey:pairValidator.key];
        }
        _propertyAndValidators = [propertyValidatorsByKey copy];

    }
    return self;
}


- (instancetype)init
{
    return [self initWithMaximumPropertyCount:nil minimumPropertyCount:nil requiredPropertyKeys:nil propertyValidators:nil patternPropertyValidators:nil
                additionalPropertiesValidator:nil propertyDependencies:nil];
}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    if (![super validateValue:value error:outError]) {
        return NO;
    } else if (![value isKindOfClass:[NSDictionary class]]) {
        if (outError) {
            *outError = [NSError twt_validationErrorWithCode:TWTValidationErrorCodeValueHasIncorrectClass
                                            failingValidator:self
                                                       value:value
                                        localizedDescription:TWTLocalizedString(@"TWTJSONSchemaObjectValidator.notDictionaryError")];
        }
        return NO;
    }

    BOOL countValidated = YES;
    BOOL requiredPropertiesValidated = YES;
    BOOL propertiesValidated = YES;
    BOOL patternPropertiesValidated = YES;
    BOOL additionalPropertiesValidated = YES;
    BOOL dependenciesValidated = YES;

    NSError *countError = nil;
    NSError *requiredPropertiesError = nil;
    NSMutableArray *propertiesErrors = outError ? [[NSMutableArray alloc] init] : nil;
    NSMutableArray *patternPropertiesErrors = outError ? [[NSMutableArray alloc] init] : nil;
    NSMutableArray *additionalPropertiesErrors = outError ? [[NSMutableArray alloc] init] : nil;
    NSMutableArray *dependenciesErrors = outError ? [[NSMutableArray alloc] init] : nil;

    NSSet *keysSet = [NSSet setWithArray:[value allKeys]];

    if (self.maximumPropertyCount || self.minimumPropertyCount) {
        TWTValidator *countValidator = [[TWTNumberValidator alloc] initWithMinimum:self.minimumPropertyCount maximum:self.maximumPropertyCount];
        countValidated = [countValidator validateValue:@([value count]) error:&countError];
    }

    if (self.requiredPropertyKeys && ![self.requiredPropertyKeys isSubsetOfSet:keysSet]) {
        requiredPropertiesValidated = NO;
        //        requiredPropertiesError = [NSError twt_validationErrorWithCode:TWTValidationErrorCodeValueNotInSet failingValidator:self value:value localizedDescription:TWTLocalizedString(@"TWTJSONObjectValidator.requiredPropertyNotPresentError")];
    }

    NSError *error = nil;
    for (NSString *key in value) {
        error = nil;
        BOOL propertyIsDefined = NO;
        id objectForKey = [value objectForKey:key];

        TWTKeyValuePairValidator *propertyValidator = [self.propertyAndValidators objectForKey:key];
        if (propertyValidator) {
            propertyIsDefined = YES;
            if (![propertyValidator validateValue:objectForKey error:outError ? &error : NULL]) {
                propertiesValidated = NO;
                [propertiesErrors addObjectsFromArray:error.twt_underlyingErrors];
            }
        }

        for (TWTKeyValuePairValidator *patternValidator in self.patternPropertyValidators) {
            NSError *regularExpressionError = nil;
            error = nil;
            NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:patternValidator.key options:0 error:&regularExpressionError];

            if (!regularExpressionError) {
                if ([regularExpression numberOfMatchesInString:key options:0 range:NSMakeRange(0, [key length])] > 0) {
                    propertyIsDefined = YES;

                    if (![patternValidator validateValue:objectForKey error:outError ? &error : NULL]) {
                        patternPropertiesValidated = NO;
                        [patternPropertiesErrors addObjectsFromArray:error.twt_underlyingErrors];
                    };
                }
            } // If regular expression is invalid, no properties will match and thus all instances are valid
        }

        error = nil;
        if (!propertyIsDefined) {
            if (![self.additionalPropertiesValidator validateValue:objectForKey error:outError ? &error : NULL]) {
                additionalPropertiesValidated = NO;
                [additionalPropertiesErrors addObjectsFromArray:error.twt_underlyingErrors];
            }
        }

        // better to check if self.propertyDependencies is nil first?
        id dependency = self.propertyDependencies[key];
        if (dependency) {
            if ([dependency isKindOfClass:[NSSet class]]) {
                if (![dependency isSubsetOfSet:keysSet]) {
                    dependenciesValidated = NO;
                    //                        [dependenciesErrors addObject:[NSError twt_validationErrorWithCode:TWTValidationErrorCodeValueNotInSet failingValidator:self value:value localizedDescription:TWTLocalizedString(@"TWTJSONObjectValidator.requiredPropertyNotPresentError")]];
                }
            } else {
                // dependencyValue is a schema validator
                error = nil;
                if (![dependency validateValue:value error:outError ? &error : NULL]) {
                    dependenciesValidated = NO;
                    [dependenciesErrors addObjectsFromArray:error.twt_underlyingErrors];
                }
            }
        }
    }

    BOOL validated = countValidated & requiredPropertiesValidated & propertiesValidated & patternPropertiesValidated & additionalPropertiesValidated & dependenciesValidated;
    if (!validated && outError) {
        // create error
    }
    
    return validated;
}

@end
