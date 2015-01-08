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


- (NSDictionary *)objectFromSchema:(TWTJSONSchemaTopLevelASTNode *)topLevelNode
{
    [self.objectStack removeAllObjects];
    [topLevelNode acceptProcessor:self];
    return [self.topLevelSchema copy];
}


#pragma mark - TWTJSONSchemaASTProcessor Protocol methods

// Top level of schema
// Delegates schema creation to its schema property, adds the path, and sets the topLevelSchema
- (void)processTopLevelNode:(TWTJSONSchemaTopLevelASTNode *)topLevelNode
{
    [topLevelNode.schema acceptProcessor:self];
    [self setObject:topLevelNode.schemaPath forKey:TWTJSONSchemaKeywordSchema];
    self.topLevelSchema = [self popCurrentObject];
}


// Generates a fully-formed schema and leaves it on the object stack
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
    [self setObject:[self dependencyDictionaryFromNodeArray:objectNode.propertyDependencies] forKey:TWTJSONSchemaKeywordDependencies];
}


- (void)processStringNode:(TWTJSONSchemaStringASTNode *)stringNode
{
    [self generateCommonSchemaFromNode:stringNode];
    [self setObject:stringNode.minimumLength forKey:TWTJSONSchemaKeywordMinLength];
    [self setObject:stringNode.maximumLength forKey:TWTJSONSchemaKeywordMaxLength];
    [self setObject:stringNode.pattern forKey:TWTJSONSchemaKeywordPattern];
}


// Responsible for adding a boolean object to the stack
- (void)processBooleanValueNode:(TWTJSONSchemaBooleanValueASTNode *)booleanValueNode
{
    [self pushNewObject:@(booleanValueNode.booleanValue)];
}


// Adds a key-value pair to the current object
// Guaranteed that a mutable dictionary is top of the stack
- (void)processNamedPropertyNode:(TWTJSONSchemaNamedPropertyASTNode *)propertyNode
{
    [self setObject:[self schemaFromNode:propertyNode.valueSchema] forKey:propertyNode.key];
}


// Adds a key-value pair to the current object
// Guaranteed that a mutable dictionary is top of the stack
- (void)processPatternPropertyNode:(TWTJSONSchemaPatternPropertyASTNode *)patternPropertyNode
{
    [self setObject:[self schemaFromNode:patternPropertyNode.valueSchema] forKey:patternPropertyNode.key];
}


// Adds a key-value pair to the current object; value is either a fully-formed schema or an array of strings
// Guaranteed that a mutable dictionary is top of the stack
- (void)processDependencyNode:(TWTJSONSchemaDependencyASTNode *)dependencyNode
{
    if (dependencyNode.valueSchema) {
        [dependencyNode.valueSchema acceptProcessor:self];
    } else {
        // Node has a property set, which is an array of strings
        [self pushNewObject:dependencyNode.propertySet];
    }

    [self setObject:[self popCurrentObject] forKey:dependencyNode.key];
}


#pragma mark - Schema-to-node conversion methods

- (void)generateCommonSchemaFromNode:(TWTJSONSchemaASTNode *)node
{
    [self pushNewObject:[[NSMutableDictionary alloc] init]];
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

- (void)setObject:(id)object forKey:(NSString *)key
{
    if (object && [self.currentObject isKindOfClass:[NSDictionary class]]) {
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
