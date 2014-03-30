//
//  TWTValidatingObject.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/29/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import <TWTValidation/TWTValidatingObject.h>

#import <TWTValidation/TWTCompoundValidator.h>

@import ObjectiveC.runtime;

@implementation TWTValidatingObject

+ (NSArray *)validatorsForKey:(NSString *)key
{
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"validatorsFor%@", key.capitalizedString]);
    NSArray *validators = objc_getAssociatedObject(self, selector);
    if (validators) {
        return validators;
    }
    
    if ([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        validators = [self performSelector:selector];
#pragma clang diagnostic pop
    }
    
    objc_setAssociatedObject(self, selector, validators, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    return validators;
}


- (BOOL)validateValueForKey:(NSString *)key error:(out NSError *__autoreleasing *)outError
{
    id value = [self valueForKey:key];
    return [self validateValue:&value forKey:key error:outError];
}


- (BOOL)validateValue:(inout __autoreleasing id *)ioValue forKey:(NSString *)inKey error:(out NSError *__autoreleasing *)outError
{
    NSArray *validators = [[self class] validatorsForKey:inKey];
    if (!validators.count) {
        return [super validateValue:ioValue forKey:inKey error:outError];
    }
    
    TWTCompoundValidator *andValidator = [TWTCompoundValidator andValidatorWithSubvalidators:validators];
    return [andValidator validateValue:(ioValue ? *ioValue : nil) error:outError];
}

@end
