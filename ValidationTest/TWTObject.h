//
//  TWTObject.h
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/29/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TWTObject : NSObject

@property (nonatomic, strong) id thing;

- (BOOL)validateValueForKey:(NSString *)key error:(out NSError *__autoreleasing *)outError;

@end
