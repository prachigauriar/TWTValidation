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
//

#import <TWTValidation/TWTJSONSchemaParser.h>

#import <TWTValidation/TWTJSONSchemaASTCommon.h>
#import <TWTValidation/TWTJSONSchemaKeywordConstants.h>
#import <TWTValidation/TWTValidationErrors.h>


static NSString *const TWTJSONExceptionErrorKey = @"error";


@interface TWTJSONSchemaParser ()

@property (nonatomic, copy, readonly) NSDictionary *JSONSchema;
@property (nonatomic, strong, readonly) NSMutableArray *pathStack;
@property (nonatomic, strong) NSMutableArray *warnings;

- (void)warnWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);
- (void)failIfObject:(id)object isNotKindOfOneOfClasses:(Class)validClass1, ... NS_REQUIRES_NIL_TERMINATION;
- (void)failWithErrorCode:(NSUInteger)code object:(id)object format:(NSString *)format, ... NS_FORMAT_FUNCTION(3, 4);

@end


@implementation TWTJSONSchemaParser

- (instancetype)initWithJSONSchema:(NSDictionary *)topLevelSchema
{
    NSParameterAssert(topLevelSchema);
    NSParameterAssert([NSJSONSerialization isValidJSONObject:topLevelSchema]);

    self = [super init];
    if (self) {
        _JSONSchema = [topLevelSchema copy];
        _pathStack = [[NSMutableArray alloc] init];
        _warnings = [[NSMutableArray alloc] init];
    }
    return self;
}


- (instancetype)init
{
    return [self initWithJSONSchema:nil];
}


- (TWTJSONSchemaTopLevelASTNode *)parseWithError:(NSError *__autoreleasing *)outError warnings:(NSArray *__autoreleasing *)outWarnings
{
    [self.warnings removeAllObjects];
    [self.pathStack removeAllObjects];

    [self pushPathComponent:TWTJSONSchemaKeywordSchema];
    if (!self.JSONSchema[TWTJSONSchemaKeywordSchema]) {
        [self warnWithFormat:@"JSON Schema version not present with keyword %@. Processing schema based on draft 4.", TWTJSONSchemaKeywordSchema];
    } else {
        [self failIfObject:self.JSONSchema[TWTJSONSchemaKeywordSchema] isNotMemberOfSet:[NSSet setWithObject:TWTJSONSchemaKeywordDraft4Path]];
    }
    [self popPathComponent];

    TWTJSONSchemaTopLevelASTNode *topLevelNode = [[TWTJSONSchemaTopLevelASTNode alloc] init];
    topLevelNode.schemaPath = self.JSONSchema[TWTJSONSchemaKeywordSchema];

    @try {
        topLevelNode.schema = [self parseSchema:self.JSONSchema];
    } @catch (NSException *exception) {
        topLevelNode = nil;
        if (outError) {
            *outError = exception.userInfo[TWTJSONExceptionErrorKey];
        }
    }

    if (outWarnings) {
        *outWarnings = [self.warnings copy];
    }

    return topLevelNode;
}


# pragma mark - Schema parser methods

// Starting point for all schema nodes (except top level)
// Evaluates the "type" keyword, creates a node of the appropriate class, directs the schema toward the appropriate parser method, and parses common keywords
// Type-specific parser methods are responsible for:
//     1. Setting the type (GenericASTNode and AmbiguousASTNode only; all others are built into the node class)
//     2. Parsing all type-specific properties
- (TWTJSONSchemaASTNode *)parseSchema:(NSDictionary *)schema
{
    NSParameterAssert(schema);

    [self failIfObject:schema isNotKindOfClass:[NSDictionary class] allowsNil:NO];

    [self pushPathComponent:TWTJSONSchemaKeywordType];
    BOOL typeIsExplicit = NO;
    id type = [self parseTypeKeywordForSchema:schema explicit:&typeIsExplicit];
    id node = nil;

    if ([type isKindOfClass:[NSArray class]]) {
        node = [[TWTJSONSchemaAmbiguousASTNode alloc] init];
        [node setTypeIsExplicit:typeIsExplicit];
        [self parseAmbiguousSchema:schema intoNode:node withTypes:type];
    } else if ([type isEqualToString:TWTJSONSchemaTypeKeywordArray]) {
        node = [[TWTJSONSchemaArrayASTNode alloc] init];
        [self parseArraySchema:schema intoNode:node];
    } else if ([type isEqualToString:TWTJSONSchemaTypeKeywordInteger] || [type isEqualToString:TWTJSONSchemaTypeKeywordNumber]) {
        node = [[TWTJSONSchemaNumberASTNode alloc] init];
        [self parseNumberSchema:schema intoNode:node withType:type];
    } else if ([type isEqualToString:TWTJSONSchemaTypeKeywordObject]) {
        node = [[TWTJSONSchemaObjectASTNode alloc] init];
        [self parseObjectSchema:schema intoNode:node];
    } else if ([type isEqualToString:TWTJSONSchemaTypeKeywordString]) {
        node = [[TWTJSONSchemaStringASTNode alloc] init];
        [self parseStringSchema:schema intoNode:node];
    } else {
        // type = "any", "boolean", or "null"
        node = [[TWTJSONSchemaGenericASTNode alloc] init];
        [self parseGenericSchema:schema intoNode:node withType:type];
    }

    [node setTypeIsExplicit:typeIsExplicit];
    [self parseCommonKeywordsFromSchema:schema intoNode:node];
    return node;
}


- (void)parseArraySchema:(NSDictionary *)arraySchema intoNode:(TWTJSONSchemaArrayASTNode *)node
{
    node.maximumItemCount = [self parseUnsignedIntegerForKey:TWTJSONSchemaKeywordMaxItems schema:arraySchema];
    node.minimumItemCount = [self parseUnsignedIntegerForKey:TWTJSONSchemaKeywordMinItems schema:arraySchema];
    node.requiresUniqueItems = [self parseBooleanForKey:TWTJSONSchemaKeywordUniqueItems schema:arraySchema valueIfNotPresent:NO];

    // "Items" must be JSON schema object or array of JSON schema objects
    if ([arraySchema[TWTJSONSchemaKeywordItems] isKindOfClass:[NSDictionary class]]) {
        node.itemSchemas = @[ [self parseSchemaForKey:TWTJSONSchemaKeywordItems schema:arraySchema] ];
        node.itemsIsSingleSchema = YES;
        // additional items is meaningless if items is a single schema
    } else {
        node.itemSchemas = [self parseNonEmptyArrayOfSchemasForKey:TWTJSONSchemaKeywordItems schema:arraySchema];
        node.itemsIsSingleSchema = NO;
        node.additionalItemsNode = [self parseAdditionalItemsOrPropertiesForKey:TWTJSONSchemaKeywordAdditionalItems schema:arraySchema];
    }
}


- (void)parseGenericSchema:(NSDictionary *)genericSchema intoNode:(TWTJSONSchemaGenericASTNode *)node withType:(NSString *)type
{
    node.validType = type;
}


- (void)parseNumberSchema:(NSDictionary *)numberSchema intoNode:(TWTJSONSchemaNumberASTNode *)node withType:(NSString *)type
{
    node.requireIntegralValue = [type isEqualToString:TWTJSONSchemaTypeKeywordInteger];
    node.minimum = [self parseNumberForKey:TWTJSONSchemaKeywordMinimum schema:numberSchema];
    node.maximum = [self parseNumberForKey:TWTJSONSchemaKeywordMaximum schema:numberSchema];
    node.multipleOf = [self parsePositiveNumberForKey:TWTJSONSchemaKeywordMultipleOf schema:numberSchema];
    if (node.maximum) {
        node.exclusiveMaximum = [self parseBooleanForKey:TWTJSONSchemaKeywordExclusiveMaximum schema:numberSchema valueIfNotPresent:NO];
    }

    if (node.minimum) {
        node.exclusiveMinimum = [self parseBooleanForKey:TWTJSONSchemaKeywordExclusiveMinimum schema:numberSchema valueIfNotPresent:NO];
    }
}


- (void)parseStringSchema:(NSDictionary *)stringSchema intoNode:(TWTJSONSchemaStringASTNode *)node
{
    node.maximumLength = [self parseUnsignedIntegerForKey:TWTJSONSchemaKeywordMaxLength schema:stringSchema];
    node.minimumLength = [self parseUnsignedIntegerForKey:TWTJSONSchemaKeywordMinLength schema:stringSchema];
    // Does not check validity of regular expression, because definition is: "MUST be a string. This string SHOULD be a valid Regular Expression."
    node.pattern = [self parseStringForKey:TWTJSONSchemaKeywordPattern schema:stringSchema];
}


- (void)parseObjectSchema:(NSDictionary *)objectSchema intoNode:(TWTJSONSchemaObjectASTNode *)node
{
    node.maximumPropertyCount = [self parseUnsignedIntegerForKey:TWTJSONSchemaKeywordMaxProperties schema:objectSchema];
    node.minimumPropertyCount = [self parseUnsignedIntegerForKey:TWTJSONSchemaKeywordMinProperties schema:objectSchema];
    NSArray *requiredKeys = [self parseNonEmptyArrayOfUnqiueStringsForKey:TWTJSONSchemaKeywordRequired schema:objectSchema];
    node.requiredPropertyKeys = requiredKeys ? [NSSet setWithArray:requiredKeys] : nil;
    node.propertySchemas = [self parseDictionaryOfSchemasForKey:TWTJSONSchemaKeywordProperties schema:objectSchema keyValuePairNodeClass:[TWTJSONSchemaNamedPropertyASTNode class]];
    node.patternPropertySchemas = [self parseDictionaryOfSchemasForKey:TWTJSONSchemaKeywordPatternProperties schema:objectSchema keyValuePairNodeClass:[TWTJSONSchemaPatternPropertyASTNode class]];
    node.additionalPropertiesNode = [self parseAdditionalItemsOrPropertiesForKey:TWTJSONSchemaKeywordAdditionalProperties schema:objectSchema];
    node.propertyDependencies = [self parseDependenciesWithSchema:objectSchema];
}


- (void)parseAmbiguousSchema:(NSDictionary *)ambigousSchema intoNode:(TWTJSONSchemaAmbiguousASTNode *)node withTypes:(NSArray *)types
{
    node.validTypes = [NSSet setWithArray:types];
    NSMutableArray *subNodes = [[NSMutableArray alloc] init];
    NSSet *validTypes = nil;
    if (node.typeIsExplicit) {
        validTypes = node.validTypes;
    } else {
        NSMutableSet *allTypes = [[self validJSONTypeKeywords] mutableCopy];
        [allTypes removeObject:TWTJSONSchemaTypeKeywordAny];
        validTypes = [allTypes copy];
    }

    for (NSString *type in validTypes) {
        id subNode = nil;

        if ([type isEqualToString:TWTJSONSchemaTypeKeywordArray]) {
            subNode = [[TWTJSONSchemaArrayASTNode alloc] init];
            [self parseArraySchema:ambigousSchema intoNode:subNode];
        } else if ([type isEqualToString:TWTJSONSchemaTypeKeywordInteger] || [type isEqualToString:TWTJSONSchemaTypeKeywordNumber]) {
            subNode = [[TWTJSONSchemaNumberASTNode alloc] init];
            [self parseNumberSchema:ambigousSchema intoNode:subNode withType:type];
        } else if ([type isEqualToString:TWTJSONSchemaTypeKeywordObject]) {
            subNode = [[TWTJSONSchemaObjectASTNode alloc] init];
            [self parseObjectSchema:ambigousSchema intoNode:subNode];
        } else if ([type isEqualToString:TWTJSONSchemaTypeKeywordString]) {
            subNode = [[TWTJSONSchemaStringASTNode alloc] init];
            [self parseStringSchema:ambigousSchema intoNode:subNode];
        } else {
            // type = "any", "boolean", or "null"
            subNode = [[TWTJSONSchemaGenericASTNode alloc] init];
            [self parseGenericSchema:ambigousSchema intoNode:subNode withType:type];
        }

        [subNode setTypeIsExplicit:YES];
        [subNodes addObject:subNode];
    }
    
    node.subNodes = subNodes;
}


#pragma mark - Nonspecific parser methods

// Keywords: exclusiveMinimum & Maximum, uniqueItems
- (BOOL)parseBooleanForKey:(NSString *)key schema:(NSDictionary *)schema valueIfNotPresent:(BOOL)defaultValue
{
    [self pushPathComponent:key];
    NSNumber *booleanObject = schema[key];
    [self failIfObject:booleanObject isNotKindOfClass:[NSNumber class] allowsNil:YES];
    [self popPathComponent];
    return booleanObject ? [booleanObject boolValue] : defaultValue;
}


// Keywords: pattern
- (NSString *)parseStringForKey:(NSString *)key schema:(NSDictionary *)schema
{
    [self pushPathComponent:key];
    NSString *string = schema[key];
    [self failIfObject:string isNotKindOfClass:[NSString class] allowsNil:YES];
    [self popPathComponent];
    return string;
}


// Keywords: minimum, maximum
- (NSNumber *)parseNumberForKey:(NSString *)key schema:(NSDictionary *)schema
{
    [self pushPathComponent:key];
    NSNumber *number = schema[key];
    [self failIfObject:number isNotKindOfClass:[NSNumber class] allowsNil:YES];
    [self popPathComponent];
    return number;
}


// Keywords: multipleOf
- (NSNumber *)parsePositiveNumberForKey:(NSString *)key schema:(NSDictionary *)schema
{
    NSNumber *number = schema[key];
    if (!number) {
        return nil;
    }

    [self pushPathComponent:key];
    [self failIfObject:number isNotKindOfClass:[NSNumber class] allowsNil:YES];
    if ([number doubleValue] <= 0) {
        NSNumber *oldNumber = [number copy];
        number = @0;
        [self warnWithFormat:@"Expected number greater than zero but found %@. Converting to %@", oldNumber, number];
    }

    [self popPathComponent];
    return number;
}


// Keywords: min & maxLength, min & maxItems, min & maxProperties
- (NSNumber *)parseUnsignedIntegerForKey:(NSString *)key schema:(NSDictionary *)schema
{
    NSNumber *number = schema[key];
    if (!number) {
        return nil;
    }

    [self pushPathComponent:key];
    [self failIfObject:number isNotKindOfClass:[NSNumber class] allowsNil:NO];

    double numberValue = [number doubleValue];
    if (numberValue < 0 || numberValue != trunc(numberValue)) {
        NSNumber *oldNumber = [number copy];

        if (numberValue < 0) {
            number = @0;
        } else {
            number = @((NSUInteger)(numberValue));
        }
        [self warnWithFormat:@"Expected unsigned integer but found %@. Converting to %@.", oldNumber, number];
    }

    [self popPathComponent];
    return number;
}


// Keywords: definitions
- (NSDictionary *)parseDictionaryForKey:(NSString *)key schema:(NSDictionary *)schema
{
    [self pushPathComponent:key];
    NSDictionary *dictionary = schema[key];
    [self failIfObject:dictionary isNotKindOfClass:[NSDictionary class] allowsNil:YES];
    [self popPathComponent];
    return dictionary;
}



// Keyword: items, not
// Example: { "items" : {} }
- (TWTJSONSchemaASTNode *)parseSchemaForKey:(NSString *)key schema:(NSDictionary *)schema
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


// Keywords: enum
- (NSArray *)parseNonEmptyArrayForKey:(NSString *)key schema:(NSDictionary *)schema
{
    [self pushPathComponent:key];
    NSArray *array = schema[key];
    [self failIfObjectIsNotArrayWithAtLeastOneItem:array allowsNil:YES];
    [self popPathComponent];
    return array;
}


// Keyword: required
// Example: { "required" : [ "name" ] }
- (NSArray *)parseNonEmptyArrayOfUnqiueStringsForKey:(NSString *)key schema:(NSDictionary *)schema
{
    NSArray *array = schema[key];
    if (!array) {
        return nil;
    }

    [self pushPathComponent:key];
    [self failIfObjectIsNotArrayWithAtLeastOneItem:array allowsNil:NO];

    [array enumerateObjectsUsingBlock:^(NSString *string, NSUInteger index, BOOL *stop) {
        [self pushPathComponent:@(index)];
        [self failIfObject:string isNotKindOfClass:[NSString class] allowsNil:NO];
        [self popPathComponent];
    }];

    NSCountedSet *countedSet = [NSCountedSet setWithArray:array];
    NSSet *repeatedItems = [countedSet objectsPassingTest:^BOOL(id object, BOOL *stop) {
        return [countedSet countForObject:object] > 1;
    }];

    if (repeatedItems.count > 0) {
        [self warnWithFormat:@"Expected an array of unique items, but the following elements occur more than once: %@", [[repeatedItems allObjects] componentsJoinedByString:@", "]];
    }

    [self popPathComponent];
    return array;
}


// Keyword: items, anyOf, allOf, oneOf
// Example: { "items" : [ {}, {} ] }
//          {
//            "anyOf": [
//                {
//                    "maxLength": 5,
//                    "type": "string"
//                },
//                {
//                    "minimum": 0,
//                    "type": "number"
//                }
//            ]
//          }

- (NSArray *)parseNonEmptyArrayOfSchemasForKey:(NSString *)key schema:(NSDictionary *)schema
{
    NSArray *array = schema[key];
    if (!array) {
        return nil;
    }

    [self pushPathComponent:key];
    [self failIfObjectIsNotArrayWithAtLeastOneItem:array allowsNil:NO];

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
- (NSArray *)parseDictionaryOfSchemasForKey:(NSString *)key schema:(NSDictionary *)schema keyValuePairNodeClass:(Class)nodeClass
{
    NSParameterAssert([nodeClass isSubclassOfClass:[TWTJSONSchemaKeyValuePairASTNode class]]);

    NSDictionary *nestedSchema = schema[key];
    if (!nestedSchema) {
        return nil;
    }

    [self pushPathComponent:key];
    [self failIfObject:nestedSchema isNotKindOfClass:[NSDictionary class] allowsNil:YES];

    NSMutableArray *propertyNodes = [[NSMutableArray alloc] init];
    [nestedSchema enumerateKeysAndObjectsUsingBlock:^(NSString *propertyKey, id object, BOOL *stop) {
        [self pushPathComponent:propertyKey];
        TWTJSONSchemaASTNode *valueNode = [self parseSchema:object];
        TWTJSONSchemaKeyValuePairASTNode *propertyNode = [[nodeClass alloc] initWithKey:propertyKey valueSchema:valueNode];
        [propertyNodes addObject:propertyNode];
        [self popPathComponent];
    }];

    [self popPathComponent];
    return propertyNodes;
}


#pragma mark - Keyword-specific parser methods

// Valid values for type are:
//    A. Nil (type keyword not present)
//    B. An array of strings that are all valid JSON types
//    C. A string that is a valid JSON type
// Returns either a string or array of strings; indirectly returns boolean indicating whether type was explicit or implied by keywords
- (id)parseTypeKeywordForSchema:(NSDictionary *)schema explicit:(BOOL *)typeIsExplicit
{
    [self pushPathComponent:TWTJSONSchemaKeywordType];
    id type = schema[TWTJSONSchemaKeywordType];

    // Case A: Type keyword not present
    if (!type) {
        // Check if type-specific keywords exist
        *typeIsExplicit = NO;
        type = [self impliedTypeForSchema:schema];
        return type;
    }

    *typeIsExplicit = YES;
    [self failIfObject:type isNotKindOfOneOfClasses:[NSString class], [NSArray class], nil];
    if ([type isKindOfClass:[NSArray class]]) {

        // Case B: Type is an array
        [(NSArray *)type enumerateObjectsUsingBlock:^(NSString *typeString, NSUInteger index, BOOL *stop) {
            [self pushPathComponent:@(index)];
            [self failIfObject:typeString isNotMemberOfSet:[self validJSONTypeKeywords]];
            [self popPathComponent];
        }];
    } else {
        // Case C: Type is a string
        [self failIfObject:type isNotMemberOfSet:[self validJSONTypeKeywords]];
    }

    [self popPathComponent];
    
    return type;
}


// If type keyword is not present, determines whether type-specific keywords indicate one or more types
- (id)impliedTypeForSchema:(NSDictionary *)schema
{
    static NSSet *objectKeywords = nil;
    static NSSet *arrayKeywords = nil;
    static NSSet *stringKeywords = nil;
    static NSSet *numberKeywords = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objectKeywords = [NSSet setWithObjects:TWTJSONSchemaKeywordMaxProperties, TWTJSONSchemaKeywordMinProperties, TWTJSONSchemaKeywordRequired, TWTJSONSchemaKeywordProperties, TWTJSONSchemaKeywordAdditionalProperties, TWTJSONSchemaKeywordPatternProperties, TWTJSONSchemaKeywordDependencies, nil];
        arrayKeywords = [NSSet setWithObjects:TWTJSONSchemaKeywordItems, TWTJSONSchemaKeywordAdditionalItems, TWTJSONSchemaKeywordMaxItems, TWTJSONSchemaKeywordMinItems, TWTJSONSchemaKeywordUniqueItems, nil];
        stringKeywords = [NSSet setWithObjects:TWTJSONSchemaKeywordMaxLength, TWTJSONSchemaKeywordMinLength, TWTJSONSchemaKeywordPattern, nil];
        numberKeywords = [NSSet setWithObjects:TWTJSONSchemaKeywordMultipleOf, TWTJSONSchemaKeywordMaximum, TWTJSONSchemaKeywordMinimum, TWTJSONSchemaKeywordExclusiveMaximum, TWTJSONSchemaKeywordExclusiveMinimum, nil];
    });

    NSSet *keys = [NSSet setWithArray:[schema allKeys]];
    NSMutableSet *types = [NSMutableSet set];

    if ([keys intersectsSet:objectKeywords]) {
        [types addObject:TWTJSONSchemaTypeKeywordObject];
    }
    if ([keys intersectsSet:arrayKeywords]) {
        [types addObject:TWTJSONSchemaTypeKeywordArray];
    }
    if ([keys intersectsSet:stringKeywords]) {
        [types addObject:TWTJSONSchemaTypeKeywordString];
    }
    if ([keys intersectsSet:numberKeywords]) {
        [types addObject:TWTJSONSchemaTypeKeywordNumber];
    }

    if (types.count == 0) {
        return TWTJSONSchemaTypeKeywordAny;
    }
    if (types.count == 1) {
        return [[types allObjects] firstObject];
    }

    return [types allObjects];
}


- (void)parseCommonKeywordsFromSchema:(NSDictionary *)schema intoNode:(TWTJSONSchemaASTNode *)node
{
    node.schemaTitle = [self parseStringForKey:TWTJSONSchemaKeywordTitle schema:schema];
    node.schemaDescription = [self parseStringForKey:TWTJSONSchemaKeywordDescription schema:schema];
    NSArray *validValues = [self parseNonEmptyArrayForKey:TWTJSONSchemaKeywordEnum schema:schema];
    node.validValues = validValues ? [NSSet setWithArray:validValues] : nil;
    node.andSchemas = [self parseNonEmptyArrayOfSchemasForKey:TWTJSONSchemaKeywordAllOf schema:schema];
    node.orSchemas = [self parseNonEmptyArrayOfSchemasForKey:TWTJSONSchemaKeywordAnyOf schema:schema];
    node.exactlyOneOfSchemas = [self parseNonEmptyArrayOfSchemasForKey:TWTJSONSchemaKeywordOneOf schema:schema];
    node.notSchema = [self parseSchemaForKey:TWTJSONSchemaKeywordNot schema:schema];
    node.definitions = [self parseDictionaryForKey:TWTJSONSchemaKeywordDefinitions schema:schema];

    return;
}


// Keywords: additionalItems, additionalProperties ONLY
// Example boolean: { "additionalItems" : false }
// Example dictionary: { "additionalProperties" : { "type" : "string" } }
// Note if either keyword is absent, it may be considered present with an empty schema, which is equivalent to "true"
- (TWTJSONSchemaASTNode *)parseAdditionalItemsOrPropertiesForKey:(NSString *)key schema:(NSDictionary *)schema
{
    NSParameterAssert([key isEqualToString:TWTJSONSchemaKeywordAdditionalItems] || [key isEqualToString:TWTJSONSchemaKeywordAdditionalProperties]);

    id value = schema[key];
    if (!value) {
        return [[TWTJSONSchemaBooleanValueASTNode alloc] initWithValue:YES];
    }

    [self pushPathComponent:key];

    [self failIfObject:value isNotKindOfOneOfClasses:[NSDictionary class], [NSNumber class], nil];

    if ([value isKindOfClass:[NSNumber class]]) {
        [self popPathComponent];
        return [[TWTJSONSchemaBooleanValueASTNode alloc] initWithValue:[value boolValue]];
    }

    // Else, value is NSDictionary, i.e., a schema
    TWTJSONSchemaASTNode *node = [self parseSchema:value];
    [self popPathComponent];
    return node;
}


// Keyword: dependencies
// Dependencies are either property or schema dependencies. Note these two examples are equivalent for validation.
// 1. Property dependency, i.e., "dependencies" object's value is an array
//	{
//		"type": "object",
//		"properties": {
//			"billing_address": {
//				"type": "string"
//			},
//			"credit_card": {
//				"type": "number"
//			}
//		},
//		"dependencies": {
//			"credit_card": [
//				"billing_address"
//			]
//		}
//	}
//
// 2. Schema dependency, i.e., "dependencies" object's value is a schema
//	 {
//		"type": "object",
//		"properties": {
//			"credit_card": {
//				"type": "number"
//			}
//		},
//		"dependencies": {
//			"credit_card": {
//				"properties": {
//					"billing_address": {
//						"type": "string"
//					}
//				},
//				"required": [
//					"billing_address"
//				]
//			}
//		}
//	}

- (NSArray *)parseDependenciesWithSchema:(NSDictionary *)schema
{
    NSDictionary *dependencies = schema[TWTJSONSchemaKeywordDependencies];
    if (!dependencies) {
        return nil;
    }
    [self pushPathComponent:TWTJSONSchemaKeywordDependencies];
    [self failIfObject:dependencies isNotKindOfClass:[NSDictionary class] allowsNil:NO];

    NSMutableArray *dependencyNodes = [[NSMutableArray alloc] init];
    [dependencies enumerateKeysAndObjectsUsingBlock:^(NSString *key, id object, BOOL *stop) {
        [self pushPathComponent:key];

        [self failIfObject:object isNotKindOfOneOfClasses:[NSDictionary class], [NSArray class], nil];

        TWTJSONSchemaDependencyASTNode *node = nil;

        if ([object isKindOfClass:[NSDictionary class]]) {
            node = [[TWTJSONSchemaDependencyASTNode alloc] initWithKey:key valueSchema:[self parseSchema:object]];
        } else {
            NSSet *propertySet = [NSSet setWithArray:[self parseNonEmptyArrayOfUnqiueStringsForKey:key schema:dependencies]];
            node = [[TWTJSONSchemaDependencyASTNode alloc] initWithKey:key propertySet:propertySet];
        }

        [dependencyNodes addObject:node];
        [self popPathComponent];

    }];
    
    [self popPathComponent];
    return dependencyNodes;
}


#pragma mark - Warning method

- (void)warnWithFormat:(NSString *)format, ...
{
    va_list arguments;
    va_start(arguments, format);
    NSString *description = [[NSString alloc] initWithFormat:format arguments:arguments];
    va_end(arguments);

    [self.warnings addObject:[@"Warning at " stringByAppendingFormat:@"%@. %@", [self currentPathString], description]];
}


#pragma mark - Failure methods

- (void)failIfObject:(id)object isNotKindOfClass:(Class)validClass allowsNil:(BOOL)allowsNil
{

    if (allowsNil && !object) {
        return;
    }

    if ([object isKindOfClass:validClass]) {
        return;
    }

    [self failWithErrorCode:TWTJSONSchemaParserErrorCodeInvalidClass object:object format:@"Expected object of class %@ but found %@.", validClass, object];
}


- (void)failIfObject:(id)object isNotKindOfOneOfClasses:(Class)validClass1, ...
{
    va_list argList;
    va_start(argList, validClass1);

    NSMutableSet *validClasses = [[NSMutableSet alloc] init];
    Class validClass = validClass1;
    while (validClass) {
        [validClasses addObject:validClass];
        validClass = va_arg(argList, id);
    }

    va_end(argList);

    for (Class validClassItem in validClasses) {
        if ([object isKindOfClass:validClassItem]) {
            return;
        }
    }

    NSString *classString = [[validClasses allObjects] componentsJoinedByString:@" or "];
    [self failWithErrorCode:TWTJSONSchemaParserErrorCodeInvalidClass object:object format:@"Expected object of class %@ but found %@.", classString, object];
}


- (void)failIfObjectIsNotArrayWithAtLeastOneItem:(NSArray *)object allowsNil:(BOOL)allowsNil
{
    [self failIfObject:object isNotKindOfClass:[NSArray class] allowsNil:allowsNil];
    if (!object || [object count] >= 1) {
        return;
    }

    [self failWithErrorCode:TWTJSONSchemaParserErrorCodeRequiresAtLeastOneItem object:object format:@"Expected array with at least one item but found %@.",  object];
}


- (void)failIfObject:(id)object isNotMemberOfSet:(NSSet *)validValues
{
    if ([validValues containsObject:object]) {
        return;
    }

    NSString *valueString = [[validValues allObjects] componentsJoinedByString:@", "];
    [self failWithErrorCode:TWTJSONSchemaParserErrorCodeInvalidValue object:object format:@"Expected one of { %@ } but found %@", valueString, object];
}


- (void)failWithErrorCode:(NSUInteger)code object:(id)object format:(NSString *)format, ...
{
    object ? object : [NSNull null];
    NSParameterAssert(format);

    va_list arguments;
    va_start(arguments, format);
    NSString *description = [[NSString alloc] initWithFormat:format arguments:arguments];
    va_end(arguments);

    description = [@"Error at " stringByAppendingFormat:@"%@. %@", [self currentPathString], description];
    NSError *error = [NSError errorWithDomain:TWTJSONSchemaParserErrorDomain code:code userInfo:@{ TWTJSONSchemaParserInvalidObjectKey : object,
                                                                                                   NSLocalizedDescriptionKey : description }];

    @throw [NSException exceptionWithName:@"Invalid JSON Schema" reason:nil userInfo:@{ TWTJSONExceptionErrorKey : error }];
}


#pragma mark - Path methods

- (NSString *)currentPathString
{
    return [@"/" stringByAppendingString:[self.pathStack componentsJoinedByString:@"/"]];
}


- (void)pushPathComponent:(id)object
{
    [self.pathStack addObject:object];
}


- (id)popPathComponent
{
    id object = self.pathStack.lastObject;
    [self.pathStack removeLastObject];
    return object;
}


#pragma mark - JSON valid types convenience method

- (NSSet *)validJSONTypeKeywords
{
    static NSSet *types = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        types = [NSSet setWithObjects:TWTJSONSchemaTypeKeywordAny,
                 TWTJSONSchemaTypeKeywordArray,
                 TWTJSONSchemaTypeKeywordBoolean,
                 TWTJSONSchemaTypeKeywordInteger,
                 TWTJSONSchemaTypeKeywordNull,
                 TWTJSONSchemaTypeKeywordNumber,
                 TWTJSONSchemaTypeKeywordObject,
                 TWTJSONSchemaTypeKeywordString,
                 nil];
    });

    return types;
}

@end
