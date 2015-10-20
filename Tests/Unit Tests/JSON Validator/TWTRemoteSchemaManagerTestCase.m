//
//  TWTRemoteSchemaManagerTestCase.m
//  TWTValidation
//
//  Created by Jill Cohen on 10/19/15.
//  Copyright © 2015 Ticketmaster Entertainment, Inc. All rights reserved.
//

#import "TWTRandomizedTestCase.h"

#import <TWTValidation/TWTJSONRemoteSchemaManager.h>
#import <TWTValidation/TWTJSONSchemaReferenceASTNode.h>


@interface TWTRemoteSchemaManagerTestCase : TWTRandomizedTestCase


@end

@implementation TWTRemoteSchemaManagerTestCase


- (void)testFilePathToSchema
{
    NSString *integerFilePath = @"/Users/jillcohen/Developer/Two-Toasters-GitHub/TWTValidation/Tests/JSONSchemaTestSuite/remotes/integer.json";
    TWTJSONRemoteSchemaManager *remoteManager = [[TWTJSONRemoteSchemaManager alloc] init];

    TWTJSONSchemaReferenceASTNode *referenceNode = [[TWTJSONSchemaReferenceASTNode alloc] init];
    BOOL success = [remoteManager attemptToConfigureFilePath:integerFilePath onReferenceNode:referenceNode];

    XCTAssertTrue(success, @"Valid file path was not successful");
    XCTAssertEqualObjects(integerFilePath, referenceNode.filePath, @"file path not configured correctly");
    XCTAssertNil(referenceNode.referencePathComponents, @"path componenets set when non-existent");

    XCTAssertNotNil([remoteManager remoteNodeForReferenceNode:referenceNode], @"Cannot retreive remote referant node at path %@", integerFilePath);
}


- (void)testFilePathToSubschema
{
    NSArray *expectedComponents = @[ @"#", @"properties", @"id" ];
    NSString *subschemasFilePath = @"/Users/jillcohen/Developer/Two-Toasters-GitHub/TWTValidation/Tests/JSONSchemaCustom/remotes/objectID.json";
    NSString *filePathWithComponents = [subschemasFilePath stringByAppendingString:[expectedComponents componentsJoinedByString:@"/"]];
    TWTJSONRemoteSchemaManager *remoteManager = [[TWTJSONRemoteSchemaManager alloc] init];
    TWTJSONSchemaReferenceASTNode *referenceNode = [[TWTJSONSchemaReferenceASTNode alloc] init];

    BOOL success = [remoteManager attemptToConfigureFilePath:filePathWithComponents onReferenceNode:referenceNode];

    XCTAssertTrue(success, @"Valid file path was not successful");
    XCTAssertEqualObjects(subschemasFilePath, referenceNode.filePath, @"file path not configured correctly");
    XCTAssertEqualObjects(expectedComponents, referenceNode.referencePathComponents, @"path componenets not configured correctly");

    XCTAssertNotNil([remoteManager remoteNodeForReferenceNode:referenceNode], @"Cannot retreive remote referant node at path %@", filePathWithComponents);

}


- (void)testDraft4File
{
    TWTJSONRemoteSchemaManager *remoteManager = [[TWTJSONRemoteSchemaManager alloc] init];

    TWTJSONSchemaReferenceASTNode *referenceNode = [[TWTJSONSchemaReferenceASTNode alloc] init];
    BOOL success = [remoteManager attemptToConfigureFilePath:TWTJSONSchemaKeywordDraft4Path onReferenceNode:referenceNode];

    XCTAssertTrue(success, @"JSON draft 4 file path was not successful");
    XCTAssertNotNil([remoteManager remoteNodeForReferenceNode:referenceNode], @"Cannot retreive remote referant node at path %@", TWTJSONSchemaKeywordDraft4Path);
}


- (void)testFailureCase
{
    NSString *invalidPath = UMKRandomAlphanumericString();

    TWTJSONRemoteSchemaManager *remoteManager = [[TWTJSONRemoteSchemaManager alloc] init];
    TWTJSONSchemaReferenceASTNode *referenceNode = [[TWTJSONSchemaReferenceASTNode alloc] init];
    BOOL success = YES;
    success = [remoteManager attemptToConfigureFilePath:invalidPath onReferenceNode:referenceNode];
    XCTAssertFalse(success, @"Invalid file path was successful");
}

@end
