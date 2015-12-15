//
//  TWTRandomizedTestCase+TWTJSONSchemaTestDirectories.m
//  TWTValidation
//
//  Created by Jill Cohen on 12/14/15.
//  Copyright © 2015 Ticketmaster Entertainment, Inc. All rights reserved.
//

#import "TWTRandomizedTestCase+TWTJSONSchemaTestDirectories.h"


@implementation TWTRandomizedTestCase (TWTJSONSchemaTestDirectories)

+ (NSString *)twt_pathForTestSuite
{
    // To change the directory of the test suite, edit the value for JSON_SCHEMA_VALIDATOR_TEST_SUITE in Build Settings
    return [NSString stringWithUTF8String:STRING_FROM_MACRO(JSON_SCHEMA_VALIDATOR_TEST_SUITE)];
}


+ (NSString *)twt_pathForDraft4TestSuite
{
    return [[self twt_pathForTestSuite] stringByAppendingString:@"/tests/draft4"];
}


+ (NSString *)twt_pathForCustomTests
{
    // To change the directory of the custom tests, edit the value for JSON_SCHEMA_VALIDATOR_CUSTOM_TESTS in Build Settings
    return [NSString stringWithUTF8String:STRING_FROM_MACRO(JSON_SCHEMA_VALIDATOR_CUSTOM_TESTS)];
}

@end
