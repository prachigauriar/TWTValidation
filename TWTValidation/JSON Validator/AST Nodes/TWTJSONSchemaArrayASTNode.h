//
//  TWTJSONSchemaArrayASTNode.h
//  TWTValidation
//
//  Created by Jill Cohen on 12/15/14.
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


/*!
 TWTJSONSchemaArrayASTNodes model a schema that expects instances of type array.
 */
@interface TWTJSONSchemaArrayASTNode : TWTJSONSchemaASTNode

/*!
 @abstract The maximum number of items allowed in the array, given by "maxItems."
 @discussion Nil indicates that "maxItems" is not present in the schema.
 */
@property (nonatomic, strong) NSNumber *maximumItemCount;
@property (nonatomic, strong) NSNumber *minimumItemCount;
@property (nonatomic, assign) BOOL requiresUniqueItems;
@property (nonatomic, strong) TWTJSONSchemaASTNode *itemSchema;
@property (nonatomic, copy) NSArray *indexedItemSchemas; // array of nodes
@property (nonatomic, strong) TWTJSONSchemaASTNode *additionalItemsNode; // parser will set to booleanValueNode or type-specific

@end
