//
//  TWTJSONSchemaASTProcessor.h
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

@import Foundation;


@class TWTJSONSchemaTopLevelASTNode;
@class TWTJSONSchemaGenericASTNode;
@class TWTJSONSchemaArrayASTNode;
@class TWTJSONSchemaNumberASTNode;
@class TWTJSONSchemaObjectASTNode;
@class TWTJSONSchemaStringASTNode;
@class TWTJSONSchemaAmbiguousASTNode;
@class TWTJSONSchemaBooleanValueASTNode;
@class TWTJSONSchemaNamedPropertyASTNode;
@class TWTJSONSchemaPatternPropertyASTNode;
@class TWTJSONSchemaDependencyASTNode;
@class TWTJSONSchemaReferenceASTNode;


@protocol TWTJSONSchemaASTProcessor <NSObject>

// Top level of schema
- (void)processTopLevelNode:(TWTJSONSchemaTopLevelASTNode *)topLevelNode;

// Specialized nodes based on value of "type" keyword
- (void)processGenericNode:(TWTJSONSchemaGenericASTNode *)genericNode;
- (void)processArrayNode:(TWTJSONSchemaArrayASTNode *)arrayNode;
- (void)processNumberNode:(TWTJSONSchemaNumberASTNode *)numberNode;
- (void)processObjectNode:(TWTJSONSchemaObjectASTNode *)objectNode;
- (void)processStringNode:(TWTJSONSchemaStringASTNode *)stringNode;
- (void)processAmbiguousNode:(TWTJSONSchemaAmbiguousASTNode *)ambiguousNode;
- (void)processReferenceNode:(TWTJSONSchemaReferenceASTNode *)referenceNode;

// Specialized nodes for array items and object properties
- (void)processBooleanValueNode:(TWTJSONSchemaBooleanValueASTNode *)booleanValueNode;
- (void)processNamedPropertyNode:(TWTJSONSchemaNamedPropertyASTNode *)propertyNode;
- (void)processPatternPropertyNode:(TWTJSONSchemaPatternPropertyASTNode *)patternPropertyNode;
- (void)processDependencyNode:(TWTJSONSchemaDependencyASTNode *)dependencyNode;

@end
