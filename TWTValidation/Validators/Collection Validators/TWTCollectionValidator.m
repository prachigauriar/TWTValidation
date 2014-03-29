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

@interface TWTCollectionValidator ()

@property (nonatomic, strong, readwrite) TWTValidator *countValidator;
@property (nonatomic, strong) TWTCompoundValidator *elementAndValidator;

@end


#pragma mark

@interface TWTKeyedCollectionValidator ()

@property (nonatomic, copy, readwrite) NSArray *keyValidators;
@property (nonatomic, copy, readwrite) NSArray *keyValuePairValidators;

@end


#pragma mark

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
    copy.countValidator = self.countValidator;
    copy.elementAndValidator = self.elementAndValidator;
    return self;
}


- (NSUInteger)hash
{
    return [super hash] ^ [self.countValidator hash] ^ [self.elementAndValidator hash];
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


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    NSMutableArray *errors = outError ? [[NSMutableArray alloc] init] : nil;
    
    NSError *error = nil;
    BOOL validated = [self.countValidator validateValue:@([value count]) error:outError ? &error : NULL];
    if (error) {
        [errors addObject:error];
    }
    
    return validated;
}

@end


