//
//  TWTJSONSchemaParser.m
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

#import "TWTJSONSchemaParser.h"

#import "TWTJSONSchemaArrayASTNode.h"
#import "TWTJSONSchemaASTNode.h"
#import "TWTJSONSchemaBooleanValueASTNode.h"
#import "TWTJSONSchemaDepedencyASTNode.h"
#import "TWTJSONSchemaGenericASTNode.h"
#import "TWTJSONSchemaKeywordConstants.h"
#import "TWTJSONSchemaNamedPropertyASTNode.h"
#import "TWTJSONSchemaNumberASTNode.h"
#import "TWTJSONSchemaObjectASTNode.h"
#import "TWTJSONSchemaPatternPropertyASTNode.h"
#import "TWTJSONSchemaStringASTNode.h"
#import "TWTJSONSchemaTopLevelASTNode.h"
#import "TWTJSONSchemaValidTypesConstants.h"


static NSString *const kTWTJSONExceptionErrorKey = @"error";
NSString *const kTWTJSONErrorInfoSelectorKey = @"selector";
NSString *const kTWTJSONErrorInfoPathKey = @"path";
NSString *const kTWTJSONErrorInfoInvalidObjectKey = @"object";


@interface TWTJSONSchemaParser ()

@property (nonatomic, strong) NSMutableArray *pathStack;

@property (nonatomic, copy) NSDictionary *JSONSchema;

@end


@implementation TWTJSONSchemaParser

- (instancetype)initWithJSONSchema:(NSDictionary *)topLevelSchema
{
    self = [super init];
    if (self) {
        _JSONSchema = [topLevelSchema copy];
        _pathStack = [[NSMutableArray alloc] init];
    }
    return self;
}


- (TWTJSONSchemaTopLevelASTNode *)parseWithError:(NSError *__autoreleasing *)errorPointer
{
    TWTJSONSchemaTopLevelASTNode *topLevelNode = [[TWTJSONSchemaTopLevelASTNode alloc] init];

    if ([self.JSONSchema[kTWTJSONSchemaKeywordSchema] isNotEqualTo:kTWTJSONSchemaKeywordDraft4Path]) {
        [self push:kTWTJSONSchemaKeywordSchema];
        [self throwExceptionWithSelector:_cmd];
        return nil;
    }

    topLevelNode.schemaPath = self.JSONSchema[kTWTJSONSchemaKeywordSchema];

    @try {
        topLevelNode.schema = [self parseSchema:self.JSONSchema];
    }

    @catch (NSException *exception) {
        NSError *outError = exception.userInfo[kTWTJSONExceptionErrorKey];
        if (errorPointer) {
            *errorPointer = outError;
            return nil;
        }
    }

    return topLevelNode;
}


# pragma mark - Schema parser methods
// starting point for all nodes (except top level)
// directs the schema toward the appropriate parser method based on the value of "type"
// type-specific parser methods are responsible for the entire process of creating a node from a schema, including:
// 1) initializing the appropriate ASTNode 2) setting the type (if its not built into that ASTNode class) and deleting the type keyword 3) parsing all general and type-specific properties 4) returning a completed node
- (TWTJSONSchemaASTNode *)parseSchema:(NSDictionary *)schema
{
    NSParameterAssert(schema);

    if (![schema isKindOfClass:[NSDictionary class]]) {
        [self throwExceptionWithSelector:_cmd];
        return nil;
    }

    if ([schema[kTWTJSONSchemaKeywordType] isKindOfClass:[NSString class]]) {
        NSString *instanceType = schema[kTWTJSONSchemaKeywordType];

        static NSDictionary *typeSelectors = nil;
        if (!typeSelectors) {
            typeSelectors = @{ kTWTJSONSchemaTypeKeywordAny : @"parseGenericTypeSchema:",
                               kTWTJSONSchemaTypeKeywordArray : @"parseArrayTypeSchema:",
                               kTWTJSONSchemaTypeKeywordBoolean : @"parseGenericTypeSchema:",
                               kTWTJSONSchemaTypeKeywordInteger : @"parseNumberTypeSchema:",
                               kTWTJSONSchemaTypeKeywordNull : @"parseGenericTypeSchema:",
                               kTWTJSONSchemaTypeKeywordNumber : @"parseNumberTypeSchema:",
                               kTWTJSONSchemaTypeKeywordObject : @"parseObjectTypeSchema:",
                               kTWTJSONSchemaTypeKeywordString : @"parseStringTypeSchema:" };
        }

        if (typeSelectors[instanceType]) {
            SEL parseSelector = NSSelectorFromString(typeSelectors[instanceType]);
            NSAssert([self respondsToSelector:parseSelector], @"selector is not defined");

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            return [self performSelector:parseSelector withObject:schema];
#pragma clang diagnostic pop
        }
    }

    return [self parseGenericTypeSchema:schema];
}



- (TWTJSONSchemaArrayASTNode *)parseArrayTypeSchema:(NSDictionary *)arraySchema
{
    TWTJSONSchemaArrayASTNode *node = [[TWTJSONSchemaArrayASTNode alloc] init];
    node = (TWTJSONSchemaArrayASTNode *)[self parseCommonKeywordsFromSchema:arraySchema toNode:node];

    node.maximumItemCount = [self parseUnsignedIntegerFromSchema:arraySchema usingKey:kTWTJSONSchemaKeywordMaxItems];
    node.minimumItemCount = [self parseUnsignedIntegerFromSchema:arraySchema usingKey:kTWTJSONSchemaKeywordMinItems];
    node.requiresUniqueItems = [self parseBooleanValueFromSchema:arraySchema usingKey:kTWTJSONSchemaKeywordUniqueItems];

    if ([arraySchema[kTWTJSONSchemaKeywordItems] isKindOfClass:[NSDictionary class]]) {
        node.itemSchemas = @[ [self parseSchemaFromSchema:arraySchema usingKey:kTWTJSONSchemaKeywordItems] ];
        // additional items is meaningless if items is a single schema
    } else {
        node.itemSchemas = [self parseArrayOfSchemasFromSchema:arraySchema usingKey:kTWTJSONSchemaKeywordItems];
        node.additionalItemsNode = [self parseAdditionalItemsOrPropertiesWithSchema:arraySchema usingKey:kTWTJSONSchemaKeywordAdditionalItems];
    }

    return node;
}

- (TWTJSONSchemaGenericASTNode *)parseGenericTypeSchema:(NSDictionary *)genericSchema
{
    TWTJSONSchemaGenericASTNode *node = [[TWTJSONSchemaGenericASTNode alloc] init];
    node = (TWTJSONSchemaGenericASTNode *)[self parseCommonKeywordsFromSchema:genericSchema toNode:node];

    node.validTypes = [self parseTypeKeywordFromSchema:genericSchema];

    return node;
}


- (TWTJSONSchemaNumberASTNode *)parseNumberTypeSchema:(NSDictionary *)numberSchema
{
    TWTJSONSchemaNumberASTNode *node = [[TWTJSONSchemaNumberASTNode alloc] init];
    node = (TWTJSONSchemaNumberASTNode *)[self parseCommonKeywordsFromSchema:numberSchema toNode:node];

    node.requireIntegralValue = [numberSchema[kTWTJSONSchemaKeywordType] isEqualToString:kTWTJSONSchemaTypeKeywordInteger];
    node.minimum = [self parseNumberFromSchema:numberSchema usingKey:kTWTJSONSchemaKeywordMinimum];
    node.maximum = [self parseNumberFromSchema:numberSchema usingKey:kTWTJSONSchemaKeywordMaximum];
    node.multipleOf = [self parseNumberFromSchema:numberSchema usingKey:kTWTJSONSchemaKeywordMultipleOf];
    node.exclusiveMaximum = [self parseBooleanValueFromSchema:numberSchema usingKey:kTWTJSONSchemaKeywordExclusiveMaximum];
    node.exclusiveMinimum = [self parseBooleanValueFromSchema:numberSchema usingKey:kTWTJSONSchemaKeywordExclusiveMinimum];

    return node;
}


- (TWTJSONSchemaStringASTNode *)parseStringTypeSchema:(NSDictionary *)stringSchema
{
    TWTJSONSchemaStringASTNode *node = [[TWTJSONSchemaStringASTNode alloc] init];
    node = (TWTJSONSchemaStringASTNode *)[self parseCommonKeywordsFromSchema:stringSchema toNode:node];

    node.maximumLength = [self parseUnsignedIntegerFromSchema:stringSchema usingKey:kTWTJSONSchemaKeywordMaxLength];
    node.minimumLength = [self parseUnsignedIntegerFromSchema:stringSchema usingKey:kTWTJSONSchemaKeywordMinLength];
    node.pattern = [self parseStringFromSchema:stringSchema usingKey:kTWTJSONSchemaKeywordPattern]; // note this has no validation of the regular expression

    return node;
}


- (TWTJSONSchemaObjectASTNode *)parseObjectTypeSchema:(NSDictionary *)objectSchema
{
    TWTJSONSchemaObjectASTNode *node = [[TWTJSONSchemaObjectASTNode alloc] init];
    node = (TWTJSONSchemaObjectASTNode *)[self parseCommonKeywordsFromSchema:objectSchema toNode:node];

    node.maximumPropertyCount = [self parseUnsignedIntegerFromSchema:objectSchema usingKey:kTWTJSONSchemaKeywordMaxProperties];
    node.minimumPropertyCount = [self parseUnsignedIntegerFromSchema:objectSchema usingKey:kTWTJSONSchemaKeywordMinProperties];
    NSArray *requiredNames = [self parseArrayOfStringsFromSchema:objectSchema usingKey:kTWTJSONSchemaKeywordRequired];
    node.requiredPropertyNames = requiredNames ? [NSSet setWithArray:requiredNames] : nil;
    node.propertySchemas = [self parseDictionaryOfSchemasFromSchema:objectSchema usingKey:kTWTJSONSchemaKeywordProperties nodeClass:[TWTJSONSchemaNamedPropertyASTNode class]];
    node.patternPropertySchemas = [self parseDictionaryOfSchemasFromSchema:objectSchema usingKey:kTWTJSONSchemaKeywordPatternProperties nodeClass:[TWTJSONSchemaPatternPropertyASTNode class]];
    node.propertyDependencies = [self parseDictionaryOfSchemasFromSchema:objectSchema usingKey:kTWTJSONSchemaKeywordDependencies nodeClass:[TWTJSONSchemaDepedencyASTNode class]];
    node.additionalPropertiesNode = [self parseAdditionalItemsOrPropertiesWithSchema:objectSchema usingKey:kTWTJSONSchemaKeywordAdditionalProperties];

    return node;
}


#pragma mark - Keyword and value parser methods

- (TWTJSONSchemaASTNode *)parseCommonKeywordsFromSchema:(NSDictionary *)schema toNode:(TWTJSONSchemaASTNode *)node
{
    node.schemaTitle = [self parseStringFromSchema:schema usingKey:kTWTJSONSchemaKeywordTitle];
    node.schemaDescription = [self parseStringFromSchema:schema usingKey:kTWTJSONSchemaKeywordDescription];
    NSArray *validValues = [self parseArrayFromSchema:schema usingKey:kTWTJSONSchemaKeywordEnum];
    node.validValues = validValues ? [NSSet setWithArray:validValues] : nil;
    node.andSchemas = [self parseArrayOfSchemasFromSchema:schema usingKey:kTWTJSONSchemaKeywordAllOf];
    node.orSchemas = [self parseArrayOfSchemasFromSchema:schema usingKey:kTWTJSONSchemaKeywordAnyOf];
    node.exactlyOneOfSchemas = [self parseArrayOfSchemasFromSchema:schema usingKey:kTWTJSONSchemaKeywordOneOf];
    node.notSchema = [self parseSchemaFromSchema:schema usingKey:kTWTJSONSchemaKeywordNot];
    node.definitions = [self parseDictionaryFromSchema:schema usingKey:kTWTJSONSchemaKeywordDefinitions];

    return node;
}


- (NSSet *)parseTypeKeywordFromSchema:(NSDictionary *)schema
{
    id typeValue = schema[kTWTJSONSchemaKeywordType];

    if (typeValue == nil) {
        return nil;
    }

    // assumes that array, object, string, number, and integer types have already been accounted for, so type is either:
    // A) one of these strings: "boolean", "null", "any"
    // B) an array of valid type strings
    // C) invalid wrt the JSON Schema definition of the type keyword

    [self push:kTWTJSONSchemaKeywordType];

    if ([[NSSet setWithObjects:kTWTJSONSchemaTypeKeywordAny, kTWTJSONSchemaTypeKeywordBoolean, kTWTJSONSchemaTypeKeywordNull, nil] containsObject:typeValue]) {
        [self pop];
        return [NSSet setWithObject:typeValue];
    }

    if ([typeValue isKindOfClass:[NSArray class]]) {
        if ([typeValue count] >= 1) {
            BOOL isValidJSONType = YES;
            for (NSString *typeString in typeValue) {
                isValidJSONType = [[self validJSONTypeKeywords] containsObject:typeString];
                if (!isValidJSONType) {
                    [self throwExceptionWithSelector:_cmd];
                    return nil;
                }
            }
            [self pop];
            return [NSSet setWithArray:typeValue];
        }
    }

    [self throwExceptionWithSelector:_cmd];
    return nil;
}


- (BOOL)parseBooleanValueFromSchema:(NSDictionary *)schema usingKey:(NSString *)key
{
    [self push:key];
    NSNumber *booleanObject = schema[key];

    if ([booleanObject isKindOfClass:[NSNumber class]] || booleanObject == nil) {
        [self pop];
        return [booleanObject boolValue];
    }

    [self throwExceptionWithSelector:_cmd];
    return NO;
}


- (NSString *)parseStringFromSchema:(NSDictionary *)schema usingKey:(NSString *)key
{
    [self push:key];
    NSString *string = schema[key];

    if ([string isKindOfClass:[NSString class]] || string == nil) {
        [self pop];
        return string;
    }

    [self throwExceptionWithSelector:_cmd];
    return nil;
}


- (NSNumber *)parseNumberFromSchema:(NSDictionary *)schema usingKey:(NSString *)key
{
    [self push:key];
    NSNumber *number = schema[key];
    if ([number isKindOfClass:[NSNumber class]] || number == nil) {
        [self pop];
        return number;
    }

    [self throwExceptionWithSelector:_cmd];
    return nil;
}


- (NSNumber *)parseUnsignedIntegerFromSchema:(NSDictionary *)schema usingKey:(NSString *)key
{
    NSNumber *number = schema[key];
    if (number == nil) {
        return nil;
    }

    [self push:key];
    double numberValue = [number doubleValue];
    BOOL isUnsignedInteger = numberValue >= 0 && numberValue == trunc(numberValue);

    if (isUnsignedInteger && [number isKindOfClass:[NSNumber class]]) {
        [self pop];
        return number;
    }

    [self throwExceptionWithSelector:_cmd];
    return nil;
}


- (NSDictionary *)parseDictionaryFromSchema:(NSDictionary *)schema usingKey:(NSString *)key
{
    [self push:key];
    NSDictionary *dictionary = schema[key];
    if ([dictionary isKindOfClass:[NSDictionary class]] || dictionary == nil) {
        [self pop];
        return dictionary;
    }

    [self throwExceptionWithSelector:_cmd];
    return nil;
}


- (NSArray *)parseArrayFromSchema:(NSDictionary *)schema usingKey:(NSString *)key
{
    NSArray *array = schema[key];
    if (array == nil) {
        return nil;
    }

    [self push:key];
    if ([array isKindOfClass:[NSArray class]]) {
        if (array.count >= 1) {
            [self pop];
            return array;
        }
    }

    [self throwExceptionWithSelector:_cmd];
    return nil;
}


- (NSArray *)parseArrayOfStringsFromSchema:(NSDictionary *)schema usingKey:(NSString *)key
{
    NSArray *array = schema[key];
    if (array == nil) {
        return nil;
    }

    [self push:key];
    if ([array isKindOfClass:[NSArray class]]) {
        for (NSString *string in array) {
            if (![string isKindOfClass:[NSString class]]) {
                [self throwExceptionWithSelector:_cmd];
                return nil;
            }
        }
        [self pop];
        return array;
    }

    [self throwExceptionWithSelector:_cmd];
    return nil;
}


- (NSArray *)parseArrayOfSchemasFromSchema:(NSDictionary *)schema usingKey:(NSString *)key
{
    NSArray *array = schema[key];
    if (array == nil) {
        return nil;
    }

    [self push:key];
    if ([array isKindOfClass:[NSArray class]]) {
        if (array.count >= 1) {
            NSMutableArray *schemaNodes = [[NSMutableArray alloc] init];
            for (NSDictionary *itemSchema in array) {
                [schemaNodes addObject:[self parseSchema:itemSchema]];
            }
            [self pop];
            return schemaNodes;
        }
    }

    [self throwExceptionWithSelector:_cmd];
    return nil;
}


- (NSArray *)parseDictionaryOfSchemasFromSchema:(NSDictionary *)schema usingKey:(NSString *)key nodeClass:(Class)className
{
    NSParameterAssert([className isSubclassOfClass:[TWTJSONSchemaKeyValuePairASTNode class]]);

    NSDictionary *nestedSchema = schema[key];
    if (nestedSchema == nil) {
        return nil;
    }

    [self push:key];
    if ([nestedSchema isKindOfClass:[NSDictionary class]]) {
        NSMutableArray *propertyNodes = [[NSMutableArray alloc] init];

        [nestedSchema enumerateKeysAndObjectsUsingBlock:^(id propertyKey, id object, BOOL *stop) {
            [self push:propertyKey];
            if (![propertyKey isKindOfClass:[NSString class]]) {
                [self throwExceptionWithSelector:_cmd];
                *stop = YES;
            }

            TWTJSONSchemaASTNode *valueNode = [self parseSchema:object];
            TWTJSONSchemaKeyValuePairASTNode *propertyNode = [[className alloc] initWithKey:propertyKey value:valueNode];
            [propertyNodes addObject:propertyNode];
            [self pop];
        }];
        [self pop];
        return propertyNodes;
    }

    [self throwExceptionWithSelector:_cmd];
    return nil;
}


- (TWTJSONSchemaASTNode *)parseAdditionalItemsOrPropertiesWithSchema:(NSDictionary *)schema usingKey:(NSString *)key
{
    NSParameterAssert([key isEqualToString:kTWTJSONSchemaKeywordAdditionalItems] || [key isEqualToString:kTWTJSONSchemaKeywordAdditionalProperties]);

    id value = schema[key];
    if (value == nil) {
        return nil;
    }

    [self push:key];
    if ([value isKindOfClass:[NSNumber class]]) {
        [self pop];
        return [[TWTJSONSchemaBooleanValueASTNode alloc] initWithValue:[value boolValue]];
    }

    if ([value isKindOfClass:[NSDictionary class]]) {
        TWTJSONSchemaASTNode *node = [self parseSchema:value];
        [self pop];
        return node;
    }

    [self throwExceptionWithSelector:_cmd];
    return nil;
}


- (TWTJSONSchemaASTNode *)parseSchemaFromSchema:(NSDictionary *)schema usingKey:(NSString *)key
{
    NSDictionary *nestedSchema = schema[key];
    if (nestedSchema == nil) {
        return nil;
    }

    [self push:key];
    TWTJSONSchemaASTNode *node = [self parseSchema:nestedSchema];
    [self pop];
    return node;
}


#pragma mark - Helper methods

- (void)throwExceptionWithSelector:(SEL)selector
{
    NSString *pathString = [@"/" stringByAppendingString:[self.pathStack componentsJoinedByString:@"/"]];
    NSError *error = [[NSError alloc] initWithDomain:@"Input schema does not match rules defined by JSON Schema Draft v4"
                                                code:0
                                            userInfo:@{ kTWTJSONErrorInfoPathKey : pathString,
                                                        kTWTJSONErrorInfoSelectorKey : NSStringFromSelector(selector) }];
    NSLog(@"FAILING -- \n%@\n%@", pathString, NSStringFromSelector(selector));
    
    [[NSException exceptionWithName:@"Invalid JSON Schema" reason:nil userInfo:@{ kTWTJSONExceptionErrorKey : error }] raise];
}


- (NSSet *)validJSONTypeKeywords
{
    static NSSet *types = nil;
    if (!types) {
        types = [NSSet setWithObjects:kTWTJSONSchemaTypeKeywordAny,
                 kTWTJSONSchemaTypeKeywordArray,
                 kTWTJSONSchemaTypeKeywordBoolean,
                 kTWTJSONSchemaTypeKeywordInteger,
                 kTWTJSONSchemaTypeKeywordNull,
                 kTWTJSONSchemaTypeKeywordNumber,
                 kTWTJSONSchemaTypeKeywordObject,
                 kTWTJSONSchemaTypeKeywordString,
                 nil];
    }
    return types;
}


- (void)push:(id)object
{
    [self.pathStack addObject:object];
}


- (void)pop
{
    [self.pathStack removeLastObject];
}

@end
