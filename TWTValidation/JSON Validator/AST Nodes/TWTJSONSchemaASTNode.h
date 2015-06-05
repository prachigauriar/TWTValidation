//
//  TWTJSONSchemaASTNode.h
//  TWTValidation
//
//  Created by Jill Cohen on 12/12/14.
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

@import Foundation;

#import <TWTValidation/TWTJSONSchemaASTProcessor.h>
#import <TWTValidation/TWTJSONSchemaKeywordConstants.h>

/*!
 TWTJSONSchemaASTNodes model a valid JSON schema, as defined by http://json-schema.org/draft-04/schema#, or a building block of
 one (e.g., TWTJSONSchemaKeyValuePairASTNode). Nodes modeling valid schemas can represent either the entire schema (see
 TWTJSONSchemaTopLevelASTNode) or nested schemas (e.g., self.andNodes represent the schemas that are the value of "allOf"). This
 is an abstract class that defines common properties and the interface for accepting a TWTJSONSchemaASTProcessor.
 */
@interface TWTJSONSchemaASTNode : NSObject

/*!
 @abstract The title of the instance described by this schema.
 @discussion This is not used for validation.
 */
@property (nonatomic, copy) NSString *schemaTitle;

/*!
 @abstract A description explaining the purpose of the instance described by this schema.
 @discussion This is not used for validation.
 */
@property (nonatomic, copy) NSString *schemaDescription;

/*!
 @abstract A flag indicating whether the "type" keyword is present in the schema.
 @discussion A YES requires that an instance be of the type specified. A NO indicates that types not matching type-specific
     keywords will be ignored for those keywords.
 */
@property (nonatomic, assign, getter = isTypeSpecified) BOOL typeSpecified;

/*!
 @abstract A set of type keywords indicating the valid types for an instance described by the schema.
 @discussion Subclasses must override this implementation with either a returned set or allowing readwrite access. May be nil,
     indicating type is not meaningful (e.g., dependencyNode).
 */
@property (nonatomic, copy, readonly) NSSet *validTypes;

/*!
 @abstract A set of valid values given by "enum."
 @discussion An instance passes if it is equal to one of these objects. Nil indicates "enum" is not present in the schema.
 */
@property (nonatomic, copy) NSSet *validValues;


/*!
 @abstract An array of TWTJSONSchemaASTNodes that model the schemas given by "allOf."
 @discussion If this property is non-nil, it must have at least one element. Nil indicates "allOf" is not present in the schema.
 */
@property (nonatomic, copy) NSArray *andSchemas;

/*!
 @abstract An array of TWTJSONSchemaASTNodes that model the schemas given by "anyOf."
 @discussion If this property is non-nil, it must have at least one element. Nil indicates "anyOf" is not present in the schema.
 */
@property (nonatomic, copy) NSArray *orSchemas;

/*!
 @abstract An array of TWTJSONSchemaASTNodes that model the schemas given by "oneOf."
 @discussion If this property is non-nil, it must have at least one element. Nil indicates "oneOf" is not present in the schema.
 */
@property (nonatomic, copy) NSArray *exactlyOneOfSchemas;

/*!
 @abstract A TWTJSONSchemaASTNode that models the schema given by "not."
 @discussion Nil indicates "not" is not present in the schema.
 */
@property (nonatomic, strong) TWTJSONSchemaASTNode *notSchema;

/*!
 @abstract A location where schemas referenced elsewhere can be defined.
 @discussion Each key provides a reference path, and its value must be a TWTJSONSchemaASTNode.
 */
@property (nonatomic, copy) NSDictionary *definitions;

/*!
 @abstract The interface for accepting a TWTJSONSchemaASTProcessor.
 @discussion Subclasses must override this, and the implementations must invoke the appropriate method from the
     TWTJSONSchemaASTProcessor protocol on the processor (for example, [processor processArrayNode:self]). If called on an
     instance of this class, this will throw a subclass responsibility exception.
 @param processor The processor on which a method from the TWTJSONSchemaASTProcessor protocol should be invoked.
 */
- (void)acceptProcessor:(id<TWTJSONSchemaASTProcessor>)processor;


# pragma mark - Only subclasses should invoke

/*!
 @abstract The children that are of class TWTJSONSchemaReferenceASTNode, which models a schema with the "$ref" keyword.
 @discussion Subclasses should override this if they have type-specific children nodes. The implementations must invoke super then
     add the reference nodes from its type-specific properties to the returned array, except TWTJSONSchemaReferenceASTNode, which
     should add itself to the array. If no children are reference nodes, this should return an empty array. See
     TWTJSONSchemaTopLevelASTNode for the external interface.
 @result An array containing all children that are reference nodes. An empty array is returned if none exist.
 */
- (NSArray *)childrenReferenceNodes;

/*!
 @abstract The children of nodes in an array that are of class TWTJSONSchemaReferenceASTNode.
 @discussion This is a convenience method to retrieve reference nodes from all the nodes in an array property.
 @param array The array from which children reference nodes are to be collected. This can be nil, in which case an empty array will be returned.
 @result An array containing all children that are reference nodes. An empty array is returned if none exist.
 */
- (NSArray *)childrenReferenceNodesFromNodeArray:(NSArray *)array;

/*!
 @abstract The node for a reference path.
 @discussion Subclasses should override this if they have type-specific children nodes. The implementations must: 
      1) invoke super, which handles common keywords and the case where self is the referent 
      2) check if a node is returned from super and if so return it 
      3) otherwise, check the first path component against its type-specific keywords. For a match, it should pass the remaining
      components to that property to serve up the referent node.

      This implementation should only be used internal to the AST node tree. See TWTJSONSchemaTopLevelASTNode for the external interface.
 @param path An array of path components. The path is with respect to the recipient of the m
 
 The root of the path  location of the recipient is considered the root of the path.
 @result The node that matches a given reference path, or nil if no match is found.
 */
- (TWTJSONSchemaASTNode *)nodeForPathComponents:(NSArray *)path;

/*!
 @abstract The node that matches a given reference path within a node array, or nil if none exists.
 @discussion This is a convenience method to retrieve a node from an array property. The first component is expected to be a
     string representation of the element's index.
 @param path An array of nodes.
 @result An array containing all children that are reference nodes. An empty array is returned if none exist.
 */
- (TWTJSONSchemaASTNode *)nodeForPathComponents:(NSArray *)path fromNodeArray:(NSArray *)array;

/*!
 @abstract A convenience method to get the remaining path after removing the first component.
 @param path An array of path components.
 @result The new path after removing the first component.
 */
- (NSArray *)remainingPathFromPath:(NSArray *)path;

@end
