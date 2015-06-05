//
//  TWTJSONSchemaKeywordConstants.h
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

@import Foundation;


// Any instance type
extern NSString *const TWTJSONSchemaKeywordTitle;
extern NSString *const TWTJSONSchemaKeywordDescription;
extern NSString *const TWTJSONSchemaKeywordType;
extern NSString *const TWTJSONSchemaKeywordEnum;
extern NSString *const TWTJSONSchemaKeywordAnyOf;
extern NSString *const TWTJSONSchemaKeywordAllOf;
extern NSString *const TWTJSONSchemaKeywordOneOf;
extern NSString *const TWTJSONSchemaKeywordNot;
extern NSString *const TWTJSONSchemaKeywordDefinitions;
extern NSString *const TWTJSONSchemaKeywordRef;

// Arrays
extern NSString *const TWTJSONSchemaKeywordItems;
extern NSString *const TWTJSONSchemaKeywordAdditionalItems;
extern NSString *const TWTJSONSchemaKeywordMaxItems;
extern NSString *const TWTJSONSchemaKeywordMinItems;
extern NSString *const TWTJSONSchemaKeywordUniqueItems;

// Numbers
extern NSString *const TWTJSONSchemaKeywordMultipleOf;
extern NSString *const TWTJSONSchemaKeywordMaximum;
extern NSString *const TWTJSONSchemaKeywordMinimum;
extern NSString *const TWTJSONSchemaKeywordExclusiveMaximum;
extern NSString *const TWTJSONSchemaKeywordExclusiveMinimum;

// Objects
extern NSString *const TWTJSONSchemaKeywordMaxProperties;
extern NSString *const TWTJSONSchemaKeywordMinProperties;
extern NSString *const TWTJSONSchemaKeywordRequired;
extern NSString *const TWTJSONSchemaKeywordProperties;
extern NSString *const TWTJSONSchemaKeywordAdditionalProperties;
extern NSString *const TWTJSONSchemaKeywordPatternProperties;
extern NSString *const TWTJSONSchemaKeywordDependencies;

// Strings
extern NSString *const TWTJSONSchemaKeywordMaxLength;
extern NSString *const TWTJSONSchemaKeywordMinLength;
extern NSString *const TWTJSONSchemaKeywordPattern;

// Top level
extern NSString *const TWTJSONSchemaKeywordSchema;
extern NSString *const TWTJSONSchemaKeywordDraft4Path; 

// Valid types
extern NSString *const TWTJSONSchemaTypeKeywordAny;
extern NSString *const TWTJSONSchemaTypeKeywordArray;
extern NSString *const TWTJSONSchemaTypeKeywordBoolean;
extern NSString *const TWTJSONSchemaTypeKeywordInteger;
extern NSString *const TWTJSONSchemaTypeKeywordNull;
extern NSString *const TWTJSONSchemaTypeKeywordNumber;
extern NSString *const TWTJSONSchemaTypeKeywordObject;
extern NSString *const TWTJSONSchemaTypeKeywordString;
