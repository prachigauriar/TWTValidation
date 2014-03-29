//
//  TWTObject.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/29/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import "TWTObject.h"

@import ObjectiveC.runtime;

#import <TWTValidation/TWTValidation.h>

@implementation TWTObject

- (BOOL)validateValueForKey:(NSString *)key error:(out NSError *__autoreleasing *)outError
{
    id value = [self valueForKey:key];
    return [self validateValue:&value forKey:key error:outError];
}


- (BOOL)validateValue:(inout __autoreleasing id *)ioValue forKey:(NSString *)inKey error:(out NSError *__autoreleasing *)outError
{
    NSSet *validators = [[self class] validatorsForKey:inKey];
    if (!validators.count) {
        return [super validateValue:ioValue forKey:inKey error:outError];
    }

    TWTCompoundValidator *andValidator = [TWTCompoundValidator andValidatorWithSubvalidators:[validators allObjects]];
    return [andValidator validateValue:(ioValue ? *ioValue : nil) error:outError];
}


+ (NSSet *)validatorsForKey:(NSString *)key
{
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"validatorsFor%@", key.capitalizedString]);
    NSSet *validators = objc_getAssociatedObject(self, selector);
    if (validators) {
        return validators;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    validators = [self respondsToSelector:selector] ? [self performSelector:selector] : [NSSet set];
#pragma clang diagnostic pop

    objc_setAssociatedObject(self, selector, validators, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    return validators;
}


+ (NSSet *)validatorsForThing
{
    return [NSSet setWithObject:[TWTCompoundValidator orValidatorWithSubvalidators:@[ [TWTStringValidator stringValidatorWithLength:4],
                                                                                      [TWTNumberValidator numberValidatorWithMinimum:@0 maximum:@3.1415] ]]];
}

@end
