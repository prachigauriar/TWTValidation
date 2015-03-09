//
//  TWTJSONSchemaASTNode.m
//  TWTValidation
//
//  Created by Jill Cohen on 12/12/14.
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

#import <URLMock/NSException+UMKSubclassResponsibility.h>


@implementation TWTJSONSchemaASTNode

- (void)acceptProcessor:(id)processor
{
    [NSException umk_subclassResponsibilityExceptionWithReceiver:self selector:_cmd];
}


- (NSSet *)validTypes
{
    [NSException umk_subclassResponsibilityExceptionWithReceiver:self selector:_cmd];
    return nil;
}


- (NSMutableArray *)childrenReferenceNodes
{
    NSMutableArray *referenceNodes = [[NSMutableArray alloc] init];

    [referenceNodes addObjectsFromArray:[self childrenReferenceNodesFromNodeArray:self.andSchemas]];
    [referenceNodes addObjectsFromArray:[self childrenReferenceNodesFromNodeArray:self.orSchemas]];
    [referenceNodes addObjectsFromArray:[self childrenReferenceNodesFromNodeArray:self.exactlyOneOfSchemas]];
    [referenceNodes addObjectsFromArray:self.notSchema.childrenReferenceNodes];

    [referenceNodes addObjectsFromArray:[self childrenReferenceNodesFromNodeDictionary:self.definitions]];

    return referenceNodes;
}


- (NSArray *)childrenReferenceNodesFromNodeArray:(NSArray *)array
{
    if (!array) {
        return @[ ];
    }

    NSMutableArray *referenceNodes = [[NSMutableArray alloc] init];
    for (TWTJSONSchemaASTNode *node in array) {
        [referenceNodes addObjectsFromArray:node.childrenReferenceNodes];
    }
    return [referenceNodes copy];
}


- (NSArray *)childrenReferenceNodesFromNodeDictionary:(NSDictionary *)dictionary
{
    if (!dictionary) {
        return @[ ];
    }

    NSMutableArray *referenceNodes = [[NSMutableArray alloc] init];
    for (NSString *key in dictionary) {
        [referenceNodes addObjectsFromArray:[dictionary[key] childrenReferenceNodes]];
    }
    return [referenceNodes copy];
}


- (TWTJSONSchemaASTNode *)nodeForPathComponents:(NSMutableArray *)path
{
    if (path.count == 0) {
        return self;
    }

    NSString *key = path.firstObject;
    [path removeObjectAtIndex:0];

    if ([key isEqualToString:TWTJSONSchemaKeywordAllOf]) {
        return [self nodeForPathComponents:path fromNodeArray:self.andSchemas];
    }
    if ([key isEqualToString:TWTJSONSchemaKeywordAnyOf]) {
        return [self nodeForPathComponents:path fromNodeArray:self.orSchemas];
    }
    if ([key isEqualToString:TWTJSONSchemaKeywordOneOf]) {
        return [self nodeForPathComponents:path fromNodeArray:self.exactlyOneOfSchemas];
    }
    if ([key isEqualToString:TWTJSONSchemaKeywordNot]) {
        return [self.notSchema nodeForPathComponents:path];
    }
    if ([key isEqualToString:TWTJSONSchemaKeywordDefinitions]) {
        return [self nodeForPathComponents:path fromNodeDictionary:self.definitions];
    }

    return [self typeSpecificChecksForKey:key referencePath:path];
}


- (TWTJSONSchemaASTNode *)typeSpecificChecksForKey:(NSString *)key referencePath:(NSMutableArray *)path
{
    return nil;
}


- (TWTJSONSchemaASTNode *)nodeForPathComponents:(NSMutableArray *)path fromNodeArray:(NSArray *)array
{
    NSString *index = path.firstObject;
    if (!index || ![self componentIsIndex:index] || index.integerValue > array.count) {
        return nil;
    }

    [path removeObjectAtIndex:0];
    return [array[index.integerValue] nodeForPathComponents:path];
}


- (TWTJSONSchemaASTNode *)nodeForPathComponents:(NSMutableArray *)path fromNodeDictionary:(NSDictionary *)dictionary
{
    NSString *key = path.firstObject;
    [path removeObjectAtIndex:0];

    return [dictionary[key] nodeForPathComponents:path];
}


- (BOOL)componentIsIndex:(NSString *)key
{
    return [key rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location == NSNotFound;
}
 
@end

