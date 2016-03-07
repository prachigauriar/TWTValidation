//
//  TWTJSONSchemaTopLevelASTNode.h
//  TWTValidation
//
//  Created by Jill Cohen on 12/16/14.
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
 TWTJSONSchemaTopLevelASTNodes model the top level of a JSON schema, which is a
 valid JSON schema plus the special keyword "$schema". It provides the starting
 point for TWTJSONSchemaProcessors to begin processing the AST node tree, and
 thus only one instance exists for a given schema.
 */
@interface TWTJSONSchemaTopLevelASTNode : TWTJSONSchemaASTNode

/*!
 @abstract The JSON Schema version identifier, given by "$schema".
 @discussion This version of TWTValidation only supports draft 4
    (http://json-schema.org/draft-04/schema#). If nil, the schema does not
    include "$schema" and is treated as draft 4.
 */
@property (nonatomic, copy) NSString *schemaPath;

/*!
 @abstract The node modeling top level of the schema.
 @discussion This node includes all of information given by the schema,
    except for the "$schema" keyword. TWTJSONSchemaProcessors in their
    implementation of processTopLevelNode: should invoke
    [topLevelNode.schema acceptProcessor:self].
 */
@property (nonatomic, strong) TWTJSONSchemaASTNode *schema;

/*!
 @abstract All of the nodes representing schemas or nested schemas with the $ref keyword.
 */
@property (nonatomic, copy, readonly) NSArray *allReferenceNodes;

/*!
 @abstract Searches the tree for the node referred to by a reference node.
 @param referenceNode The reference node containing the path to the referant.
 @result The referant node, or nil if it cannot be found.
 */
- (TWTJSONSchemaASTNode *)nodeForReferenceNode:(TWTJSONSchemaReferenceASTNode *)referenceNode;

@end
