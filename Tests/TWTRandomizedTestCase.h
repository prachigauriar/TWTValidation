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

#import <XCTest/XCTest.h>
#import <URLMock/UMKTestUtilities.h>

@class TWTValidator;

/*!
 TWTRandomizedTestCases override +setUp to call srandomdev() and -setUp to generate and log a random seed
 value before calling srandom(). Subclasses that override +setUp or -setUp should invoke the superclass 
 implementation.
 
 Additionally, randomized test cases have several utility methods that are generally useful when testing
 the TWTValidation framework. These methods include returning a random object, error, and returning mock
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
 @abstract Returns a random error object.
 @discussion The error has a random ten-character Unicode string as its domain, a random unsigned integer
     as its code, and a ten-element dictionary with random string keys and values as its userInfo.
 @result A random error object.
 */
- (NSError *)randomError;

/*!
 @abstract Returns a random validator.
 @discussion The validator is either a mock passing validator or a mock failing validator.
 @result A random validator.
 */
- (TWTValidator *)randomValidator;

/*!
 @abstract Returns a mock TWTValidator object that always validates values.
 @discussion The mock object responds to -validateValue:error: by returning YES and setting the error 
     parameter to nil if a non-NULL error pointer is provided.
 @param outError The error pointer that will be used when invoking -validateValue:error:.
 @result A mock TWTValidator object that always validates values.
 */
- (id)mockPassingValidatorWithErrorPointer:(NSError *__autoreleasing *)outError;

/*!
 @abstract Returns a mock TWTValidator object that never validates values.
 @discussion The mock object responds to -validateValue:error: by returning NO and setting the error
     parameter to the specified error if a non-NULL error pointer is provided.
 @param outError The error pointer that will be used when invoking -validateValue:error:.
 @param error The error to return by reference.
 @result A mock TWTValidator object that never validates values.
 */
- (id)mockFailingValidatorWithErrorPointer:(NSError *__autoreleasing *)outError error:(NSError *)error;

@end


/*!
 @abstract XCTAsserts that the given expression evaluates to YES before the given timeout interval elapses.
 @param timeoutInterval An NSTimeInterval containing the amount of time to wait for the expression to evaluate to YES.
 @param expression The boolean expression to evaluate.
 @param format An NSString object that contains a printf-style string containing an error message describing the failure
     condition and placeholders for the arguments.
 @param ... The arguments displayed in the format string.
 */
#define UMKAssertTrueBeforeTimeout(timeoutInterval, expression, format...) \
    XCTAssertTrue(UMKWaitForCondition((timeoutInterval), ^BOOL{ return (expression); }), ## format)
