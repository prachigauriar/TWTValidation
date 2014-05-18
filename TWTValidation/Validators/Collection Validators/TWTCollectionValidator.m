//
//  TWTCollectionValidator.m
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

#import <TWTValidation/TWTCollectionValidator.h>

#import <TWTValidation/TWTCompoundValidator.h>
#import <TWTValidation/TWTNumberValidator.h>
#import <TWTValidation/TWTValidationErrors.h>
#import <TWTValidation/TWTValidationLocalization.h>


@interface TWTCollectionValidator ()

@property (nonatomic, strong, readwrite) TWTValidator *countValidator;
@property (nonatomic, strong) TWTCompoundValidator *elementAndValidator;

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
        _countValidator = countValidator;
        _elementAndValidator = [TWTCompoundValidator andValidatorWithSubvalidators:elementValidators];
    }
    
    return self;
}


- (NSUInteger)hash
{
    return [super hash] ^ self.countValidator.hash ^ self.elementAndValidator.hash;
}


- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    } else if (self == object) {
        return YES;
    }
    
    typeof(self) other = object;
    return (other.countValidator == self.countValidator || [other.countValidator isEqual:self.countValidator]) && 
        [other.elementAndValidator isEqual:self.elementAndValidator];
}


- (NSArray *)elementValidators
{
    return self.elementAndValidator.subvalidators;
}


- (BOOL)validateValue:(id)collection error:(out NSError *__autoreleasing *)outError
{
    NSError *countValidationError = nil;
    BOOL countValidated = YES;
    if (self.countValidator) {
        countValidated = [self.countValidator validateValue:@([collection count]) error:outError ? &countValidationError : NULL];
    }
    
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
        userInfo[NSLocalizedDescriptionKey] = TWTLocalizedString(@"TWTCollectionValidator.validationError");

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
