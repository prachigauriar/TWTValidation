//
//  TWTJSONSchemaArrayValidator.h
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

#import <TWTValidation/TWTValidation.h>


@interface TWTJSONSchemaArrayValidator : TWTValidator <NSCopying>

@property (nonatomic, strong, readonly) NSNumber *maximumItemCount;
@property (nonatomic, strong, readonly) NSNumber *minimumItemCount;
@property (nonatomic, assign, readonly) BOOL requiresUniqueItems;
@property (nonatomic, strong, readonly) TWTValidator *itemValidator;
@property (nonatomic, copy, readonly) NSArray *indexedItemValidators;
@property (nonatomic, strong, readonly) TWTValidator *additionalItemsValidator; // either JSON validator or always passing/failing

- (instancetype)initWithMaximumItemCount:(NSNumber *)maximumItemCount
                        minimumItemCount:(NSNumber *)minimumItemCount
                     requiresUniqueItems:(BOOL)requiresUniqueItems
                           itemValidator:(TWTValidator *)itemValidator
                   indexedItemValidators:(NSArray *)indexedItemValidators
                additionalItemsValidator:(TWTValidator *)additionalItemsValidator;

@end
