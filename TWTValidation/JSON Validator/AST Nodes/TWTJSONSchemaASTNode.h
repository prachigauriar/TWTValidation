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


#import <Foundation/Foundation.h>


#pragma mark Constants
typedef NS_ENUM(NSUInteger, TWTJSONValueType) {
    TWTJSONValueTypeFalse,
    TWTJSONValueTypeTrue,
    TWTJSONValueTypeSchema
};


#pragma mark -

@protocol TWTJSONSchemaASTProcessor;


@interface TWTJSONSchemaASTNode : NSObject

@property (nonatomic, copy) NSString *schemaTitle;
@property (nonatomic, copy) NSString *schemaDescription;
@property (nonatomic, copy) NSSet *validValues;
@property (nonatomic, copy) NSSet *validTypes;
@property (nonatomic, copy) NSArray *allOfSchemas;
@property (nonatomic, copy) NSArray *anyOfSchemas;
@property (nonatomic, copy) NSArray *oneOfSchemas;
@property (nonatomic, copy) NSDictionary *notSchema;
@property (nonatomic, copy) NSDictionary *definitions;

- (void)acceptProcessor:(id<TWTJSONSchemaASTProcessor>)processor;

@end


#pragma mark - TWTJSONSchemaASTProcessor Protocol

@class TWTJSONSchemaArrayASTNode;
@class TWTJSONSchemaBooleanASTNode;
@class TWTJSONSchemaNumberASTNode;
@class TWTJSONSchemaObjectASTNode;
@class TWTJSONSchemaStringASTNode;


@protocol TWTJSONSchemaASTProcessor <NSObject>

- (void)processArrayNode:(TWTJSONSchemaArrayASTNode *)arrayNode;
- (void)processBooleanNode:(TWTJSONSchemaBooleanASTNode *)booleanNode;
- (void)processNumberNode:(TWTJSONSchemaNumberASTNode *)numberNode;
- (void)processObjectNode:(TWTJSONSchemaObjectASTNode *)objectNode;
- (void)processStringNode:(TWTJSONSchemaStringASTNode *)stringNode;

@end
