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

#import "TWTJSONSchemaASTCommon.h"
#import "TWTJSONSchemaKeywordConstants.h"

@interface TWTJSONSchemaPrettyPrinter ()

@property (nonatomic, copy) NSDictionary *topLevelSchema;

@property (nonatomic, strong) id currentObject;
@property (nonatomic, strong, readonly) NSMutableDictionary *currentSchema;
@property (nonatomic, strong) NSMutableArray *objectStack;


@end

@implementation TWTJSONSchemaPrettyPrinter

- (NSDictionary *)objectFromSchema:(TWTJSONSchemaTopLevelASTNode *)topLevelNode
{
    self.objectStack = [[NSMutableArray alloc] init];

    [topLevelNode acceptProcessor:self];

    return [self.topLevelSchema copy];
}

#pragma mark - TWTJSONSchemaASTProcessor Protocol methods

// Top level of schema
- (void)processTopLevelNode:(TWTJSONSchemaTopLevelASTNode *)topLevelNode
{
    [self newCurrentSchema];
    [self setObject:topLevelNode.schemaPath forKey:TWTJSONSchemaKeywordSchema];
    [topLevelNode.schema acceptProcessor:self];
    self.topLevelSchema = self.currentSchema;
    [self finishedCurrentSchema];
}

// Specialized nodes based on value of "type" keyword
- (void)processGenericNode:(TWTJSONSchemaGenericASTNode *)genericNode
{
    [self generateCommonSchemaFromNode:genericNode];
}


- (void)processArrayNode:(TWTJSONSchemaArrayASTNode *)arrayNode
{
    [self generateCommonSchemaFromNode:arrayNode];
    [self setObject:arrayNode.minimumItemCount forKey:TWTJSONSchemaKeywordMinItems];
    [self setObject:arrayNode.maximumItemCount forKey:TWTJSONSchemaKeywordMaxItems];
    [self setObject:@(arrayNode.requiresUniqueItems) forKey:TWTJSONSchemaKeywordUniqueItems];
    [self setObject:[self schemaArrayFromNodeArray:arrayNode.itemSchemas] forKey:TWTJSONSchemaKeywordItems];
    [self setObject:[self additionalItemsOrPropertiesFromNode:arrayNode.additionalItemsNode] forKey:TWTJSONSchemaKeywordAdditionalItems];
}


- (void)processNumberNode:(TWTJSONSchemaNumberASTNode *)numberNode
{
    [self generateCommonSchemaFromNode:numberNode];
    [self setObject:numberNode.minimum forKey:TWTJSONSchemaKeywordMinimum];
    [self setObject:numberNode.maximum forKey:TWTJSONSchemaKeywordMaximum];
    [self setObject:@(numberNode.exclusiveMinimum) forKey:TWTJSONSchemaKeywordExclusiveMinimum];
    [self setObject:@(numberNode.exclusiveMaximum) forKey:TWTJSONSchemaKeywordExclusiveMaximum];
    [self setObject:numberNode.multipleOf forKey:TWTJSONSchemaKeywordMultipleOf];
}


- (void)processObjectNode:(TWTJSONSchemaObjectASTNode *)objectNode
{
    [self generateCommonSchemaFromNode:objectNode];
    [self setObject:objectNode.minimumPropertyCount forKey:TWTJSONSchemaKeywordMinProperties];
    [self setObject:objectNode.maximumPropertyCount forKey:TWTJSONSchemaKeywordMaxProperties];
    [self setObject:objectNode.requiredPropertyNames forKey:TWTJSONSchemaKeywordRequired];
    [self setObject:[self schemaDictionaryFromKeyValuePairNodeArray:objectNode.propertySchemas] forKey:TWTJSONSchemaKeywordProperties];
    [self setObject:[self schemaDictionaryFromKeyValuePairNodeArray:objectNode.patternPropertySchemas] forKey:TWTJSONSchemaKeywordPatternProperties];
    [self setObject:[self additionalItemsOrPropertiesFromNode:objectNode.additionalPropertiesNode] forKey:TWTJSONSchemaKeywordAdditionalProperties];
    [self setObject:[s] forKey:TWTJSONSchemaKeywordDependencies];
}


- (void)processStringNode:(TWTJSONSchemaStringASTNode *)stringNode
{
    [self generateCommonSchemaFromNode:stringNode];
    [self setObject:stringNode.minimumLength forKey:TWTJSONSchemaKeywordMinLength];
    [self setObject:stringNode.maximumLength forKey:TWTJSONSchemaKeywordMaxLength];
    [self setObject:stringNode.pattern forKey:TWTJSONSchemaKeywordPattern];
}
//
//// Specialized nodes for array items and object properties
- (void)processBooleanValueNode:(TWTJSONSchemaBooleanValueASTNode *)booleanValueNode
{
//    self.current1DObject = @(booleanValueNode.booleanValue);
}
- (void)processNamedPropertyNode:(TWTJSONSchemaNamedPropertyASTNode *)propertyNode
{
    [self setObject:[self schemaFromNode:propertyNode.valueSchema] forKey:propertyNode.key];
}

- (void)processPatternPropertyNode:(TWTJSONSchemaPatternPropertyASTNode *)patternPropertyNode
{
    [self setObject:[self schemaFromNode:patternPropertyNode.valueSchema] forKey:patternPropertyNode.key];
}


- (void)processDependencyNode:(TWTJSONSchemaDependencyASTNode *)dependencyNode
{
    if (dependencyNode.valueSchema) {
        [self newCurrentSchema]
        [dependencyNode.valueSchema acceptProcessor:self];
        NSDictionary *valueSchema = self.currentSchema;
        [self finishedCurrentSchema];

    }
}


#pragma mark - Schema-to-node conversion methods

- (void)generateCommonSchemaFromNode:(TWTJSONSchemaASTNode *)node
{
    [self setObject:node.validTypes forKey:TWTJSONSchemaKeywordType];
    [self setObject:node.schemaTitle forKey:TWTJSONSchemaKeywordTitle];
    [self setObject:node.schemaDescription forKey:TWTJSONSchemaKeywordDescription];
    [self setObject:node.validValues forKey:TWTJSONSchemaKeywordEnum];

    [self setObject:[self schemaArrayFromNodeArray:node.andSchemas] forKey:TWTJSONSchemaKeywordAllOf];
    [self setObject:[self schemaArrayFromNodeArray:node.orSchemas] forKey:TWTJSONSchemaKeywordAnyOf];
    [self setObject:[self schemaArrayFromNodeArray:node.exactlyOneOfSchemas] forKey:TWTJSONSchemaKeywordOneOf];
    [self setObject:[self schemaFromNode:node.notSchema] forKey:TWTJSONSchemaKeywordNot];

    [self setObject:node.definitions forKey:TWTJSONSchemaKeywordDefinitions];
}


- (id)additionalItemsOrPropertiesFromNode:(TWTJSONSchemaASTNode *)additionalNode
{
    if (!additionalNode) {
        return nil;
    }

    if ([additionalNode isKindOfClass:[TWTJSONSchemaBooleanValueASTNode class]]) {
        return @([(TWTJSONSchemaBooleanValueASTNode *)additionalNode booleanValue]);
    }

    return [self schemaFromNode:additionalNode];
}


- (NSDictionary *)dependencyDictionaryFromNodeArray:(NSArray *)array
{
    if (!array) {
        return nil;
    }

    [self newCurrentSchema];
    for (TWTJSONSchemaDependencyASTNode *node in array) {
        [node acceptProcessor:self];
    }

    NSDictionary *dependencyValue = self.currentSchema;
    [self finishedCurrentSchema];
    return dependencyValue;
}


- (NSDictionary *)schemaFromNode:(TWTJSONSchemaASTNode *)node
{
    NSDictionary *schema = nil;

    if (node) {
        [self newCurrentSchema];
        [node acceptProcessor:self];
        schema = self.currentSchema;
        [self finishedCurrentSchema];
    }

    return schema;
}


- (NSArray *)schemaArrayFromNodeArray:(NSArray *)array
{
    if (!array) {
        return nil;
    }

    NSMutableArray *nodeArray = [[NSMutableArray alloc] init];
    for (TWTJSONSchemaASTNode *node in array) {
        [self newCurrentSchema];
        [node acceptProcessor:self];
        [nodeArray addObject:self.currentSchema];
        [self finishedCurrentSchema];
    }

    return nodeArray;
}


- (NSDictionary *)schemaDictionaryFromKeyValuePairNodeArray:(NSArray *)array
{
    if (!array) {
        return  nil;
    }

    [self newCurrentSchema];
    for (TWTJSONSchemaKeyValuePairASTNode *node in array) {
        [node acceptProcessor:self];
    }

    NSDictionary *schema = self.currentSchema;
    [self finishedCurrentSchema];
    return schema;
}


# pragma mark - Convenience methods

- (void)setObject:(id)object forKey:(NSString *)key
{
    if (object) {
        [self.currentSchema setObject:object forKey:key];
    }
}

- (NSMutableDictionary *)currentSchema
{
    return self.objectStack.lastObject;
}


- (void)newCurrentSchema
{
    [self.objectStack addObject:[[NSMutableDictionary alloc] init]];
}


- (void)finishedCurrentSchema
{
    [self.objectStack removeLastObject];
}

@end
