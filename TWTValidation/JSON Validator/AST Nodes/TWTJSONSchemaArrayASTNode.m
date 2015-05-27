//
//  TWTJSONSchemaArrayASTNode.m
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

#import <TWTValidation/TWTJSONSchemaArrayASTNode.h>

#import <TWTValidation/TWTJSONSchemaBooleanValueASTNode.h>


@implementation TWTJSONSchemaArrayASTNode

- (instancetype)init
{
    self = [super init];

    if (self) {
        _additionalItemsNode = [[TWTJSONSchemaBooleanValueASTNode alloc] initWithValue:YES];
    }

    return self;
}


- (void)acceptProcessor:(id<TWTJSONSchemaASTProcessor>)processor
{
    [processor processArrayNode:self];
}


- (NSSet *)validTypes
{
    return [NSSet setWithObject:TWTJSONSchemaTypeKeywordArray];
}


- (NSArray *)childrenReferenceNodes
{
    NSMutableArray *nodes = [[super childrenReferenceNodes] mutableCopy];
    if (self.itemSchema) {
        [nodes addObjectsFromArray:self.itemSchema.childrenReferenceNodes];
    } else {
        [nodes addObjectsFromArray:[self childrenReferenceNodesFromNodeArray:self.indexedItemSchemas]];
    }

    [nodes addObjectsFromArray:self.additionalItemsNode.childrenReferenceNodes];

    return nodes;
}


- (TWTJSONSchemaASTNode *)nodeForPathComponents:(NSArray *)path
{
    TWTJSONSchemaASTNode *node = [super nodeForPathComponents:path];
    if (node) {
        return node;
    }

    NSString *key = path.firstObject;
    NSArray *remainingPath = [self remainingPathFromPath:path];

    if ([key isEqualToString:TWTJSONSchemaKeywordItems]) {
        if (self.itemSchema) {
            return [self.itemSchema nodeForPathComponents:remainingPath];
        } else {
            return [self nodeForPathComponents:remainingPath fromNodeArray:self.indexedItemSchemas];
        }
    } else if ([key isEqualToString:TWTJSONSchemaKeywordAdditionalItems]) {
        return [self.additionalItemsNode nodeForPathComponents:remainingPath];
    }

    return nil;
}

@end
