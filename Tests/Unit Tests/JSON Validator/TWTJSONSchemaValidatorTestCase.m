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
#import "TWTJSONObjectValidator.h"

@interface TWTJSONSchemaValidatorTestCase : TWTRandomizedTestCase

@end

@implementation TWTJSONSchemaValidatorTestCase

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

//    NSLog(@"%@", error);

    XCTAssertNotNil(error);
    XCTAssertNil(topLevelNode);
    XCTAssertFalse(warnings.count);

    parser = [[TWTJSONSchemaParser alloc] initWithJSONSchema:[self warningsSchema]];
    error = nil;
    topLevelNode = [parser parseWithError:&error warnings:&warnings];

//    NSLog(@"%@", warnings);

    XCTAssertNotNil(topLevelNode);
    XCTAssertNil(error);
    XCTAssertTrue(warnings.count);

    // if error or warning parameters aren't given
    parser = [[TWTJSONSchemaParser alloc] initWithJSONSchema:[self warningsSchema]];
    XCTAssertNoThrow([parser parseWithError:nil warnings:nil]);
    parser = [[TWTJSONSchemaParser alloc] initWithJSONSchema:[self errorSchema]];
    XCTAssertNoThrow([parser parseWithError:nil warnings:nil]);
}


- (void)testJSONObjectValidator
{
    NSError *error = nil;
    TWTJSONObjectValidator *validator = [TWTJSONObjectValidator validatorWithJSONSchema:[self simpleStringSchema] error:&error warnings:nil];
    XCTAssertNotNil(validator);

    XCTAssertTrue([validator validateValue:@"hello" error:&error]);
    XCTAssertFalse([validator validateValue:@"hellooooo" error:&error]);
    XCTAssertFalse([validator validateValue:@"hey" error:nil]);
//    NSLog(@"%@", error);

    error = nil;
    validator = [TWTJSONObjectValidator validatorWithJSONSchema:[self errorSchema] error:&error warnings:nil];
    XCTAssertNil(validator);
    XCTAssertNotNil(error);
//    NSLog(@"%@", error);

    validator = [TWTJSONObjectValidator validatorWithJSONSchema:[self simpleObjectSchema] error:nil warnings:nil];
    NSDictionary *pass = @{ @"foo" : @1 };

    NSDictionary *fail = @{ @"foo" : @3,
                            @"bah" : @"hey" };

    XCTAssertTrue([validator validateValue:pass error:nil]);
    XCTAssertFalse([validator validateValue:fail error:nil]);

    // array

    validator  = [TWTJSONObjectValidator validatorWithJSONSchema:[self arraySchema1] error:nil warnings:nil];
    NSArray *passing = @[ @[ @1, @2], @[ @3 ], @"hello" ];
    NSArray *failing = @[ @[ @1.2 ], @[ ], @[ @1, @2, @3, @4], @[@2, @2] ];

    for (NSArray *array in passing) {
        XCTAssertTrue([validator validateValue:array error:nil]);
    }

    for (NSArray *array in failing) {
        XCTAssertFalse([validator validateValue:array error:nil]);
    }

    validator  = [TWTJSONObjectValidator validatorWithJSONSchema:[self arraySchema2] error:nil warnings:nil];
    passing = @[ @[ @1, @2], @[ @3 ], @"hello", @[ @1, @2, @"hi"] ];
    failing = @[ @[ @1.2 ], @[ ], @[ @1, @2, @"hello", @4], @[@2, @2],  @[ @1, @2, @30]];

    for (NSArray *array in passing) {
        XCTAssertTrue([validator validateValue:array error:nil], @"%@", array);
    }

    for (NSArray *array in failing) {
        XCTAssertFalse([validator validateValue:array error:nil], @"%@", array);
    }

// ambiguous

    validator  = [TWTJSONObjectValidator validatorWithJSONSchema:[self ambiguousSchema1] error:nil warnings:nil];
    passing = @[ @"hello", @1, [NSNull null] ];
    failing = @[ @[ @1 ], @{ }, @1.2];

    for (id item in passing) {
        XCTAssertTrue([validator validateValue:item error:nil], @"%@", item);
    }

    for (id item in failing) {
        XCTAssertFalse([validator validateValue:item error:nil], @"%@", item);
    }
    
    validator  = [TWTJSONObjectValidator validatorWithJSONSchema:[self ambiguousSchema2] error:nil warnings:nil];
    passing = @[ @"hello", @[ @1, @2], @{ }, [NSNull null], @2, @2.5];
    failing = @[ @"helloooo", @[ @1 ]];

    for (id item in passing) {
        XCTAssertTrue([validator validateValue:item error:nil], @"%@", item);
    }

    for (id item in failing) {
        XCTAssertFalse([validator validateValue:item error:nil], @"%@", item);
    }

    // always passing
    validator = [TWTJSONObjectValidator validatorWithJSONSchema:@{} error:nil warnings:nil];
    passing = @[ @"hello", @[ @1, @2], @{ }, [NSNull null], @2, @2.5, @"helloooo", @[ @1 ]];

    for (id item in passing) {
        XCTAssertTrue([validator validateValue:item error:nil], @"%@", item);
    }

}

- (NSDictionary *)arraySchema1
{
    return @{ @"uniqueItems" : @(YES),
              @"items" : @{ @"type" : @"integer" },
              @"minItems" : @1,
              @"maxItems" : @3 };
}


- (NSDictionary *)arraySchema2
{
    return @{ @"uniqueItems" : @(YES),
              @"items" : @[ @{ @"type" : @"integer" }, @{@"type" : @"integer" }, @{ @"type" : @"string" } ],
              @"additionalItems" : @(NO),
              @"minItems" : @1,
              @"maxItems" : @3 };
}


- (NSDictionary *)ambiguousSchema1
{
    return @{ @"type" : @[ @"string", @"integer", @"null"] };
}


- (NSDictionary *)ambiguousSchema2
{
    return @{ @"maxLength" : @5,
              @"minItems" : @2 };
}


- (void)testOldValidators
{
    id null = [NSNull null];
    NSString *invalid = @"bad";
//
//    TWTValueSetValidator *validator = [[TWTValueSetValidator alloc] initWithValidValues:[NSSet setWithObjects:@"hello", [NSNull null], nil]];

    TWTValueValidator *validator = [TWTValueValidator valueValidatorWithClass:[NSNull class] allowsNil:NO allowsNull:YES];
    XCTAssertTrue([validator validateValue:null error:nil]);
    XCTAssertFalse([validator validateValue:invalid error:nil]);


//    NSDictionary *object = @{ @"stringProperty" : @"string" };
//    TWTStringValidator *stringValidator = [TWTStringValidator stringValidatorWithPrefix:@"str" caseSensitive:NO];
//    TWTNumberValidator *numberValidator = [[TWTNumberValidator alloc] initWithMinimum:@1 maximum:@100];
//    TWTKeyValuePairValidator *stringPropertyValidator = [[TWTKeyValuePairValidator alloc] initWithKey:@"stringProperty" valueValidator:stringValidator];
//    TWTKeyValuePairValidator *numberPropertyValidator = [[TWTKeyValuePairValidator alloc] initWithKey:@"numberProperty" valueValidator:numberValidator];
//    TWTKeyedCollectionValidator *objectValidator = [[TWTKeyedCollectionValidator alloc] initWithCountValidator:nil keyValidators:nil valueValidators:nil keyValuePairValidators:@[ stringPropertyValidator, numberPropertyValidator]];
//
//    XCTAssertTrue([objectValidator validateValue:object error:nil]);

}


- (NSDictionary *)simpleObjectSchema
{
    return   @{ @"$schema": @"http://json-schema.org/draft-04/schema#",
                @"description": @"Specification for JSON Stat (URL: http://json-stat.org/format/",
                @"type": @"object",
//                @"minProperties": @2,
                @"additionalProperties": @(NO),
//                @"properties" : @{ @"foo" : @{ @"type" : @"integer"} },
                @"patternProperties" : @{ @"f" : @{} }
//                @"oneOf":
//                    @[
//                        @{ @"properties": @{ @"foo" : @{ @"type" : @"integer"} },
//                           @"additionalProperties" : @1 },
//                        @{ @"properties": @{ @"bah" : @{ @"type" : @"integer"} },
//                           @"additionalProperties" : @1  } ]
//                @"dependencies":
//                    @{ @"foo" : @[ @"bah" ] }
                };
}



- (NSDictionary *)simpleStringSchema
{
    return   @{ @"$schema": @"http://json-schema.org/draft-04/schema#",
                @"description": @"Specification for JSON Stat (URL: http://json-stat.org/format/",
                @"type": @"string",
                @"minLength" : @1,
                @"maxLength" : @5 ,
                @"enum" : @[ @"hello", @"hi" ]};
//                @"oneOf":
//                    // Non-sensical, since it can't be a string and an number
//                @[ @{ @"type": @"number",
//                      @"multipleOf": @(3.2) },
//                   @{ @"type": @"integer" } ]
//                };
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
