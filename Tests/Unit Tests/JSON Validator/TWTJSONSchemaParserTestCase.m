//
//  TWTJSONSchemaValidatorTestCase.m
//  TWTValidation
//
//  Created by Jill Cohen on 12/15/14.
//  Copyright (c) 2015 Ticketmaster. All rights reserved.
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

#import "TWTRandomizedTestCase.h"

#import <TWTValidation/TWTValidation.h>

#import "TWTJSONSchemaParser.h"
#import "TWTJSONSchemaASTNode.h"


@interface TWTJSONSchemaParserTestCase : TWTRandomizedTestCase

@end


@implementation TWTJSONSchemaParserTestCase

- (void)testParsingSimpleObjectSchema
{
    TWTJSONSchemaParser *parser = [[TWTJSONSchemaParser alloc] initWithJSONSchema:[self simpleObjectSchema]];
    NSError *error = nil;
    NSArray *warnings = nil;
    TWTJSONSchemaTopLevelASTNode *topLevelNode = [parser parseWithError:&error warnings:&warnings];

    XCTAssertNotNil(topLevelNode, @"Parser did not produce top level node from valid schema");
    XCTAssertNil(error, @"Error was returned while parsing a valid schema");
    XCTAssert(warnings.count == 0, @"Warnings were added while parsing a valid schema");
}


- (void)testParsingComplexObjectSchema
{
    TWTJSONSchemaParser *parser = [[TWTJSONSchemaParser alloc] initWithJSONSchema:[self multiLevelObjectSchema]];
    NSError *error = nil;
    NSArray *warnings = nil;
    TWTJSONSchemaTopLevelASTNode *topLevelNode = [parser parseWithError:&error warnings:&warnings];

    XCTAssertNotNil(topLevelNode, @"Parser did not produce top level node from valid schema");
    XCTAssertNil(error, @"Error was returned while parsing a valid schema");
    XCTAssert(warnings.count == 0, @"Warnings were added while parsing a valid schema");
}

- (void)testParsingErrorSchemas
{
    for (NSDictionary *schema in [self errorSchemas]) {
        TWTJSONSchemaParser *parser = [[TWTJSONSchemaParser alloc] initWithJSONSchema:schema];
        NSError *error = nil;
        NSArray *warnings = nil;
        TWTJSONSchemaTopLevelASTNode *topLevelNode = [parser parseWithError:&error warnings:&warnings];

        XCTAssertNotNil(error, @"invalid schema did not produce error %@", schema);
        XCTAssertNil(topLevelNode, @"Parser produced top level node from invalid schema");
    }
}


- (void)testParsingNilSchema
{
    XCTAssertThrows([[TWTJSONSchemaParser alloc] initWithJSONSchema:nil]);
}


- (void)testParsingMultiLevelErrorSchema
{
    TWTJSONSchemaParser *parser = [[TWTJSONSchemaParser alloc] initWithJSONSchema:[self multiLevelErrorSchema]];
    NSError *error = nil;
    NSArray *warnings = nil;
    TWTJSONSchemaTopLevelASTNode *topLevelNode = [parser parseWithError:&error warnings:&warnings];

    XCTAssertNotNil(error, @"invalid schema did not produce error");
    XCTAssertNil(topLevelNode, @"Parser produced top level node from invalid schema");
    XCTAssert(warnings.count == 0, @"Warnings were added while parsing an invalid schema");

    // if error parameter is nil
    parser = [[TWTJSONSchemaParser alloc] initWithJSONSchema:[self multiLevelErrorSchema]];
    XCTAssertNoThrow([parser parseWithError:nil warnings:nil]);
}


- (void)testParsingWarningsSchema
{
    TWTJSONSchemaParser *parser = [[TWTJSONSchemaParser alloc] initWithJSONSchema:[self warningsSchema]];
    NSError *error = nil;
    NSArray *warnings = nil;
    TWTJSONSchemaTopLevelASTNode *topLevelNode = [parser parseWithError:&error warnings:&warnings];

    XCTAssertNotNil(topLevelNode, @"Parser did not produce top level node from valid schema that had warnings");
    XCTAssertNil(error, @"Error was returned while parsing a valid schema");
    XCTAssert(warnings.count == 9, @"Returned %lu warnings, but 9 were expected", warnings.count);

    // if warning parameter is nil
    parser = [[TWTJSONSchemaParser alloc] initWithJSONSchema:[self warningsSchema]];
    XCTAssertNoThrow([parser parseWithError:nil warnings:nil]);
}


//- (void)testParsingRemoteSchema
//{
//    NSDictionary *schema = @{ TWTJSONSchemaKeywordRef : @"/Users/jillcohen/Developer/Two-Toasters-GitHub/TWTValidation/Tests/JSONSchemaCustom/remotes/objectID.json#/properties/id" };
//    TWTJSONSchemaParser *parser = [[TWTJSONSchemaParser alloc] initWithJSONSchema:schema];
//    NSError *error = nil;
//    NSArray *warnings = nil;
//    TWTJSONSchemaTopLevelASTNode *topLevelNode = [parser parseWithError:&error warnings:&warnings];
//
//    XCTAssertNotNil(topLevelNode);
//    XCTAssertNil(error);
//    XCTAssert(warnings.count == 0);
//}
//
//
//- (void)testParsingRemoteErrorScham
//{
//    NSDictionary *schema = @{ TWTJSONSchemaKeywordRef : @"/Users/jillcohen/Developer/Two-Toasters-GitHub/TWTValidation/Tests/JSONSchemaCustom/remotes/remoteErrorSchema.json" };
//    TWTJSONSchemaParser *parser = [[TWTJSONSchemaParser alloc] initWithJSONSchema:schema];
//    NSError *error = nil;
//    NSArray *warnings = nil;
//    TWTJSONSchemaTopLevelASTNode *topLevelNode = [parser parseWithError:&error warnings:&warnings];
//
//    XCTAssertNotNil(error);
//    XCTAssertNil(topLevelNode);
//}


#pragma mark - Schema examples

- (NSDictionary *)simpleObjectSchema
{
    return   @{ @"$schema": @"http://json-schema.org/draft-04/schema#",
                @"type": @"object",
                @"minProperties": @2,
                @"additionalProperties": @(NO),
                @"patternProperties" : @{ @"f" : @{} }
                };
}



- (NSDictionary *)stringSchema
{
    return   @{ @"$schema": @"http://json-schema.org/draft-04/schema#",
                @"description": @"Specification for JSON Stat (URL: http://json-stat.org/format/",
                @"type": @"string",
                @"minLength" : @1,
                @"maxLength" : @5 ,
                @"enum" : @[ @"hello", @"hi" ]
                };
}

- (NSDictionary *)multiLevelObjectSchema
{
    return   @{ @"$schema": @"http://json-schema.org/draft-04/schema#",
                @"description": @"Specification for JSON Stat (URL: http://json-stat.org/format/",
                @"type": @"object",
                @"minProperties": @1,
                @"required" : @[ @"note", @"arrayProperty" ],
                @"additionalProperties": @{ @"enum": @[ @4, [NSNull null], @[], @(YES), @"hello" ] },
                @"properties": @{ @"note": @{ @"type": @[ @"array", @"string", @"object" ] },
                                  @"arrayProperty" : @{@"type" : @"array",
                                                       @"minItems": @1,
                                                       @"uniqueItems" : @(YES),
                                                       @"items": @{ @"type": @"string",
                                                                    @"maxLength" : @5 } },
                                  @"oneOfProperty" : @{ @"oneOf":
                                                            @[ @{ @"type": @"array",
                                                                  @"items": @[ @{ @"type" : @"boolean" },
                                                                               @{ @"type" : @"null" } ] },
                                                               @{ @"type": @"object",
                                                                  @"additionalProperties": @{ @"not" :
                                                                                                  @{ @"type":@"object",
                                                                                                     @"properties" : @{ @"NOT PROPERTY" : @{} } } } },
                                                               @{ @"type" : @"number",
                                                                  @"multipleOf" : @6.2 },
                                                               @{ @"type" : @"integer",
                                                                  @"maximum" : @7,
                                                                  @"exclusiveMaximum" : @(YES)}
                                                               ] } } };

}


- (NSDictionary *)multiLevelErrorSchema
{
    return   @{ @"$schema": @"http://json-schema.org/draft-04/schema#",
                @"description": @"Specification for JSON Stat (URL: http://json-stat.org/format/",
                @"type": @"object",
                @"minProperties": @1,
                @"additionalProperties": @{ @"enum": @[ @4, [NSNull null], @[], @(YES), @"hello" ] },
                @"properties": @{ @"note": @{ @"type": @[ @"arrayy", @"string", @"object" ] },
                                  @"arrayProperty" : @{@"type" : @"array",
                                                       @"minItems": @1,
                                                       @"uniqueItems" : @(YES),
                                                       @"items": @{ @"type": @"string",
                                                                    @"maxLength" : @5 } },
                                  @"oneOfProperty" : @{ @"oneOf":
                                                            @[ @{ @"type": @"array",
                                                                  @"items": @[ @{ @"type" : @"boolean" },
                                                                               @{ @"type" : @"null" } ] },
                                                               @{ @"type": @"object",
                                                                  @"additionalProperties": @{ @"not" :
                                                                                                  @{ @"type":@"object",
                                                                                                     @"properties" : @{ @"NOT PROPERTY" : @{} } } } },
                                                               @{ @"type" : @"number",
                                                                  @"multipleOf" : @(6.2) },
                                                               @{ @"type" : @"integer",
                                                                  @"maximum" : @7,
                                                                  @"exclusiveMaximum" : @(YES)}
                                                               ] } } };

}


- (NSArray *)errorSchemas
{
    return @[ @[ @"top level object is not a dictionary"],
              @"top level object is not a dictionary",
              @NO ,
              @{ @"type" : @NO },
              @{ @"type" : @"no" },
              @{ @"type" : @[ @"string", @"integer", @"no" ] },
              @{ @"type" : @[ ] },
              @{ @"type" : @"array", @"items" : @"not a schema or array" },
              @{ @"type" : @"array", @"items" : @"not a schema or array" },
              @{ @"type" : @"array", @"items" : @[ ] },
              @{ @"minLength": @[ @1 ] },
              @{ @"maximum" : @4, @"exclusiveMaximum" : @"yes" },
              @{ @"pattern" : @1 },
              @{ @"type" : @[ ] },
              @{ @"definitions" : @[ @{ @"1" : @{} } ] },
              @{ TWTJSONSchemaKeywordSchema : @"not draft 4" },
              @{ @1 : @"not valid JSON" },
              @{ @[ @1 ]: @"not valid JSON" }
              ];
}


- (NSDictionary *)warningsSchema
{
    return   @{ @"type": @"object",
                //warning (no schema draft #)
                @"required" : @[ @"note", @"note" ], //warning: repeated elements
                @"minProperties" : @(-3.1), //warning: negative & non-integer
                @"maxProperties" : @(4.6), //warning: non-integer
                @"properties": @{ @"note": @{ @"type": @[ @"array", @"string", @"object" ] },
                                  @"regex" : @{ @"pattern" : @"*asdf" }, //warning: invalid pattern
                                  @"arrayProperty" : @{@"type" : @"array",
                                                       @"minItems": @(-1), //warning: negative
                                                       @"uniqueItems" : @(YES),
                                                       @"items": @{ @"type": @"string",
                                                                    @"maxLength" : @5.2 } }, //warning: non-integer
                                  @"oneOfProperty" : @{ @"oneOf":
                                                            @[ @{ @"type": @"array",
                                                                  @"items": @[ @{ @"type" : @"boolean" },
                                                                               @{ @"type" : @"null" } ] },
                                                               @{ @"type": @"object" },
                                                               @{ @"type" : @"number",
                                                                  @"multipleOf" : @(-6.2) }, //warning: negative
                                                               @{ @"type" : @"integer",
                                                                  @"maximum" : @7,
                                                                  @"exclusiveMaximum" : @(YES)}
                                                               ] }
                                  },
                @"dependencies" : @{ @"note" : @[ @"arrayProperty", @"arrayProperty"] } //warning: repeated elements
                };
    
}

@end
