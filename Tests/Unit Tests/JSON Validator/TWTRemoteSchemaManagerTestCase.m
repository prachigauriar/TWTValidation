//
//  TWTRemoteSchemaManagerTestCase.m
//  TWTValidation
//
//  Created by Jill Cohen on 10/19/15.
//  Copyright © 2015 Ticketmaster Entertainment, Inc. All rights reserved.
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

#import <TWTValidation/TWTJSONRemoteSchemaManager.h>
#import <TWTValidation/TWTJSONSchemaReferenceASTNode.h>

#import "TWTJSONSchemaTestDirectories.h"


@interface TWTRemoteSchemaManagerTestCase : TWTRandomizedTestCase

@end


@implementation TWTRemoteSchemaManagerTestCase

- (void)testFilePathToSchema
{
    NSString *integerFilePath = [TWTPathForJSONSchemaTestSuite() stringByAppendingString:@"/remotes/integer.json"];
    TWTJSONRemoteSchemaManager *remoteManager = [[TWTJSONRemoteSchemaManager alloc] init];
    NSString *filePath;
    NSArray *pathComponents;

    BOOL success = [remoteManager loadSchemaForReferencePath:integerFilePath filePath:&filePath pathComponents:&pathComponents error:nil];
    XCTAssertTrue(success, @"Valid file path was not successful");

    TWTJSONSchemaReferenceASTNode *referenceNode = [[TWTJSONSchemaReferenceASTNode alloc] init];
    referenceNode.filePath = filePath;
    referenceNode.referencePathComponents = pathComponents;

    XCTAssertEqualObjects(integerFilePath, referenceNode.filePath, @"file path not configured correctly");
    XCTAssertNil(referenceNode.referencePathComponents, @"path componenets set when non-existent");

    XCTAssertNotNil([remoteManager remoteNodeForReferenceNode:referenceNode], @"Cannot retreive remote referant node at path %@", integerFilePath);
}


- (void)testFilePathToSubschema
{
    NSArray *expectedComponents = @[ @"#", @"properties", @"id" ];
    NSString *subschemasFilePath = [TWTPathForCustomJSONSchemaTests() stringByAppendingString:@"/remotes/objectID.json"];
    NSString *filePathWithComponents = [subschemasFilePath stringByAppendingString:[expectedComponents componentsJoinedByString:@"/"]];
    TWTJSONRemoteSchemaManager *remoteManager = [[TWTJSONRemoteSchemaManager alloc] init];
    NSString *filePath;
    NSArray *pathComponents;

    BOOL success = [remoteManager loadSchemaForReferencePath:filePathWithComponents filePath:&filePath pathComponents:&pathComponents error:nil];
    XCTAssertTrue(success, @"Valid file path was not successful");

    TWTJSONSchemaReferenceASTNode *referenceNode = [[TWTJSONSchemaReferenceASTNode alloc] init];
    referenceNode.filePath = filePath;
    referenceNode.referencePathComponents = pathComponents;

    XCTAssertEqualObjects(subschemasFilePath, referenceNode.filePath, @"file path not configured correctly");
    XCTAssertEqualObjects(expectedComponents, referenceNode.referencePathComponents, @"path componenets not configured correctly");

    XCTAssertNotNil([remoteManager remoteNodeForReferenceNode:referenceNode], @"Cannot retreive remote referant node at path %@", filePathWithComponents);

}


- (void)testDraft4File
{
    TWTJSONRemoteSchemaManager *remoteManager = [[TWTJSONRemoteSchemaManager alloc] init];
    NSString *filePath;
    NSArray *pathComponents;

    BOOL success = [remoteManager loadSchemaForReferencePath:TWTJSONSchemaKeywordDraft4Path filePath:&filePath pathComponents:&pathComponents error:nil];
    XCTAssertTrue(success, @"JSON draft 4 file path was not successful");

    TWTJSONSchemaReferenceASTNode *referenceNode = [[TWTJSONSchemaReferenceASTNode alloc] init];
    referenceNode.filePath = filePath;
    referenceNode.referencePathComponents = pathComponents;

    XCTAssertNotNil([remoteManager remoteNodeForReferenceNode:referenceNode], @"Cannot retreive remote referant node at path %@", TWTJSONSchemaKeywordDraft4Path);
}


- (void)testMutlipleFileReferences
{
    NSString *baseFilePath = [TWTPathForCustomJSONSchemaTests() stringByAppendingString:@"/remotes/objectID.json"];
    NSString *components1 = @"#";
    NSString *components2 = @"#/properties/id";
    TWTJSONRemoteSchemaManager *remoteManager = [[TWTJSONRemoteSchemaManager alloc] init];
    NSString *filePath;
    NSArray *pathComponents;

    BOOL success = [remoteManager loadSchemaForReferencePath:[baseFilePath stringByAppendingString:components1] filePath:&filePath pathComponents:&pathComponents error:nil];
    XCTAssertTrue(success, @"Valid file path was not successful");

    TWTJSONSchemaReferenceASTNode *referenceNode1 = [[TWTJSONSchemaReferenceASTNode alloc] init];
    referenceNode1.filePath = filePath;
    referenceNode1.referencePathComponents = pathComponents;

    XCTAssertEqualObjects(filePath, referenceNode1.filePath, @"file path not configured correctly");
    XCTAssertEqualObjects(referenceNode1.referencePathComponents, @[components1], @"path componenets not set correctly");

    success = [remoteManager loadSchemaForReferencePath:[baseFilePath stringByAppendingString:components2] filePath:&filePath pathComponents:&pathComponents error:nil];
    XCTAssertTrue(success, @"File path that was previously loaded was not successful");

    TWTJSONSchemaReferenceASTNode *referenceNode2 = [[TWTJSONSchemaReferenceASTNode alloc] init];
    referenceNode2.filePath = filePath;
    referenceNode2.referencePathComponents = pathComponents;

    XCTAssertEqualObjects(baseFilePath, referenceNode2.filePath, @"File path that was previously loaded not configured correctly");
    XCTAssertEqualObjects(referenceNode2.referencePathComponents, [components2 componentsSeparatedByString:@"/"], @"Path componenets for file path that was previously loaded not set correctly");

    XCTAssertNotNil([remoteManager remoteNodeForReferenceNode:referenceNode2], @"Cannot retreive remote referant node at path %@", [baseFilePath stringByAppendingString:components2]);

    XCTAssertNotEqual([remoteManager remoteNodeForReferenceNode:referenceNode1], [remoteManager remoteNodeForReferenceNode:referenceNode2], @"remote manager returns the same referent node for different reference paths");
}


- (void)testFailureCase
{
    NSString *invalidPath = UMKRandomAlphanumericString();

    TWTJSONRemoteSchemaManager *remoteManager = [[TWTJSONRemoteSchemaManager alloc] init];
    BOOL success = YES;
    NSString *filePath;
    NSArray *pathComponents;
    NSError *error;

    success = [remoteManager loadSchemaForReferencePath:invalidPath filePath:&filePath pathComponents:&pathComponents error:&error];
    XCTAssertFalse(success, @"Invalid file path was successful");
    XCTAssertNotNil(error, @"Error was not set for invalid file");
    XCTAssertEqual(error.code, TWTJSONRemoteSchemaManagerErrorCodeLoadFileFailure, @"Error was not coded correctly for invalid file");
    XCTAssertNil(filePath, @"outFilePath is non-nil for failing file");
    XCTAssertNil(pathComponents, @"outPathComponents is non-nil for failing file");
}


- (void)testNilOutParameters
{
    TWTJSONRemoteSchemaManager *remoteManager = [[TWTJSONRemoteSchemaManager alloc] init];
    NSString *invalidPath = UMKRandomAlphanumericString();
    NSString *filePath;
    NSArray *pathComponents;

    XCTAssertNoThrow([remoteManager loadSchemaForReferencePath:invalidPath filePath:&filePath pathComponents:&pathComponents error:nil]);

    NSString *validPath = [TWTPathForJSONSchemaTestSuite() stringByAppendingString:@"/remotes/integer.json"];
    XCTAssertNoThrow([remoteManager loadSchemaForReferencePath:validPath filePath:&filePath pathComponents:&pathComponents error:nil]);

    remoteManager = [[TWTJSONRemoteSchemaManager alloc] init];
    XCTAssertNoThrow([remoteManager loadSchemaForReferencePath:validPath filePath:&filePath pathComponents:&pathComponents error:nil]);

    XCTAssertNil(filePath, @"File path was set without corresponding components");
}

@end
