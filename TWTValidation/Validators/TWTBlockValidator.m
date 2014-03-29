//
//  TWTBlockValidator.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/28/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import <TWTValidation/TWTBlockValidator.h>

@interface TWTBlockValidator ()

@property (nonatomic, copy, readwrite) TWTValidationBlock block;

@end


@implementation TWTBlockValidator

- (instancetype)init
{
    return [self initWithBlock:nil];
}


- (instancetype)initWithBlock:(TWTValidationBlock)block
{
    self = [super init];
    if (self) {
        _block = block;
    }
    
    return self;
}


+ (instancetype)blockValidatorWithBlock:(TWTValidationBlock)block
{
    return [[self alloc] initWithBlock:block];
}


- (instancetype)copyWithZone:(NSZone *)zone
{
    typeof(self) copy = [super copyWithZone:zone];
    copy.block = self.block;
    return copy;
}


- (NSUInteger)hash
{
    return [super hash] ^ [self.block hash];
}


- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    }
    
    typeof(self) other = object;
    return [self.block isEqual:other.block];
}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    return self.block ? self.block(value, outError) : YES;
}

@end
