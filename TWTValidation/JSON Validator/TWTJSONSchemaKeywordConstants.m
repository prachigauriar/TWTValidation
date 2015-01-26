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

#import <TWTValidation/TWTJSONSchemaKeywordConstants.h>


// Any instance type
NSString *const TWTJSONSchemaKeywordTitle = @"title";
NSString *const TWTJSONSchemaKeywordDescription = @"description";
NSString *const TWTJSONSchemaKeywordType = @"type";
NSString *const TWTJSONSchemaKeywordEnum = @"enum";
NSString *const TWTJSONSchemaKeywordAnyOf = @"anyOf";
NSString *const TWTJSONSchemaKeywordAllOf = @"allOf";
NSString *const TWTJSONSchemaKeywordOneOf = @"oneOf";
NSString *const TWTJSONSchemaKeywordNot = @"not";
NSString *const TWTJSONSchemaKeywordDefinitions = @"definitions";

// Arrays
NSString *const TWTJSONSchemaKeywordItems = @"items";
NSString *const TWTJSONSchemaKeywordAdditionalItems = @"additionalItems";
NSString *const TWTJSONSchemaKeywordMaxItems = @"maxItems";
NSString *const TWTJSONSchemaKeywordMinItems = @"minItems";
NSString *const TWTJSONSchemaKeywordUniqueItems = @"uniqueItems";

// Numbers
NSString *const TWTJSONSchemaKeywordMultipleOf = @"multipleOf";
NSString *const TWTJSONSchemaKeywordMaximum = @"maximum";
NSString *const TWTJSONSchemaKeywordMinimum = @"minimum";
NSString *const TWTJSONSchemaKeywordExclusiveMaximum = @"exclusiveMaximum";
NSString *const TWTJSONSchemaKeywordExclusiveMinimum = @"exclusiveMinimum";

// Objects
NSString *const TWTJSONSchemaKeywordMaxProperties = @"maxProperties";
NSString *const TWTJSONSchemaKeywordMinProperties = @"minProperties";
NSString *const TWTJSONSchemaKeywordRequired = @"required";
NSString *const TWTJSONSchemaKeywordProperties = @"properties";
NSString *const TWTJSONSchemaKeywordAdditionalProperties = @"additionalProperties";
NSString *const TWTJSONSchemaKeywordPatternProperties = @"patternProperties";
NSString *const TWTJSONSchemaKeywordDependencies = @"dependencies";

// Strings
NSString *const TWTJSONSchemaKeywordMaxLength = @"maxLength";
NSString *const TWTJSONSchemaKeywordMinLength = @"minLength";
NSString *const TWTJSONSchemaKeywordPattern = @"pattern";


// Top Level
NSString *const TWTJSONSchemaKeywordSchema = @"$schema";
NSString *const TWTJSONSchemaKeywordDraft4Path = @"http://json-schema.org/draft-04/schema#";

// Valid types
NSString *const TWTJSONSchemaTypeKeywordAny = @"any";
NSString *const TWTJSONSchemaTypeKeywordArray = @"array";
NSString *const TWTJSONSchemaTypeKeywordBoolean = @"boolean";
NSString *const TWTJSONSchemaTypeKeywordInteger = @"integer";
NSString *const TWTJSONSchemaTypeKeywordNull = @"null";
NSString *const TWTJSONSchemaTypeKeywordNumber = @"number";
NSString *const TWTJSONSchemaTypeKeywordObject = @"object";
NSString *const TWTJSONSchemaTypeKeywordString = @"string";
