//
//  TWTValidatorTests.m
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

#import "TWTRandomizedTestCase.h"

#import <TWTValidation/TWTValidator.h>

@interface TWTValidatorTests : TWTRandomizedTestCase

@property (nonatomic, strong) TWTValidator *validator;

- (void)testInit;
- (void)testCopy;
- (void)testHashAndIsEqual;
- (void)testValidateValueError;

@end


@implementation TWTValidatorTests

- (void)setUp
{
    [super setUp];
    self.validator = [[TWTValidator alloc] init];
}

- (void)testInit
{
    XCTAssertNotNil(self.validator, @"returns nil");
}


- (void)testCopy
{
    TWTValidator *copy = [self.validator copy];
    XCTAssertEqual(copy, self.validator, @"copy returns different object");
}


- (void)testHashAndIsEqual
{
    TWTValidator *otherValidator = [[TWTValidator alloc] init];
    XCTAssertEqual(self.validator.hash, otherValidator.hash, @"hashes are different for equal objects");
    XCTAssertEqualObjects(self.validator, otherValidator, @"equal objects are not equal");
}


- (void)testValidateValueError
{
    id value = UMKRandomBoolean() ? UMKRandomUnicodeStringWithLength(10) : UMKRandomUnsignedNumber();
    NSError *error = nil;
    XCTAssertTrue([self.validator validateValue:value error:&error], @"returns NO");
}

@end
