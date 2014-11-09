//
//  TWTCollectionValidator.h
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

#import <TWTValidation/TWTValidator.h>

/*!
 TWTCollectionValidators validate a collection’s count and elements. To iterate over a collection’s elements,
 collection validators use fast enumeration. As such, TWTCollectionValidator is primarily intended for
 validating arrays, sets, and the like. For keyed collections like dictionaries and map tables, use
 TWTKeyedCollectionValidator.

 In order to pass validation with a collection validator, an object must minimally respond to -count and 
 conform to the NSFastEnumeration protocol.

 Collection validators are immutable objects. As such, sending -copy or -copyWithZone: to a collection
 validator will simply return the validator itself.
 */
@interface TWTCollectionValidator : TWTValidator <NSCopying>

/*! 
 @abstract The validator for a collection’s count.
 @discussion If nil, collections with any number of objects will pass validation. Collection validators 
     get a collection’s count by sending it the -count message.
 */
@property (nonatomic, strong, readonly) TWTValidator *countValidator;

/*! 
 @abstract The validators for a collection’s elements.
 @discussion A collection is only valid if all its elements pass validation by all the element validators.
     If nil, all elements in a collection will pass validation. Collection validators get a collection’s
     keys using fast enumeration.
 */
@property (nonatomic, copy, readonly) NSArray *elementValidators;

/*!
 @abstract Initializes a newly created collection validator with the specified count and element validators.
 @discussion This is the class’s designated initializer.
 @param countValidator The validator to validate a collection’s count. If nil, collections with any number of
     objects will pass validation.
 @param elementValidators The validators to use for a collection’s elements. If nil, the resulting validator
     will successfully validate all a collection’s elements.
 @result An initialized collection validator with the specified count and element validators.
 */
- (instancetype)initWithCountValidator:(TWTValidator *)countValidator elementValidators:(NSArray *)elementValidators;

@end
