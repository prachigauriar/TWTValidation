//
//  main.m
//  JSONSchemaPrettyPrinter
//
//  Created by Jill Cohen on 1/9/15.
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

@import Foundation;

#import <TWTValidation/TWTValidation.h>

#import <TWTValidation/TWTJSONSchemaASTCommon.h>
#import <TWTValidation/TWTJSONSchemaParser.h>
#import "TWTJSONSchemaPrettyPrinter.h"
#import <TWTValidation/TWTJSONSchemaKeywordConstants.h>


static const BOOL debug = YES;

static NSString *const TWTJSONSchemaKey = @"schema";


int main(int argc, const char *argv[])
{
    @autoreleasepool {
        NSArray *arguments = [[NSProcessInfo processInfo] arguments];
        if (arguments.count != 2) {
            fprintf(stderr, "Usage: %s json_schema_file\n", argv[0]);
            return 1;
        }

        NSString *JSONSchemaTestFile = [arguments[1] stringByExpandingTildeInPath];
        NSError *error = nil;
        id JSONObject = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:JSONSchemaTestFile] options:0 error:&error];

        if (error) {
            fprintf(stderr, "Error reading file: %s\n", [error.description UTF8String]);
            return -1;
        }

        if (![JSONObject isKindOfClass:[NSArray class]]) {
            fprintf(stderr, "Expected array of dictionaries with schema as value for ""schema"" key.\n");
            return -1;
        }

        NSMutableArray *inputSchemas = [[NSMutableArray alloc] init];
        for (NSDictionary *testDictionary in JSONObject) {
            NSDictionary *schema = testDictionary[@"schema"];
            if (!schema) {
                fprintf(stderr, "Expected array of dictionaries with schema as value for ""schema"" key.\n");
                return -1;
            }

            [inputSchemas addObject:schema];
        }

        NSMutableArray *testOutputs = [[NSMutableArray alloc] init];
        for (NSDictionary *testSchema in inputSchemas) {
            error = nil;
            NSArray *warnings = nil;
            TWTJSONSchemaParser *parser = [[TWTJSONSchemaParser alloc] initWithJSONSchema:testSchema];
            TWTJSONSchemaTopLevelASTNode *topLevelNode = [parser parseWithError:&error warnings:&warnings];

            if (error) {
                fprintf(stderr, "Error parsing schema: %s\n", [error.localizedDescription UTF8String]);
                [testOutputs addObject:@{ @"ERROR" : error.localizedDescription} ];
            } else {

                if (debug && warnings.count > 0) {
                    fprintf(stderr, "Warnings parsing schema: %s\n", [warnings.description UTF8String]);
                }

                TWTJSONSchemaPrettyPrinter *prettyPrinter = [[TWTJSONSchemaPrettyPrinter alloc] init];
                [testOutputs addObject:[prettyPrinter objectFromTopLevelNode:topLevelNode]];
            }
        }

        error = nil;
        NSData *schemaData = [NSJSONSerialization dataWithJSONObject:testOutputs options:NSJSONWritingPrettyPrinted error:&error];

        if (error) {
            fprintf(stderr, "Error converting to JSON: %s\n", [error.description UTF8String]);
            return -1;
        }

        NSString *schemaString = [[NSString alloc] initWithData:schemaData encoding:NSUTF8StringEncoding];
        printf("%s\n", [schemaString UTF8String]);
    }

    return 0;
}
