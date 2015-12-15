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
#import <TWTValidation/TWTValidationErrors.h>


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


- (BOOL)loadSchemaForReferencePath:(NSString *)referencePath filePath:(NSString **)outFilePath pathComponents:(NSArray **)outPathComponents error:(NSError **)outError;
{
    // Some references require validation against the schema rules; redirect these to the file's location in this bundle
    if ([referencePath isEqualToString:TWTJSONSchemaKeywordDraft4Path]) {
        referencePath = [[NSBundle bundleForClass:[self class]] pathForResource:kTWTJSONSchemaDraftFileInBundle ofType:@"json"];
    }

    // Break the full path into the file path and components
    NSUInteger subschemaLocation = [referencePath rangeOfString:@"#"].location;
    NSString *filePath;
    NSArray *components;
    if (subschemaLocation == NSNotFound) {
        filePath = referencePath;
    } else {
        filePath = [referencePath substringToIndex:subschemaLocation];
        NSString *componentString = [referencePath substringFromIndex:subschemaLocation];
        components = [componentString componentsSeparatedByString:@"/"];
    }

    // If the file has not already been loaded, attempt to load it
    if (!self.filePathsToJSONSchemaTopLevelNodes[filePath] && ![self fetchFileAtPath:filePath error:outError]) {
        return NO;
    }

    // The file has been loaded, set the return values and return
    // Either set both return values or neither, since nil values have meaning (a nil file path indicates that the reference is local to the schema)
    if (outFilePath && outPathComponents) {
        *outFilePath = filePath;
        *outPathComponents = components;
    }

    return YES;
}


- (BOOL)fetchFileAtPath:(NSString *)filePath error:(NSError **)outError
{
    NSError *error;
    NSData *data = [NSData dataWithContentsOfFile:filePath options:0 error:&error];

    if (!data) {
        if (outError) {
            *outError = [NSError errorWithDomain:TWTJSONSchemaParserErrorDomain
                                            code:TWTJSONRemoteSchemaManagerErrorCodeLoadFileFailure
                                        userInfo:@{ NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"A data object could not be created from the file with path %@", nil), filePath],
                                                    NSUnderlyingErrorKey : error }];
            // Note: Foundation documentation guarantees that error will be returned from dataWithContentsOfFile:options:error:
        }

        return NO;
    }

    NSDictionary *remoteSchema = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (!remoteSchema) {
        if (outError) {
            *outError = [NSError errorWithDomain:TWTJSONSchemaParserErrorDomain
                                            code:TWTJSONRemoteSchemaManagerErrorCodeJSONSerializationError
                                        userInfo:@{ NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"An error occurred serializing the data with file path %@", nil), filePath],
                                                    NSUnderlyingErrorKey : error }];
            // Note: Foundation documentation guarantees that error will be returned from JSONObjectWithData:options:error:
        }
        return NO;
    }

    TWTJSONSchemaParser *parser = [[TWTJSONSchemaParser alloc] initWithJSONSchema:remoteSchema];
    TWTJSONSchemaTopLevelASTNode *topLevelNode = [parser parseWithError:&error warnings:nil];
    if (!topLevelNode) {
        if (outError) {
            *outError = [NSError errorWithDomain:TWTJSONSchemaParserErrorDomain
                                            code:TWTJSONRemoteSchemaManagerErrorCodeInvalidSchemaError
                                        userInfo:@{ NSLocalizedDescriptionKey : [NSString stringWithFormat:NSLocalizedString(@"The reference file %@ does not contain a valid JSON Schema", nil), filePath],
                                                    NSUnderlyingErrorKey : error }];
            // Note: This framework guarantees that error will be returned from parseWithError:warnings:
        }
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
