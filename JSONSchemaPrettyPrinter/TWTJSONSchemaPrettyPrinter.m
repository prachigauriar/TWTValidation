//
//  TWTJSONSchemaPrettyPrinter.m
//  TWTValidation
//
//  Created by Jill Cohen on 1/7/15.
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

#import "TWTJSONSchemaPrettyPrinter.h"

#import <TWTValidation/TWTJSONSchemaASTCommon.h>
#import <TWTValidation/TWTJSONSchemaKeywordConstants.h>


@interface TWTJSONSchemaPrettyPrinter ()

@property (nonatomic, strong, readonly) NSMutableArray *objectStack;

@end


@implementation TWTJSONSchemaPrettyPrinter

- (instancetype)init
{
    self = [super init];
    if (self) {
        _objectStack = [[NSMutableArray alloc] init];
    }
    return self;
}


- (NSDictionary *)objectFromTopLevelNode:(TWTJSONSchemaTopLevelASTNode *)topLevelNode
{
    [self.objectStack removeAllObjects];
    [topLevelNode acceptProcessor:self];
    return [self popCurrentObject];
}


#pragma mark - TWTJSONSchemaASTProcessor Protocol methods

// Top level of schema
// Delegates schema creation to its schema property, adds the path, and sets the topLevelSchema
- (void)processTopLevelNode:(TWTJSONSchemaTopLevelASTNode *)topLevelNode
{
    [topLevelNode.schema acceptProcessor:self];
    [self setObject:topLevelNode.schemaPath inCurrentSchemaForKey:TWTJSONSchemaKeywordSchema];
}


// Adds a fully-formed schema (i.e., NSDictionary) to the stack
- (void)processGenericNode:(TWTJSONSchemaGenericASTNode *)genericNode
{
    [self generateCommonSchemaFromNode:genericNode];
}


- (void)processArrayNode:(TWTJSONSchemaArrayASTNode *)arrayNode
{
    [self generateCommonSchemaFromNode:arrayNode];
    [self setObject:arrayNode.minimumItemCount inCurrentSchemaForKey:TWTJSONSchemaKeywordMinItems];
    [self setObject:arrayNode.maximumItemCount inCurrentSchemaForKey:TWTJSONSchemaKeywordMaxItems];
    [self setObject:@(arrayNode.requiresUniqueItems) inCurrentSchemaForKey:TWTJSONSchemaKeywordUniqueItems];
    if (arrayNode.itemsIsSingleSchema) {
        [self setObject:[self schemaFromNode:arrayNode.itemSchemas[0]] inCurrentSchemaForKey:TWTJSONSchemaKeywordItems];
    } else {
        [self setObject:[self schemaArrayFromNodeArray:arrayNode.itemSchemas] inCurrentSchemaForKey:TWTJSONSchemaKeywordItems];
    }
    [self setObject:[self additionalItemsOrPropertiesFromNode:arrayNode.additionalItemsNode] inCurrentSchemaForKey:TWTJSONSchemaKeywordAdditionalItems];
}


- (void)processNumberNode:(TWTJSONSchemaNumberASTNode *)numberNode
{
    [self generateCommonSchemaFromNode:numberNode];
    [self setObject:numberNode.minimum inCurrentSchemaForKey:TWTJSONSchemaKeywordMinimum];
    [self setObject:numberNode.maximum inCurrentSchemaForKey:TWTJSONSchemaKeywordMaximum];
    [self setObject:@(numberNode.exclusiveMinimum) inCurrentSchemaForKey:TWTJSONSchemaKeywordExclusiveMinimum];
    [self setObject:@(numberNode.exclusiveMaximum) inCurrentSchemaForKey:TWTJSONSchemaKeywordExclusiveMaximum];
    [self setObject:numberNode.multipleOf inCurrentSchemaForKey:TWTJSONSchemaKeywordMultipleOf];
}


- (void)processObjectNode:(TWTJSONSchemaObjectASTNode *)objectNode
{
    [self generateCommonSchemaFromNode:objectNode];
    [self setObject:objectNode.minimumPropertyCount inCurrentSchemaForKey:TWTJSONSchemaKeywordMinProperties];
    [self setObject:objectNode.maximumPropertyCount inCurrentSchemaForKey:TWTJSONSchemaKeywordMaxProperties];
    [self setObject:objectNode.requiredPropertyNames inCurrentSchemaForKey:TWTJSONSchemaKeywordRequired];
    [self setObject:[self schemaDictionaryFromKeyValuePairNodeArray:objectNode.propertySchemas] inCurrentSchemaForKey:TWTJSONSchemaKeywordProperties];
    [self setObject:[self schemaDictionaryFromKeyValuePairNodeArray:objectNode.patternPropertySchemas] inCurrentSchemaForKey:TWTJSONSchemaKeywordPatternProperties];
    [self setObject:[self additionalItemsOrPropertiesFromNode:objectNode.additionalPropertiesNode] inCurrentSchemaForKey:TWTJSONSchemaKeywordAdditionalProperties];
    [self setObject:[self dependencyDictionaryFromNodeArray:objectNode.propertyDependencies] inCurrentSchemaForKey:TWTJSONSchemaKeywordDependencies];
}


- (void)processStringNode:(TWTJSONSchemaStringASTNode *)stringNode
{
    [self generateCommonSchemaFromNode:stringNode];
    [self setObject:stringNode.minimumLength inCurrentSchemaForKey:TWTJSONSchemaKeywordMinLength];
    [self setObject:stringNode.maximumLength inCurrentSchemaForKey:TWTJSONSchemaKeywordMaxLength];
    [self setObject:stringNode.pattern inCurrentSchemaForKey:TWTJSONSchemaKeywordPattern];
}


- (void)processAmbiguousNode:(TWTJSONSchemaAmbiguousASTNode *)ambiguousNode
{
    [self generateCommonSchemaFromNode:ambiguousNode];

    [self setObject:ambiguousNode.minimumItemCount inCurrentSchemaForKey:TWTJSONSchemaKeywordMinItems];
    [self setObject:ambiguousNode.maximumItemCount inCurrentSchemaForKey:TWTJSONSchemaKeywordMaxItems];
    [self setObject:@(ambiguousNode.requiresUniqueItems) inCurrentSchemaForKey:TWTJSONSchemaKeywordUniqueItems];
    if (ambiguousNode.itemsIsSingleSchema) {
        [self setObject:[self schemaFromNode:ambiguousNode.itemSchemas[0]] inCurrentSchemaForKey:TWTJSONSchemaKeywordItems];
    } else {
        [self setObject:[self schemaArrayFromNodeArray:ambiguousNode.itemSchemas] inCurrentSchemaForKey:TWTJSONSchemaKeywordItems];
    }
    [self setObject:[self additionalItemsOrPropertiesFromNode:ambiguousNode.additionalItemsNode] inCurrentSchemaForKey:TWTJSONSchemaKeywordAdditionalItems];

    [self setObject:ambiguousNode.minimum inCurrentSchemaForKey:TWTJSONSchemaKeywordMinimum];
    [self setObject:ambiguousNode.maximum inCurrentSchemaForKey:TWTJSONSchemaKeywordMaximum];
    [self setObject:@(ambiguousNode.exclusiveMinimum) inCurrentSchemaForKey:TWTJSONSchemaKeywordExclusiveMinimum];
    [self setObject:@(ambiguousNode.exclusiveMaximum) inCurrentSchemaForKey:TWTJSONSchemaKeywordExclusiveMaximum];
    [self setObject:ambiguousNode.multipleOf inCurrentSchemaForKey:TWTJSONSchemaKeywordMultipleOf];

    [self setObject:ambiguousNode.minimumLength inCurrentSchemaForKey:TWTJSONSchemaKeywordMinLength];
    [self setObject:ambiguousNode.maximumLength inCurrentSchemaForKey:TWTJSONSchemaKeywordMaxLength];
    [self setObject:ambiguousNode.pattern inCurrentSchemaForKey:TWTJSONSchemaKeywordPattern];

    [self setObject:ambiguousNode.minimumPropertyCount inCurrentSchemaForKey:TWTJSONSchemaKeywordMinProperties];
    [self setObject:ambiguousNode.maximumPropertyCount inCurrentSchemaForKey:TWTJSONSchemaKeywordMaxProperties];
    [self setObject:ambiguousNode.requiredPropertyNames inCurrentSchemaForKey:TWTJSONSchemaKeywordRequired];
    [self setObject:[self schemaDictionaryFromKeyValuePairNodeArray:ambiguousNode.propertySchemas] inCurrentSchemaForKey:TWTJSONSchemaKeywordProperties];
    [self setObject:[self schemaDictionaryFromKeyValuePairNodeArray:ambiguousNode.patternPropertySchemas] inCurrentSchemaForKey:TWTJSONSchemaKeywordPatternProperties];
    [self setObject:[self additionalItemsOrPropertiesFromNode:ambiguousNode.additionalPropertiesNode] inCurrentSchemaForKey:TWTJSONSchemaKeywordAdditionalProperties];
    [self setObject:[self dependencyDictionaryFromNodeArray:ambiguousNode.propertyDependencies] inCurrentSchemaForKey:TWTJSONSchemaKeywordDependencies];
}


// Adds a boolean object to the stack
- (void)processBooleanValueNode:(TWTJSONSchemaBooleanValueASTNode *)booleanValueNode
{
    [self pushNewObject:@(booleanValueNode.booleanValue)];
}


// Adds a key-value pair to the current object
// Guaranteed that a mutable dictionary is top of the stack
- (void)processNamedPropertyNode:(TWTJSONSchemaNamedPropertyASTNode *)propertyNode
{
    [self setObject:[self schemaFromNode:propertyNode.valueSchema] inCurrentSchemaForKey:propertyNode.key];
}


// Adds a key-value pair to the current object
// Guaranteed that a mutable dictionary is top of the stack
- (void)processPatternPropertyNode:(TWTJSONSchemaPatternPropertyASTNode *)patternPropertyNode
{
    [self setObject:[self schemaFromNode:patternPropertyNode.valueSchema] inCurrentSchemaForKey:patternPropertyNode.key];
}


// Adds a key-value pair to the current object; value is either a fully-formed schema or an array of strings
// Guaranteed that a mutable dictionary is top of the stack
- (void)processDependencyNode:(TWTJSONSchemaDependencyASTNode *)dependencyNode
{
    if (dependencyNode.valueSchema) {
        [dependencyNode.valueSchema acceptProcessor:self];
    } else {
        // Else, node has a property set, which is an array of strings
        [self pushNewObject:dependencyNode.propertySet];
    }

    [self setObject:[self popCurrentObject] inCurrentSchemaForKey:dependencyNode.key];
}


#pragma mark - Schema-to-node conversion methods

- (void)generateCommonSchemaFromNode:(TWTJSONSchemaASTNode *)node
{
    [self pushNewObject:[[NSMutableDictionary alloc] init]];
    if (node.typeIsExplicit) {
        if (node.validTypes.count == 1) {
            NSString *typeString = [[node.validTypes allObjects] firstObject];
            [self setObject:typeString inCurrentSchemaForKey:TWTJSONSchemaKeywordType];
        } else {
            [self setObject:node.validTypes inCurrentSchemaForKey:TWTJSONSchemaKeywordType];
        }
    }
    [self setObject:node.schemaTitle inCurrentSchemaForKey:TWTJSONSchemaKeywordTitle];
    [self setObject:node.schemaDescription inCurrentSchemaForKey:TWTJSONSchemaKeywordDescription];
    [self setObject:node.validValues inCurrentSchemaForKey:TWTJSONSchemaKeywordEnum];

    [self setObject:[self schemaArrayFromNodeArray:node.andSchemas] inCurrentSchemaForKey:TWTJSONSchemaKeywordAllOf];
    [self setObject:[self schemaArrayFromNodeArray:node.orSchemas] inCurrentSchemaForKey:TWTJSONSchemaKeywordAnyOf];
    [self setObject:[self schemaArrayFromNodeArray:node.exactlyOneOfSchemas] inCurrentSchemaForKey:TWTJSONSchemaKeywordOneOf];
    [self setObject:[self schemaFromNode:node.notSchema] inCurrentSchemaForKey:TWTJSONSchemaKeywordNot];

    [self setObject:node.definitions inCurrentSchemaForKey:TWTJSONSchemaKeywordDefinitions];
}


- (id)additionalItemsOrPropertiesFromNode:(TWTJSONSchemaASTNode *)additionalNode
{
    if (!additionalNode) {
        return nil;
    }

    [additionalNode acceptProcessor:self];

    return [self popCurrentObject];
}


- (NSDictionary *)dependencyDictionaryFromNodeArray:(NSArray *)array
{
    if (!array) {
        return nil;
    }

    [self pushNewObject:[[NSMutableDictionary alloc] init]];
    for (TWTJSONSchemaDependencyASTNode *node in array) {
        [node acceptProcessor:self];
    }

    return [self popCurrentObject];
}


- (NSDictionary *)schemaFromNode:(TWTJSONSchemaASTNode *)node
{
    if (!node) {
        return nil;
    }

    [node acceptProcessor:self];
    return [self popCurrentObject];
}


- (NSArray *)schemaArrayFromNodeArray:(NSArray *)array
{
    if (!array) {
        return nil;
    }

    NSMutableArray *nodeArray = [[NSMutableArray alloc] init];
    for (TWTJSONSchemaASTNode *node in array) {
        [node acceptProcessor:self];
        [nodeArray addObject:[self popCurrentObject]];
    }

    return nodeArray;
}


- (NSDictionary *)schemaDictionaryFromKeyValuePairNodeArray:(NSArray *)array
{
    if (!array) {
        return  nil;
    }

    [self pushNewObject:[[NSMutableDictionary alloc] init]];
    for (TWTJSONSchemaKeyValuePairASTNode *node in array) {
        [node acceptProcessor:self];
    }

    return [self popCurrentObject];
}


# pragma mark - Convenience methods

- (void)setObject:(id)object inCurrentSchemaForKey:(NSString *)key
{
    if (object) {
        if ([object isKindOfClass:[NSSet class]]) {
            object = [object allObjects];
        }
        [self.currentObject setObject:object forKey:key];
    }
}


- (void)pushNewObject:(id)object
{
    [self.objectStack addObject:object];
}


- (id)currentObject
{
    return self.objectStack.lastObject;
}


- (id)popCurrentObject
{
    id object = self.currentObject;
    [self.objectStack removeLastObject];
    return object;
}

@end
