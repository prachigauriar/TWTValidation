//
//  TWTJSONSchemaArrayASTNode.h
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
 TWTJSONSchemaArrayASTNodes model a schema that expects instances of type array.
 */
@interface TWTJSONSchemaArrayASTNode : TWTJSONSchemaASTNode

/*!
 @abstract The maximum number of items allowed in the array, given by "maxItems."
 @discussion Nil indicates that "maxItems" is not present in the schema.
 */
@property (nonatomic, strong) NSNumber *maximumItemCount;

/*!
 @abstract The minimum number of items allowed in the array, given by "minItems," or nil if the keyword is not present.
 */
@property (nonatomic, strong) NSNumber *minimumItemCount;

/*!
 @abstract Indicates whether the array requires unique items, given by "uniqueItems". Defaults to NO.
 */
@property (nonatomic, assign) BOOL requiresUniqueItems;

/*!
 @abstract If the schema has a single schema for "items", this property will be a node representing it. Otherwise, it will be nil.
 */
@property (nonatomic, strong) TWTJSONSchemaASTNode *itemSchema;

/*!
 @abstract If the schema has an array of schemas for "items", this property will be an array of nodes representing those items. Otherwise, it will be nil.
 */
@property (nonatomic, copy) NSArray *indexedItemSchemas;

/*!
 @abstract Represents the value of "additionalItems", either with a TWTJSONSchemaBooleanValueASTNode or a type-specific node.
 @discussion The value of "additionalItems" can either be a boolean or a schema. A boolean represents whether additional items not defined by items are allowed at all. A schema represents what any additional items, if present, must validate against. (If the keyword is not present, it defaults to the boolean value YES.) Parsers simply need to invoke [node acceptProcessor:self], and the visitor pattern will take care of processing the appropriate type.
 */
@property (nonatomic, strong) TWTJSONSchemaASTNode *additionalItemsNode; 

@end
