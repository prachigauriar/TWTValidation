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


@interface TWTJSONRemoteSchemaManager : NSObject

- (TWTJSONSchemaASTNode *)remoteNodeForReferenceNode:(TWTJSONSchemaReferenceASTNode *)referenceNode;

- (BOOL)attemptToConfigureFilePath:(NSString *)filePath onReferenceNode:(TWTJSONSchemaReferenceASTNode *)referenceNode;

@end
