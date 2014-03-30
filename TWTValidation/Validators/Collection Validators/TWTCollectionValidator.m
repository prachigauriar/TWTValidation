//
//  TWTCollectionValidator.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/29/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import <TWTValidation/TWTCollectionValidator.h>

#import <TWTValidation/TWTCompoundValidator.h>
#import <TWTValidation/TWTNumberValidator.h>
#import <TWTValidation/TWTValidationErrors.h>

@interface TWTCollectionValidator ()

@property (nonatomic, strong, readwrite) TWTValidator *countValidator;
@property (nonatomic, strong) TWTCompoundValidator *elementAndValidator;

@end


@implementation TWTCollectionValidator

- (instancetype)init
{
    return [self initWithCountValidator:nil elementValidators:nil];
}


- (instancetype)initWithCountValidator:(TWTValidator *)countValidator elementValidators:(NSArray *)elementValidators
{
    self = [super init];
    if (self) {
        _countValidator = countValidator ? countValidator : [[TWTNumberValidator alloc] init];
        _elementAndValidator = [TWTCompoundValidator andValidatorWithSubvalidators:elementValidators];
    }
    
    return self;
}


+ (instancetype)collectionValidatorWithCountValidator:(TWTValidator *)countValidator elementValidators:(NSArray *)elementValidators
{
    return [[self alloc] initWithCountValidator:countValidator elementValidators:elementValidators];
}


- (instancetype)copyWithZone:(NSZone *)zone
{
    typeof(self) copy = [super copyWithZone:zone];
    copy.countValidator = [self.countValidator copy];
    copy.elementAndValidator = [self.elementAndValidator copy];
    return copy;
}


- (NSUInteger)hash
{
    return [super hash] ^ self.countValidator.hash ^ self.elementAndValidator.hash;
}


- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    }
    
    typeof(self) other = object;
    return [other.countValidator isEqual:self.countValidator] && [other.elementAndValidator isEqual:self.elementAndValidator];
}


- (NSArray *)elementValidators
{
    return self.elementAndValidator.subvalidators;
}


- (BOOL)validateValue:(id)collection error:(out NSError *__autoreleasing *)outError
{
    NSError *countValidationError = nil;
    BOOL countValidated = [self.countValidator validateValue:@([collection count]) error:outError ? &countValidationError : NULL];
    
    BOOL elementsValidated = YES;
    NSMutableArray *elementValidationErrors = outError ? [[NSMutableArray alloc] init] : nil;
    for (id element in collection) {
        NSError *error = nil;
        if (![self.elementAndValidator validateValue:element error:outError ? &error : NULL]) {
            elementsValidated = NO;
            [elementValidationErrors addObjectsFromArray:error.twt_underlyingErrors];
        }
    }
    
    BOOL validated = countValidated && elementsValidated;
    if (!validated && outError) {
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:4];
        userInfo[NSLocalizedDescriptionKey] = NSLocalizedString(@"collection is invalid", @"TWTValidationErrorCodeCollectionValidatorError error message");

        if (collection) {
            userInfo[TWTValidationValidatedValueKey] = collection;
        }
        
        if (!countValidated && countValidationError) {
            userInfo[TWTValidationCountValidationErrorKey] = countValidationError;
        }
        
        if (!elementsValidated && elementValidationErrors.count) {
            userInfo[TWTValidationElementValidationErrorsKey] = [elementValidationErrors copy];
        }
        
        *outError = [NSError errorWithDomain:TWTValidationErrorDomain code:TWTValidationErrorCodeCollectionValidatorError userInfo:[userInfo copy]];
    }
    
    return validated;
}

@end
