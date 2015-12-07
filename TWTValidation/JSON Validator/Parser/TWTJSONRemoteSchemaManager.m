//
//  TWTJSONRemoteSchemaManager.m
//  TWTValidation
//
//  Created by Jill Cohen on 10/19/15.
//  Copyright © 2015 Ticketmaster Entertainment, Inc. All rights reserved.
//

#import "TWTJSONRemoteSchemaManager.h"

#import <TWTValidation/TWTJSONSchemaASTCommon.h>
#import <TWTValidation/TWTJSONSchemaParser.h>


static NSString *const kTWTJSONSchemaDraftFileInBundle = @"JSONSchemaDraft4";


@interface TWTJSONRemoteSchemaManager ()

@property (nonatomic, strong) NSMutableDictionary *filePathsToJSONSchemaTopLevelNodes;

@end


@implementation TWTJSONRemoteSchemaManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _filePathsToJSONSchemaTopLevelNodes = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (BOOL)attemptToConfigureFilePath:(NSString *)fullReferencePath onReferenceNode:(TWTJSONSchemaReferenceASTNode *)referenceNode
{
    // Some references require validation against the schema rules; redirect these to the file's location in this bundle
    if ([fullReferencePath isEqualToString:TWTJSONSchemaKeywordDraft4Path]) {
        fullReferencePath = [[NSBundle bundleForClass:[self class]] pathForResource:kTWTJSONSchemaDraftFileInBundle ofType:@"json"];
    }

    // Break the full path into the file path and components
    NSUInteger subschemaLocation = [fullReferencePath rangeOfString:@"#"].location;
    NSString *filePath;
    NSArray *components;
    if (subschemaLocation == NSNotFound) {
        filePath = fullReferencePath;
    } else {
        filePath = [fullReferencePath substringToIndex:subschemaLocation];
        NSString *componentString = [fullReferencePath substringFromIndex:subschemaLocation];
        components = [componentString componentsSeparatedByString:@"/"];
    }

    // If the file has not already been loaded, attempt to load it
    if (!self.filePathsToJSONSchemaTopLevelNodes[filePath] && ![self fetchFileAtPath:filePath]) {
        return NO;
    }

    // The file has been loaded, set the reference node properties and return
    referenceNode.filePath = filePath;
    referenceNode.referencePathComponents = components;

    return YES;
}


- (BOOL)fetchFileAtPath:(NSString *)filePath
{
    NSData *data = [NSData dataWithContentsOfFile:filePath];

    if (!data) {
        return NO;
    }

    NSDictionary *remoteSchema = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if (!remoteSchema) {
        return NO;
    }

    TWTJSONSchemaParser *parser = [[TWTJSONSchemaParser alloc] initWithJSONSchema:remoteSchema];
    TWTJSONSchemaTopLevelASTNode *topLevelNode = [parser parseWithError:nil warnings:nil];
    if (!topLevelNode) {
        return NO;
    }

    self.filePathsToJSONSchemaTopLevelNodes[filePath] = topLevelNode;
    return YES;
}


- (TWTJSONSchemaASTNode *)remoteNodeForReferenceNode:(TWTJSONSchemaReferenceASTNode *)referenceNode
{
    TWTJSONSchemaTopLevelASTNode *topLevelNode = self.filePathsToJSONSchemaTopLevelNodes[referenceNode.filePath];
    return [topLevelNode nodeForReferenceNode:referenceNode];
}

@end
