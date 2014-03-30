//
//  TWTKeyValuePairValidator.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/29/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import <TWTValidation/TWTKeyValuePairValidator.h>

#import <TWTValidation/TWTValidationErrors.h>

@interface TWTKeyValuePairValidator ()

@property (nonatomic, strong, readwrite) id key;
@property (nonatomic, strong, readwrite) TWTValidator *valueValidator;

@end


@implementation TWTKeyValuePairValidator

- (instancetype)init
{
    return [self initWithKey:nil valueValidator:nil];
}


- (instancetype)initWithKey:(id)key valueValidator:(TWTValidator *)valueValidator
{
    NSParameterAssert(key);
    self = [super init];
    if (self) {
        _key = key;
        _valueValidator = valueValidator;
    }
    
    return self;
}


+ (instancetype)keyValuePairValidatorWithKey:(id)key valueValidator:(TWTValidator *)valueValidator
{
    return [[self alloc] initWithKey:key valueValidator:valueValidator];
}


- (instancetype)copyWithZone:(NSZone *)zone
{
    typeof(self) copy = [super copyWithZone:zone];
    copy.key = self.key;
    copy.valueValidator = [self.valueValidator copy];
    return copy;
}


- (NSUInteger)hash
{
    return [super hash] ^ [self.key hash] ^ self.valueValidator.hash;
}


- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    }
    
    typeof(self) other = object;
    return [other.key isEqual:self.key] && [other.valueValidator isEqual:self.valueValidator];
}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    return self.valueValidator ? [self.valueValidator validateValue:value error:outError] : YES;
}

@end
