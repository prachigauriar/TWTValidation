//
//  TWTRandomizedTestCase.h
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/30/2014.
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

@import XCTest;

#import <URLMock/UMKTestUtilities.h>
#import <TWTValidation/TWTValidation.h>


@class TWTValidator;

/*!
 TWTRandomizedTestCases override +setUp to call srandomdev() and -setUp to generate and log a random seed
 value before calling srandom(). Subclasses that override +setUp or -setUp should invoke the superclass 
 implementation.
 
 Additionally, randomized test cases have several utility methods that are generally useful when testing
 the TWTValidation framework. These utilities include returning a random object, class, error, and mock
 objects that pass and fail validation, respectively.
 */
@interface TWTRandomizedTestCase : XCTestCase

/*!
 @abstract Returns a random object or nil.
 @discussion If the return value is non-nil, it is either a random number, string, URL, or NSNull.
 @result A random object.
 */
- (id)randomObject;

/*!
 @abstract Returns a random class or Nil.
 @discussion If the return value is non-Nil, it is either NSNumber, NSString, NSURL, or NSNull.
 @result A random class.
 */
- (Class)randomClass;

/*!
 @abstract Returns a random class that has a mutable variant.
 @discussion The returned class is either NSArray, NSData, NSDictionary, NSSet, or NSString.
 @result A random class that has a mutable variant.
 */
- (Class)randomClassWithMutableVariant;

/*!
 @abstract Returns a random validator.
 @discussion The validator is either a mock passing validator or a mock failing validator.
 @result A random validator.
 */
- (TWTValidator *)randomValidator;

/*!
 @abstract Returns a TWTValidator object that always validates values.
 @result A TWTValidator object that always validates values.
 */
- (TWTValidator *)passingValidator;

/*!
 @abstract Returns a TWTValidator object that never validates values.
 @param error The error that the validator should return by reference.
 @result A TWTValidator object that never validates values.
 */
- (TWTValidator *)failingValidatorWithError:(NSError *)error;

@end
