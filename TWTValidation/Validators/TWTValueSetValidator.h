//
//  TWTValueSetValidator.h
//  TWTValidation
//
//  Created by Prachi Gauriar on 8/13/2014.
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
 TWTValueSetValidators validate that a value is a member of a set of valid values. Each instance has a set of
 valid values and can optionally allow for nil values.

 Value set validators are immutable objects. As such, sending -copy or -copyWithZone: to a value set validator
 will simply return the validator itself.
 */
@interface TWTValueSetValidator : TWTValidator <NSCopying>

/*!
 @abstract The set of values the validator considers valid.
 @discussion The default is nil. If nil (or empty), validation will never pass.
 */
@property (nonatomic, copy, readonly) NSSet *validValues;

/*!
 @abstract Whether the validator considers nil values valid.
 @discussion The default is NO.
 */
@property (nonatomic, assign, readonly) BOOL allowsNil;

/*!
 @abstract Initializes a newly created value set validator with the specified valid values.
 @discussion The returned validator does not allow nil values.
 @param validValues The set of values the validator should consider valid. If nil or empty, the validator will
     never consider a value valid.
 @result An initialized value set validator with the specified valid values.
 */
- (instancetype)initWithValidValues:(NSSet *)validValues;

/*!
 @abstract Initializes a newly created value set validator with the specified valid values and 
     whether to allow nil.
 @discussion This is the class’s designated initializer.
 @param validValues The set of values the validator should consider valid. If nil or empty, the validator will
     never consider a value valid.
 @param allowsNil Whether the validator should allow nil values.
 @result An initialized value set validator with the specified valid values and whether to allow nil.
 */
- (instancetype)initWithValidValues:(NSSet *)validValues allowsNil:(BOOL)allowsNil;

@end
