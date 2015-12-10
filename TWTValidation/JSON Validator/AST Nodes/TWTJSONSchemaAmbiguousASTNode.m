//
//  TWTJSONSchemaAmbiguousASTNode.m
//  TWTValidation
//
//  Created by Jill Cohen on 1/12/15.
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

#import <TWTValidation/TWTJSONSchemaAmbiguousASTNode.h>

#import <TWTValidation/TWTJSONSchemaBooleanValueASTNode.h>


@implementation TWTJSONSchemaAmbiguousASTNode

@synthesize validTypes;


- (void)acceptProcessor:(id<TWTJSONSchemaASTProcessor>)processor
{
    [processor processAmbiguousNode:self];
}

- (NSArray *)childrenReferenceNodes
{
    return [[super childrenReferenceNodes] arrayByAddingObjectsFromArray:[self childrenReferenceNodesFromNodeArray:self.subNodes]];
}


- (TWTJSONSchemaASTNode *)nodeForPathComponents:(NSArray *)path
{
    TWTJSONSchemaASTNode *node = [super nodeForPathComponents:path];
    if (node) {
        return node;
    }

    for (TWTJSONSchemaASTNode *subnode in self.subNodes) {
        node = [subnode nodeForPathComponents:path];
        if (node) {
            return node;
        }
    }

    return nil;
}

@end
