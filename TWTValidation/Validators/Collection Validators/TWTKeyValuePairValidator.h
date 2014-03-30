//
//  TWTKeyValuePairValidator.h
//  TWTValidation
//
//  Created by Prachi Gauriar on 3/29/2014.
//  Copyright (c) 2014 Two Toasters, LLC. All rights reserved.
//

#import <TWTValidation/TWTValueValidator.h>

@interface TWTKeyValuePairValidator : TWTValueValidator <NSCopying>

@property (nonatomic, strong, readonly) id key;
@property (nonatomic, strong, readonly) TWTValidator *valueValidator;

- (instancetype)initWithKey:(id)key valueValidator:(TWTValidator *)valueValidator;
+ (instancetype)keyValuePairValidatorWithKey:(id)key valueValidator:(TWTValidator *)valueValidator;

@end
