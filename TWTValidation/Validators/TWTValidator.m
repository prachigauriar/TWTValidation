//
//  TWTValidator.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/27/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import <TWTValidation/TWTValidator.h>

#pragma mark Constants

NSString *const TWTValidatorErrorDomain = @"TWTValidatorErrorDomain";
NSString *const TWTValidatorUnderlyingErrorsKey = @"TWTValidatorUnderlyingErrorsKey";


#pragma mark

@implementation TWTValidator

- (instancetype)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] init];
}


- (NSUInteger)hash
{
    return 0;
}


- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[self class]];
}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    return YES;
}

@end
