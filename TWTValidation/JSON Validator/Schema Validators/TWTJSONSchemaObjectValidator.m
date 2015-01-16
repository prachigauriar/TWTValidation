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

@property (nonatomic, strong) NSMapTable *propertyAndValidators;

@end


@implementation TWTJSONSchemaObjectValidator

- (instancetype)initWithMaximumPropertyCount:(NSNumber *)maximumPropertyCount
                        minimumPropertyCount:(NSNumber *)minimumPropertyCount
                          requiredProperties:(NSSet *)requiredPropertyNames
                          propertyValidators:(NSArray *)propertyValidators
                   patternPropertyValidators:(NSArray *)patternPropertyValidators
               additionalPropertiesValidator:(TWTValidator *)additionalPropertiesValidator
                        propertyDependencies:(NSDictionary *)propertyDependencies
{
    self = [super init];
    if (self) {
        _maximumPropertyCount = maximumPropertyCount;
        _minimumPropertyCount = minimumPropertyCount;
        _requiredPropertyNames = [requiredPropertyNames copy];
        _propertyValidators = [propertyValidators copy];
        _patternPropertyValidators = [patternPropertyValidators copy];
        _additionalPropertiesValidator = [additionalPropertiesValidator copy];
        _propertyDependencies = [propertyDependencies copy];

        // Group all our property validators by their key
        NSMapTable *pairValidatorsByKey = [NSMapTable strongToStrongObjectsMapTable];
        for (TWTKeyValuePairValidator *pairValidator in propertyValidators) {
            NSMutableArray *validators = [pairValidatorsByKey objectForKey:pairValidator.key];
            if (!validators) {
                validators = [[NSMutableArray alloc] init];
                [pairValidatorsByKey setObject:validators forKey:pairValidator.key];
            }

            [validators addObject:pairValidator];
        }

        _propertyAndValidators = [NSMapTable strongToStrongObjectsMapTable];
        for (id key in pairValidatorsByKey) {
            [_propertyAndValidators setObject:[TWTCompoundValidator andValidatorWithSubvalidators:[pairValidatorsByKey objectForKey:key]]
                                       forKey:key];
        }
    }
    return self;
}


- (instancetype)init
{
    return [self initWithMaximumPropertyCount:nil minimumPropertyCount:nil requiredProperties:nil propertyValidators:nil patternPropertyValidators:nil additionalPropertiesValidator:nil propertyDependencies:nil];
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

    // Rename and typecast value to faciliate calling NSDictionary methods
    NSDictionary *dictionary = value;

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

    NSSet *keysSet = [NSSet setWithArray:dictionary.allKeys];

    if (self.maximumPropertyCount || self.minimumPropertyCount) {
        TWTValidator *countValidator = [[TWTNumberValidator alloc] initWithMinimum:self.minimumPropertyCount maximum:self.maximumPropertyCount];
        countValidated = [countValidator validateValue:@(dictionary.count) error:&countError];
    }

    if (self.requiredPropertyNames && ![self.requiredPropertyNames isSubsetOfSet:keysSet]) {
        requiredPropertiesValidated = NO;
//        requiredPropertiesError = [NSError twt_validationErrorWithCode:TWTValidationErrorCodeValueNotInSet failingValidator:self value:value localizedDescription:TWTLocalizedString(@"TWTJSONObjectValidator.requiredPropertyNotPresentError")];
    }

    NSError *error = nil;
    for (NSString *key in dictionary) {
        error = nil;
        BOOL propertyIsDefined = NO;
        id valueForKey = dictionary[key];

        TWTCompoundValidator *propertyValidator = [self.propertyAndValidators objectForKey:key];
        if (propertyValidator) {
            propertyIsDefined = YES;
            if (![propertyValidator validateValue:valueForKey error:outError ? &error : NULL]) {
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

                    if (![patternValidator validateValue:valueForKey error:outError ? &error : NULL]) {
                        patternPropertiesValidated = NO;
                        [patternPropertiesErrors addObjectsFromArray:error.twt_underlyingErrors];
                    };
                }
            } // If regular expression is invalid, no properties will match and thus all instances are valid
        }

        error = nil;
        if (!propertyIsDefined) {
            if (![self.additionalPropertiesValidator validateValue:valueForKey error:outError ? &error : NULL]) {
                additionalPropertiesValidated = NO;
                [additionalPropertiesErrors addObjectsFromArray:error.twt_underlyingErrors];
            }
        }
    }

    if (self.propertyDependencies) {
        for (NSString *propertyKey in self.propertyDependencies) {
            if ([keysSet containsObject:propertyKey]) {
                id dependencyValue = self.propertyDependencies[propertyKey];

                if ([dependencyValue isKindOfClass:[NSSet class]]) {
                    if (![dependencyValue isSubsetOfSet:keysSet]) {
                        dependenciesValidated = NO;
//                        [dependenciesErrors addObject:[NSError twt_validationErrorWithCode:TWTValidationErrorCodeValueNotInSet failingValidator:self value:value localizedDescription:TWTLocalizedString(@"TWTJSONObjectValidator.requiredPropertyNotPresentError")]];
                    }
                } else {
                    // dependencyValue is a schema validator
                    error = nil;
                    if (![dependencyValue validateValue:dictionary error:outError ? &error : NULL]) {
                        dependenciesValidated = NO;
                        [dependenciesErrors addObjectsFromArray:error.twt_underlyingErrors];
                    }
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
