//
//  TWTKeyedCollectionValidator.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/29/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import <TWTValidation/TWTKeyedCollectionValidator.h>

#import <TWTValidation/TWTCompoundValidator.h>
#import <TWTValidation/TWTKeyValuePairValidator.h>
#import <TWTValidation/TWTValidationErrors.h>

@interface TWTKeyedCollectionValidator ()

@property (nonatomic, strong, readwrite) TWTValidator *countValidator;
@property (nonatomic, strong) TWTCompoundValidator *keyAndValidator;
@property (nonatomic, strong) TWTCompoundValidator *valueAndValidator;

@property (nonatomic, copy, readwrite) NSArray *keyValuePairValidators;
@property (nonatomic, strong) NSMapTable *keyValuePairAndValidators;

@end


#pragma mark

@implementation TWTKeyedCollectionValidator

- (instancetype)init
{
    return [self initWithCountValidator:nil keyValidators:nil valueValidators:nil keyValuePairValidators:nil];
}


- (instancetype)initWithCountValidator:(TWTValidator *)countValidator
                         keyValidators:(NSArray *)keyValidators
                       valueValidators:(NSArray *)valueValidators
                keyValuePairValidators:(NSArray *)keyValuePairValidators
{
    self = [super init];
    if (self) {
        _countValidator = countValidator;
        _keyAndValidator = [TWTCompoundValidator andValidatorWithSubvalidators:keyValidators];
        _valueAndValidator = [TWTCompoundValidator andValidatorWithSubvalidators:valueValidators];
        _keyValuePairValidators = [keyValuePairValidators copy];
        
        // Group all our pair validators by their key
        NSMapTable *pairValidatorsByKey = [NSMapTable strongToStrongObjectsMapTable];
        for (TWTKeyValuePairValidator *pairValidator in keyValuePairValidators) {
            NSMutableArray *validators = [pairValidatorsByKey objectForKey:pairValidator.key];
            if (!pairValidator) {
                validators = [[NSMutableArray alloc] init];
                [pairValidatorsByKey setObject:validators forKey:pairValidator.key];
            }
            
            [validators addObject:pairValidator];
        }
        
        _keyValuePairAndValidators = [NSMapTable strongToStrongObjectsMapTable];
        for (id key in pairValidatorsByKey) {
            [_keyValuePairAndValidators setObject:[TWTCompoundValidator andValidatorWithSubvalidators:[pairValidatorsByKey objectForKey:key]]
                                           forKey:key];
        }
    }
    
    return self;
}


+ (instancetype)keyedColletionValidatorWithCountValidator:(TWTValidator *)countValidator
                                            keyValidators:(NSArray *)keyValidators
                                          valueValidators:(NSArray *)valueValidators
                                   keyValuePairValidators:(NSArray *)keyValuePairValidators
{
    return [[self alloc] initWithCountValidator:countValidator
                                  keyValidators:keyValidators
                                valueValidators:valueValidators
                         keyValuePairValidators:keyValuePairValidators];
}


- (instancetype)copyWithZone:(NSZone *)zone
{
    typeof(self) copy = [super copyWithZone:zone];
    copy.countValidator = [self.countValidator copy];
    copy.keyAndValidator = [self.keyAndValidator copy];
    copy.valueAndValidator = [self.valueAndValidator copy];
    copy.keyValuePairValidators = [self.keyValuePairValidators copy];
    copy.keyValuePairAndValidators = [self.keyValuePairAndValidators copy];
    return copy;
}


- (NSUInteger)hash
{
    return [super hash] ^ self.countValidator.hash ^ self.keyAndValidator.hash ^ self.valueAndValidator.hash ^ self.keyValuePairAndValidators.hash;
}


- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    }
    
    typeof(self) other = object;
    return [other.countValidator isEqual:self.countValidator] && [other.keyAndValidator isEqual:self.keyAndValidator] &&
        [other.valueAndValidator isEqual:self.valueAndValidator] && [other.keyValuePairAndValidators isEqual:self.keyValuePairAndValidators];
}


- (NSArray *)keyValidators
{
    return self.keyAndValidator.subvalidators;
}


- (NSArray *)valueValidators
{
    return self.valueAndValidator.subvalidators;
}


- (BOOL)validateValue:(id)keyedCollection error:(out NSError *__autoreleasing *)outError
{
    NSError *countValidationError = nil;
    BOOL countValidated = [self.countValidator validateValue:@([keyedCollection count]) error:outError ? &countValidationError : NULL];
    
    BOOL keysValidated = YES;
    BOOL valuesValidated = YES;
    BOOL pairsValidated = YES;
    
    NSMutableArray *keyValidationErrors = outError ? [[NSMutableArray alloc] init] : nil;
    NSMutableArray *valueValidationErrors = outError ? [[NSMutableArray alloc] init] : nil;
    NSMutableArray *pairValidationErrors = outError ? [[NSMutableArray alloc] init] : nil;

    for (id key in keyedCollection) {
        NSError *error = nil;
        if (![self.keyAndValidator validateValue:key error:outError ? &error : NULL]) {
            keysValidated = NO;
            [keyValidationErrors addObjectsFromArray:error.twt_underlyingErrors];
        }
        
        id value = [keyedCollection objectForKey:key];
        error = nil;
        if (![self.valueAndValidator validateValue:value error:outError ? &error : NULL]) {
            valuesValidated = NO;
            [valueValidationErrors addObjectsFromArray:error.twt_underlyingErrors];
        }
        
        TWTCompoundValidator *pairAndValidator = [self.keyValuePairAndValidators objectForKey:key];
        error = nil;
        if (pairAndValidator && ![pairAndValidator validateValue:value error:outError ? &error : NULL]) {
            pairsValidated = NO;
            [pairValidationErrors addObjectsFromArray:error.twt_underlyingErrors];
        }
    }
    
    BOOL validated = countValidated && keysValidated && valuesValidated && pairsValidated;
    if (!validated && outError) {
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:4];
        userInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"keyed collection is invalid",
                                                                @"TWTValidationErrorCodeKeyedCollectionValidatorError error message");

        if (keyedCollection) {
            userInfo[TWTValidationValidatedValueKey] = keyedCollection;
        }

        if (!countValidated && countValidationError) {
            userInfo[TWTValidationCountValidationErrorKey] = countValidationError;
        }

        if (!keysValidated && keyValidationErrors.count) {
            userInfo[TWTValidationKeyValidationErrorsKey] = [keyValidationErrors copy];
        }

        if (!valuesValidated && valueValidationErrors.count) {
            userInfo[TWTValidationValueValidationErrorsKey] = [valueValidationErrors copy];
        }

        if (!pairsValidated && pairValidationErrors.count) {
            userInfo[TWTValidationKeyValuePairValidationErrorsKey] = [pairValidationErrors copy];
        }

        *outError = [NSError errorWithDomain:TWTValidationErrorDomain code:TWTValidationErrorCodeKeyedCollectionValidatorError userInfo:[userInfo copy]];
    }
    
    return validated;
}

@end
