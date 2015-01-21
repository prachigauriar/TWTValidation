//
//  TWTJSONSchemaArrayValidator.m
//  TWTValidation
//
//  Created by Jill Cohen on 1/15/15.
//  Copyright (c) 2015 Two Toasters, LLC.
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

#import "TWTJSONSchemaArrayValidator.h"

@implementation TWTJSONSchemaArrayValidator

- (instancetype)initWithMaximumItemCount:(NSNumber *)maximumItemCount minimumItemCount:(NSNumber *)minimumItemCount requiresUniqueItems:(BOOL)requiresUniqueItems itemCommonValidator:(TWTValidator *)itemCommonValidator itemOrderedValidators:(NSArray *)itemOrderedValidators additionalItemsValidator:(TWTValidator *)additionalItemsValidator
{
    self = [super init];
    if (self) {
        _maximumItemCount = maximumItemCount;
        _minimumItemCount = minimumItemCount;
        _requiresUniqueItems = requiresUniqueItems;
        _itemCommonValidator = itemCommonValidator;
        _itemOrderedValidators = [itemOrderedValidators copy];
        _additionalItemsValidator = additionalItemsValidator;
    }
    return self;
}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    if (![super validateValue:value error:outError]) {
        return NO;
    } else if (![value isKindOfClass:[NSArray class]]) {
        if (outError) {
            //            *outError = [NSError twt_validationErrorWithCode:TWTValidationErrorCodeValueHasIncorrectClass
            //                                            failingValidator:self
            //                                                       value:value
            //                                        localizedDescription:TWTLocalizedString(@"TWTJSONSchemaArrayValidator.notArrayError")];
        }
        return NO;
    }

    BOOL countValidated = YES;
    BOOL uniqueItemsValidated = YES;
    BOOL itemsValidated = YES;
    BOOL additionalItemsValidated = YES;

    NSError *countError = nil;
    NSError *uniqueItemsError = nil;
    NSMutableArray *itemsErrors = outError ? [[NSMutableArray alloc] init] : nil;
    NSMutableArray *additionalItemsErrors = outError ? [[NSMutableArray alloc] init] : nil;

    if (self.maximumItemCount || self.minimumItemCount) {
        TWTValidator *countValidator = [[TWTNumberValidator alloc] initWithMinimum:self.minimumItemCount maximum:self.maximumItemCount];
        countValidated = [countValidator validateValue:@([value count]) error:&countError];
    }

    if (self.requiresUniqueItems) {
        NSCountedSet *itemSet = [[NSCountedSet alloc] initWithArray:value];
        NSSet *repeats = [itemSet objectsPassingTest:^BOOL(id object, BOOL *stop) {
            return [itemSet countForObject:object] > 1;
        }];
        if (repeats.count > 0) {
            uniqueItemsValidated = NO;
            //            uniqueItemsError =
        }
    }

    NSError *error = nil;


    if (self.itemCommonValidator) {
        for (id item in value) {
            error = nil;
            if (![self.itemCommonValidator validateValue:item error:outError ? &error : NULL]) {
                itemsValidated = NO;
                //                    itemsErrors addObject:
            }
        }
    } else if (self.itemOrderedValidators) {
        NSUInteger index = 0;
        for (id item in value) {
            error = nil;

            if (index < self.itemOrderedValidators.count) {
                if (![self.itemOrderedValidators[index] validateValue:item error:outError ? &error : NULL]) {
                    itemsValidated = NO;
                    //                        add error
                }
            } else {
                if (![self.additionalItemsValidator validateValue:item error:outError ? &error : NULL]) {
                    additionalItemsValidated = NO;
                    //                        add error
                }
            }
            index++;
        }
    }


    BOOL validated = countValidated && uniqueItemsValidated && itemsValidated && additionalItemsValidated;
    if (!validated && outError) {
        //error
    }
    
    return validated;
}


@end
