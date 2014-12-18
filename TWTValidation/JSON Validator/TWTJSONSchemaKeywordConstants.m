//
//  TWTJSONSchemaKeywordConstants.m
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

#import "TWTJSONSchemaKeywordConstants.h"

// Any instance type
NSString *const kTWTJSONSchemaKeywordTitle = @"title";
NSString *const kTWTJSONSchemaKeywordDescription = @"description";
NSString *const kTWTJSONSchemaKeywordType = @"type";
NSString *const kTWTJSONSchemaKeywordEnum = @"enum";
NSString *const kTWTJSONSchemaKeywordAnyOf = @"anyOf";
NSString *const kTWTJSONSchemaKeywordAllOf = @"allOf";
NSString *const kTWTJSONSchemaKeywordOneOf = @"oneOf";
NSString *const kTWTJSONSchemaKeywordNot = @"not";
NSString *const kTWTJSONSchemaKeywordDefinitions = @"definitions";

// Arrays
NSString *const kTWTJSONSchemaKeywordItems = @"items";
NSString *const kTWTJSONSchemaKeywordAdditionalItems = @"additionalItems";
NSString *const kTWTJSONSchemaKeywordMaxItems = @"maxItems";
NSString *const kTWTJSONSchemaKeywordMinItems = @"minItems";
NSString *const kTWTJSONSchemaKeywordUniqueItems = @"uniqueItems";

// Numbers
NSString *const kTWTJSONSchemaKeywordMultipleOf = @"multipleOf";
NSString *const kTWTJSONSchemaKeywordMaximum = @"maximum";
NSString *const kTWTJSONSchemaKeywordMinimum = @"minimum";
NSString *const kTWTJSONSchemaKeywordExclusiveMaximum = @"exclusiveMaximum";
NSString *const kTWTJSONSchemaKeywordExclusiveMinimum = @"exclusiveMinimum";

// Objects
NSString *const kTWTJSONSchemaKeywordMaxProperties = @"maxProperties";
NSString *const kTWTJSONSchemaKeywordMinProperties = @"minProperties";
NSString *const kTWTJSONSchemaKeywordRequired = @"required";
NSString *const kTWTJSONSchemaKeywordProperties = @"properties";
NSString *const kTWTJSONSchemaKeywordAdditionalProperties = @"additionalProperties";
NSString *const kTWTJSONSchemaKeywordPatternProperties = @"patternProperties";
NSString *const kTWTJSONSchemaKeywordDependencies = @"dependencies";

// Strings
NSString *const kTWTJSONSchemaKeywordMaxLength = @"maxLength";
NSString *const kTWTJSONSchemaKeywordMinLength = @"minLength";
NSString *const kTWTJSONSchemaKeywordPattern = @"pattern";


// Top Level
NSString *const kTWTJSONSchemaKeywordSchema = @"$schema";
NSString *const kTWTJSONSchemaKeywordDraft4Path = @"http://json-schema.org/draft-04/schema#";
