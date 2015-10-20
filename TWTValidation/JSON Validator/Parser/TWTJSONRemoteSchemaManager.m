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


- (BOOL)attemptToConfigureFilePath:(NSString *)filePath onReferenceNode:(TWTJSONSchemaReferenceASTNode *)referenceNode
{
    if (self.filePathsToJSONSchemaTopLevelNodes[filePath]) {
        return YES;
    }

    if ([filePath isEqualToString:TWTJSONSchemaKeywordDraft4Path]) {
        filePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"JSONSchemaDraft4" ofType:@"json"];
    }

    NSRange range = [filePath rangeOfString:@"#"];
    if (range.location == NSNotFound) {
        referenceNode.filePath = filePath;
        if (![self fetchFileAtPath:referenceNode.filePath]) {
            return NO;
        }

        return YES;
    }

    referenceNode.filePath = [filePath substringWithRange:NSMakeRange(0, range.location)];
    if (![self fetchFileAtPath:referenceNode.filePath]) {
        return NO;
    }

    NSString *componentString = [filePath substringWithRange:NSMakeRange(range.location, filePath.length - range.location)];
    referenceNode.referencePathComponents = [componentString componentsSeparatedByString:@"/"];
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

    [self.filePathsToJSONSchemaTopLevelNodes setObject:topLevelNode forKey:filePath];
    return YES;
}


- (TWTJSONSchemaASTNode *)remoteNodeForReferenceNode:(TWTJSONSchemaReferenceASTNode *)referenceNode
{
    TWTJSONSchemaTopLevelASTNode *topLevelNode = self.filePathsToJSONSchemaTopLevelNodes[referenceNode.filePath];
    return [topLevelNode nodeForReferenceNode:referenceNode];
}

@end
