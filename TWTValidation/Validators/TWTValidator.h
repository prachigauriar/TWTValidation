//
//  TWTValidator.h
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/27/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

@import Foundation;

@interface TWTValidator : NSObject <NSCopying>

- (BOOL)validateValue:(id)value error:(out NSError *__autoreleasing *)outError;

@end
