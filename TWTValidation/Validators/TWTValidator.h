//
//  TWTValidator.h
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/27/2014.
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

@import Foundation;

/*!
 TWTValidator is the base class for all validators in the TWTValidation framework. TWTValidator should almost
 never be used directly, as it provides little useful validation functionality. It mostly exists to define an
 interface and behaviors that subclasses can use to validate objects.
 */
@interface TWTValidator : NSObject <NSCopying>

/*!
 @abstract Returns a copy of the receiver.
 @discussion Because base TWTValidator objects are immutable, this simply returns the receiver. Subclass
     implementations should not invoke the base implementation if they are mutable.
 @param zone The zone in which to make the copy.
 @result A copy of the receiver.
 */
- (instancetype)copyWithZone:(NSZone *)zone;

/*!
 @abstract Returns whether the specified object is equal to the receiver.
 @discussion The base implementation returns whether the specified object is an instance of the receiver’s
     class. Subclasses can safely invoke the base implementation from their own isEqual: implementations.
 @param object The object to equality-test against the receiver. 
 @result Whether the specified object is equal to the receiver.
 */
- (BOOL)isEqual:(id)object;

/*!
 @abstract Returns whether the specified value is valid.
 @discussion This is the primary interface that validators use to perform validations. The base
     implementation returns YES unless the value is nil or the NSNull instance. Subclasses should override 
     this method to validate the specified value and return an error indirectly that describes any validation
     failures. The error’s userInfo dictionary should minimally include the NSLocalizedDescriptionKey, 
     TWTValidationFailingValidatorKey, and TWTValidationValidatedValueKey keys. The former has the typical 
     meaning; see TWTValidationErrors.h for more information on the latter two.
 @param value The value to validate.
 @param outError A pointer to an error object to return indirectly. If NULL, no error should be returned.
 @result Whether the specified value is valid.
 */
- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError;

@end
