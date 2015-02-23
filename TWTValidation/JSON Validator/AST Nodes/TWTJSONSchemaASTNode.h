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
 TWTJSONSchemaASTNodes model a valid JSON schema, as defined by http://json-schema.org/draft-04/schema#, or a building block of one (e.g., TWTJSONSchemaKeyValuePairASTNode). Nodes modeling valid schemas can represent either the entire schema (see TWTJSONSchemaTopLevelASTNode) or nested schemas (e.g., self.andNodes represent the schemas that are the value of "allOf"). This is an abstract class that defines common properties and the interface for accepting a TWTJSONSchemaASTProcessor.
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
 @discussion A YES requires that an instance be of the type specified. A NO indicates that types not matching type-specific keywords will be ignored for those keywords.
 */
@property (nonatomic, assign, getter = isTypeSpecified) BOOL typeSpecified;

/*!
 @abstract A set of type keywords indicating the valid types for an instance described by the schema.
 @discussion Subclasses must override this implementation with either a returned set or allowing readwrite access. May be nil, indicating type is not meaningful (e.g., dependencyNode).
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
 @discussion Subclasses must override this, and the implementations must invoke the appropriate method from the TWTJSONSchemaASTProcessor protocol on the processor (for example, [processor processArrayNode:self]). If called on an instance of this class, this will throw a umk_subclassResponsibilityException.
 @param processor The processor on which a method from the TWTJSONSchemaASTProcessor protocol should be invoked.
 */
- (void)acceptProcessor:(id<TWTJSONSchemaASTProcessor>)processor;


# pragma mark - Only subclasses should invoke

/*!
 @abstract The children that are of class TWTJSONSchemaReferenceASTNode.
 @discussion Subclasses should override this if they have type-specific children nodes. The implementations must invoke super then add the reference nodes from its type-specific properties to the mutable array, except TWTJSONSchemaReferenceASTNode, which should return an array containing self. If no children are reference nodes, this should return an empty array.
 @result An array containing all children that are reference nodes. An empty array is returned if none exist.
 */
- (NSMutableArray *)childrenReferenceNodes;


- (NSArray *)childrenReferenceNodesFromNodeArray:(NSArray *)array;


- (NSArray *)childrenReferenceNodesFromNodeDictionary:(NSDictionary *)dictionary;


- (TWTJSONSchemaASTNode *)nodeForPathComponents:(NSMutableArray *)path;


- (TWTJSONSchemaASTNode *)nodeForPathComponents:(NSMutableArray *)path fromNodeArray:(NSArray *)array;


- (TWTJSONSchemaASTNode *)typeSpecificChecksForKey:(NSString *)key referencePath:(NSMutableArray *)path;


@end
