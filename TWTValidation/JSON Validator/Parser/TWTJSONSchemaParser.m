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

#import <TWTValidation/TWTJSONSchemaParser.h>

#import <TWTValidation/TWTJSONSchemaArrayASTNode.h>
#import <TWTValidation/TWTJSONSchemaASTNode.h>
#import <TWTValidation/TWTJSONSchemaBooleanValueASTNode.h>
#import <TWTValidation/TWTJSONSchemaDepedencyASTNode.h>
#import <TWTValidation/TWTJSONSchemaGenericASTNode.h>
#import <TWTValidation/TWTJSONSchemaKeywordConstants.h>
#import <TWTValidation/TWTJSONSchemaNamedPropertyASTNode.h>
#import <TWTValidation/TWTJSONSchemaNumberASTNode.h>
#import <TWTValidation/TWTJSONSchemaObjectASTNode.h>
#import <TWTValidation/TWTJSONSchemaPatternPropertyASTNode.h>
#import <TWTValidation/TWTJSONSchemaStringASTNode.h>
#import <TWTValidation/TWTJSONSchemaTopLevelASTNode.h>
#import <TWTValidation/TWTJSONSchemaValidTypesConstants.h>


static NSString *const kTWTJSONExceptionErrorKey = @"error";
NSString *const kTWTJSONSchemaParserErrorInfoDomainKey = @"TWTJSONSchemaParserErrorDomain";
NSString *const kTWTJSONSchemaParserErrorInfoPathKey = @"path";
NSString *const kTWTJSONSchemaParserErrorInfoInvalidObjectKey = @"object";


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
    [self checkObject:self.JSONSchema[kTWTJSONSchemaKeywordSchema] isOneOf:[NSSet setWithObject:kTWTJSONSchemaKeywordDraft4Path]];

    TWTJSONSchemaTopLevelASTNode *topLevelNode = [[TWTJSONSchemaTopLevelASTNode alloc] init];
    topLevelNode.schemaPath = self.JSONSchema[kTWTJSONSchemaKeywordSchema];

    @try {
        topLevelNode.schema = [self parseSchema:self.JSONSchema];
    } @catch (NSException *exception) {
        NSError *outError = exception.userInfo[kTWTJSONExceptionErrorKey];
        if (errorPointer) {
            *errorPointer = outError;
            return nil;
        }
    }

    return topLevelNode;
}


# pragma mark - Schema parser methods
// starting point for all schema nodes (except top level)
// directs the schema toward the appropriate parser method based on the value of "type"
// type-specific parser methods are responsible for the entire process of creating a node from a schema, including:
// 1) initializing the appropriate ASTNode 2) setting the type (if its not built into that ASTNode class) 3) parsing all general and type-specific properties 4) returning a completed node
- (TWTJSONSchemaASTNode *)parseSchema:(NSDictionary *)schema
{
    NSParameterAssert(schema);

    [self checkObject:schema isOfClass:[NSDictionary class] allowNil:NO];

    if ([schema[kTWTJSONSchemaKeywordType] isKindOfClass:[NSString class]]) {
        NSString *instanceType = schema[kTWTJSONSchemaKeywordType];

        static NSDictionary *typeSelectors = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            typeSelectors = @{ kTWTJSONSchemaTypeKeywordAny : @"parseGenericTypeSchema:",
                               kTWTJSONSchemaTypeKeywordArray : @"parseArrayTypeSchema:",
                               kTWTJSONSchemaTypeKeywordBoolean : @"parseGenericTypeSchema:",
                               kTWTJSONSchemaTypeKeywordInteger : @"parseNumberTypeSchema:",
                               kTWTJSONSchemaTypeKeywordNull : @"parseGenericTypeSchema:",
                               kTWTJSONSchemaTypeKeywordNumber : @"parseNumberTypeSchema:",
                               kTWTJSONSchemaTypeKeywordObject : @"parseObjectTypeSchema:",
                               kTWTJSONSchemaTypeKeywordString : @"parseStringTypeSchema:" };
        });

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

    node.maximumItemCount = [self parseUnsignedIntegerFromSchema:arraySchema forKey:kTWTJSONSchemaKeywordMaxItems];
    node.minimumItemCount = [self parseUnsignedIntegerFromSchema:arraySchema forKey:kTWTJSONSchemaKeywordMinItems];
    node.requiresUniqueItems = [self parseBooleanValueFromSchema:arraySchema forKey:kTWTJSONSchemaKeywordUniqueItems valueIfNotPresent:NO];


    // "Items" must be JSON schema object or array of JSON schema objects
    if ([arraySchema[kTWTJSONSchemaKeywordItems] isKindOfClass:[NSDictionary class]]) {
        node.itemSchemas = @[ [self parseSchemaFromSchema:arraySchema forKey:kTWTJSONSchemaKeywordItems] ];
        // additional items is meaningless if items is a single schema
    } else {
        node.itemSchemas = [self parseArrayOfSchemasFromSchema:arraySchema forKey:kTWTJSONSchemaKeywordItems];
        node.additionalItemsNode = [self parseAdditionalItemsOrPropertiesWithSchema:arraySchema forKey:kTWTJSONSchemaKeywordAdditionalItems];
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
    node.minimum = [self parseNumberFromSchema:numberSchema forKey:kTWTJSONSchemaKeywordMinimum];
    node.maximum = [self parseNumberFromSchema:numberSchema forKey:kTWTJSONSchemaKeywordMaximum];
    node.multipleOf = [self parsePositiveNumberFromSchema:numberSchema forKey:kTWTJSONSchemaKeywordMultipleOf];
    if (node.maximum) {
        node.exclusiveMaximum = [self parseBooleanValueFromSchema:numberSchema forKey:kTWTJSONSchemaKeywordExclusiveMaximum valueIfNotPresent:NO];
    }
    if (node.minimum) {
        node.exclusiveMinimum = [self parseBooleanValueFromSchema:numberSchema forKey:kTWTJSONSchemaKeywordExclusiveMinimum valueIfNotPresent:NO];
    }

    return node;
}


- (TWTJSONSchemaStringASTNode *)parseStringTypeSchema:(NSDictionary *)stringSchema
{
    TWTJSONSchemaStringASTNode *node = [[TWTJSONSchemaStringASTNode alloc] init];
    node = (TWTJSONSchemaStringASTNode *)[self parseCommonKeywordsFromSchema:stringSchema toNode:node];

    node.maximumLength = [self parseUnsignedIntegerFromSchema:stringSchema forKey:kTWTJSONSchemaKeywordMaxLength];
    node.minimumLength = [self parseUnsignedIntegerFromSchema:stringSchema forKey:kTWTJSONSchemaKeywordMinLength];
    node.pattern = [self parseStringFromSchema:stringSchema forKey:kTWTJSONSchemaKeywordPattern]; // Does not check validity of regular expression, because definition is: "MUST be a string. This string SHOULD be a valid Regular Expression."

    return node;
}


- (TWTJSONSchemaObjectASTNode *)parseObjectTypeSchema:(NSDictionary *)objectSchema
{
    TWTJSONSchemaObjectASTNode *node = [[TWTJSONSchemaObjectASTNode alloc] init];
    node = (TWTJSONSchemaObjectASTNode *)[self parseCommonKeywordsFromSchema:objectSchema toNode:node];

    node.maximumPropertyCount = [self parseUnsignedIntegerFromSchema:objectSchema forKey:kTWTJSONSchemaKeywordMaxProperties];
    node.minimumPropertyCount = [self parseUnsignedIntegerFromSchema:objectSchema forKey:kTWTJSONSchemaKeywordMinProperties];
    NSArray *requiredNames = [self parseArrayOfUnqiueStringsFromSchema:objectSchema forKey:kTWTJSONSchemaKeywordRequired];
    node.requiredPropertyNames = requiredNames ? [NSSet setWithArray:requiredNames] : nil;
    node.propertySchemas = [self parseDictionaryOfSchemasFromSchema:objectSchema forKey:kTWTJSONSchemaKeywordProperties nodeClass:[TWTJSONSchemaNamedPropertyASTNode class]];
    node.patternPropertySchemas = [self parseDictionaryOfSchemasFromSchema:objectSchema forKey:kTWTJSONSchemaKeywordPatternProperties nodeClass:[TWTJSONSchemaPatternPropertyASTNode class]];
    node.additionalPropertiesNode = [self parseAdditionalItemsOrPropertiesWithSchema:objectSchema forKey:kTWTJSONSchemaKeywordAdditionalProperties];
    node.propertyDependencies = [self parseDependenciesWithSchema:objectSchema];

    return node;
}


#pragma mark - Keyword and value parser methods

- (TWTJSONSchemaASTNode *)parseCommonKeywordsFromSchema:(NSDictionary *)schema toNode:(TWTJSONSchemaASTNode *)node
{
    node.schemaTitle = [self parseStringFromSchema:schema forKey:kTWTJSONSchemaKeywordTitle];
    node.schemaDescription = [self parseStringFromSchema:schema forKey:kTWTJSONSchemaKeywordDescription];
    NSArray *validValues = [self parseArrayFromSchema:schema forKey:kTWTJSONSchemaKeywordEnum];
    node.validValues = validValues ? [NSSet setWithArray:validValues] : nil;
    node.andSchemas = [self parseArrayOfSchemasFromSchema:schema forKey:kTWTJSONSchemaKeywordAllOf];
    node.orSchemas = [self parseArrayOfSchemasFromSchema:schema forKey:kTWTJSONSchemaKeywordAnyOf];
    node.exactlyOneOfSchemas = [self parseArrayOfSchemasFromSchema:schema forKey:kTWTJSONSchemaKeywordOneOf];
    node.notSchema = [self parseSchemaFromSchema:schema forKey:kTWTJSONSchemaKeywordNot];
    node.definitions = [self parseDictionaryFromSchema:schema forKey:kTWTJSONSchemaKeywordDefinitions];

    return node;
}

// Keyword: type
// Example: { "type" : "boolean" }
//          { "type" : [ "string", "object", "null" ] }
- (NSSet *)parseTypeKeywordFromSchema:(NSDictionary *)schema
{
    id typeValue = schema[kTWTJSONSchemaKeywordType];

    if (!typeValue) {
        return nil;
    }

    // Relies on parseSchema: having filtered out schemas with type array, object, string, number, or integer. Thus, type is either:
    // A) One of these strings: "boolean", "null", "any"
    // B) An array of valid type strings
    // C) Invalid wrt the JSON Schema definition of the type keyword

    [self pushPathComponent:kTWTJSONSchemaKeywordType];

    static NSSet *allowedTypes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        allowedTypes = [NSSet setWithObjects:kTWTJSONSchemaTypeKeywordAny, kTWTJSONSchemaTypeKeywordBoolean, kTWTJSONSchemaTypeKeywordNull, nil];
    });

    if ([allowedTypes containsObject:typeValue]) {
        [self popPathComponent];
        return [NSSet setWithObject:typeValue];
    }

    [self checkObjectIsArrayWithAtLeastOneItem:typeValue allowNil:NO];

    [typeValue enumerateObjectsUsingBlock:^(NSString *typeString, NSUInteger index, BOOL *stop) {
        [self pushPathComponent:@(index)];
        [self checkObject:typeString isOneOf:[self validJSONTypeKeywords]];
        [self popPathComponent];
    }];

    [self popPathComponent];
    return [NSSet setWithArray:typeValue];
}


// Keywords: exclusiveMinimum & Maximum, uniqueItems
- (BOOL)parseBooleanValueFromSchema:(NSDictionary *)schema forKey:(NSString *)key valueIfNotPresent:(BOOL)defaultValue
{
    [self pushPathComponent:key];
    NSNumber *booleanObject = schema[key];
    [self checkObject:booleanObject isOfClass:[NSNumber class] allowNil:YES];
    [self popPathComponent];
    return booleanObject ? [booleanObject boolValue] : defaultValue;
}


// Keywords: pattern
- (NSString *)parseStringFromSchema:(NSDictionary *)schema forKey:(NSString *)key
{
    [self pushPathComponent:key];
    NSString *string = schema[key];
    [self checkObject:string isOfClass:[NSString class] allowNil:YES];
    [self popPathComponent];
    return string;
}


// Keywords: minimum, maximum
- (NSNumber *)parseNumberFromSchema:(NSDictionary *)schema forKey:(NSString *)key
{
    [self pushPathComponent:key];
    NSNumber *number = schema[key];
    [self checkObject:number isOfClass:[NSNumber class] allowNil:YES];
    [self popPathComponent];
    return number;
}


// Keywords: multipleOf
- (NSNumber *)parsePositiveNumberFromSchema:(NSDictionary *)schema forKey:(NSString *)key
{
    NSNumber *number = schema[key];
    if (!number) {
        return nil;
    }

    [self pushPathComponent:key];
    [self checkObject:number isOfClass:[NSNumber class] allowNil:YES];
    if ([number doubleValue] <= 0) {
        NSString *reason = [NSString stringWithFormat:@"Invalid value for key %@. Expected number greater than zero.", key];
        [self failWithErrorCode:TWTJSONSchemaParserErrorCodeInvalidValue reason:reason object:number];
    }

    [self popPathComponent];
    return number;
}


// Keywords: min & maxLength, min & maxItems, min & maxProperties
- (NSNumber *)parseUnsignedIntegerFromSchema:(NSDictionary *)schema forKey:(NSString *)key
{
    [self pushPathComponent:key];
    NSNumber *number = schema[key];
    [self checkObject:number isOfClass:[NSNumber class] allowNil:YES];

    if (number) {
        double numberValue = [number doubleValue];
        BOOL isUnsignedInteger = numberValue >= 0 && numberValue == trunc(numberValue);
        if (!isUnsignedInteger) {
            NSString *reason = [NSString stringWithFormat:@"Invalid value for key %@. Expected unsigned integer.", key];
            [self failWithErrorCode:TWTJSONSchemaParserErrorCodeInvalidValue reason:reason object:number];
        }
    }

    [self popPathComponent];
    return number;
}


// Keywords: definitions
- (NSDictionary *)parseDictionaryFromSchema:(NSDictionary *)schema forKey:(NSString *)key
{
    [self pushPathComponent:key];
    NSDictionary *dictionary = schema[key];
    [self checkObject:dictionary isOfClass:[NSDictionary class] allowNil:YES];
    [self popPathComponent];
    return dictionary;
}


// Keywords: enum
- (NSArray *)parseArrayFromSchema:(NSDictionary *)schema forKey:(NSString *)key
{
    [self pushPathComponent:key];
    NSArray *array = schema[key];
    [self checkObjectIsArrayWithAtLeastOneItem:array allowNil:YES];
    [self popPathComponent];
    return array;
}


// Keyword: required
// Example: { "required" : [ "name" ] }
- (NSArray *)parseArrayOfUnqiueStringsFromSchema:(NSDictionary *)schema forKey:(NSString *)key
{
    [self pushPathComponent:key];
    NSArray *array = schema[key];
    [self checkObjectIsArrayWithAtLeastOneItem:array allowNil:YES];

    NSMutableSet *uniqueStrings = [[NSMutableSet alloc] init];

    [array enumerateObjectsUsingBlock:^(NSString *string, NSUInteger index, BOOL *stop) {
        [self pushPathComponent:@(index)];
        [self checkObject:string isOfClass:[NSString class] allowNil:NO];
        if ([uniqueStrings containsObject:string]) {
            NSString *reason = [NSString stringWithFormat:@"Invalid value for key %@. Expected array of unique strings.", key];
            [self failWithErrorCode:TWTJSONSchemaParserErrorCodeRequiresUniqueness reason:reason object:string];
        }

        [uniqueStrings addObject:string];
        [self popPathComponent];
    }];

    [self popPathComponent];
    return array;
}


// Keyword: items, anyOf, allOf, oneOf
// Example: { "items" : [ {}, {} ] }
/*
 { "anyOf": [
 { "type": "string", "maxLength": 5 },
 { "type": "number", "minimum": 0 } ]
 }
 */
- (NSArray *)parseArrayOfSchemasFromSchema:(NSDictionary *)schema forKey:(NSString *)key
{
    [self pushPathComponent:key];
    NSArray *array = schema[key];
    [self checkObjectIsArrayWithAtLeastOneItem:array allowNil:YES];

    NSMutableArray *schemaNodes = [[NSMutableArray alloc] init];
    [array enumerateObjectsUsingBlock:^(NSDictionary *itemSchema , NSUInteger index, BOOL *stop) {
        [self pushPathComponent:@(index)];
        [schemaNodes addObject:[self parseSchema:itemSchema]];
        [self popPathComponent];
    }];

    [self popPathComponent];
    return schemaNodes;
}


// Keyword: properties, patternProperties
// Example: { "properties" : { "hello" : {}, "world" : {} } }
//          { "patternProperties" : { "^h" : {}, "r" : {} } }
- (NSArray *)parseDictionaryOfSchemasFromSchema:(NSDictionary *)schema forKey:(NSString *)key nodeClass:(Class)className
{
    NSParameterAssert([className isSubclassOfClass:[TWTJSONSchemaKeyValuePairASTNode class]]);

    [self pushPathComponent:key];
    NSDictionary *nestedSchema = schema[key];
    [self checkObject:nestedSchema isOfClass:[NSDictionary class] allowNil:YES];

    NSMutableArray *propertyNodes = [[NSMutableArray alloc] init];
    [nestedSchema enumerateKeysAndObjectsUsingBlock:^(id propertyKey, id object, BOOL *stop) {
        [self pushPathComponent:propertyKey];

        [self checkObject:propertyKey isOfClass:[NSString class] allowNil:NO]; // Defined by JSON syntax, not schema definition

        TWTJSONSchemaASTNode *valueNode = [self parseSchema:object];
        TWTJSONSchemaKeyValuePairASTNode *propertyNode = [[className alloc] initWithKey:propertyKey valueSchema:valueNode];
        [propertyNodes addObject:propertyNode];
        [self popPathComponent];
    }];

    [self popPathComponent];
    return propertyNodes;
}


// Keywords: additionalItems, additionalProperties ONLY
// Example boolean: { "additionalItems" : false }
// Example dictionary: { "additionalProperties" : { "type" : "string" } }
// Note if either keyword is absent, it may be considered present with an empty schema, which is equivalent to "true"
- (TWTJSONSchemaASTNode *)parseAdditionalItemsOrPropertiesWithSchema:(NSDictionary *)schema forKey:(NSString *)key
{
    NSParameterAssert([key isEqualToString:kTWTJSONSchemaKeywordAdditionalItems] || [key isEqualToString:kTWTJSONSchemaKeywordAdditionalProperties]);

    id value = schema[key];
    if (!value) {
        return [[TWTJSONSchemaBooleanValueASTNode alloc] initWithValue:YES];
    }

    [self pushPathComponent:key];
    if ([value isKindOfClass:[NSNumber class]]) {
        [self popPathComponent];
        return [[TWTJSONSchemaBooleanValueASTNode alloc] initWithValue:[value boolValue]];
    }

    if ([value isKindOfClass:[NSDictionary class]]) {
        TWTJSONSchemaASTNode *node = [self parseSchema:value];
        [self popPathComponent];
        return node;
    }

    NSString *reason = [NSString stringWithFormat:@"Invalid value for key %@. Expected boolean or schema.", key];
    [self failWithErrorCode:TWTJSONSchemaParserErrorCodeInvalidClass reason:reason object:value];
    return nil;
}


/* Keyword: dependencies
 Showing example of 1) property dependency 2) schema dependency; note these are equivalent for validation
 1) Property dependency, i.e., "dependencies" object's value is an array
 { "type": "object",
 "properties": {
 "name": { "type": "string" },
 "credit_card": { "type": "number" },
 "billing_address": { "type": "string" } },
 "required": ["name"],
 "dependencies": {
 "credit_card": ["billing_address"] }
 }

 2) Schema dependency, i.e., "dependencies" object's value is a schema
 { "type": "object",
 "properties": {
 "name": { "type": "string" },
 "credit_card": { "type": "number" } },
 "required": ["name"],
 "dependencies": {
 "credit_card": {
 "properties": {
 "billing_address": { "type": "string" }
 },
 "required": ["billing_address"] }
 }
 }
 */
- (NSArray *)parseDependenciesWithSchema:(NSDictionary *)schema
{
    NSDictionary *dependencies = schema[kTWTJSONSchemaKeywordDependencies];
    if (!dependencies) {
        return nil;
    }
    [self pushPathComponent:kTWTJSONSchemaKeywordDependencies];
    [self checkObject:dependencies isOfClass:[NSDictionary class] allowNil:NO];

    NSMutableArray *dependencyNodes = [[NSMutableArray alloc] init];
    [dependencies enumerateKeysAndObjectsUsingBlock:^(NSString *key, id object, BOOL *stop) {
        [self pushPathComponent:key];

        [self checkObject:key isOfClass:[NSString class] allowNil:NO];

        if ([object isKindOfClass:[NSDictionary class]]) {
            TWTJSONSchemaDepedencyASTNode *node = [[TWTJSONSchemaDepedencyASTNode alloc] initWithKey:key valueSchema:[self parseSchema:object]];
            [dependencyNodes addObject:node];
        } else {
            NSArray *propertySet = [self parseArrayOfUnqiueStringsFromSchema:dependencies forKey:key];
            TWTJSONSchemaDepedencyASTNode *node = [[TWTJSONSchemaDepedencyASTNode alloc] init];
            node.key = key;
            node.propertySet = propertySet;
            [dependencyNodes addObject:node];
        }

        [self popPathComponent];

    }];

    [self popPathComponent];
    return dependencyNodes;
}


// Keyword: items, not
// Example: { "items" : {} }
- (TWTJSONSchemaASTNode *)parseSchemaFromSchema:(NSDictionary *)schema forKey:(NSString *)key
{
    NSDictionary *nestedSchema = schema[key];
    if (!nestedSchema) {
        return nil;
    }

    [self pushPathComponent:key];
    TWTJSONSchemaASTNode *node = [self parseSchema:nestedSchema];
    [self popPathComponent];
    return node;
}


#pragma mark - Helper methods

- (void)checkObject:(id)object isOfClass:(Class)className allowNil:(BOOL)allowNil
{

    if (allowNil && !object) {
        return;
    }

    if ([object isKindOfClass:className]) {
        return;
    }

    NSString *reason = [NSString stringWithFormat:@"Invalid type encountered. Expected object of class %@.", NSStringFromClass(className)];
    [self failWithErrorCode:TWTJSONSchemaParserErrorCodeInvalidClass reason:reason object:object];
}


- (void)checkObjectIsArrayWithAtLeastOneItem:(id)object allowNil:(BOOL)allowNil
{
    [self checkObject:object isOfClass:[NSArray class] allowNil:allowNil];
    if (!object || [object count] >= 1) {
        return;
    }

    NSString *reason = @"Expected array with at least one item.";
    [self failWithErrorCode:TWTJSONSchemaParserErrorCodeRequiresAtLeastOneItem reason:reason object:object];
}


- (void)checkObject:(id)object isOneOf:(NSSet *)validValues
{
    if ([validValues containsObject:object]) {
        return;
    }

    NSString *reason = [NSString stringWithFormat:@"Invalid valid encountered. Expected one of %@", validValues];
    [self failWithErrorCode:TWTJSONSchemaParserErrorCodeInvalidValue reason:reason object:object];
}


- (void)failWithErrorCode:(NSUInteger)code reason:(NSString *)reason object:(id)object
{
    NSString *pathString = [@"/" stringByAppendingString:[self.pathStack componentsJoinedByString:@"/"]];
    object = object ?: [NSNull null];
    reason = reason ?: @"";

    NSError *error = [NSError errorWithDomain:kTWTJSONSchemaParserErrorInfoDomainKey code:code userInfo:@{ kTWTJSONSchemaParserErrorInfoPathKey : pathString,
                                                                                                           kTWTJSONSchemaParserErrorInfoInvalidObjectKey : object,
                                                                                                           NSLocalizedFailureReasonErrorKey : reason }];

    [[NSException exceptionWithName:@"Invalid JSON Schema"
                             reason:nil
                           userInfo:@{ kTWTJSONExceptionErrorKey : error }] raise];
}


- (NSSet *)validJSONTypeKeywords
{
    static NSSet *types = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        types = [NSSet setWithObjects:kTWTJSONSchemaTypeKeywordAny,
                 kTWTJSONSchemaTypeKeywordArray,
                 kTWTJSONSchemaTypeKeywordBoolean,
                 kTWTJSONSchemaTypeKeywordInteger,
                 kTWTJSONSchemaTypeKeywordNull,
                 kTWTJSONSchemaTypeKeywordNumber,
                 kTWTJSONSchemaTypeKeywordObject,
                 kTWTJSONSchemaTypeKeywordString,
                 nil];
    });

    return types;
}


- (void)pushPathComponent:(id)object
{
    [self.pathStack addObject:object];
}


- (void)popPathComponent
{
    [self.pathStack removeLastObject];
}

@end
