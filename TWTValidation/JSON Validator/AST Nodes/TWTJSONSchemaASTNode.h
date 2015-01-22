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


@interface TWTJSONSchemaASTNode : NSObject

@property (nonatomic, copy) NSString *schemaTitle;
@property (nonatomic, copy) NSString *schemaDescription;
@property (nonatomic, assign, getter = isTypeExplicit) BOOL typeExplicit;
@property (nonatomic, copy, readonly) NSSet *validTypes;
@property (nonatomic, copy, readonly) NSSet *validClasses;
@property (nonatomic, copy) NSSet *validValues; //enum keyword
@property (nonatomic, copy) NSArray *andSchemas; // allOf
@property (nonatomic, copy) NSArray *orSchemas; // anyOf
@property (nonatomic, copy) NSArray *exactlyOneOfSchemas; // oneOf
@property (nonatomic, strong) TWTJSONSchemaASTNode *notSchema;
@property (nonatomic, copy) NSDictionary *definitions;

- (void)acceptProcessor:(id<TWTJSONSchemaASTProcessor>)processor;

@end
