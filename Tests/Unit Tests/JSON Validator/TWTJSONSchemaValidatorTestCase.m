//
//  TWTJSONSchemaValidatorTestCase.m
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

#import "TWTRandomizedTestCase.h"

#import "TWTJSONSchemaParser.h"
#import "TWTJSONSchemaASTNode.h"


@interface TWTJSONSchemaValidatorTestCase : TWTRandomizedTestCase

@end

@implementation TWTJSONSchemaValidatorTestCase

- (void)testScratchPad
{
    TWTJSONSchemaParser *parser = [[TWTJSONSchemaParser alloc] initWithJSONSchema:[self exampleSimpleObjectSchema]];
    NSError *error = nil;
    NSArray *warnings = nil;
    TWTJSONSchemaTopLevelASTNode *topLevelNode = [parser parseWithError:&error warnings:&warnings];

    XCTAssertNotNil(topLevelNode);
    XCTAssertNil(error);
    XCTAssertNil(warnings);

    parser = [[TWTJSONSchemaParser alloc] initWithJSONSchema:[self exampleComplexObjectSchema]];
    error = nil;
    topLevelNode = [parser parseWithError:&error warnings:&warnings];

    XCTAssertNotNil(topLevelNode);
    XCTAssertNil(error);
    XCTAssertNil(warnings);


    parser = [[TWTJSONSchemaParser alloc] initWithJSONSchema:[self exampleErrorSchema]];
    error = nil;
    topLevelNode = [parser parseWithError:&error warnings:&warnings];

    NSLog(@"%@", error);

    XCTAssertNotNil(error);
    XCTAssertNil(topLevelNode);
    XCTAssertNil(warnings);


    parser = [[TWTJSONSchemaParser alloc] initWithJSONSchema:[self exampleWarningsSchema]];
    error = nil;
    topLevelNode = [parser parseWithError:&error warnings:&warnings];

    NSLog(@"%@", warnings);

    XCTAssertNotNil(topLevelNode);
    XCTAssertNil(error);
    XCTAssertNotNil(warnings);

    // if error or warning parameters aren't given
    parser = [[TWTJSONSchemaParser alloc] initWithJSONSchema:[self exampleWarningsSchema]];
    XCTAssertNoThrow([parser parseWithError:nil warnings:nil]);
    parser = [[TWTJSONSchemaParser alloc] initWithJSONSchema:[self exampleErrorSchema]];
    XCTAssertNoThrow([parser parseWithError:nil warnings:nil]);
}

- (NSDictionary *)exampleSimpleObjectSchema
{
    return   @{ @"$schema": @"http://json-schema.org/draft-04/schema#",
                @"description": @"Specification for JSON Stat (URL: http://json-stat.org/format/",
                @"type": @"object",
                @"minProperties": @1,
                @"additionalProperties": @(true),
                @"oneOf":
                    @[ @{ @"type": @"object" },
                       @{ @"type": @"object",
                          @"additionalProperties": @(false) } ],
                @"dependencies":
                    @{ @"name" : @[ @"lastName", @"firstName" ] }
                };
}


- (NSDictionary *)exampleComplexObjectSchema
{
    return   @{ @"$schema": @"http://json-schema.org/draft-04/schema#",
                @"description": @"Specification for JSON Stat (URL: http://json-stat.org/format/",
                @"type": @"object",
                @"minProperties": @1,
                @"required" : @[ @"note", @"arrayProperty" ],
                @"additionalProperties": @{ @"enum": @[ @4, [NSNull null], @[], @(true), @"hello" ] },
                @"properties": @{ @"note": @{ @"type": @[ @"array", @"string", @"object" ] },
                                  @"arrayProperty" : @{@"type" : @"array",
                                                       @"minItems": @1,
                                                       @"uniqueItems" : @(true),
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


- (NSDictionary *)exampleErrorSchema
{
    return   @{ @"$schema": @"http://json-schema.org/draft-04/schema#",
                @"description": @"Specification for JSON Stat (URL: http://json-stat.org/format/",
                @"type": @"object",
                @"minProperties": @1,
                @"additionalProperties": @{ @"enum": @[ @4, [NSNull null], @[], @(true), @"hello" ] },
                @"properties": @{ @"note": @{ @"type": @[ @"arrayy", @"string", @"object" ] },
                                  @"arrayProperty" : @{@"type" : @"array",
                                                       @"minItems": @1,
                                                       @"uniqueItems" : @(true),
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


- (NSDictionary *)exampleWarningsSchema
{
    return   @{ @"$schema": @"http://json-schema.org/draft-04/schema#",
                @"description": @"Specification for JSON Stat (URL: http://json-stat.org/format/",
                @"type": @"object",
                @"minProperties": @1,
                @"additionalProperties": @{ @"enum": @[ @4, [NSNull null], @[], @(true), @"hello" ] },
                @"required" : @[ @"note", @"note" ],
                @"properties": @{ @"note": @{ @"type": @[ @"array", @"string", @"object" ] },
                                  @"arrayProperty" : @{@"type" : @"array",
                                                       @"minItems": @(-1),
                                                       @"uniqueItems" : @(true),
                                                       @"items": @{ @"type": @"string",
                                                                    @"maxLength" : @5.2 } },
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


@end
