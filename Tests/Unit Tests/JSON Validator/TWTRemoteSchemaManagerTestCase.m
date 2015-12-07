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


- (void)testMutlipleFileReferences
{
    NSString *filePath = @"/Users/jillcohen/Developer/Two-Toasters-GitHub/TWTValidation/Tests/JSONSchemaCustom/remotes/objectID.json";
    NSString *components1 = @"#";
    NSString *components2 = @"#/properties/id";
    TWTJSONRemoteSchemaManager *remoteManager = [[TWTJSONRemoteSchemaManager alloc] init];

    TWTJSONSchemaReferenceASTNode *referenceNode1 = [[TWTJSONSchemaReferenceASTNode alloc] init];
    TWTJSONSchemaReferenceASTNode *referenceNode2 = [[TWTJSONSchemaReferenceASTNode alloc] init];

    BOOL success = [remoteManager attemptToConfigureFilePath:[filePath stringByAppendingString:components1] onReferenceNode:referenceNode1];

    XCTAssertTrue(success, @"Valid file path was not successful");
    XCTAssertEqualObjects(filePath, referenceNode1.filePath, @"file path not configured correctly");
    XCTAssertEqualObjects(referenceNode1.referencePathComponents, @[components1], @"path componenets not set correctly");

    success = [remoteManager attemptToConfigureFilePath:[filePath stringByAppendingString:components2] onReferenceNode:referenceNode2];
    XCTAssertTrue(success, @"File path that was previously loaded was not successful");
    XCTAssertEqualObjects(filePath, referenceNode2.filePath, @"File path that was previously loaded not configured correctly");
    XCTAssertEqualObjects(referenceNode2.referencePathComponents, [components2 componentsSeparatedByString:@"/"], @"Path componenets for file path that was previously loaded not set correctly");

    XCTAssertNotNil([remoteManager remoteNodeForReferenceNode:referenceNode2], @"Cannot retreive remote referant node at path %@", [filePath stringByAppendingString:components2]);

    XCTAssertNotEqual([remoteManager remoteNodeForReferenceNode:referenceNode1], [remoteManager remoteNodeForReferenceNode:referenceNode2], @"remote manager returns the same referent node for different reference paths");
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
