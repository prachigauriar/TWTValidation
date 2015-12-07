//
//  TWTJSONRemoteSchemaManager.h
//  TWTValidation
//
//  Created by Jill Cohen on 10/19/15.
//  Copyright © 2015 Ticketmaster Entertainment, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TWTJSONSchemaASTNode;
@class TWTJSONSchemaReferenceASTNode;


/*!
 @abstract TWTJSONRemoteSchemaManagerErrorCode defines constants used as error codes by TWTJSONRemoteSchemaManager.
 */
typedef NS_ENUM(NSInteger, TWTJSONRemoteSchemaManagerErrorCode) {
    /*! Indicates a data object could not be created from the file. */
    TWTJSONRemoteSchemaManagerErrorCodeLoadFileFailure,

    /*! Indicates the file's contents could not be serialized to a JSON object. */
    TWTJSONRemoteSchemaManagerErrorCodeJSONSerializationError,

    /*! Indicates the file's contents did not represent a valid JSON object. */
    TWTJSONRemoteSchemaManagerErrorCodeInvalidSchemaError,
};


@interface TWTJSONRemoteSchemaManager : NSObject

- (TWTJSONSchemaASTNode *)remoteNodeForReferenceNode:(TWTJSONSchemaReferenceASTNode *)referenceNode;

- (BOOL)attemptToConfigureFilePath:(NSString *)filePath onReferenceNode:(TWTJSONSchemaReferenceASTNode *)referenceNode error:(NSError **)outError;

@end
