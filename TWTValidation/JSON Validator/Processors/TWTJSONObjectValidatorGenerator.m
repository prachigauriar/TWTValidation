//
//  TWTJSONObjectValidatorGenerator.m
//  TWTValidation
//
//  Created by Jill Cohen on 1/14/15.
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

#import <TWTValidation/TWTJSONObjectValidatorGenerator.h>

#import <TWTValidation/TWTValidation.h>

#import <TWTValidation/TWTJSONSchemaASTCommon.h>
#import <TWTValidation/TWTJSONSchemaParser.h>
#import <TWTValidation/TWTJSONSchemaAmbiguousTypeValidator.h>
#import <TWTValidation/TWTJSONSchemaArrayValidator.h>
#import <TWTValidation/TWTJSONSchemaObjectValidator.h>
#import <TWTValidation/TWTJSONSchemaValidTypesConstants.h>


@interface TWTConstantValidator : TWTValidator

@property (nonatomic, assign) BOOL validationPasses;

@end


@implementation TWTConstantValidator

- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError
{
    return self.validationPasses;
}


+ (TWTConstantValidator *)validatorWithConstant:(BOOL)validationPasses
{
    TWTConstantValidator *validator = [[TWTConstantValidator alloc] init];
    validator.validationPasses = validationPasses;
    return validator;
}

@end



@interface TWTJSONObjectValidatorGenerator ()

@property (nonatomic, strong, readonly) NSMutableArray *objectStack;

@end


@implementation TWTJSONObjectValidatorGenerator

- (instancetype)init
{
    self = [super init];
    if (self) {
        _objectStack = [[NSMutableArray alloc] init];
    }
    return self;
}


- (TWTJSONObjectValidator *)validatorFromJSONSchema:(NSDictionary *)schema error:(NSError *__autoreleasing *)outError warnings:(NSArray *__autoreleasing *)outWarnings
{
    [self.objectStack removeAllObjects];
    TWTJSONSchemaParser *parser = [[TWTJSONSchemaParser alloc] initWithJSONSchema:schema];
    NSError *parsingError = nil;
    TWTJSONSchemaTopLevelASTNode *topLevelNode = [parser parseWithError:&parsingError warnings:outWarnings];
    if (parsingError) {
        if (outError) {
            *outError = parsingError;
        }
        return nil;
    }

    [topLevelNode acceptProcessor:self];
    return [self popCurrentObject];
}


- (void)processTopLevelNode:(TWTJSONSchemaTopLevelASTNode *)topLevelNode
{
    [topLevelNode.schema acceptProcessor:self];
}


- (void)processGenericNode:(TWTJSONSchemaGenericASTNode *)genericNode
{
    TWTValidator *commonValidator = [self commonValidatorFromNode:genericNode];
    NSString *type = genericNode.validTypes.allObjects.firstObject;
    TWTValidator *typeValidator = nil;
    TWTJSONType typeEnum = TWTJSONTypeAny;

    if ([type isEqualToString:TWTJSONSchemaTypeKeywordBoolean]) {
        typeValidator = [TWTValueValidator valueValidatorWithClass:[NSNumber class] allowsNil:NO allowsNull:NO];
        typeEnum = TWTJSONTypeNumber;
    } else if ([type isEqualToString:TWTJSONSchemaTypeKeywordNull]) {
        typeValidator = [TWTValueValidator valueValidatorWithClass:[NSNull class] allowsNil:NO allowsNull:YES];
        typeEnum = TWTJSONTypeNull;
    }

    [self pushJSONObjectValidatorWithCommonValidator:commonValidator typeValidator:typeValidator type:typeEnum requiresType:genericNode.typeIsExplicit];
}


- (void)processArrayNode:(TWTJSONSchemaArrayASTNode *)arrayNode
{
    TWTValidator *commonValidator = [self commonValidatorFromNode:arrayNode];
    TWTJSONSchemaArrayValidator *typeValidator = [self validatorForArrayNode:arrayNode];
    [self pushJSONObjectValidatorWithCommonValidator:commonValidator typeValidator:typeValidator type:TWTJSONTypeArray requiresType:arrayNode.typeIsExplicit];
}


- (TWTJSONSchemaArrayValidator *)validatorForArrayNode:(TWTJSONSchemaArrayASTNode *)arrayNode
{
    NSArray *itemValidators = [self validatorsFromNodeArray:arrayNode.itemSchemas];
    TWTValidator *additionalItems = [self validatorFromNode:arrayNode.additionalItemsNode];
    return [[TWTJSONSchemaArrayValidator alloc] initWithMaximumItemCount:arrayNode.maximumItemCount minimumItemCount:arrayNode.minimumItemCount requiresUniqueItems:arrayNode.requiresUniqueItems itemValidators:itemValidators itemsIsSingleSchema:arrayNode.itemsIsSingleSchema additionalItemsValidator:additionalItems];
}


- (void)processNumberNode:(TWTJSONSchemaNumberASTNode *)numberNode
{
    TWTValidator *commonValidator = [self commonValidatorFromNode:numberNode];
    TWTValidator *typeValidator = [self validatorForNumberNode:numberNode];
    [self pushJSONObjectValidatorWithCommonValidator:commonValidator typeValidator:typeValidator type:TWTJSONTypeNumber requiresType:numberNode.typeIsExplicit];
}


- (TWTValidator *)validatorForNumberNode:(TWTJSONSchemaNumberASTNode *)numberNode
{
    [self pushNewObject:[[NSMutableArray alloc] init]];
    TWTNumberValidator *validator = [[TWTNumberValidator alloc] initWithMinimum:numberNode.minimum maximum:numberNode.maximum];
    validator.maximumExclusive = numberNode.exclusiveMaximum;
    validator.minimumExclusive = numberNode.exclusiveMinimum;
    validator.requiresIntegralValue = numberNode.requireIntegralValue;

    [self addSubvalidator:validator];

    if (numberNode.multipleOf) {
        [self addSubvalidator:[[TWTBlockValidator alloc] initWithBlock:^BOOL(id value, NSError *__autoreleasing *outError) {
            double result = [(NSNumber *)value doubleValue] / numberNode.multipleOf.doubleValue;;
            if (result == trunc(result)) {
                return YES;
            }
            return NO;
        }]];
    }

    return [self collectSubvalidators];
}


- (void)processObjectNode:(TWTJSONSchemaObjectASTNode *)objectNode
{
    TWTValidator *commonValidator = [self commonValidatorFromNode:objectNode];
    TWTJSONSchemaObjectValidator *typeValidator = [self validatorForObjectNode:objectNode];
    [self pushJSONObjectValidatorWithCommonValidator:commonValidator typeValidator:typeValidator type:TWTJSONTypeObject requiresType:objectNode.typeIsExplicit];
}


- (TWTJSONSchemaObjectValidator *)validatorForObjectNode:(TWTJSONSchemaObjectASTNode *)objectNode
{
    NSArray *properties = [self validatorsFromNodeArray:objectNode.propertySchemas];
    NSArray *patterns = [self validatorsFromNodeArray:objectNode.patternPropertySchemas];
    TWTValidator *additionalPropertiesValidator = [self validatorFromNode:objectNode.additionalPropertiesNode];
    NSDictionary *dependencies = [self dependencyDictionaryFromNodeArray:objectNode.propertyDependencies];
    return [[TWTJSONSchemaObjectValidator alloc] initWithMaximumPropertyCount:objectNode.maximumPropertyCount minimumPropertyCount:objectNode.minimumPropertyCount requiredProperties:objectNode.requiredPropertyNames propertyValidators:properties patternPropertyValidators:patterns additionalPropertiesValidator:additionalPropertiesValidator propertyDependencies:dependencies];
}


- (void)processStringNode:(TWTJSONSchemaStringASTNode *)stringNode
{
    TWTValidator *commonValidator = [self commonValidatorFromNode:stringNode];
    TWTValidator *typeValidator = [self validatorForStringNode:stringNode];
    [self pushJSONObjectValidatorWithCommonValidator:commonValidator typeValidator:typeValidator type:TWTJSONTypeString requiresType:stringNode.typeIsExplicit];
}


- (TWTValidator *)validatorForStringNode:(TWTJSONSchemaStringASTNode *)stringNode
{
    [self pushNewObject:[[NSMutableArray alloc] init]];

    [self addSubvalidator:[TWTStringValidator stringValidatorWithMinimumLength:stringNode.minimumLength.integerValue maximumLength: stringNode.maximumLength ? stringNode.maximumLength.integerValue : NSUIntegerMax]];
    if (stringNode.pattern) {
        [self addSubvalidator:[TWTStringValidator stringValidatorWithPattern:stringNode.pattern caseSensitive:NO]];
    }

    return [self collectSubvalidators];
}


- (void)processAmbiguousNode:(TWTJSONSchemaAmbiguousASTNode *)ambiguousNode
{
    TWTValidator *commonValidator = [self commonValidatorFromNode:ambiguousNode];
    id node = ambiguousNode;

    NSMutableDictionary *subvalidators = [[NSMutableDictionary alloc] init];
    for (NSString *type in ambiguousNode.validTypes) {
        if ([type isEqualToString:TWTJSONSchemaTypeKeywordArray]) {
            [subvalidators setObject:[self validatorForArrayNode:node] forKey:type];
        } else if ([[NSSet setWithObjects:TWTJSONSchemaTypeKeywordInteger, TWTJSONSchemaTypeKeywordNumber, nil] containsObject:type]) {
            [subvalidators setObject:[self validatorForNumberNode:node] forKey:type];
        } else if ([type isEqualToString:TWTJSONSchemaTypeKeywordObject]) {
            [subvalidators setObject:[self validatorForObjectNode:node] forKey:type];
        } else if ([type isEqualToString:TWTJSONSchemaTypeKeywordString]) {
            [subvalidators setObject:[self validatorForStringNode:node] forKey:type];
        } else if ([type isEqualToString:TWTJSONSchemaTypeKeywordNull]) {
            TWTValueValidator *nullValidator = [TWTValueValidator valueValidatorWithClass:[NSNull class] allowsNil:NO allowsNull:YES];
            [subvalidators setObject:nullValidator forKey:type];
        } else if ([type isEqualToString:TWTJSONSchemaTypeKeywordBoolean]) {
            TWTValueValidator *nullValidator = [TWTValueValidator valueValidatorWithClass:[NSNumber class] allowsNil:NO allowsNull:NO];
            [subvalidators setObject:nullValidator forKey:type];
        }
    }

    TWTValidator *typeValidator = [[TWTJSONSchemaAmbiguousTypeValidator alloc] initWithTypeValidators:subvalidators requiresType:ambiguousNode.typeIsExplicit];
    [self pushJSONObjectValidatorWithCommonValidator:commonValidator typeValidator:typeValidator type:TWTJSONTypeAmbiguous requiresType:YES];
}


- (void)processBooleanValueNode:(TWTJSONSchemaBooleanValueASTNode *)booleanValueNode
{
    [self pushNewObject:
     [[TWTBlockValidator alloc] initWithBlock:^BOOL(id value, NSError *__autoreleasing *outError) {
        return booleanValueNode.booleanValue;
    }]];
}


- (void)processNamedPropertyNode:(TWTJSONSchemaNamedPropertyASTNode *)propertyNode
{
    [self pushNewObject:[[TWTKeyValuePairValidator alloc] initWithKey:propertyNode.key valueValidator:[self validatorFromNode:propertyNode.valueSchema]]];
}


- (void)processPatternPropertyNode:(TWTJSONSchemaPatternPropertyASTNode *)patternPropertyNode
{
    [self pushNewObject:[[TWTKeyValuePairValidator alloc] initWithKey:patternPropertyNode.key valueValidator:[self validatorFromNode:patternPropertyNode.valueSchema]]];
}


- (void)processDependencyNode:(TWTJSONSchemaDependencyASTNode *)dependencyNode
{
    if (dependencyNode.valueSchema) {
        [dependencyNode.valueSchema acceptProcessor:self];
    } else {
        // node has a property set, which is a set of strings
        [self pushNewObject:dependencyNode.propertySet];
    }
}


- (TWTValidator *)commonValidatorFromNode:(TWTJSONSchemaASTNode *)node
{
    [self pushNewObject:[[NSMutableArray alloc] init]];
    if (node.validValues) {
        [self addSubvalidator:[[TWTValueSetValidator alloc] initWithValidValues:node.validValues]];
    }
    [self addSubvalidator:[self compoundValidatorFromNodeArray:node.andSchemas type:TWTCompoundValidatorTypeAnd]];
    [self addSubvalidator:[self compoundValidatorFromNodeArray:node.orSchemas type:TWTCompoundValidatorTypeOr]];
    [self addSubvalidator:[self compoundValidatorFromNodeArray:node.exactlyOneOfSchemas type:TWTCompoundValidatorTypeMutualExclusion]];
    if (node.notSchema) {
        [node.notSchema acceptProcessor:self];
        [self addSubvalidator:[TWTCompoundValidator notValidatorWithSubvalidator:[self popCurrentObject]]];
    }

    return [self collectSubvalidators];
}


- (TWTCompoundValidator *)compoundValidatorFromNodeArray:(NSArray *)array type:(TWTCompoundValidatorType)type
{
    if (!array) {
        return nil;
    }

    return [[TWTCompoundValidator alloc] initWithType:type subvalidators:[self validatorsFromNodeArray:array]];
}


- (NSArray *)validatorsFromNodeArray:(NSArray *)array
{
    if (!array) {
        return nil;
    }

    NSMutableArray *validators = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (TWTJSONSchemaASTNode *node in array) {
        [node acceptProcessor:self];
        [validators addObject:[self popCurrentObject]];
    }

    return validators;
}


- (TWTValidator *)validatorFromNode:(TWTJSONSchemaASTNode *)node
{
    if (!node) {
        return nil;
    }

    [node acceptProcessor:self];
    return [self popCurrentObject];
}


- (NSDictionary *)dependencyDictionaryFromNodeArray:(NSArray *)array
{
    if (!array) {
        return nil;
    }

    NSMutableDictionary *dependencies = [[NSMutableDictionary alloc] init];
    for (TWTJSONSchemaDependencyASTNode *node in array) {
        [node acceptProcessor:self];
        [dependencies setObject:[self popCurrentObject] forKey:node.key];
    }

    return dependencies;
}


# pragma mark - Convenience methods

- (void)addSubvalidator:(TWTValidator *)subvalidator
{
    if (subvalidator) {
        [self.currentObject addObject:subvalidator];
    }
}


- (void)pushJSONObjectValidatorWithCommonValidator:(TWTValidator *)commonValidator
                                     typeValidator:(TWTValidator *)typeValidator
                                              type:(TWTJSONType)type
                                      requiresType:(BOOL)requiresType
{
    [self pushNewObject:[[TWTJSONObjectValidator alloc] initWithCommonValidator:commonValidator typeValidator:typeValidator type:type requiresType:requiresType]];
}


- (TWTValidator *)collectSubvalidators
{
    NSArray *subvalidators = [self popCurrentObject];
    switch (subvalidators.count) {
        case 0:
            return nil;

        case 1:
            return subvalidators.firstObject;

        default:
            return [TWTCompoundValidator andValidatorWithSubvalidators:subvalidators];
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
