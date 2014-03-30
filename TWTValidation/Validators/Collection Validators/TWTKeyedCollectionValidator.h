//
//  TWTKeyedCollectionValidator.h
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/29/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import <TWTValidation/TWTValueValidator.h>
#import <TWTValidation/TWTCollectionValidator.h>

@interface TWTKeyedCollectionValidator : TWTCollectionValidator <NSCopying>

@property (nonatomic, copy, readonly) NSArray *keyValidators;
@property (nonatomic, copy, readonly) NSArray *valueValidators;
@property (nonatomic, copy, readonly) NSArray *keyValuePairValidators;

- (instancetype)initWithCountValidator:(TWTValidator *)countValidator
                         keyValidators:(NSArray *)keyValidators
                       valueValidators:(NSArray *)valueValidators
                keyValuePairValidators:(NSArray *)keyValuePairValidators;

+ (instancetype)keyedColletionValidatorWithCountValidator:(TWTValidator *)countValidator
                                            keyValidators:(NSArray *)keyValidators
                                          valueValidators:(NSArray *)valueValidators
                                   keyValuePairValidators:(NSArray *)keyValuePairValidators;


@end


@interface TWTKeyValuePairValidator : TWTValueValidator <NSCopying>

@property (nonatomic, strong, readonly) id key;
@property (nonatomic, strong, readonly) TWTValidator *valueValidator;

@end