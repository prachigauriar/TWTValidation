//
//  TWTBlockValidator.h
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/28/2014.
//  Copyright (c) 2015 Ticketmaster. All rights reserved.
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
 @abstract The block signature for validation blocks.
 @param value The value to validate.
 @param outError A pointer to an error object to return indirectly. If NULL, no error should be returned.
     TWTBlockValidators will automatically add the failing validator and validated value to this error’s
     userInfo dictionary.
 @result Whether the specified value is valid.
 */
typedef BOOL (^TWTValidationBlock)(id value, NSError *__autoreleasing *outError);


/*!
 TWTBlockValidators validate objects using a validation block. They are primarily useful when validation logic
 is easier to express in code than by composing one or more validators, but is too unique to warrant creating
 a TWTValidator subclass.
 
 Block validators are immutable objects. As such, sending -copy or -copyWithZone: to a block validator will
 simply return the validator itself.
 */
@interface TWTBlockValidator : TWTValidator <NSCopying>

/*! 
 @abstract The instance’s validation block. 
 @discussion If nil, the instance will successfully validate all values. 
 */
@property (nonatomic, copy, readonly) TWTValidationBlock block;

/*!
 @abstract Initializes a newly created block validator with the specified validation block.
 @discussion This is the class’s designated initializer.
 @param block The validation block. If nil, the resulting validator will successfully validate all values.
 @result An initialized block validator with the specified validation block.
 */
- (instancetype)initWithBlock:(TWTValidationBlock)block;

@end
