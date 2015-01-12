//
//  TWTJSONSchemaAmbiguousASTNode.m
//  TWTValidation
//
//  Created by Jill Cohen on 1/12/15.
//  Copyright (c) 2015 Two Toasters, LLC.
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

#import <TWTValidation/TWTJSONSchemaAmbiguousASTNode.h>

#import <TWTValidation/TWTJSONSchemaBooleanValueASTNode.h>


@implementation TWTJSONSchemaAmbiguousASTNode

- (instancetype)init
{
    self = [super init];

    if (self) {
        _additionalItemsNode = [[TWTJSONSchemaBooleanValueASTNode alloc] initWithValue:YES];
        _additionalPropertiesNode = [[TWTJSONSchemaBooleanValueASTNode alloc] initWithValue:YES];
    }

    return self;
}


- (void)acceptProcessor:(id<TWTJSONSchemaASTProcessor>)processor
{
    [processor processAmbiguousNode:self];
}


- (NSSet *)validTypes
{
    // by definition, this node is only used if the type keyword is not present and keywords are present for multiple JSON types
    // No type validation is required, just validiation of keywords corresponding to the instance's types
    return [NSSet setWithObject:TWTJSONSchemaTypeKeywordAny];
}

@end
