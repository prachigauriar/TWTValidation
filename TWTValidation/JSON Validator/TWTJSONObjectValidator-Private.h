//
//  TWTJSONObjectValidator-Private.h
//  TWTValidation
//
//  Created by Jill Cohen on 3/4/16.
//  Copyright © 2016 Ticketmaster Entertainment, Inc. All rights reserved.
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

#import "TWTJSONObjectValidator.h"


@interface TWTJSONObjectValidator ()

/*!
 @abstract Initializes a TWTJSONObjectValidator with a combination of validators representing validation rules
 	defined by a schema.
 @discussion This initializer is used by a TWTJSONObjectValidatorGenerator to create a validator from a schema. The
 	initializer, as well as the concepts of common and type validators, is private because it reveals implementation
 	details that are specific to the TWTJSONObjectValidatorGenerator. This is also reason subclassing is discouraged
 	-- the implementation of `‑validateValue` relies on this the concept of common and type validators.
 @warning This initializer is not intended for use by other classes; instead, the constructor
 	`‑validatorWithJSONSchema:error:warnings:` should be used.
 @param commonValidator A validator representing the validation rules for keywords common across all types (e.g.,
 	anyOf, definitions).
 @param typeValidator A validator representing the validation rules for keywords specific to a type (e.g., minLength
 	for a string).
 @result A configured TWTJSONObjectValidator.
 */
- (instancetype)initWithCommonValidator:(TWTValidator *)commonValidator
                          typeValidator:(TWTValidator *)typeValidator NS_DESIGNATED_INITIALIZER;

@end
