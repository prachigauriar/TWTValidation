//
//  TWTJSONObjectValidator.h
//  TWTValidation
//
//  Created by Jill Cohen on 1/14/15.
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

#import <TWTValidation/TWTValidator.h>

/*!
 TWTJSONObjectValidators validate JSON objects against a JSON schema, which describes the expected format for JSON
 objects and is itself a JSON object. (See http://json-schema.org for more information about JSON schemas.)

 A TWTJSONObjectValidator is useful for validating a response from an API before mapping that response into a model
 object.
 
 TWTJSONObjectValidators are created by passing a JSON schema to `‑validatorWithJSONSchema:error:warnings:`. Then,
 `‑validateValue:` validates the object against that schema following the validation rules described by
 http://json-schema.org/latest/json-schema-validation.html. Currently, this only supports draft v4 of JSON schema
 validation (http://json-schema.org/draft-04/schema# )
 
 This class is not intended to be subclassed.
 */
@interface TWTJSONObjectValidator : TWTValidator

/*!
 The JSON schema against which values are validated.
 */
@property (nonatomic, copy, readonly, nonnull) NSDictionary *schema;


/*!
 @abstract Creates a new validator that validates JSON objects against a JSON schema, or nil if one cannot be created.
 @param schema The JSON schema describing validation rules for the validator. This must be a valid schema based on
 	draft v4 of the JSON schema validation rules in order to create a validator.
 @param outError A pointer to an error object to return indirectly if an invalid schema is passed and a validator
 	cannot be created. If NULL, no error should be returned.
 @param outWarnings A pointer to an array of warnings to return indirectly if the schema has ambiguous content but a
 	validator can still be created by making certain assumptions. If NULL, no warnings should be returned. 
 @result A validator that validates against the schema, or nil if one could not be created.
 @remarks Possible warnings and ensuing assumptions include:

    1. Keyword "$schema" is not present. Draft v4 will be assumed.

    2. Value for "pattern" is not a valid regular expression. This will not be used for validation (i.e., all values
    	will pass this rule).

    3. Value for "multipleOf" is a negative number. Zero will be used instead.

    4. Value for a keyword requiring an unsigned integer (mixLength, maxLength, minItems, maxItems, minProperties,
    	maxProperties) is negative. Zero will be used instead.
    5. Value for a keyword requiring an unsigned integer is not an integer. The rounded number will be used instead.

    6. Value for a keyword requiring an array of unique strings has non-unique elements. The repeated string(s) will
    	be ignored.
 */
+ (nullable TWTJSONObjectValidator *)validatorWithJSONSchema:(nonnull NSDictionary *)schema
                                                       error:(NSError *_Nullable *_Nullable)outError
                                                    warnings:(NSArray *_Nullable *_Nullable)outWarnings;

@end
