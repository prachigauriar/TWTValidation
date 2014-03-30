//
//  TWTValidatingObject.h
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/29/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

@import Foundation;

@interface TWTValidatingObject : NSObject

+ (NSSet *)validatorsForKey:(NSString *)key;
- (BOOL)validateValueForKey:(NSString *)key error:(out NSError *__autoreleasing *)outError;

@end
