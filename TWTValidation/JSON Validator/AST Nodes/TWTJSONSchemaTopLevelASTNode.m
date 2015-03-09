//
//  TWTJSONSchemaTopLevelASTNode.m
//  TWTValidation
//
//  Created by Jill Cohen on 12/16/14.
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

#import <TWTValidation/TWTJSONSchemaTopLevelASTNode.h>

#import <TWTValidation/TWTJSONSchemaReferenceASTNode.h>


@interface TWTJSONSchemaTopLevelASTNode ()

@property (nonatomic, copy, readwrite) NSArray *allReferenceNodes;

@end


@implementation TWTJSONSchemaTopLevelASTNode

- (NSSet *)validTypes
{
    return self.schema.validTypes;
}


- (void)acceptProcessor:(id<TWTJSONSchemaASTProcessor>)processor
{
    [processor processTopLevelNode:self];
}


- (NSArray *)allReferenceNodes
{
    // Assumes this only runs after the entire AST node tree has been generated, and no changes are made to the tree afterward
    if (!_allReferenceNodes) {
        _allReferenceNodes = [[self childrenReferenceNodes] copy];
    }

    return _allReferenceNodes;
}


- (TWTJSONSchemaASTNode *)nodeForReferenceNode:(TWTJSONSchemaReferenceASTNode *)referenceNode
{
    return [self nodeForPathComponents:[referenceNode.referencePathComponents mutableCopy]];
}


- (TWTJSONSchemaASTNode *)nodeForPathComponents:(NSMutableArray *)path
{
    // Assumes key is @"#"
    if (path.count == 1) {
        return self.schema;
    }

    [path removeObjectAtIndex:0];
    return [self.schema nodeForPathComponents:path];
}


- (NSArray *)childrenReferenceNodes
{
    return [self.schema childrenReferenceNodes];
}

@end
