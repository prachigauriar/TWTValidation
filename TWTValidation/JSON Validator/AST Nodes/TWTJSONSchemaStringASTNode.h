//
//  TWTJSONSchemaStringASTNode.h
//  TWTValidation
//
//  Created by Jill Cohen on 12/15/14.
//  Copyright (c) 2015 Ticketmaster Entertainment, Inc. All rights reserved.
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

#import <TWTValidation/TWTJSONSchemaASTNode.h>


@interface TWTJSONSchemaStringASTNode : TWTJSONSchemaASTNode

/*!
 @abstract The maximum length allowed, given by "maxLength," or nil if the keyword is not present.
 */
@property (nonatomic, strong) NSNumber *maximumLength;

/*!
 @abstract The minimum length allowed, given by "minLength," or nil if the keyword is not present.
 */
@property (nonatomic, strong) NSNumber *minimumLength;

/*!
 @abstract The string value of the "pattern" keyword, or nil if the keyword is not present.
 */
@property (nonatomic, strong) NSString *pattern;

/*!
 @abstract A regular expression created from the string value of the "pattern" keyword, or nil if the keyword is not present or a regular expression could not be created from it.
 */
@property (nonatomic, strong) NSRegularExpression *regularExpression;

@end
