//
//  TWTJSONSchemaNumberASTNode.h
//  TWTValidation
//
//  Created by Jill Cohen on 12/15/14.
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

#import <TWTValidation/TWTJSONSchemaASTNode.h>


@interface TWTJSONSchemaNumberASTNode : TWTJSONSchemaASTNode

@property (nonatomic, strong) NSNumber *multipleOf;
@property (nonatomic, strong) NSNumber *maximum;
@property (nonatomic, strong) NSNumber *minimum;
@property (nonatomic, assign) BOOL exclusiveMaximum;
@property (nonatomic, assign) BOOL exclusiveMinimum;
@property (nonatomic, assign) BOOL requireIntegralValue;

@end
