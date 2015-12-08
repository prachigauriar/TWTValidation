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

- (void)testJSONSchemaParser
{
    TWTJSONSchemaParser *parser = [[TWTJSONSchemaParser alloc] initWithJSONSchema:[self simpleObjectSchema]];
    NSError *error = nil;
    NSArray *warnings = nil;
    TWTJSONSchemaTopLevelASTNode *topLevelNode = [parser parseWithError:&error warnings:&warnings];

    XCTAssertNotNil(topLevelNode);
    XCTAssertNil(error);
    XCTAssertFalse(warnings.count);

    parser = [[TWTJSONSchemaParser alloc] initWithJSONSchema:[self complexObjectSchema]];
    error = nil;
    topLevelNode = [parser parseWithError:&error warnings:&warnings];

    XCTAssertNotNil(topLevelNode);
    XCTAssertNil(error);
    XCTAssertFalse(warnings.count);

    parser = [[TWTJSONSchemaParser alloc] initWithJSONSchema:[self errorSchema]];
    error = nil;
    topLevelNode = [parser parseWithError:&error warnings:&warnings];

    XCTAssertNotNil(error);
    XCTAssertNil(topLevelNode);
    XCTAssertFalse(warnings.count);

    parser = [[TWTJSONSchemaParser alloc] initWithJSONSchema:[self warningsSchema]];
    error = nil;
    topLevelNode = [parser parseWithError:&error warnings:&warnings];

    XCTAssertNotNil(topLevelNode);
    XCTAssertNil(error);
    XCTAssertTrue(warnings.count);

    // if error or warning parameters aren't given
    parser = [[TWTJSONSchemaParser alloc] initWithJSONSchema:[self warningsSchema]];
    XCTAssertNoThrow([parser parseWithError:nil warnings:nil]);
    parser = [[TWTJSONSchemaParser alloc] initWithJSONSchema:[self errorSchema]];
    XCTAssertNoThrow([parser parseWithError:nil warnings:nil]);
}



- (NSDictionary *)simpleObjectSchema
{
    return   @{ @"$schema": @"http://json-schema.org/draft-04/schema#",
                @"description": @"Specification for JSON Stat (URL: http://json-stat.org/format/",
                @"type": @"object",
                @"additionalProperties": @(NO),
                @"patternProperties" : @{ @"f" : @{} }
                };
}


- (NSDictionary *)complexObjectSchema
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


- (NSDictionary *)errorSchema
{
    return   @{ @"$schema": @"http://json-schema.org/draft-04/schema#",
                @"description": @"Specification for JSON Stat (URL: http://json-stat.org/format/",
                @"type": @"object",
                @"minProperties": @1,
                @"additionalProperties": @{ @"enum": @[ @4, [NSNull null], @[], @(YES), @"hello" ] },
                @"properties": @{ @"note": @{ @"type": @[ @"arrayy", @"string", @"object" ] }, //"arrayy" is not a valid type
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


- (NSDictionary *)warningsSchema
{
    return   @{ @"$schema": @"http://json-schema.org/draft-04/schema#",
                @"description": @"Specification for JSON Stat (URL: http://json-stat.org/format/",
                @"type": @"object",
                @"minProperties": @1,
                @"additionalProperties": @{ @"enum": @[ @4, [NSNull null], @[], @(YES), @"hello" ] },
                @"required" : @[ @"note", @"note" ],
                @"properties": @{ @"note": @{ @"type": @[ @"array", @"string", @"object" ] },
                                  @"arrayProperty" : @{@"type" : @"array",
                                                       @"minItems": @(-1),
                                                       @"uniqueItems" : @(YES),
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
