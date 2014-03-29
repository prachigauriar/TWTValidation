//
//  TWTBlockValidator.h
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/28/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import <TWTValidation/TWTValidator.h>

typedef BOOL (^TWTValidationBlock)(id object, NSError *__autoreleasing *outError);

@interface TWTBlockValidator : TWTValidator

@property (nonatomic, copy, readonly) TWTValidationBlock block;

+ (instancetype)blockValidatorWithBlock:(TWTValidationBlock)block;

@end
