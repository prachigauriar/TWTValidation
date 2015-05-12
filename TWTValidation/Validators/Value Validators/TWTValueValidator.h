//
//  TWTValueValidator.h
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
 TWTValueValidators validate a single object. Each value validator can validate that an object is of a given
 class, is not nil, and is not the NSNull instance. This class is primarily useful as the superclass of more
 specific validators.
 */
@interface TWTValueValidator : TWTValidator <NSCopying>

/*!
 @abstract Whether the validator considers nil values valid.
 @discussion The default is NO.
 */
@property (nonatomic, assign) BOOL allowsNil;

/*!
 @abstract Whether the validator considers NSNull instances valid.
 @discussion The default is NO.
 */
@property (nonatomic, assign) BOOL allowsNull;

/*!
 @abstract The class that values have to be an instance of for the validator to consider them valid.
 @discussion Nil by default, meaning all objects are valid.
 */
@property (nonatomic, unsafe_unretained) Class valueClass;


/*!
 @abstract Creates and returns a new TWTValueValidator instance with the specified value class.
 @param valueClass The class that values have to be an instance of for the validator to consider them valid.
 @param allowsNil Whether the validator considers nil values valid.
 @param allowsNull Whether the validator considers the NSNull instance valid. This option takes precedence
     over valueClass; if valueClass is equal to [NSNull class], but allowsNull is NO, the NSNull instance
     is not considered valid.
 @result A new TWTValidator instance with the specified value class.
 */
+ (instancetype)valueValidatorWithClass:(Class)valueClass allowsNil:(BOOL)allowsNil allowsNull:(BOOL)allowsNull;

@end


/*!
 @abstract Returns whether the specified value is nil or the NSNull instance.
 @discussion This function is provided as a convenience for TWTValueValidator subclasses. If both
    TWTValueValidator’s implementation of -validateValue:error: and this function return YES for a value,
    the value is both valid and nil/null. Typically, this means no further validation is necessary.
 @param value The value.
 @result Whether the value is nil or the NSNull instance.
 */
static inline BOOL TWTValidatorValueIsNilOrNull(id value)
{
    return !value || [[NSNull null] isEqual:value];
}
