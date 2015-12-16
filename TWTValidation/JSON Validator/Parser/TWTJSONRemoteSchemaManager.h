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


NS_ASSUME_NONNULL_BEGIN

@interface TWTJSONRemoteSchemaManager : NSObject

- (TWTJSONSchemaASTNode *)remoteNodeForReferenceNode:(TWTJSONSchemaReferenceASTNode *)referenceNode;

- (BOOL)loadSchemaForReferencePath:(NSString *)referencePath filePath:(NSString *_Nullable *_Nonnull)outFilePath pathComponents:(NSArray *_Nullable *_Nonnull)outPathComponents error:(NSError *_Nullable *_Nullable)outError;

@end

NS_ASSUME_NONNULL_END
