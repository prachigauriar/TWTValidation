//
//  TWTNumberValidator.h
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/28/2014.
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

#import <TWTValidation/TWTValueValidator.h>

/*!
 TWTNumberValidators validate that values are NSNumber instances with values between a minimum and
 maximum. Further, number validators can validate that a number is an integer.
 */
@interface TWTNumberValidator : TWTValueValidator <NSCopying>

/*!
 @abstract Whether the validator requires a number to be an integer in order to be valid.
 @discussion The default is NO.
 */
@property (nonatomic, assign) BOOL requiresIntegralValue;

/*!
 @abstract Whether the validator’s maximum check is exclusive.
 @discussion The default is NO. When set to YES, the validator checks if a value is greater than the
     maximum value. Otherwise, it checks if a value is greater than or equal to the maximum value.
 */
@property (nonatomic, assign, getter = isMaximumExclusive) BOOL maximumExclusive;

/*!
 @abstract Whether the validator’s minimum check is exclusive.
 @discussion The default is NO. When set to YES, the validator checks if a value is less than the
     minimum value. Otherwise, it checks if a value is less than or equal to the minimum value.
 */
@property (nonatomic, assign, getter = isMinimumExclusive) BOOL minimumExclusive;


/*!
 @abstract The minimum value that the validator considers valid.
 @discussion If nil, there is no minimum value. The default is nil.
 */
@property (nonatomic, strong, readonly) NSNumber *minimum;

/*!
 @abstract The maximum value that the validator considers valid.
 @discussion If nil, there is no maximum value. The default is nil.
 */
@property (nonatomic, strong, readonly) NSNumber *maximum;


/*!
 @abstract Initializes a newly created number validator with the specified minimum and maximum values.
 @discussion This is the class’s designated initializer. If both minimum and maximum are non-nil, minimum
     must be less than or equal to maximum.
 @param minimum The minimum value that the validator considers valid. nil indicates no minimum.
 @param maximum The maximum value that the validator considers valid. nil indicates no maximum.
 @result An initialized number validator with the specified minimum and maximum values.
 */
- (instancetype)initWithMinimum:(NSNumber *)minimum maximum:(NSNumber *)maximum;

@end
