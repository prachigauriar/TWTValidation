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

#import <TWTValidation/TWTJSONSchemaArrayValidator.h>

#import <TWTValidation/TWTNumberValidator.h>
#import <TWTValidation/TWTValidationErrors.h>
#import <TWTValidation/TWTValidationLocalization.h>


@interface TWTJSONSchemaArrayValidator ()

@property (nonatomic, strong, readonly) TWTNumberValidator *countValidator;

@end


@implementation TWTJSONSchemaArrayValidator

- (instancetype)initWithMinimumItemCount:(NSNumber *)minimumItemCount
                        maximumItemCount:(NSNumber *)maximumItemCount
                     requiresUniqueItems:(BOOL)requiresUniqueItems
                           itemValidator:(TWTValidator *)itemValidator
                   indexedItemValidators:(NSArray *)indexedItemValidators
                additionalItemsValidator:(TWTValidator *)additionalItemsValidator
{
    self = [super init];
    if (self) {
        _minimumItemCount = minimumItemCount;
        _maximumItemCount = maximumItemCount;
        _requiresUniqueItems = requiresUniqueItems;
        _itemValidator = itemValidator;
        _indexedItemValidators = [indexedItemValidators copy];
        _additionalItemsValidator = additionalItemsValidator;

        if (minimumItemCount || maximumItemCount) {
            _countValidator = [[TWTNumberValidator alloc] initWithMinimum:minimumItemCount maximum:maximumItemCount];
        }
    }
    return self;
}


- (instancetype)init
{
    return [self initWithMinimumItemCount:nil maximumItemCount:nil requiresUniqueItems:NO itemValidator:nil indexedItemValidators:nil additionalItemsValidator:nil];
}


- (NSUInteger)hash
{
    return [super hash] ^ self.minimumItemCount.hash ^ self.maximumItemCount.hash ^ self.requiresUniqueItems ^ self.itemValidator.hash ^
        self.indexedItemValidators.hash ^ self.additionalItemsValidator.hash;
}


- (BOOL)isEqual:(id)object
{
    if (![super isEqual:object]) {
        return NO;
    } else if (self == object) {
        return YES;
    }

    typeof(self) other = object;
    return other.requiresUniqueItems == self.requiresUniqueItems &&
        (other.minimumItemCount == self.minimumItemCount || (self.minimumItemCount && [other.minimumItemCount isEqual:self.minimumItemCount])) &&
        (other.maximumItemCount == self.maximumItemCount || (self.maximumItemCount && [other.maximumItemCount isEqualToNumber:self.maximumItemCount])) &&
        (other.itemValidator == self.itemValidator || [other.itemValidator isEqual:self.itemValidator]) &&
        (other.indexedItemValidators == self.indexedItemValidators || [other.indexedItemValidators isEqualToArray:self.indexedItemValidators]) &&
        (other.additionalItemsValidator == self.additionalItemsValidator || [other.additionalItemsValidator isEqual:self.additionalItemsValidator]);

}


- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    if (![super validateValue:value error:outError]) {
        return NO;
    } else if (![value isKindOfClass:[NSArray class]]) {
        if (outError) {
            *outError = [NSError twt_validationErrorWithCode:TWTValidationErrorCodeValueHasIncorrectClass
                                            failingValidator:self
                                                       value:value
                                        localizedDescription:TWTLocalizedString(@"TWTJSONSchemaArrayValidator.notArrayError")];
        }
        return NO;
    }

    BOOL countValidated = YES;
    BOOL uniqueItemsValidated = YES;
    BOOL itemsValidated = YES;
    BOOL additionalItemsValidated = YES;

    NSError *countError = nil;
    NSError *uniqueItemsError = nil;
    NSError *error = nil;
    NSMutableArray *itemErrors = outError ? [[NSMutableArray alloc] init] : nil;

    if (self.countValidator) {
        countValidated = [self.countValidator validateValue:@([value count]) error:&countError];
    }

    if (self.requiresUniqueItems) {
        NSCountedSet *itemSet = [[NSCountedSet alloc] initWithArray:value];
        NSSet *repeats = [itemSet objectsPassingTest:^BOOL(id object, BOOL *stop) {
            return [itemSet countForObject:object] > 1;
        }];
        if (repeats.count > 0) {
            uniqueItemsValidated = NO;
            uniqueItemsError = [NSError twt_validationErrorWithCode:TWTValidationErrorCodeNotUniqueElements
                                                   failingValidator:self
                                                              value:value
                                               localizedDescription:TWTLocalizedString(@"TWTJSONSchemaArrayValidator.nonUniqueItems.validationError")];
        }
    }

    if (self.itemValidator) {
        for (id item in value) {
            error = nil;
            if (![self.itemValidator validateValue:item error:outError ? &error : NULL]) {
                itemsValidated = NO;
                if (error) {
                    [itemErrors addObject:error];
                }
            }
        }
    } else if (self.indexedItemValidators) {
        NSUInteger index = 0;
        for (id item in value) {
            error = nil;

            if (index < self.indexedItemValidators.count) {
                if (![self.indexedItemValidators[index] validateValue:item error:outError ? &error : NULL]) {
                    itemsValidated = NO;
                    if (outError) {
                        [itemErrors addObject:error];
                    }
                }
            } else {
                if (![self.additionalItemsValidator validateValue:item error:outError ? &error : NULL]) {
                    additionalItemsValidated = NO;
                    if (outError) {
                        [itemErrors addObject:error];
                    }
                }
            }
            index++;
        }
    }


    BOOL validated = countValidated && uniqueItemsValidated && itemsValidated && additionalItemsValidated;
    if (!validated && outError) {
        if (!countValidated) {
            [itemErrors addObject:countError];
        }

        if (!uniqueItemsValidated) {
            [itemErrors addObject:uniqueItemsError];
        }

        *outError = [NSError twt_validationErrorWithCode:TWTValidationErrorCodeJSONSchemaArrayValidatorError
                                        failingValidator:self
                                                   value:value
                                    localizedDescription:TWTLocalizedString(@"TWTJSONSchemaArrayValidator.validationError")
                                        underlyingErrors:itemErrors];
    }
    
    return validated;
}


@end
