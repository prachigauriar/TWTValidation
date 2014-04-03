//
//  TWTValidatingObject.m
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/29/2014.
//  Copyright (c) 2014 Two Toasters, LLC.
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

#import <TWTValidation/TWTValidatingObject.h>

#import <TWTValidation/TWTCompoundValidator.h>

@import ObjectiveC.runtime;

@implementation TWTValidatingObject

+ (NSSet *)validatorsForKey:(NSString *)key
{
    SEL selector = NSSelectorFromString([NSString stringWithFormat:@"validatorsFor%@", key.capitalizedString]);
    NSSet *validators = objc_getAssociatedObject(self, selector);
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
    NSSet *validators = [[self class] validatorsForKey:inKey];
    if (!validators.count) {
        return [super validateValue:ioValue forKey:inKey error:outError];
    }
    
    TWTCompoundValidator *andValidator = [TWTCompoundValidator andValidatorWithSubvalidators:[validators allObjects]];
    return [andValidator validateValue:(ioValue ? *ioValue : nil) error:outError];
}

@end
