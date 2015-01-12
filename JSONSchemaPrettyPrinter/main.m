//
//  main.m
//  JSONSchemaPrettyPrinter
//
//  Created by Jill Cohen on 1/9/15.
//  Copyright (c) 2015 Two Toasters, LLC. All rights reserved.
//

@import Foundation;

#import <TWTValidation/TWTValidation.h>

#import <TWTValidation/TWTJSONSchemaASTCommon.h>
#import <TWTValidation/TWTJSONSchemaParser.h>
#import "TWTJSONSchemaPrettyPrinter.h"
#import <TWTValidation/TWTJSONSchemaKeywordConstants.h>


static NSString *const TWTJSONSchemaKey = @"schema";


int main(int argc, const char *argv[])
{
    @autoreleasepool {
        NSArray *arguments = [[NSProcessInfo processInfo] arguments];
        if (arguments.count != 2) {
            fprintf(stderr, "Usage: %s json_schema\n", argv[0]);
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
                fprintf(stderr, "Error parsing schema: %s\n", [error.description UTF8String]);
                return -1;
            }

            if (warnings.count > 0) {
                fprintf(stderr, "Warnings parsing schema: %s\n", [warnings.description UTF8String]);
            }

            TWTJSONSchemaPrettyPrinter *prettyPrinter = [[TWTJSONSchemaPrettyPrinter alloc] init];
            [testOutputs addObject:[prettyPrinter objectFromTopLevelNode:topLevelNode]];
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
