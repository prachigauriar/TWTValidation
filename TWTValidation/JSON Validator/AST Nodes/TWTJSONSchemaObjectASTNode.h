//
//  TWTJSONSchemaObjectASTNode.h
//  TWTValidation
//
//  Created by Jill Cohen on 12/15/14.
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

#import <TWTValidation/TWTJSONSchemaASTNode.h>


/*!
 TWTJSONSchemaObjectASTNodes model a schema that expects instances of type object.
 */
@interface TWTJSONSchemaObjectASTNode : TWTJSONSchemaASTNode

/*!
 @abstract The minimum number of properties allowed, given by "minProperties," or nil if the keyword is not present.
 */
@property (nonatomic, strong) NSNumber *maximumPropertyCount;

/*!
 @abstract The maximum number of properties allowed, given by "maxProperties," or nil if the keyword is not present.
 */
@property (nonatomic, strong) NSNumber *minimumPropertyCount;

/*!
 @abstract A set of required property keys, given by "required," or nil if the keyword is not present.
 */
@property (nonatomic, copy) NSSet *requiredPropertyKeys;

/*!
 @abstract An array of TWTJSONSchemaNamedPropertyASTNodes representing the property schemas, or nil if the keyword "properties" is not present.
 */
@property (nonatomic, copy) NSArray *propertySchemas;

/*!
 @abstract An array of TWTJSONSchemaPatternPropertyASTNodes representing the pattern property schemas, or nil if the keyword "patternProperties" is not present.
 */
@property (nonatomic, copy) NSArray *patternPropertySchemas;

/*!
 @abstract Represents the value of "additionalProperties", either with a TWTJSONSchemaBooleanValueASTNode or a type-specific node.
 @discussion The value of "additionalProperties" can either be a boolean or a schema. A boolean represents whether additional properties not defined by "properties" or "patternProperties" are allowed at all. A schema represents what any additional properties, if present, must validate against. (If the keyword is not present, it defaults to the boolean value YES.) Parsers simply need to invoke [node acceptProcessor:self], and the visitor pattern will take care of processing the appropriate type.
 */
@property (nonatomic, strong) TWTJSONSchemaASTNode *additionalPropertiesNode;

/*!
 @abstract An array of TWTJSONSchemaDependencyASTNodes representing the schema dependencies and property dependencies, or nil if the keyword "dependencies" is not present.
 */
@property (nonatomic, copy) NSArray *propertyDependencies;

@end
