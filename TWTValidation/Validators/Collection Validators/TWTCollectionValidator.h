//
//  TWTCollectionValidator.h
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/29/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import <TWTValidation/TWTValidator.h>

@interface TWTCollectionValidator : TWTValidator <NSCopying>

@property (nonatomic, strong, readonly) TWTValidator *countValidator;
@property (nonatomic, copy, readonly) NSArray *elementValidators;

- (instancetype)initWithCountValidator:(TWTValidator *)countValidator elementValidators:(NSArray *)elementValidators;
+ (instancetype)collectionValidatorWithCountValidator:(TWTValidator *)countValidator elementValidators:(NSArray *)elementValidators;

@end
